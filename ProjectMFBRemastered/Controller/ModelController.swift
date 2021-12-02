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
    
    func delete(_ object: NSManagedObject, save: Bool = true) {
        viewContext.delete(object)
        if save {
            managedSave()
        }
    }
    
    func managedSave() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let nserror as NSError {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
