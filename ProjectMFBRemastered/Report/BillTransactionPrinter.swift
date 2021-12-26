//
//  BillTransactionPrinter.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-25.
//

import Foundation

struct BillTransactionPrinter: BillReportPrinter {
    func extract(from bill: Bill) -> String {
        let data = BillData(context: PersistenceController.shared.container.viewContext, bill: bill)
        
        var proceedBalance: [Currency: Decimal] {
            var dict = [Currency: Decimal]()
            for payment in data.allPayments {
                if let currency = payment.currency, let amount = payment.amount as Decimal? {
                    dict[currency] = (dict[currency] ?? 0) + amount
                }
            }
            return dict
        }
        var stringResult = ""
        
        stringResult.append(allTransactionSection(bill.transactions?.allObjects as? [Transaction] ?? []))
        
        stringResult.append("\tSummary\n")
        for key in proceedBalance.keys.sorted() {
            stringResult.append("\t\t\(key.toStringRepresentation) \(proceedBalance[key] ?? 0)\n")
        }
        
        return stringResult
    }
    
    func allTransactionSection(_ transactions: [Transaction]) -> String{
        var stringResult = "\tTransactions\n"
        
        transactions.forEach({stringResult.append("\t\t\($0.paymentMethod?.toStringRepresentation ?? "PM") \($0.currency?.toStringRepresentation ?? "CU") \(($0.amount as Decimal?)?.toStringRepresentation ?? "ND")\n")})
        
        return stringResult
    }
}
