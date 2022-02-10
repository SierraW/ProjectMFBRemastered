//
//  AppData.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-02-10.
//

import Foundation
import Combine
import CoreData

class AppData: ObservableObject {
    @Published var user: User
    @Published var majorCurrency: Currency
    var onLogout: () -> Void
    
    init? (_ user: User, viewContext: NSManagedObjectContext, onLogout: @escaping () -> Void) {
        self.user = user
        self.onLogout = onLogout
        if let currency = CurrencyController.getMajorCurrency(from: viewContext) {
            self.majorCurrency = currency
        } else {
            return nil
        }
    }
}
