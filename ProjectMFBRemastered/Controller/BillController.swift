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
    
    
    /// Fetch bills from the database, ordered by open timestamp deascending.
    /// - Parameters:
    ///   - context: Managed Object Context.
    ///   - unreportedOnly: Fetch unreported bills only. (Unreported is a discountinue concept)
    ///   - fetchLimit: Limit the number of bills.
    /// - Returns: The result bills, will return empty array if there is nothing or an error rised.
    static func fetch(_ context: NSManagedObjectContext, unreportedOnly: Bool = false, limitTo fetchLimit: Int? = nil) -> [Bill] {
        let fetchRequest: NSFetchRequest<Bill> = Bill.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Bill.openTimestamp, ascending: false)]
        if unreportedOnly {
            fetchRequest.predicate = NSPredicate(format: "report = nil")
        }
        if let fetchLimit = fetchLimit {
            fetchRequest.fetchLimit = fetchLimit
        }
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            print("Fetch error in Bill Controller")
        }
        return []
    }
    
    /// Generate new bill payment and add to current bill.
    /// - Returns: The new bill payment generated.
    func createBillPayment() -> BillPayment {
        let billPayment = BillPayment(context: viewContext)
        self.bill.addToPayments(billPayment)
        return billPayment
    }
    
    /// Generate a sub-bill using the current bill as parent bill.
    /// - Returns: Generated sub-bill.
    func createChildBill() -> Bill {
        let bill = Bill(context: viewContext)
        self.bill.addToChildren(bill)
        bill.openTimestamp = Date()
        return bill
    }
    
    /// Generate a bill total CoreData object.
    /// - Parameter bill: A bill that the new bill total should attach to.
    /// - Returns: Generated bill total.
    func createBillTotal(for bill: Bill) -> BillTotal {
        let billTotal = BillTotal(context: viewContext)
        billTotal.bill = bill
        return billTotal
    }
    
    /// init controller as an existing bill.
    /// - Parameters:
    ///   - bill: An existing bill object.
    ///   - context: Managed Object Context.
    init(_ bill: Bill, context: NSManagedObjectContext) {
        self.bill = bill
        super.init(context)
    }
    
    /// init controller as an new bill.
    /// - Parameters:
    ///   - tag: The room tag for the new bill.
    ///   - associatedTag: The associated tag for the bill for tagging.
    ///   - size: The number of customer in the bill, this value will be use as an initial value for SBA (split by amount) function.
    ///   - context: Managed Object Context.
    init(new tag: Tag, associatedTag: Tag?, size: Int, context: NSManagedObjectContext) {
        self.bill = Bill(context: context)
        self.bill.tag = tag
        self.bill.size = Int16(size)
        self.bill.associatedTag = associatedTag
        self.bill.activeTag = tag
        self.bill.openTimestamp = Date()
        super.init(context)
    }
    
    /// Duplicate a bill item to a new bill.
    /// - Parameters:
    ///   - billItem: The original bill item.
    ///   - bill: The bill that the duplicated bill item should attach to.
    /// - Returns: Duplicated bill item.
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
        bi.is_add_on = true
        bi.count = billItem.count
        bill.addToItems(bi)
        return bi
    }
    
    /// Create a bill item from product.
    /// - Parameters:
    ///   - payable: Product to be used to create a bill item.
    ///   - order: Order use to keep track of order in a set.
    ///   - isAddOn: Indicates the bill item should be consider an add-on item.
    /// - Returns: New bill item created.
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
    
    /// Create a bill item from rated item.
    /// - Parameters:
    ///   - ratedPayable: Rated item to be used to create a bill item.
    ///   - order: Order use to keep track of order in a set.
    ///   - isAddOn: Indicates the bill item should be consider an add-on item.
    /// - Returns: New bill item created.
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
    
    /// Submit the original balance and move to "OBR" mode in the Bill object side.
    func submitOriginalBalance() {
        bill.isSubmitted = true
        managedSave()
    }
    
    /// Resign the original balance and return to "Bill" mode in the Bill object side.
    /// - Parameters:
    ///   - proceedPayments: All proceed payments needed to be remove.
    ///   - addOns: All add-on items needed to be remove.
    func resignOriginalBill(proceedPayments: [BillPayment], addOns: [BillItem]) {
        for payment in proceedPayments {
            delete(payment)
        }
        for addOn in addOns {
            delete(addOn)
        }
        bill.isSubmitted = false
        managedSave()
    }
    
    /// Submit and closed the current bill, should be used incooperated will function within BillData, will not save on complete.
    /// - Parameters:
    ///   - proceedBalance: Current proceed payments balance.
    ///   - majorCurrency: The app's assigned major currency.
    ///   - additionalDescription: Additional description that should be display when reviewing the bill.
    func submit(proceedBalance: Decimal, majorCurrency: Currency, additionalDescription: String) {
        self.bill.closeTimestamp = Date()
        self.bill.proceedBalance = NSDecimalNumber(decimal: proceedBalance)
        self.bill.majorCurrencyString = majorCurrency.toStringRepresentation
        self.bill.additionalDescription = additionalDescription
    }
}

