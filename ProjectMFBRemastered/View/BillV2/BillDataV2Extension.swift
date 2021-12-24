//
//  BillDataV2Extension.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-24.
//

import Foundation

extension BillData {
    func addItems(with billItems: [BillItem: Int]) {
        for key in billItems.keys.sorted() {
            if let count = billItems[key], count > 0, count <= Int(key.count) {
                let item = controller.createBillItem(from: key, to: bill)
                item.is_add_on = false
                item.count = Int32(count)
                if let value = item.value as Decimal? {
                    item.subtotal = NSDecimalNumber(decimal: value * Decimal(count))
                }
            }
        }
        self.reloadItems()
        self.calculateRatedSubtotals()
        self.controller.bill.isSubmitted = true
        self.isSubmitted = true
        self.controller.managedSave()
    }
    
    func removeItems(items: [BillItem: Int]) {
        for key in items.keys.sorted() {
            if let count = items[key] {
                removeItem(key, count: count)
            }
        }
    }
    
    func resignProceedBalance() {
        self.proceedBalance = nil
        self.controller.bill.proceedBalance = nil
    }
}
