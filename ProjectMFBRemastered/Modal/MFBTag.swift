//
//  MFBTag.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-23.
//

import Foundation


struct MFBTag: MFBDataModel, MFBBasicModel {
    
    var id: Int64
    
    var tagType: Int
    
    var name: String
    
    var groupName: String?
    
    var starred: Bool
    
    var disabled: Bool
    
    var dateCreated: String
    
    var lastModified: String
    
    
    var toDict: [String : Any] {
        var data = [
            "name": name,
            "starred": starred,
            "disabled": disabled
        ] as [String : Any]
        if let groupName = groupName {
            data["groupName"] = groupName
        }
        return data
    }
    
    
}
