//
//  MFBSeat.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-08-09.
//

import Foundation

struct MFBSeat: MFBDataModel, MFBBasicModel {
    var id: Int64
    
    var room: String
    
    var name: String
    
    var code: String
    
    var starred: Bool
    
    var disabled: Bool
    
    var dateCreated: String
    
    var lastModified: String
    
    var toDict: [String : Any] {
        return [:]
    }
}
