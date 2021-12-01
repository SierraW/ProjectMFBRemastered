//
//  BillController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-22.
//

import Foundation
import CoreData

class BillController: ModelController {
    var bill: Bill
    
    func createBillPayment() -> BillPayment {
        let billPayment = BillPayment(context: viewContext)
        self.bill.addToPayments(billPayment)
        return billPayment
    }
    
    func createChildBill() -> Bill {
        let bill = Bill(context: viewContext)
        self.bill.addToChildren(bill)
        bill.openTimestamp = Date()
        return bill
    }
    
    func createBillTotal(for bill: Bill) -> BillTotal {
        let billTotal = BillTotal(context: viewContext)
        billTotal.bill = bill
        return billTotal
    }
    
    init(_ bill: Bill, context: NSManagedObjectContext) {
        self.bill = bill
        super.init(context)
    }
    
    init(new tag: Tag, context: NSManagedObjectContext) {
        self.bill = Bill(context: context)
        self.bill.tag = tag
        self.bill.activeTag = tag
        self.bill.openTimestamp = Date()
        super.init(context)
    }
    
    func createBillItem(from billItem: BillItem, to bill: Bill) -> BillItem {
        let bi = BillItem(context: viewContext)
        bi.name = billItem.name
        bi.payable = billItem.payable
        bi.ratedPayable = billItem.ratedPayable
        bi.is_rated = billItem.is_rated
        bi.is_tax = billItem.is_tax
        bi.is_deposit = billItem.is_deposit
        bi.value = billItem.value
        bi.order = billItem.order
        bi.is_add_on = false
        bi.count = billItem.count
        bill.addToItems(bi)
        return bi
    }
    
    func createBillItem(_ payable: Payable, order: Int32, isAddOn: Bool) -> BillItem {
        let bi = BillItem(context: viewContext)
        bi.name = payable.toStringRepresentation
        bi.payable = payable
        bi.is_rated = false
        bi.is_tax = false
        bi.is_deposit = payable.is_deposit
        bi.value = payable.amount
        bi.order = order
        bi.is_add_on = isAddOn
        bi.count = 0
        bill.addToItems(bi)
        return bi
    }
    
    func createBillItem(_ ratedPayable: RatedPayable, order: Int32, isAddOn: Bool) -> BillItem {
        let bi = BillItem(context: viewContext)
        bi.name = ratedPayable.toStringRepresentation
        bi.ratedPayable = ratedPayable
        bi.is_rated = true
        bi.is_tax = ratedPayable.is_tax
        bi.is_deposit = ratedPayable.is_deposit
        bi.value = ratedPayable.rate
        bi.order = order
        bi.is_add_on = isAddOn
        bi.count = 1
        bill.addToItems(bi)
        return bi
    }
    
    func submitOriginalBalance(_ balance: Decimal) {
        bill.originalBalance = NSDecimalNumber(decimal: balance)
        managedSave()
    }
    
    func resignOriginalBill(proceedPayments: [BillPayment], addOns: [BillItem]) {
        for payment in proceedPayments {
            delete(payment)
        }
        for addOn in addOns {
            delete(addOn)
        }
        bill.originalBalance = nil
        managedSave()
    }
    
    
    func submit(majorCurrency: Currency) {
        self.bill.majorCurrenctString = majorCurrency.toStringRepresentation
    }
}

