//
//  MFBBillItem.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-08-03.
//

import Foundation


struct MFBBillItem: MFBDataModel {
    var id: Int64
    
    var status: Int
    
    var additionalDescription: String?
    
    var bill: Int64
    
    var item: MFBItem
    
    var isRate: Bool
    
    var isNegativeEffectOnBill: Bool
    
    var name: String
    
    var value: Decimal
    
    var count: Int
    
    var subtotal: Decimal
    
    var dateCreated: String

    var toDict: [String : Any] {
        [:]
    }
}


