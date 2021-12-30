//
//  PayableRatedPayableSelectionController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-26.
//

import Foundation
import CoreData
import Combine

class PayableRatedPayableSelectionController: ModelController, ObservableObject {
    enum Status {
        case loading
        case succeeded
        case paused
    }
    
    @Published var status: Status = .paused
    
    @Published var payables = [Payable]()
    @Published var ratedPayables = [RatedPayable]()
    
    override init(_ viewContext: NSManagedObjectContext) {
        super.init(viewContext)
        reloadData()
    }
    
    func reloadData() {
        status = .loading
        payables = PayableController.fetch(viewContext)
        ratedPayables = RatedPayableController.fetch(viewContext)
        status = .succeeded
    }
}
