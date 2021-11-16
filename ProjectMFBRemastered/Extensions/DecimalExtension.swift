//
//  DecimalExtension.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-12.
//

import Foundation

extension Decimal {
    func rounded(toPlaces places:Int) -> Decimal {
        var value = self
        var roundedValue = Decimal()
        NSDecimalRound(&roundedValue, &value, places, NSDecimalNumber.RoundingMode.plain)
        return roundedValue
    }
}

extension NSDecimalNumber {
    var isNegative: Bool {
        (self as Decimal) < 0
    }
}
