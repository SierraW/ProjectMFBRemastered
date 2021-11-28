//
//  BillDataSPAExtension.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-27.
//

import Foundation

extension BillData {
    func splitByAmountSubmit(splitCount: Int) {
        let totalAmountPerBill = (total / Decimal(splitCount)).rounded(toPlaces: 2)
        if totalAmountPerBill <= 0 {
            return
        }
        var discountableAmountPerBill = discountableSubtotal - discount
        discountableAmountPerBill = (discountableAmountPerBill / Decimal(splitCount)).rounded(toPlaces: 2)
        if discountableAmountPerBill < 0 {
            discountableAmountPerBill = 0
        }
        let nsDecimalTotal = NSDecimalNumber(decimal: totalAmountPerBill)
        let nsDecimalDiscountableTotal = NSDecimalNumber(decimal: discountableAmountPerBill)
        
        for _ in 0..<splitCount {
            let bill = controller.createChildBill()
            let billTotal = controller.createBillTotal(for: bill)
            bill.originalBalance = nsDecimalTotal
            billTotal.total = nsDecimalTotal
            billTotal.discountableTotal = nsDecimalDiscountableTotal
        }
        
        self.controller.managedSave()
        
        if let children = self.controller.bill.children?.allObjects as? [Bill] {
            self.children = children
        }
    }
    
    func splitByAmountResign() {
        if let childrenSet = self.controller.bill.children {
            self.controller.bill.removeFromChildren(childrenSet)
        }
        self.children = []
    }
    
    func splitByAmountUngroup(bill: Bill) {
        if let children = bill.children?.allObjects as? [Bill] {
            for child in children {
                controller.bill.addToChildren(child)
            }
            controller.delete(bill)
            reloadChildren()
        }
    }
    
    func splitByAmountUndoPayments(bill: Bill) {
        if let payments = bill.payments {
            bill.removeFromPayments(payments)
        }
        bill.proceedBalance = nil
        
        controller.managedSave()
        
        reloadPayments()
        proceedBalance = nil
    }
}
