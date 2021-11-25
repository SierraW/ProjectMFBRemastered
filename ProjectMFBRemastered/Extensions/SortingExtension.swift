//
//  SortingExtension.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-24.
//

import Foundation

extension BillItem {
    func compare(to item: BillItem) -> Bool {
        return self.order < item.order
    }
}

extension BillPayment {
    func compare(to payment: BillPayment) -> Bool {
        return self.order < payment.order
    }
}
