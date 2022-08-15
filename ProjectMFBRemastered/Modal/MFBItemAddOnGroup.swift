//
//  MFBItemAddOnGroup.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-08-14.
//

import Foundation


struct MFBItemAddOnGroup: MFBDataModel, MFBBasicModel {
    var id: Int64
    
    var name : String
    
    var multiSelect: Bool
    
    var requried: Bool
    
    var itemAddOns: [MFBItemAddOn]
    
    var order: Int
    
    var starred: Bool
    
    var disabled: Bool
    
    var dateCreated: String
    
    var lastModified: String
    
    var toDict: [String : Any] {
        return [:]
    }
}
