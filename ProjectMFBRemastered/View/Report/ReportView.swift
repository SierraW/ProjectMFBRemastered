//
//  ReportView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-24.
//

import SwiftUI

struct ReportView: View {
    
    var bills: [Bill]
    
    var combinedIncome: [Currency: Decimal] {
        var result = [Currency: Decimal]()
        for bill in bills {
            if let transactions = bill.transactions?.allObjects as? [Transaction] {
                for transaction in transactions {
                    if let currency = transaction.currency, let amount = transaction.amount as Decimal? {
                        result[currency] = (result[currency] ?? 0) + amount
                    }
                }
            }
        }
        return result
    }
    
    var allPayable: [Payable: Int] {
        func retrievePayable(from bill: Bill, payableAmountDict: inout [Payable: Int]) {
            if let items = bill.items?.allObjects as? [BillItem] {
                for item in items {
                    if let payable = item.payable {
                        payableAmountDict[payable] = (payableAmountDict[payable] ?? 0) + Int(item.count)
                    }
                }
            }
            
            if let children = bill.children?.allObjects as? [Bill] {
                for child in children {
                    retrievePayable(from: child, payableAmountDict: &payableAmountDict)
                }
            }
        }
        
        var result = [Payable: Int]()
        for bill in bills {
            retrievePayable(from: bill, payableAmountDict: &result)
        }
        return result
    }
    
    var body: some View {
        VStack {
            Text("Report")
                .bold()
                .font(.largeTitle)
                .padding(.top)
            Form {
                Section {
                    HStack {
                        Text("From")
                        Spacer()
                        if let bill = bills.first, let openDate = bill.openTimestamp {
                            Text(openDate.toStringRepresentation)
                        }
                    }
                    HStack {
                        Text("To")
                        Spacer()
                        if let bill = bills.last, let openDate = bill.openTimestamp {
                            Text(openDate.toStringRepresentation)
                        }
                    }
                    HStack {
                        Text("Number of Bills")
                        Spacer()
                        Text("\(bills.count)")
                    }
                }
                Section {
                    ForEach(combinedIncome.keys.sorted()) { key in
                        HStack {
                            Text(key.name ?? "err")
                            Spacer()
                            Text("\(key.toStringRepresentation) \(combinedIncome[key]?.toStringRepresentation ?? "err")")
                        }
                    }
                } header: {
                    Text("Combined Income")
                }
                Section {
                    ForEach(allPayable.keys.sorted(by: { allPayable[$0] ?? 0 > allPayable[$1] ?? 0 })) { payable in
                        HStack {
                            Text(payable.toStringRepresentation)
                            Spacer()
                            Text("\(allPayable[payable] ?? 0)")
                        }
                    }
                } header: {
                    Text("Best-sells products")
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}
