//
//  AccountController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-01.
//

import Foundation
import CoreData

class AccountController: ModelController {
    func fetchUsers() -> [User] {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result
        } catch {
            print("Fetch error in Payment Method Controller")
        }
        return []
    }
    
    func setUsername(_ user: User, value: String) {
        if fetchUsers().contains(where: { fetchUser in
            fetchUser.username == value
        }) {
            return
        }
        user.username = value
        managedSave()
    }
    
    func setDisabled(_ user: User, value: Bool) {
        user.disabled = value
        managedSave()
    }
    
    func setSuperuser(_ user: User, value: Bool) {
        user.is_superuser = value
        managedSave()
    }
    
    func setHighlight(_ user: User, value: Bool) {
        user.is_highlighted = value
        managedSave()
    }
}
