//
//  BillDataSPAExtension.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-27.
//

import Foundation


/// Split By Amount (SBA) section extensions.
extension BillData {
    
    
    /// Split the original bill by given number of bills.
    /// - Parameter splitCount: Number of sub-bills should generate. Will save on complete.
    func splitByAmountSubmit(splitCount: Int) {
        var total: Decimal = 0
        var discountableTotal: Decimal = 0
        var ratedItems = [BillItem]()
        for item in items {
            if item.is_rated {
                ratedItems.append(item)
            } else if let subtotal = item.subtotal as Decimal? {
                if item.is_deposit {
                    discountableTotal -= subtotal
                } else if item.payable?.discountable ?? false {
                    discountableTotal += subtotal
                } else {
                    total += subtotal
                }
            }
        }
        
        if discountableTotal < 0 {
            discountableTotal = 0
        }
        
        total += discountableTotal
        
        let totalAmountPerBill = (total / Decimal(splitCount)).rounded(toPlaces: 2)
        if totalAmountPerBill <= 0 {
            return
        }
        var discountableAmountPerBill = (discountableTotal / Decimal(splitCount)).rounded(toPlaces: 2)
        if discountableAmountPerBill < 0 {
            discountableAmountPerBill = 0
        }
        
        let nsDecimalTotal = NSDecimalNumber(decimal: totalAmountPerBill)
        let nsDecimalDiscountableTotal = NSDecimalNumber(decimal: discountableAmountPerBill)
        
        // duplicate rated items to each bill.
        for _ in 0..<splitCount {
            let bill = controller.createChildBill()
            let billTotal = controller.createBillTotal(for: bill)
            billTotal.total = nsDecimalTotal
            billTotal.discountableTotal = nsDecimalDiscountableTotal
            for item in ratedItems.sorted(by: { lhs, rhs in
                BillItem.calculationOrderComparator(lhs: lhs, rhs: rhs)
            }) {
                if let amount = item.subtotal as Decimal? {
                    let billItem = controller.createBillItem(from: item, to: bill)
                    let subtotal = amount / Decimal(splitCount)
                    billItem.subtotal = NSDecimalNumber(decimal: subtotal.rounded(toPlaces: 2))
                }
            }
            bill.isSubmitted = true
        }
        
        self.controller.managedSave()
        
        if let children = self.controller.bill.children?.allObjects as? [Bill] {
            self.children = children
        }
    }
    
    /// Discard splited (SBA) bill, remove all sub-bills.
    func splitByAmountResign() {
        if let children = self.controller.bill.children?.allObjects as? [Bill] {
            for child in children {
                controller.delete(child)
            }
        }
        self.children = []
    }
    
    /// Remove sub-bill grouping.
    func splitByAmountUngroup(bill: Bill) {
        if let children = bill.children?.allObjects as? [Bill] {
            for child in children {
                controller.bill.addToChildren(child)
            }
            controller.delete(bill)
            reloadChildren()
        }
    }
    
    /// Undo the completed payment on a sub-bill.
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
