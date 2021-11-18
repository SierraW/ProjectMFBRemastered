//
//  PresentationExtensions.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-12.
//

import Foundation

extension User {
    var toStringPresentation: String {
        "\(self.username ?? "err user")"
    }
}

extension Currency {
    var toStringPresentation: String {
        return "\(self.prefix ?? "err") \(self.symbol ?? "err")"
    }
}

extension PaymentMethod {
    var toStringPresentation: String {
        "\(self.name ?? "err")"
    }
}

extension Decimal {
    var toStringPresentation: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        let number = NSDecimalNumber(decimal: self)
        return formatter.string(from: number) ?? "Error"
    }
}

extension Tag {
    var toStringPresentation: String {
        return self.name ?? "err"
    }
}

extension Payable {
    var toStringPresentation: String {
        return self.tag?.name ?? "err"
    }
}
