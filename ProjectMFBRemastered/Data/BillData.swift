//
//  BillData.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-22.
//

import Foundation
import Combine
import CoreData
import UIKit

/// Observable Object work for bill views.
class BillData: ObservableObject, Identifiable {
    enum ViewState {
        case bill
        case originalBillReview
        case splitByPayable
        case splitByAmount
        case completed
    }
    
    var viewState: ViewState {
        if !isSubmitted {
            return .bill
        } else if proceedBalance != nil {
            return .completed
        } else if mandatoryShowSplitByProductView {
            return .splitByPayable
        } else if children.count == 0 {
            return .originalBillReview
        } else {
            if let _ = children[0].total {
                return .splitByAmount
            } else {
                return .splitByPayable
            }
        }
    }
    
    var id: String {
        "\(size) \(viewState.hashValue)"
    }
    
    var controller: BillController
    
    var roomTag: Tag?
    
    @Published var size: Int
    
    @Published var associatedTag: Tag?
    
    @Published var additionalDescription: String
    
    @Published var isSubmitted = false
    
    @Published var items: [BillItem] = []
    @Published var payments: [BillPayment] = []
    
    var parent: Bill? = nil
    
    @Published var children: [Bill] = []
    
    @Published var mandatoryShowSplitByProductView = false
    
    @Published var billTotal: BillTotal? = nil
    
    var proceedBalance: Decimal? = nil

    var identifierFactory: Int32 = 0
    
    
    /// Init data as a new bill, then save.
    /// - Parameters:
    ///   - context: managed object context.
    ///   - tag: the tag indicate the room of the bill.
    ///   - associatedTag: the optional tag indicate the event of the bill.
    ///   - payable: optional service product.
    ///   - size: the number of the service product generated, "splite by amount" function also uses this number as an initial value.
    init(context: NSManagedObjectContext, tag: Tag, associatedTag: Tag? = nil, payable: Payable? = nil, size: Int = 0) {
        self.controller = BillController(new: tag, associatedTag: associatedTag, size: size, context: context)
        self.roomTag = tag
        self.associatedTag = associatedTag
        self.size = size
        self.additionalDescription = ""
        if let payable = payable, size > 0 {
            addItem(payable, count: size)
        }
        controller.managedSave()
    }
    
    
    /// Init data from an existing bill.
    /// - Parameters:
    ///   - context: managed object context.
    ///   - bill: the existing bill object came from database.
    init(context: NSManagedObjectContext, bill: Bill) {
        self.controller = BillController(bill, context: context)
        
        self.roomTag = bill.tag
        
        self.additionalDescription = bill.additionalDescription ?? ""
        
        self.size = Int(bill.size)
        self.associatedTag = bill.associatedTag
        self.isSubmitted = bill.isSubmitted
        if let items = bill.items?.allObjects as? [BillItem] {
            self.items = items.sorted()
        }
        
        reloadPayments()
        
        self.billTotal = bill.total
        
        self.parent = bill.parent
        
        reloadChildren()
        
        reloadItems()
        
        identifierFactory = self.items.last?.order ?? 0
        
        self.proceedBalance = bill.proceedBalance as Decimal?
    }
    
    
    /// Reload children data from CoreData Object.
    func reloadChildren() {
        if let children = controller.bill.children?.allObjects as? [Bill] {
            self.children = children.filter({!$0.isDeleted})
        } else {
            self.children = []
        }
    }
    
    /// Reload payments data from CoreData Object.
    func reloadPayments() {
        if let payments = controller.bill.payments?.allObjects as? [BillPayment] {
            self.payments = payments.sorted()
        } else {
            payments = []
        }
    }
    
    /// Reload items data from CoreData Object.
    func reloadItems() {
        if let items = controller.bill.items?.allObjects as? [BillItem] {
            self.items = items.sorted().filter({!$0.isDeleted})
        } else {
            items = []
        }
    }
    
    
    /// Set the assoiated tag for the bill.
    /// - Parameter newTag: Associated Tag.
    func setAssociatedTag(_ newTag: Tag) {
        if newTag != associatedTag {
            associatedTag = newTag
            controller.bill.associatedTag = newTag
            controller.managedSave()
        }
    }
    
    
    /// Async calcualte subtotals. Will save on complete.
    func reloadItemsAndCalculateRatedSubtotals() {
        DispatchQueue.main.async {
            self.reloadItems()
            self.calculateRatedSubtotals()
            self.controller.managedSave()
        }
    }
    
    /// Add item to the bill.
    /// - Parameter calcualteRatedSubtotals: Optional calculate the subtotals on rated items after the addtion.
    func addItem(_ payable: Payable, count: Int = 1, calculateRatedSubtotals: Bool = true, isAddOn: Bool = false) {
        var item: BillItem
        if let firstItem = items.first(where: { $0.payable == payable && $0.is_add_on == isAddOn }) {
            item = firstItem
        } else {
            item = controller.createBillItem(payable, order: getBillItemsIdentifier(), isAddOn: isAddOn)
            items.append(item)
        }
        item.count += Int32(count)
        if let value = item.value as Decimal? {
            item.subtotal = NSDecimalNumber(decimal: value * Decimal(item.count))
        }
        if calculateRatedSubtotals {
            reloadItemsAndCalculateRatedSubtotals()
        }
    }
    
    /// Add item to the bill.
    /// - Parameter calcualteRatedSubtotals: Optional calculate the subtotals on rated items after the addtion.
    func addItem(_ ratedPayable: RatedPayable, calculateRatedSubtotals: Bool = true, isAddOn: Bool = false) {
        var item: BillItem
        item = controller.createBillItem(ratedPayable, order: getBillItemsIdentifier(), isAddOn: isAddOn)
        items.append(item)
        if calculateRatedSubtotals {
            reloadItemsAndCalculateRatedSubtotals()
        }
    }
    
    /// Add item to the bill.
    /// - Parameters:
    ///     - index: The index of BillItem in related to self.items.
    ///     - calcualteRatedSubtotals: Optional calculate the subtotals on rated items after the addtion.
    func addItem(_ index: Int, count: Int = 1, calculateRatedSubtotals: Bool = true) { // todo make it one
        let item = items[index]
        addItem(item, count: count, calculateRatedSubtotals: calculateRatedSubtotals)
    }
    
    /// Add item to the bill.
    /// - Parameters:
    ///     - index: The index of BillItem in related to self.items.
    ///     - calcualteRatedSubtotals: Optional calculate the subtotals on rated items after the addtion.
    func addItem(_ item: BillItem, count: Int = 1, calculateRatedSubtotals: Bool = true) {
        if item.is_rated {
            return
        }
        item.count += Int32(count)
        if let value = item.value as Decimal? {
            item.subtotal = NSDecimalNumber(decimal: value * Decimal(item.count))
        }
        if calculateRatedSubtotals {
            reloadItemsAndCalculateRatedSubtotals()
        }
    }
    
    /// Remove item from the bill.
    /// - Parameters:
    ///     - index: The index of BillItem in related to self.items.
    ///     - all: Optional, should remove all item with the given BillItem.
    func removeItem(_ index: Int, count: Int = 1, all: Bool = false) {
        let item = items[index]
        removeItem(item, count: count, all: all)
    }
    
    /// Remove item from the bill.
    /// - Parameters:
    ///     - all: Optional, should remove all item with the given BillItem.
    func removeItem(_ item: BillItem, count: Int = 1, all: Bool = false) {
        if !all && Int(item.count) > count {
            item.count -= Int32(count)
            if let value = item.value as Decimal? {
                item.subtotal = NSDecimalNumber(decimal: value * Decimal(item.count))
            }
        } else {
            controller.bill.removeFromItems(item)
            controller.delete(item)
        }
        reloadItemsAndCalculateRatedSubtotals()
    }
    
    /// Calculate all the subtotals for all rated items, will not save after calculation.
    func calculateRatedSubtotals() {
        var discountableTotal = self.discountableSubtotal
        let fixedTotal = self.subtotal - discountableTotal
        var taxAndService: Decimal = 0
        
        for item in items.filter({ bi in
            bi.is_deposit && !bi.is_rated
        }) {
            if let subtotal = item.subtotal as Decimal? {
                discountableTotal -= subtotal
            }
        }
        
        for item in items.filter({ bi in
            bi.is_rated
        }).sorted(by: { lhs, rhs in
            BillItem.calculationOrderComparator(lhs: lhs, rhs: rhs)
        }) {
            if let value = item.value as Decimal? {
                if item.is_deposit {
                    if discountableTotal > 0 {
                        let discountedValue = (discountableTotal * value).rounded(toPlaces: 2)
                        discountableTotal -= discountedValue
                        item.subtotal = NSDecimalNumber(decimal: discountedValue)
                    } else {
                        item.subtotal = 0
                    }
                } else {
                    let subtotal = (discountableSubtotal > 0 ? discountableTotal : 0) + fixedTotal
                    let chargedValue = (subtotal * value).rounded(toPlaces: 2)
                    taxAndService += chargedValue
                    item.subtotal = NSDecimalNumber(decimal: chargedValue)
                }
            }
        }
    }
    
    
    /// Submit the bill, generate transaction, inactive the bill, and then save.
    /// - Parameter appData: Main app data contains user object.
    func submitBill(_ appData: AppData) {
        var proceedBalance: Decimal = 0
        let transactionController = TransactionController(controller.viewContext, user: appData.user, majorCurrency: appData.majorCurrency)
        for payment in allPayments {
            if let amount = payment.amount as Decimal?, let paymentMethod = payment.paymentMethod, let currency = payment.currency {
                transactionController.transact(bill: controller.bill, amount: amount, description: payment.additionalDescription, paymentMethod: paymentMethod, currency: currency, tags: nil)
                if let mce = payment.majorCurrencyEquivalent as Decimal? {
                    proceedBalance += mce
                }
            }
        }
        if let items = bill.items, !self.items.contains(where: {!$0.is_rated}) {
            bill.removeFromItems(items)
        }
        additionalDescription.trimmingWhitespacesAndNewlines()
        controller.submit(proceedBalance: proceedBalance, majorCurrency: appData.majorCurrency, additionalDescription: additionalDescription)
        self.proceedBalance = proceedBalance
        setInactive()
    }
    
    /// Identifier generator, identifier is for storing bill items order.
    func getBillItemsIdentifier() -> Int32 {
        identifierFactory += Int32(1)
        return identifierFactory
    }
}

/// Computed vars for the original BillData
extension BillData {
    var name: String {
        controller.bill.name
    }
    
    var openTimestamp: Date? {
        controller.bill.openTimestamp
    }
    
    
    /// The subtotal without discount and rated charges of the current bill, including carry-on subs ( From split by amount ) and normal product only, in an order of:
    /// carry-on subs -> product excl. promotion product.
    var subtotal: Decimal {
        var total: Decimal = 0
        
        if let billTotal = billTotal, let carryOnSubtotal = billTotal.total as Decimal? {
            total += carryOnSubtotal
        }
        
        for item in items.filter({ bi in
            !bi.is_rated && !bi.is_deposit
        }) {
            if let subtotal = item.subtotal as Decimal? {
                total += subtotal
            }
        }
        
        return total
    }
    
    /// The subtotal for all discountable product of the current bill, including carry-on discountable total ( From split by amount ) and normal discountable product only, in an order of:
    /// carry-on discountable total -> discountable product total.
    var discountableSubtotal: Decimal {
        var total: Decimal = 0
        
        if let billTotal = billTotal, let carryOnDiscountableSubtotal = billTotal.discountableTotal as Decimal? {
            total += carryOnDiscountableSubtotal
        }
        
        for item in items.filter({ bi in
            !bi.is_rated && !bi.is_deposit && bi.payable?.discountable == true
        }) {
            if let subtotal = item.subtotal as Decimal? {
                total += subtotal
            }
        }
        
        return total
    }
    
    /// The subtotal for promotion items of the current bill, in an order of:
    /// promotion items total.
    var discount: Decimal {
        var total: Decimal = 0
        
        for item in items.filter({ bi in
            bi.is_deposit
        }) {
            if let subtotal = item.subtotal as Decimal? {
                total += subtotal
            }
        }
        
        return total
    }
    
    /// The subtotal for all tax and service of the current bill, including all rated items.
    var taxAndService: Decimal {
        var total: Decimal = 0
        
        for item in items.filter({ bi in
            bi.is_rated && !bi.is_deposit
        }) {
            if let subtotal = item.subtotal as Decimal? {
                total += subtotal
            }
        }
        
        return total
    }
    
    /// The total of the current bill, discount will not go over the discountable subtotals.
    var total: Decimal {
        subtotal - (discount > discountableSubtotal ? discountableSubtotal : discount) + taxAndService
    }
    
    
    /// Return all payments including payments from sub-bills.
    var allPayments: [BillPayment] {
        var allPayments = [BillPayment]()
        
        allPayments.append(contentsOf: self.payments)
        
        func retrievePayments(of bill: Bill) -> [BillPayment] {
            var allPayments = [BillPayment]()
            if let payments = bill.payments?.allObjects as? [BillPayment] {
                allPayments.append(contentsOf: payments)
            }
            if let children = bill.children?.allObjects as? [Bill] {
                for child in children {
                    allPayments.append(contentsOf: retrievePayments(of: child))
                }
            }
            return allPayments
        }
        
        for child in children {
            allPayments.append(contentsOf: retrievePayments(of: child))
        }
        
        return allPayments
    }
    
    /// Indicates if it a complete bill.
    var completed: Bool {
        controller.bill.completed
    }
    
    /// CoreData Managed Object Bill.
    var bill: Bill {
        controller.bill
    }
}
