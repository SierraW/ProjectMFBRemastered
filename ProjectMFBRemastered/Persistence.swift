//
//  Persistence.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-10.
//

import CoreData
import SwiftUI

private struct PersistenceControllerKey: EnvironmentKey {
    static let defaultValue: PersistenceController = PersistenceController()
}

extension EnvironmentValues {
    var persistenceController: PersistenceController {
        get { self[PersistenceControllerKey.self] }
        set { self[PersistenceControllerKey.self] = newValue }
    }
}

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = User(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentCloudKitContainer
    let persistentContainerQueue = OperationQueue()
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "ProjectMFBRemastered")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        persistentContainerQueue.maxConcurrentOperationCount = 1
    }
    
    func enqueue(block: @escaping (_ context: NSManagedObjectContext) -> Void) {
        persistentContainerQueue.addOperation(){
            let context: NSManagedObjectContext = self.container.newBackgroundContext()
            context.performAndWait {
                block(context)
                try? context.save() //Don't just use '?' here look at the error and log it to your analytics service
            }
        }
    }
}
