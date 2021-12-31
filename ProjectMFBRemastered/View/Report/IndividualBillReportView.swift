//
//  IndividualBillReportView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-26.
//

import SwiftUI

struct IndividualBillReportView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Bill.openTimestamp, ascending: false)],
        predicate: NSPredicate(format: "parent = nil"),
        animation: .default)
    private var fetchedBill: FetchedResults<Bill>
    
    var bills: [Bill] {
        fetchedBill.map({$0})
    }
    
    @State var selection = Set<Bill>()
    @State var showReportView = false
    
    var body: some View {
        BillReportListView(majorCurrency: appData.majorCurrency, bills: bills, selection: $selection)
            .sheet(isPresented: $showReportView, content: {
                ReportView(bills: selection.sorted(by: { $0.openTimestamp ?? Date() < $1.openTimestamp ?? Date() }))
            })
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
