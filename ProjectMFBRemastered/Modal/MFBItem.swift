//
//  MFBItem.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-31.
//

import Foundation


struct MFBItem: MFBDataModel, MFBBasicModel {
    var id: Int64
    
    var name: String
    
    var autoAddOnCheckout: Bool
    
    var value: Decimal
    
    var isRate: Bool
    
    var isNegativeEffectOnBill: Bool
    
    var tags: [MFBTag]
    
    var effectiveTags: [MFBTag]
    
    var primaryImageName: String?
    
    var toDict: [String : Any] {
        var data = [
            "name": name,
            "autoAddOnCheckout": autoAddOnCheckout,
            "value": value,
            "isRate": isRate,
            "isNegativeEffectOnBill": isNegativeEffectOnBill,
            "tags": tags.map({ mfbTag in
                mfbTag.id
            }),
            "effectiveTags": effectiveTags.map({ mfbTag in
                mfbTag.id
            }),
            "starred": starred,
            "disabled": disabled
        ] as [String : Any]
        if let primaryImageName = primaryImageName {
            data["primaryImageName"] = primaryImageName
        }
        return data
    }
    
    var starred: Bool
    
    var disabled: Bool
    
    var dateCreated: String
    
    var lastModified: String
    
    
}
