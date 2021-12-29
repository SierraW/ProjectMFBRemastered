//
//  PayableRatedPayableSelectionController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-26.
//

import Foundation
import CoreData

class PayableRatedPayableSelectionController: ModelController {
    enum Status {
        case loading
        case success
        case failed
    }
    
    var status: Status = .loading
    
    var payables = [Payable]()
    var ratedPayables = [RatedPayable]()
    var billItems = [BillItem]()
    
    override init(_ viewContext: NSManagedObjectContext) {
        super.init(viewContext)
        
        payables = PayableController.fetch(viewContext)
        ratedPayables = RatedPayableController.fetch(viewContext)
        
        
    }
}
