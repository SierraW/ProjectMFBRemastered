//
//  MembershipDataTransactionExtension.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-20.
//

import Foundation

extension MembershipData {
    func createCase(for membershipAccountId: Int64) async -> MFBMembershipTransactionCase? {
        let controller = AuthenticatedDataAccessController<MFBMembershipTransactionCase>(self.authentication)
        
        let parameters: [String: Any] = [
            "membershipAccountId": membershipAccountId
        ]
        let (result, _) = await controller.post(to: "\(controller.baseUrl)membership_transaction_case/create/", with: parameters)
        
        return result
    }
    
    func deposit(for transactionCase: MFBMembershipTransactionCase, amount: Decimal) async -> MFBMembershipTransactionResult? {
        let controller = AuthenticatedDataAccessController<MFBMembershipTransactionResult>(self.authentication)
        
        let parameters: [String: Any] = [
            "caseUid": transactionCase.caseUid,
            "amount": amount
        ]
        
        let (result, _) = await controller.post(to: "\(controller.baseUrl)membership_transaction/deposit/", with: parameters)
        
        return result
    }
    
    func purchase(for transactionCase: MFBMembershipTransactionCase, amount: Decimal) async -> MFBMembershipTransactionResult? {
        let controller = AuthenticatedDataAccessController<MFBMembershipTransactionResult>(self.authentication)
        
        let parameters: [String: Any] = [
            "caseUid": transactionCase.caseUid,
            "amount": amount
        ]
        
        let (result, _) = await controller.post(to: "\(controller.baseUrl)membership_transaction/purchase/", with: parameters)
        
        return result
    }
}
