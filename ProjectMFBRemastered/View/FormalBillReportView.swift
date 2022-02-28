//
//  FormalBillReportView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-26.
//

import SwiftUI

struct FormalBillReportView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BillReport.timestamp, ascending: false)],
        animation: .default)
    private var fetchedBillReport: FetchedResults<BillReport>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Bill.openTimestamp, ascending: false)],
        predicate: NSCompoundPredicate(type: .and, subpredicates: [NSPredicate(format: "parent = nil"), NSPredicate(format: "report = nil")]),
        animation: .default)
    private var fetchedBill: FetchedResults<Bill>
    
    var reports: [BillReport] {
        fetchedBillReport.sorted().reversed()
    }
    
    var bills: [Bill] {
        fetchedBill.sorted()
    }
    
    var controller: ReportController {
        return ReportController(viewContext)
    }
    
    @State var showBillSelectionView = false
    @State var selection = Set<Bill>()
    @State var showEmptySelctionAlert = false
    
    var body: some View {
        Group {
            if reports.isEmpty {
                Text("No Report")
                    .foregroundColor(.gray)
            }
            List(reports) { report in
                NavigationLink {
                    TESEReportView(report: report)
                } label: {
                    HStack {
                        VStack {
                            HStack {
                                Image(systemName: "forward.fill")
                                    .foregroundColor(.gray)
                                if let timestamp = report.from {
                                    Text(timestamp.toStringRepresentation)
                                }
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "backward.fill")
                                    .foregroundColor(.gray)
                                if let timestamp = report.to {
                                    Text(timestamp.toStringRepresentation)
                                }
                                Spacer()
                            }
                        }
                        Spacer()
                        Text("\(report.bills?.count ?? 0) Bills")
                            .foregroundColor(.green)
                    }
                }
                .contextMenu {
                    Button(role: .destructive) {
                        controller.removeReport(report)
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Remove")
                        }
                    }

                }
            }
            .navigationTitle("Formal Reports")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("New", isActive: $showBillSelectionView) {
                        generator
                    }
                }
        }
        }
    }
    
    var generator: some View {
        Group {
            if bills.isEmpty {
                VStack {
                    Text("Nothing to report.")
                        .foregroundColor(.gray)
                    Spacer()
                }
            } else {
                BillReportListView(majorCurrency: appData.majorCurrency, bills: bills, selection: $selection)
            }
        }
        .navigationTitle("Report")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if selection.isEmpty {
                        return
                    }
                    controller.makeReport(selection)
                    showBillSelectionView = false
                } label: {
                    Image(systemName: "arrowtriangle.forward.circle")
                }
            }
        }
        .alert("You must select at least one bill.", isPresented: $showEmptySelctionAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}
