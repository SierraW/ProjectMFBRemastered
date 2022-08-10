//
//  MFBRoom.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-08-01.
//

import Foundation


struct MFBRoom: MFBDataModel, MFBBasicModel {
    var id: Int64
    
    var linkedItem: MFBItem
    
    var seats: [MFBSeat]
    
    var name: String
    
    var starred: Bool
    
    var disabled: Bool
    
    var dateCreated: String
    
    var lastModified: String
    
    var toDict: [String : Any] {
        return [
            "name": name,
            "starred": starred,
            "disabled": disabled
        ]
    }
}
