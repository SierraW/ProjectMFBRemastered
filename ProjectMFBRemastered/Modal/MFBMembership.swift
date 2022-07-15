//
//  MFBMembershipAccount.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-12.
//

import Foundation

struct MFBPagedMembership: MFBPaginationModel {
    var count: Int
    
    var next: Int?
    
    var previous: Int?
    
    var results: [MFBMembership]
    
}

struct MFBMembership: MFBDataModel, MFBBasicModel {
    var id: Int64
    var membershipAccounts: [MFBMembershipAccount]
    var cardNumber: String
    var phoneNumber: String
    var name: String
    var starred: Bool
    var disabled: Bool
    var dateCreated: String
    var lastModified: String
}


struct MFBMembershipAccount: MFBDataModel, MFBBasicModel {
    var id: Int64
    
    var currency: MFBCurrencyIdentity
    
    var amount: String
    
    var starred: Bool
    
    var disabled: Bool
    
    var dateCreated: String
    
    var lastModified: String
    
}
