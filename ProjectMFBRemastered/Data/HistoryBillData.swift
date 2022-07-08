//
//  HistoryBillData.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-05-20.
//

import Foundation
import Combine
import CoreData


class HistoryBillData: ObservableObject {
    @Published var billGroup: [String: [Bill]] = [:]
    @Published var status: Status = .Ready
    
    enum Status {
        case Fetching
        case Ready
    }
    
    func reload(viewContext: NSManagedObjectContext) {
        if status == .Fetching {
            return
        }
        status = .Fetching
        billGroup.removeAll()
        let controller = HistoryBillController(viewContext)
        let bills = controller.fetchBills()
        
        let now = Date()
        for bill in bills {
            if let key = bill.openTimestamp?.listGroupRepresentation(now: now) {
                if billGroup[key] == nil {
                    billGroup[key] = []
                }
                billGroup[key]?.append(bill)
            }
        }
        status = .Ready
    }
    
}
