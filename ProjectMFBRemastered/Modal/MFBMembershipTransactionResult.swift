//
//  MFBTransactionResult.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-20.
//

import Foundation

struct MFBMembershipTransactionResult: MFBDataModel {
    var id: Int64
    
    var transactionCase: String
    
    var originMembershipAccount: Int64?
    
    var destinationMembershipAccount: Int64?
    
    var amount: String
    
    var status: String
    
    var transactionType: String
    
    var dateCreated: String
    
    var lastModified: String
    
    var toDict: [String : Any] {
        return [:]
    }
    
    
}
