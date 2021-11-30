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
        sortDescriptors: [NSSortDescriptor(keyPath: \Bill.openTimestamp, ascending: true)],
        predicate: NSPredicate(format: "parent = nil"),
        animation: .default)
    private var fetchedBill: FetchedResults<Bill>
    
    var bills: [Bill] {
        let fetchedBill = fetchedBill.filter { bill in
//            bill.tag != nil
            true
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
//        .onAppear(perform: {
//            for bill in fetchedBill {
//                viewContext.delete(bill)
//                do {
//                    try viewContext.save()
//                } catch {
//                    print("err")
//                }
//            }
//        })
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
            ForEach(groups.keys.sorted(), id:\.self) { groupName in
                Section {
                    if let groupBills = groups[groupName] {
                        ForEach(groupBills) { bill in
                            if bill.proceedBalance != nil {
                                BillListViewCell(bill: bill, resultMode: true)
                                    .environmentObject(appData)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selection = BillData(context: viewContext, bill: bill)
                                    }
                            } else {
                                NavigationLink {
                                    BillView(data: BillData(context: viewContext, bill: bill)) {
                                        
                                    }
                                    .environmentObject(appData)
                                } label: {
                                    BillListViewCell(bill: bill, resultMode: true)
                                        .environmentObject(appData)
                                }
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