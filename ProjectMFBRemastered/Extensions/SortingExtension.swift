//
//  SortingExtension.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-24.
//

import Foundation

extension BillItem: Comparable {
    public static func < (lhs: BillItem, rhs: BillItem) -> Bool {
        lhs.order < rhs.order
    }
}

extension BillPayment: Comparable {
    public static func < (lhs: BillPayment, rhs: BillPayment) -> Bool {
        lhs.order < rhs.order
    }
}

extension Payable: Comparable {
    public static func < (lhs: Payable, rhs: Payable) -> Bool {
        lhs.toStringRepresentation < rhs.toStringRepresentation
    }
}


extension RatedPayable: Comparable {
    public static func < (lhs: RatedPayable, rhs: RatedPayable) -> Bool {
        lhs.toStringRepresentation < rhs.toStringRepresentation
    }
}

extension Tag: Comparable {
    public static func < (lhs: Tag, rhs: Tag) -> Bool {
        lhs.toStringRepresentation < rhs.toStringRepresentation
    }
}
