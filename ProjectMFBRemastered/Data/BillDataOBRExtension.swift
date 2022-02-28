//
//  BillDataOBRExtension.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-27.
//

import Foundation

/// Original Bill Review (OBR) section extensions
extension BillData {
    /// The current balance of all payments.
    var currentBillPaymentBalance: Decimal {
        var balance: Decimal = 0
        
        for payment in payments {
            if let mce = payment.majorCurrencyEquivalent as Decimal? {
                balance += mce
            }
        }
        
        return balance
    }
    
    /// The amount need to pay in order to complete
    var remainingBalance: Decimal {
        let result = total - currentBillPaymentBalance
        return result > 0 ? result : 0
    }
    
    /// Submit the current bill and transfering to "OBR" mode. This function will add the first tax item if there is any.
    func originalBillSubmit() {
        if isSubmitted {
            return
        }
        isSubmitted = true
        controller.submitOriginalBalance()
        if let taxItem = RatedPayableController.firstTaxRatedPayable(controller.viewContext) {
            addItem(taxItem, isAddOn: true)
        }
    }
    
    /// Resign the submitted bill and return to "Bill" mode. This function wil alsol remove all add-on item.
    func originalBillResign() {
        controller.resignOriginalBill(proceedPayments: payments, addOns: items.filter({ bi in
            bi.is_add_on
        }))
        payments = []
        reloadItems()
        self.isSubmitted = false
    }
    
    
    /// Add items from a shopping view to the current bill, save on complete.
    /// - Parameters:
    ///   - payableDict: products and counts from shopping view
    ///   - ratedPayableDict: rated items and counts dict from shopping view
    ///   - isAddOn: Indicates that the above items should add as an add-on item.
    func addItems(payableDict: [Payable: Int], ratedPayableDict: [RatedPayable: Int], isAddOn: Bool = false) {
        for key in payableDict.keys.sorted() {
            if let count = payableDict[key], count > 0 {
                addItem(key, count: count, calculateRatedSubtotals: false, isAddOn: isAddOn)
            }
        }
        for key in ratedPayableDict.keys.sorted() {
            if let count = ratedPayableDict[key], count > 0 {
                addItem(key, calculateRatedSubtotals: false, isAddOn: isAddOn)
            }
        }
        reloadItemsAndCalculateRatedSubtotals()
    }
    
    
    /// Add a payment to current bill, the payment should come from Transaction View, save on complete.
    /// - Parameters:
    ///   - majorCurrencyEquivalent: The current amount equals to major currencies.
    ///   - additionalDescription: Additional description about this payment.
    func submitBillPayment(paymentMethod: PaymentMethod, currency: Currency, amount: Decimal, majorCurrencyEquivalent: Decimal, additionalDescription: String?) {
        let billPayment = controller.createBillPayment()
        billPayment.paymentMethod = paymentMethod
        billPayment.currency = currency
        billPayment.amount = NSDecimalNumber(decimal: amount)
        billPayment.majorCurrencyEquivalent = NSDecimalNumber(decimal: majorCurrencyEquivalent)
        billPayment.additionalDescription = additionalDescription
        controller.managedSave()
        reloadPayments()
    }
    
    
    /// Remove the completed payment, save on complete.
    /// - Parameter payment: The payment needs to be removed.
    func undoPayment(_ payment: BillPayment) {
        controller.delete(payment)
        if self.proceedBalance != nil {
            controller.bill.proceedBalance = nil
            self.proceedBalance = nil
        }
        controller.managedSave()
        reloadPayments()
    }
    
    /// Set the current bill as complete, assign proceed balance, save on complete.
    func setComplete() {
        let currentBillPaymentBalance = currentBillPaymentBalance
        controller.bill.proceedBalance = NSDecimalNumber(decimal: currentBillPaymentBalance)
        self.proceedBalance = currentBillPaymentBalance
        controller.managedSave()
    }
    
    /// Remove the bill from attach to a room tag, indicates "inactive", save on complete.
    func setInactive() {
        controller.bill.activeTag = nil
        controller.managedSave()
    }
    
    /// Attach the bill to it room tag, indicates "active", a bill that already attach to this room tag will be inactive, save on complete.
    func setActive() {
        if let tag = bill.tag {
            controller.bill.activeTag = tag
            controller.managedSave()
        }
    }
}
