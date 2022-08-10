//
//  MFBBillPayment.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-08-03.
//

import Foundation


struct MFBBillPayment: MFBDataModel {
    var id: Int64
    
    var bill: Int64
    
    var additionalDescription: String?
    
    var currency: MFBCurrency
    
    var paymentMethod: MFBPaymentMethod?
    
    var amount: Decimal
    
    var majorCurrencyEquivalent: Decimal
    
    var dateCreated: String
    
    var lastModified: String
    
    var user: String
    
    var username: String
    
    var toDict: [String : Any] {
        [:]
    }
    
    
}
