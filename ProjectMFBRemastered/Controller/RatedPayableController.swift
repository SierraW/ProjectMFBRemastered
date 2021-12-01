//
//  RatedPayableController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-17.
//

import Foundation
import CoreData

class RatedPayableController: TagController {
    
    static func firstTaxRatedPayable(_ context: NSManagedObjectContext) -> RatedPayable? {
        let fetchRequest: NSFetchRequest<RatedPayable> = RatedPayable.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \RatedPayable.is_tax, ascending: false)]
        do {
            let result = try context.fetch(fetchRequest)
            return result.first(where: {$0.is_tax})
        } catch {
            print("Fetch error in RatedPayableController, ftrp")
        }
        return nil
    }
    
    func modifyOrCreateIfNotExist(name: String, ratedPayable: RatedPayable? = nil, rate: Decimal, is_deposit: Bool = false, is_tax: Bool = false, starred: Bool = false) -> RatedPayable? {
        if rate < 0 {
            return nil
        }
        if (ratedPayable == nil || ratedPayable?.tag?.name != name) && fetchTags().contains(where: { tag in
            tag.name == name
        }) {
            return nil
        }
        
        return modify(name: name, ratedPayable: ratedPayable ?? RatedPayable(context: viewContext), rate: rate, is_deposit: is_deposit, is_tax: is_tax, starred: starred)
    }
    
    private func modify(name: String, ratedPayable: RatedPayable, rate: Decimal, is_deposit: Bool = false, is_tax: Bool = false, starred: Bool = false) -> RatedPayable? {
        if let tag = ratedPayable.tag {
            tag.name = name
        } else {
            ratedPayable.tag = modifyOrCreateIfNotExist(name: name, is_rated: true)
        }
        
        ratedPayable.rate = NSDecimalNumber(decimal: rate)
        ratedPayable.is_deposit = is_deposit
        ratedPayable.starred = starred
        ratedPayable.is_tax = is_tax
        
        managedSave()
        return ratedPayable
    }
}
