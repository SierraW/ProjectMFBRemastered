//
//  MembershipData.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-15.
//

import Foundation
import Combine

class MembershipData: ObservableObject {
    @Published var memberships: [MFBMembership]
    @Published var selectedMembershipIndex: Int?
    let authentication: MFBAuthentication
    
    init (profile authentication: MFBAuthentication) {
        self.memberships = []
        self.authentication = authentication
        self.selectedMembershipIndex = nil
    }
    
    func fetchAll() {
        let controller = AuthenticatedDataAccessController<MFBPagedDataModel<MFBMembership>>(authentication)
        memberships = []
        
        Task.detached {
            var (result, _) = await controller.get(to: controller.baseUrl + "membership_account/list/")
            while (result != nil) {
                if let result = result {
                    await MainActor.run {
                        self.memberships.append(contentsOf: result.results)
                    }
                }
                if let next = result?.next {
                    (result, _) = await controller.get(to: next)
                } else {
                    break
                }
            }
        }
        
    }
    
    func search(for key: String, insertTo index: Int? = nil) {
        let controller = AuthenticatedDataAccessController<[MFBMembership]>(self.authentication)
        if index == nil {
            memberships = []
        }
        
        
        Task.detached {
            let (result, _) = await controller.get(to: controller.baseUrl + "membership_account/search/" + key)
            if let result = result {
                await MainActor.run {
                    if let index = index, !result.isEmpty {
                        self.memberships[index] = result[0]
                    } else {
                        self.memberships.append(contentsOf: result)
                    }
                    
                }
            }
        }
    }
    
    func updateMembership(item: MFBMembership, with index: Int, completion: @escaping (Bool) -> Void) {
        let controller = AuthenticatedDataAccessController<MFBMembership>(self.authentication)
        
        Task.detached {
            let (result, _) = await controller.post(to: "\(controller.baseUrl)membership_account/list/\(item.id)", with: item.toDict)
            if let result = result {
                await MainActor.run {
                    self.memberships[index] = result
                }
                completion(true)
            } else {
                completion(false)
            }
        }
        
    }
    
    func createMembership(item: MFBMembership, currency index: Int64, completion: @escaping (Bool) -> Void) {
        let controller = AuthenticatedDataAccessController<MFBMembership>(self.authentication)
        
        
        Task.detached {
            var parameters = item.toDict
            parameters["currencyId"] = index
            let (result, _) = await controller.post(to: "\(controller.baseUrl)membership_account/create/", with: parameters)
            if let result = result {
                await MainActor.run {
                    self.memberships.append(result)
                }
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
}
