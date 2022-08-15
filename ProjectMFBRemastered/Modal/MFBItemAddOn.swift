//
//  MFBItemAddOn.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-08-14.
//

import Foundation


struct MFBItemAddOn: MFBDataModel, MFBBasicModel {
    var id: Int64
    
    var name: String
    
    var value: String
    
    var primaryImageName: String?
    
    var disableUntil: String?
    
    var order: Int
    
    var starred: Bool
    
    var disabled: Bool
    
    var dateCreated: String
    
    var lastModified: String
    
    var toDict: [String : Any] {
        return [:]
    }
}
