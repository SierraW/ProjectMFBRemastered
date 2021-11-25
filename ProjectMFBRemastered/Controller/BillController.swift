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
    
    func createBillItem(_ payable: Payable, order: Int32) -> BillItem {
        let bi = BillItem(context: viewContext)
        bi.name = payable.toStringRepresentation
        bi.payable = payable
        bi.is_rated = false
        bi.is_tax = false
        bi.is_deposit = payable.is_deposit
        bi.value = payable.amount
        bi.order = order
        bi.count = 0
        bill.addToItems(bi)
        return bi
    }
    
    
    
    func submit(majorCurrency: Currency) {
        self.bill.majorCurrenctString = majorCurrency.toStringRepresentation
    }
}

