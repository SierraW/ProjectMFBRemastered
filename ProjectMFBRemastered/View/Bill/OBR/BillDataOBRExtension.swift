//
//  BillDataOBRExtension.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-27.
//

import Foundation

// OBR view related
extension BillData {
    var currentBillPaymentBalance: Decimal {
        var balance: Decimal = 0
        
        for payment in payments {
            if let mce = payment.majorCurrencyEquivalent as Decimal? {
                balance += mce
            }
        }
        
        return balance
    }
    
    func originalBillSubmit() {
        if originalBalance != nil {
            return
        }
        let total = total
        originalBalance = total
        controller.submitOriginalBalance(total)
        if let taxItem = RatedPayableController.firstTaxRatedPayable(controller.viewContext) {
            addItem(taxItem, isAddOn: true)
        }
    }
    
    func originalBillResign() {
        controller.resignOriginalBill(proceedPayments: payments, addOns: items.filter({ bi in
            bi.is_add_on
        }))
        payments = []
        reloadItems()
        self.originalBalance = nil
    }
    
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
    
    func undoPayment(_ payment: BillPayment) {
        controller.delete(payment)
        if self.proceedBalance != nil {
            controller.bill.proceedBalance = nil
            self.proceedBalance = nil
        }
        controller.managedSave()
        reloadPayments()
    }
    
    func setComplete() {
        let currentBillPaymentBalance = currentBillPaymentBalance
        controller.bill.proceedBalance = NSDecimalNumber(decimal: currentBillPaymentBalance)
        self.proceedBalance = currentBillPaymentBalance
        controller.managedSave()
    }
    
    func setInactive() {
        controller.bill.activeTag = nil
        controller.managedSave()
    }
}
