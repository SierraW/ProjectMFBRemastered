//
//  MFBCurrency.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-07.
//

import Foundation


struct MFBCurrency: MFBDataModel, MFBBasicModel {
    var name: String
    
    var prefix: String
    
    var symbol: String
    
    var isMajorCurrency: Bool
    
    var exchangeRate: String
    
    var id: Int64
    
    var starred: Bool
    
    var disabled: Bool
    
    var dateCreated: String
    
    var lastModified: String
    
    var toDict: [String : Any] {
        [
            "pk": id,
            "name": name,
            "prefix": prefix,
            "symbol": symbol,
            "exchangeRate": exchangeRate,
            "starred": starred,
            "disabled": disabled
        ]
    }
}


struct MFBCurrencyIdentity: MFBDataModel {
    var id: Int64
    var stringRepresentation: String
    
    var toDict: [String : Any] {
        [
            "pk": id
        ]
    }
}
