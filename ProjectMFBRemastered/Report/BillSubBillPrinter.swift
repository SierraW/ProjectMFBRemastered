//
//  BillSubBillPrinter.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-25.
//

import Foundation

struct BillSubBillPrinter: BillReportPrinter {
    func extract(from bill: Bill) -> String {
        var stringResult = ""
        stringResult.append(billItemsSection(name: "Original Bill", billItems: bill.items?.allObjects as? [BillItem] ?? []))
        if let children = bill.children?.allObjects as? [Bill] {
            children.forEach({stringResult.append(billItemsSection(name: "=>", billItems: $0.items?.allObjects as? [BillItem] ?? []))})
        }
        return stringResult
    }
    
    func billItemsSection(name: String, billItems: [BillItem]) -> String {
        if billItems.isEmpty {
            return ""
        }
        var stringResult = "\t\(name)\n"
        billItems.forEach({stringResult.append("\t\t\($0.toStringRepresentation) x\($0.count) sub:\(($0.subtotal as Decimal?)?.toStringRepresentation ?? "0.00")\n")})
        return stringResult
    }
}
