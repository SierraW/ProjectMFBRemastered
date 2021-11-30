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
        ZStack {
            content
            VStack {
                Spacer()
                Button {
                    //
                } label: {
                    SubmitButtonView(title: "Delete", foregroundColor: .white, backgroundColor: .red)
                }
            }
            .padding(.bottom)
        }
        
    }
    
    var content: some View {
        List {
            Section {
                BillListViewCell(bill: data.controller.bill)
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
                            
                        }
                    }
                } label: {
                    Text("Generated Transactions")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
