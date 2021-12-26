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
    
    public static func calculationOrderComparator(lhs: BillItem, rhs: BillItem) -> Bool {
        (lhs.calculationOrder == rhs.calculationOrder) ? (lhs.subtotal as Decimal? ?? 0) > (rhs.subtotal as Decimal? ?? 0) : lhs.calculationOrder < rhs.calculationOrder
    }
    
    var calculationOrder: Int {
        if is_tax {
            return 4
        }
        if is_rated && is_deposit {
            return 2
        } else if is_deposit {
            return 1
        } else if is_rated {
            return 3
        } else {
            return 0
        }
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

extension Currency: Comparable {
    public static func < (lhs: Currency, rhs: Currency) -> Bool {
        (lhs.is_major && !rhs.is_major) ? true : lhs.name ?? "" < rhs.name ?? ""
    }
}

extension Bill: Comparable {
    public static func < (lhs: Bill, rhs: Bill) -> Bool {
        (lhs.proceedBalance == nil && rhs.proceedBalance != nil) ? true : lhs.openTimestamp ?? Date() > rhs.openTimestamp ?? Date()
    }
}
