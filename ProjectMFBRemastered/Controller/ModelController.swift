//
//  ModelController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-12.
//

import Foundation
import CoreData

class ModelController {
    var viewContext: NSManagedObjectContext
    
    init(_ viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func managedSave() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving currency at currency controller.")
        }
    }
}
