//
//  MFBPaymentMethod.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-31.
//

import Foundation


struct MFBPaymentMethod: MFBDataModel, MFBBasicModel {
    var id: Int64
    
    var name: String
    
    var assignedCurrency: Int64?
    
    var autoAddItemTag: Int64?
    
    var toDict: [String : Any] {
        var data = [
            "name": name,
        ] as [String: Any]
        if let assignedCurrency = assignedCurrency {
            data["assignedCurrency"] = assignedCurrency
        }
        if let autoAddItemTag = autoAddItemTag {
            data["autoAddItemTag"] = autoAddItemTag
        }
        return data
    }
    
    var starred: Bool
    
    var disabled: Bool
    
    var dateCreated: String
    
    var lastModified: String
    
    
}
