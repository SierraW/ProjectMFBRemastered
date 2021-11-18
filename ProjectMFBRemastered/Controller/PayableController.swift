//
//  PayableController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-17.
//

import Foundation

class PayableController: TagController {
    
    func modifyOrCreateIfNotExist(name: String, amount: Decimal, payable: Payable? = nil, groupedBy tag: Tag? = nil, discountable: Bool = false, is_deposit: Bool = false, starred: Bool = false) -> Payable? {
        if amount < 0 {
            return nil
        }
        if (payable == nil || payable?.tag?.name != name) && fetchTags().contains(where: { tag in
            tag.name == name
        }) {
            return nil
        }
        
        if let payable = payable {
            return modifyPayable(name: name, amount: amount, payable: payable, groupedBy: tag, discountable: discountable, is_deposit: is_deposit, starred: starred)
        } else {
            return modifyPayable(name: name, amount: amount, payable: Payable(context: viewContext), groupedBy: tag, discountable: discountable, is_deposit: is_deposit, starred: starred)
        }
    }
    
    private func modifyPayable(name: String, amount: Decimal, payable: Payable, groupedBy tag: Tag? = nil, discountable: Bool = false, is_deposit: Bool = false, starred: Bool = false) -> Payable? {
        if payable.tag == nil {
            payable.tag = modifyOrCreateIfNotExist(name: name, is_payable: true)
        }
        
        guard let currentTag = payable.tag else {
            return nil
        }
        
        if let tag = tag, currentTag.parent != tag {
            currentTag.parent = tag
        } else if tag == nil && currentTag.parent != nil {
            currentTag.parent = nil
        }
        
        payable.amount = NSDecimalNumber(decimal: amount)
        payable.discountable = discountable
        payable.is_deposit = is_deposit
        payable.starred = starred
        
        managedSave()
        return payable
    }
}
