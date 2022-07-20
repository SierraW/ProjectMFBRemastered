//
//  MFBMembershipAccount.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-12.
//

import Foundation



struct MFBMembership: MFBDataModel, MFBBasicModel {
    var id: Int64
    var membershipAccounts: [MFBMembershipAccount]
    var cardNumber: String?
    var phoneNumber: String
    var name: String?
    var starred: Bool
    var disabled: Bool
    var dateCreated: String
    var lastModified: String
    
    var toDict: [String : Any] {
        var data = [
            "phoneNumber": phoneNumber,
            "starred": starred,
            "disabled": disabled
        ] as [String : Any]
        if let cardNumber = cardNumber {
            data["cardNumber"] = cardNumber
        }
        if let name = name {
            data["name"] = name
        }
        return data
    }
}


struct MFBMembershipAccount: MFBDataModel, MFBBasicModel {
    var id: Int64
    
    var currency: MFBCurrencyIdentity
    
    var amount: String
    
    var starred: Bool
    
    var disabled: Bool
    
    var dateCreated: String
    
    var lastModified: String
    
    var toDict: [String : Any] {
        [
            "pk": id,
            "amount": amount,
            "starred": starred,
            "disabled": disabled
        ]
    }
}
