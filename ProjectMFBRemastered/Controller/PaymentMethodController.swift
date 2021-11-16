//
//  PaymentMethodController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-16.
//

import Foundation
import CoreData

class PaymentMethodController: ModelController {
    
    
    func fetchPaymentMethods() -> [PaymentMethod] {
        let fetchRequest: NSFetchRequest<PaymentMethod> = PaymentMethod.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PaymentMethod.assignedCurrency?.is_major, ascending: false), NSSortDescriptor(keyPath: \PaymentMethod.name, ascending: false)]
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result
        } catch {
            print("Fetch error in Payment Method Controller")
        }
        return []
    }
    
    
    func createPaymentMethod(name: String, assignCurrency currency: Currency) -> Bool {
        if fetchPaymentMethods().contains(where: { paymentMethod in
            paymentMethod.name == name
        }) {
            
        }
        
        
        let paymentMethod = PaymentMethod(context: viewContext)
        
        paymentMethod.name = name
        paymentMethod.assignedCurrency = currency
        
        
        
    }
    
}
