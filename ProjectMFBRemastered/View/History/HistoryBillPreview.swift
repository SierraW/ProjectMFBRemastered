//
//  HistoryBillPreview.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-30.
//

import SwiftUI

struct HistoryBillPreview: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var data: BillData
    
    var bill: Bill {
        data.controller.bill
    }
    
    var proceedBalance: [Currency: Decimal] {
        var dict = [Currency: Decimal]()
        for payment in data.allPayments {
            if let currency = payment.currency, let amount = payment.amount as Decimal? {
                dict[currency] = (dict[currency] ?? 0) + amount
            }
        }
        return dict
    }
    
    var body: some View {
        VStack {
            Text("\(bill.name) 🕓\(bill.openTimestamp?.toStringRepresentation ?? "")")
                .padding(.top)
            content
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    var content: some View {
        List {
            Section {
                HStack {
                    Text("From")
                    Spacer()
                    Text(bill.openTimestamp?.toStringRepresentation ?? "NO DATA")
                }
                HStack {
                    Text("To")
                    Spacer()
                    Text(bill.closeTimestamp?.toStringRepresentation ?? "NO DATA")
                }
                
            }
            Section {
                BillListViewCell(bill: data.controller.bill, total: data.total)
                    .environmentObject(appData)
            } header: {
                Text("Original Bill")
            }
            
            Section {
                ForEach(data.children) { bill in
                    BillListViewCell(bill: bill)
                        .environmentObject(appData)
                }
            } header: {
                Text("All Sub-Bills")
            }
            
            Section {
                ForEach(data.allPayments) { payment in
                    PaymentViewCell(billPayment: payment)
                }
            } header: {
                Text("All Payments")
            }
            
            Section {
                ForEach(proceedBalance.keys.sorted()) { key in
                    HStack {
                        Text(key.name ?? "Err Name")
                        Spacer()
                        Text(key.toStringRepresentation)
                        if let amount = proceedBalance[key] {
                            Text(amount.toStringRepresentation)
                        }
                    }
                }
                HStack {
                    Text("Final Balance")
                    Spacer()
                    Text("Equiv.")
                        .bold()
                    Text(appData.majorCurrency.toStringRepresentation)
                        .bold()
                    if let proceedBalance = data.proceedBalance {
                        Text(proceedBalance.toStringRepresentation)
                            .bold()
                    }
                }
            } header: {
                Text("Proceed Balance")
            }
            
            Section {
                DisclosureGroup {
                    if let transactions = data.controller.bill.transactions?.allObjects as? [Transaction] {
                        ForEach(transactions) { transaction in
                            TransactionListViewCell(transaction: transaction)
                                .environmentObject(appData)
                        }
                    }
                } label: {
                    Text("Generated Transactions")
                        .foregroundColor(.gray)
                }
            }
            
            Section {
                DisclosureGroup {
                    TextEditor(text: $data.additionalDescription)
                    Button("Save") {
                        data.controller.managedSave()
                    }
                } label: {
                    Text("Message")
                        .foregroundColor(.gray)
                }

            }
        }
    }
}
