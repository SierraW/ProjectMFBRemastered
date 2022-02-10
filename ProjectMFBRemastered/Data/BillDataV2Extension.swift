//
//  BillDataV2Extension.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-24.
//

import Foundation

/// Extension for BillViewV2
extension BillData {
    
    /// Create a new sub-bill with the selecting BillItems, save after the creation is complete.
    /// - Parameters:
    ///   - billItems: items that should be added to the new sub-bill.
    ///   - isAddOn: items should be added as an add-on item (add-ons can be edit in Bill Review phase).
    func addItems(with billItems: [BillItem: Int], isAddOn: Bool = false) {
        for key in billItems.keys.sorted() {
            if let count = billItems[key], count > 0, count <= Int(key.count) {
                let item = controller.createBillItem(from: key, to: bill)
                item.is_add_on = isAddOn
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
    
    
    /// Remove the selected items from the current bill. Usually call after selected items was added to a new sub-bill.
    /// - Parameter items: selected bill items.
    func removeItems(items: [BillItem: Int]) {
        for key in items.keys.sorted() {
            if let count = items[key] {
                removeItem(key, count: count)
            }
        }
    }
    
    
    /// Resign the Proceed Balance of the current bill. An assigned Proceed Balance means the current bill is fully paid and completed.
    /// Usually call if a new item is add to a paid bill.
    func resignProceedBalance() {
        self.proceedBalance = nil
        self.controller.bill.proceedBalance = nil
    }
    
    
    /// Remove selected sub-bill, saved.
    /// - Parameter bill: Sub-bill for delete.
    func removeSubBill(_ bill: Bill) {
        controller.delete(bill)
        reloadChildren()
    }
}
