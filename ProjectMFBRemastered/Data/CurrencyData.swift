//
//  CurrencyData.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-20.
//

import Foundation
import Combine

class CurrencyData: ObservableObject {
    @Published var currencies: [MFBCurrency]
    @Published var selectedCurrencyIndex: Int?
    let authentication: MFBAuthentication
    
    init (profile authentication: MFBAuthentication) {
        self.currencies = []
        self.authentication = authentication
        self.selectedCurrencyIndex = nil
    }
    
    func fetchAll() {
        let controller = AuthenticatedDataAccessController<[MFBCurrency]>(authentication)
        
        Task.detached {
            let (result, _) = await controller.get(to: controller.baseUrl + "currency/")
            if let result = result {
                await MainActor.run {
                    self.currencies = result
                }
            }
        }
        
    }
    
    func update(item: MFBCurrency, with index: Int, completion: @escaping (Bool) -> Void) {
        let controller = AuthenticatedDataAccessController<MFBCurrency>(self.authentication)
        
        Task.detached {
            let (result, _) = await controller.post(to: "\(controller.baseUrl)membership_account/list/\(item.id)", with: item.toDict)
            if let result = result {
                await MainActor.run {
                    self.currencies[index] = result
                }
                completion(true)
            } else {
                completion(false)
            }
        }
        
    }
    
    func create(item: MFBCurrency, completion: @escaping (Bool) -> Void) {
        let controller = AuthenticatedDataAccessController<MFBCurrency>(self.authentication)
        
        
        Task.detached {
            let (result, _) = await controller.post(to: "\(controller.baseUrl)membership_account/create/", with: item.toDict)
            if let result = result {
                await MainActor.run {
                    self.currencies.append(result)
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
