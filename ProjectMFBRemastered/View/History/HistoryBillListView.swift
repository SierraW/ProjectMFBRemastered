//
//  TransactionListView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-30.
//

import SwiftUI

struct HistoryBillListView: View {
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
        if !searchString.isEmpty {
            return fetchedBill.filter { bill in
                bill.tag?.name?.contains(searchString) ?? false || bill.associatedTag?.name?.contains(searchString) ?? false || bill.openTimestamp?.dateStringRepresentation.contains(searchString) ?? false
            }
        }
        return fetchedBill
    }
    
    var groups: [String: [Bill]] {
        let now = Date()
        return Dictionary(grouping: bills, by: {$0.openTimestamp?.listGroupRepresentation(now: now) ?? "Error Bills"})
    }
    
    @State var searchString = ""
    @State var selection: BillData? = nil
    
    var body: some View {
        VStack {
            SearchBar(text: $searchString) {

            }
            billsSection
        }
        .sheet(item: $selection, content: { billData in
            HistoryBillPreview()
                .environmentObject(appData)
                .environmentObject(billData)
        })
        .navigationBarTitle("Histroies")
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    var billsSection: some View {
        Form {
            ForEach(groups.keys.sorted().reversed(), id:\.self) { groupName in
                Section {
                    if let groupBills = groups[groupName] {
                        ForEach(groupBills) { bill in
                            if let proceedBalance = bill.proceedBalance as Decimal? {
                                BillListViewCell(bill: bill, total: proceedBalance, resultMode: true)
                                    .environmentObject(appData)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selection = BillData(context: viewContext, bill: bill)
                                    }
                                    .contextMenu {
                                        Text("You cannot delete a sumitted bill.")
                                    }
                            } else {
                                NavigationLink {
                                    BillViewV2() {
                                        
                                    }
                                    .environment(\.managedObjectContext, viewContext)
                                    .environmentObject(appData)
                                    .environmentObject(BillData(context: viewContext, bill: bill))
                                    .environmentObject(PayableRatedPayableSelectionController(viewContext))
                                } label: {
                                    BillListViewCell(bill: bill, resultMode: true)
                                        .environmentObject(appData)
                                }
                                .contextMenu(menuItems: {
                                    Button(role: .destructive) {
                                        let controller = ModelController(viewContext)
                                        controller.delete(bill)
                                    } label: {
                                        Text("Delete")
                                    }
                                })
                            }
                        }
                    }
                } header: {
                    Text(groupName)
                }
            }
        }
    }
}

struct TransactionListView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryBillListView()
    }
}
