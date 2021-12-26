//
//  ReportPreparationView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-24.
//

import SwiftUI

struct ReportPreparationView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Bill.openTimestamp, ascending: false)],
        predicate: NSPredicate(format: "parent = nil"),
        animation: .default)
    private var fetchedBill: FetchedResults<Bill>
    
    var bills: [Bill] {
        let fetchedBill = fetchedBill.filter { bill in
            bill.tag != nil
        }
        return fetchedBill
    }
    
    @State var selection = Set<Bill>()
    @State var editMode: EditMode = .active
    @State var showReportView = false
    
    var body: some View {
        VStack {
            List(bills, id: \.self, selection: $selection) { bill in
                HStack {
                    Text(bill.associatedTag?.toStringRepresentation ?? bill.tag?.toStringRepresentation ?? "NODATA")
                    if let timestamp = bill.openTimestamp {
                        Text(timestamp.toStringRepresentation)
                    }
                    Spacer()
                    if let pb = bill.proceedBalance as Decimal? {
                        Text(bill.majorCurrencyString ?? appData.majorCurrency.toStringRepresentation)
                        Text(pb.toStringRepresentation)
                    }
                }
            }
            .environment(\.editMode, .constant(EditMode.active))
        }
        .sheet(isPresented: $showReportView, content: {
            ReportView(bills: selection.sorted(by: { $0.openTimestamp ?? Date() < $1.openTimestamp ?? Date() }))
        })
        .navigationTitle("[TEST] Make Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showReportView.toggle()
                } label: {
                    Text("Generate")
                }
                .disabled(selection.isEmpty)
            }
        }
    }
}
