//
//  MFBMembershipTransactionCase.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-20.
//

import Foundation


struct MFBMembershipTransactionCase: MFBDataModel {
    var id: Int64
    
    var caseUid: String
    
    var preparedFor: String
    
    var membershipAccountRequested: Decimal
    
    var dateCreated: String
    
    var membership_transaction: MFBMembershipTransactionResult?
    
    var toDict: [String : Any] {
        [:]
    }
    
    
}
