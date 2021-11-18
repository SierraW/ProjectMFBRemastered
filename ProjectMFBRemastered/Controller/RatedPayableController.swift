//
//  RatedPayableController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-17.
//

import Foundation

class RatedPayableController: TagController {
    
    func modifyOrCreateIfNotExist(name: String, ratedPayable: RatedPayable? = nil, rate: Decimal, is_deposit: Bool = false, starred: Bool = false) -> RatedPayable? {
        if rate < 0 {
            return nil
        }
        if (ratedPayable == nil || ratedPayable?.tag?.name != name) && fetchTags().contains(where: { tag in
            tag.name == name
        }) {
            return nil
        }
        
        return modify(name: name, ratedPayable: ratedPayable ?? RatedPayable(context: viewContext), rate: rate, is_deposit: is_deposit, starred: starred)
    }
    
    private func modify(name: String, ratedPayable: RatedPayable, rate: Decimal, is_deposit: Bool = false, starred: Bool = false) -> RatedPayable? {
        if let tag = ratedPayable.tag {
            tag.name = name
        } else {
            ratedPayable.tag = modifyOrCreateIfNotExist(name: name, is_payable: true)
        }
        
        ratedPayable.rate = NSDecimalNumber(decimal: rate)
        ratedPayable.is_deposit = is_deposit
        ratedPayable.starred = starred
        
        managedSave()
        return ratedPayable
    }
}
