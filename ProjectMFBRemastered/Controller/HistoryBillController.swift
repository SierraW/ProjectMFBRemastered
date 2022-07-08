//
//  HistoryController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-05-20.
//

import Foundation
import CoreData


class HistoryBillController: ModelController {
    func fetchBills() -> [Bill] {
        let fetchRequest: NSFetchRequest<Bill> = Bill.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Bill.openTimestamp, ascending: false)]
        do {
            fetchRequest.predicate = NSPredicate(format: "parent = nil")
            let result = try viewContext.fetch(fetchRequest)
            return result
        } catch {
            print("Fetch error in Payment Method Controller")
        }
        return []
    }
}
