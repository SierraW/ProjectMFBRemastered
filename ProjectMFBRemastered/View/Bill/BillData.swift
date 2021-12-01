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

class BillData: ObservableObject, Identifiable {
    enum ViewState {
        case bill
        case originalBillReview
        case splitByPayable
        case splitByAmount
        case completed
    }
    
    var viewState: ViewState {
        if originalBalance == nil {
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
    
    @Published var originalBalance: Decimal? = nil
    
    @Published var items: [BillItem] = []
    @Published var payments: [BillPayment] = []
    
    var parent: Bill? = nil
    
    @Published var children: [Bill] = []
    
    @Published var mandatoryShowSplitByProductView = false
    
    @Published var billTotal: BillTotal? = nil
    
    var proceedBalance: Decimal? = nil
    
    init(context: NSManagedObjectContext, tag: Tag, associatedTag: Tag? = nil, payable: Payable? = nil, size: Int = 0) {
        self.controller = BillController(new: tag, context: context)
        self.roomTag = tag
        self.associatedTag = associatedTag
        self.size = size
        if let payable = payable, size > 0 {
            addItem(payable, count: size)
        }
    }
    
    init(context: NSManagedObjectContext, bill: Bill) {
        self.controller = BillController(bill, context: context)
        
        self.roomTag = bill.tag
        
        self.size = Int(bill.size)
        self.associatedTag = bill.associatedTag
        self.originalBalance = bill.originalBalance as Decimal?
        if let items = bill.items?.allObjects as? [BillItem] {
            self.items = items.sorted()
        }
        
        reloadPayments()
        
        self.billTotal = bill.total
        
        self.parent = bill.parent
        
        reloadChildren()
        
        self.proceedBalance = bill.proceedBalance as Decimal?
    }
    
    func reloadChildren() {
        if let children = controller.bill.children?.allObjects as? [Bill] {
            self.children = children
        } else {
            self.children = []
        }
    }
    
    func reloadPayments() {
        if let payments = controller.bill.payments?.allObjects as? [BillPayment] {
            self.payments = payments.sorted()
        } else {
            payments = []
        }
    }
    
    func addItem(_ payable: Payable, count: Int = 1, calculateRatedSubtotals: Bool = true, isAddOn: Bool = false) {
        var item: BillItem
        if let index = items.firstIndex(where: { $0.payable == payable && $0.is_add_on == isAddOn }) {
            item = items.remove(at: index)
        } else {
            item = controller.createBillItem(payable, order: billItemsIdentifierFactory, isAddOn: isAddOn)
        }
        item.count += Int32(count)
        if let value = item.value as Decimal? {
            item.subtotal = NSDecimalNumber(decimal: value * Decimal(item.count))
        }
        items.append(item)
        if calculateRatedSubtotals {
            self.calculateRatedSubtotals()
            controller.managedSave()
        }
    }
    
    func addItem(_ ratedPayable: RatedPayable, calculateRatedSubtotals: Bool = true, isAddOn: Bool = false) {
        var item: BillItem
        item = controller.createBillItem(ratedPayable, order: billItemsIdentifierFactory, isAddOn: isAddOn)
        items.append(item)
        if calculateRatedSubtotals {
            self.calculateRatedSubtotals()
            controller.managedSave()
        }
    }
    
    func addItem(_ index: Int, count: Int = 1, calculateRatedSubtotals: Bool = true) { // todo make it one
        if items[index].is_rated {
            return
        }
        let item = items.remove(at: index)
        item.count += Int32(count)
        if let value = item.value as Decimal? {
            item.subtotal = NSDecimalNumber(decimal: value * Decimal(item.count))
            items.append(item)
        }
        if calculateRatedSubtotals {
            self.calculateRatedSubtotals()
            controller.managedSave()
        }
    }
    
    func removeItem(_ index: Int, all: Bool = false) {
        let item = items.remove(at: index)
        
        if !all && item.count > 1 {
            item.count -= 1
            if let value = item.value as Decimal? {
                item.subtotal = NSDecimalNumber(decimal: value * Decimal(item.count))
                items.append(item)
            }
        } else {
            controller.delete(item, save: false)
        }
        self.calculateRatedSubtotals()
        controller.managedSave()
    }
    
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
        controller.bill.proceedBalance = NSDecimalNumber(decimal: proceedBalance)
        self.proceedBalance = proceedBalance
        setInactive()
    }
}

//computed var
extension BillData {
    var name: String {
        controller.bill.name
    }
    
    var openTimestamp: Date? {
        controller.bill.openTimestamp
    }
    
    var billPaymentsIdentifierFactory: Int32 {
        (payments.last?.order ?? -1) + 1
    }
    
    var billItemsIdentifierFactory: Int32 {
        (items.last?.order ?? -1) + 1
    }
    
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
    
    var total: Decimal {
        subtotal - (discount > discountableSubtotal ? discountableSubtotal : discount) + taxAndService
    }
    
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
    
    var completed: Bool {
        controller.bill.completed
    }
}
