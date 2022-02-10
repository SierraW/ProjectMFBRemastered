//
//  BillDataSBPExtension.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-28.
//

import Foundation

/// (Discountinued) Split By Products (SBP) section extensions
extension BillData {
    
    /// init BillData as a sub-BillData from a parent BillData, Create new bill object and will not save on complete.
    /// - Parameter billData: parent BillData object.
    convenience init(asChildOf billData: BillData) {
        let newBill = billData.controller.createChildBill()
        for item in billData.items.filter({$0.is_rated}) {
            let _ = billData.controller.createBillItem(from: item, to: newBill)
        }
        self.init(context: billData.controller.viewContext, bill: newBill)
    }
    
    func showSplitByProductView() {
        self.mandatoryShowSplitByProductView = true
    }
    
    func sbpResign() {
        splitByAmountResign()
        self.mandatoryShowSplitByProductView = false
    }
    
    func sbpClearCart() {
        controller.delete(controller.bill)
    }
    
    func sbpAddToCart(miniProductDict: [Payable: Int]) {
        for key in miniProductDict.keys.sorted() {
            if let count = miniProductDict[key], count > 0 {
                addItem(key, count: count, calculateRatedSubtotals: false, isAddOn: false)
            }
        }
        DispatchQueue.main.async {
            self.reloadItems()
            self.calculateRatedSubtotals()
            self.controller.bill.isSubmitted = true
            self.isSubmitted = true
            self.controller.managedSave()
        }
    }
}
