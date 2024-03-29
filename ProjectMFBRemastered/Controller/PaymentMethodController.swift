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
    
    func modifyOrCreateIfNotExist(_ paymentMethod: PaymentMethod?, name: String, assignmentCurrency currency: Currency? = nil) -> PaymentMethod? {
        if name.isEmpty {
            return nil
        }
        if (paymentMethod == nil || paymentMethod?.name != name) && fetchPaymentMethods().contains(where: { paymentMethod in
            paymentMethod.name == name
        }) {
            return nil
        }
        
        if let paymentMethod = paymentMethod {
            return modifyPaymentMethod(paymentMethod: paymentMethod, name: name, assignCurrency: currency)
        } else {
            return modifyPaymentMethod(paymentMethod: PaymentMethod(context: viewContext), name: name, assignCurrency: currency)
        }
    }
    
    func modifyPaymentMethod(paymentMethod: PaymentMethod, name: String, assignCurrency currency: Currency? = nil) -> PaymentMethod? {
        paymentMethod.name = name
        if let currency = currency {
            paymentMethod.assignedCurrency = currency
        }
        managedSave()
        return paymentMethod
    }
    
}
