//
//  MFBBill.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-08-03.
//

import Foundation


struct MFBBill: MFBDataModel {
    var id: Int64
    
    var additionalDescription: String?
    
    var room: MFBRoom?
    
    var activeRoom: String?
    
    var tag: MFBTag
    
    var majorCurrencyString: String

    var cartItemList: [MFBBillCartItem]
    
    var billItemList: [MFBBillItem]
    
    var subtotal: Decimal
    
    var promotionSubtotal: Decimal
    
    var taxAndServiceSubtotal: Decimal
    
    var billPaymentList: [MFBBillPayment]
    
    var paymentTotal: Decimal
    
    var remainingBalance: Decimal
    
    var children: [MFBSubBill]
    
    var supervisorName: String
    
    var closed: Bool
    
    var dateCreated: String
    
    var lastModified: String
    
    var toDict: [String : Any] {
        [:]
    }
    
    
}


struct MFBSubBill: MFBDataModel {
    var id: Int64
    
    var additionalDescription: String?
    
    var seat: MFBSeat?
    
    var activeSeat: String?

    var cartItemList: [MFBBillCartItem]
    
    var billItemList: [MFBBillItem]
    
    var subtotal: Decimal
    
    var promotionSubtotal: Decimal
    
    var taxAndServiceSubtotal: Decimal
    
    var billPaymentList: [MFBBillPayment]
    
    var paymentTotal: Decimal
    
    var remainingBalance: Decimal
    
    var parent: Int64
    
    var dateCreated: String
    
    var lastModified: String
    
    var toDict: [String : Any] {
        [:]
    }
    
    
}
