//
//  BillExtension.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-29.
//

import Foundation

extension Payable {
    var pricePerUnit: Decimal {
        if let amount = amount as Decimal? {
            return amount
        }
        return 0
    }
}

extension Bill {
    var isOnHold: Bool {
        self.activeTag == nil
    }
}
