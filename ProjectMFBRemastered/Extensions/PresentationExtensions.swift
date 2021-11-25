//
//  PresentationExtensions.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-12.
//

import Foundation

extension User {
    var toStringRepresentation: String {
        "\(self.username ?? "err user")"
    }
}

extension Currency {
    var toStringRepresentation: String {
        return "\(self.prefix ?? "err") \(self.symbol ?? "err")"
    }
}

extension PaymentMethod {
    var toStringRepresentation: String {
        "\(self.name ?? "err")"
    }
}

extension Decimal {
    var toStringRepresentation: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        let number = NSDecimalNumber(decimal: self)
        return formatter.string(from: number) ?? "Error"
    }
}

extension Date {
    var toStringRepresentation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm EEEE"
        return formatter.string(from: self)
    }
}


extension Tag {
    var toStringRepresentation: String {
        return self.name ?? "err"
    }
}

extension Payable {
    var toStringRepresentation: String {
        return self.tag?.name ?? "err"
    }
}

extension RatedPayable {
    var toStringRepresentation: String {
        return self.tag?.name ?? "err"
    }
}

extension Bill {
    var name: String {
        "\(self.tag?.toStringRepresentation ?? "err") \(self.associatedTag == nil ? "" : "- \(self.associatedTag!.toStringRepresentation)")"
    }
    
    var itemSnapshot: String {
        var snapshotString = ""
        var first = true
        if let items = self.items?.allObjects as? [BillItem] {
            items.sorted { lhs, rhs in
                lhs.order < rhs.order
            }
        }
        return snapshotString
    }
}

extension BillItem {
    var toStringRepresentation: String {
        if self.is_rated {
            if let originalName = self.ratedPayable?.tag?.name {
                if self.name == originalName {
                    return name ?? "err"
                } else {
                    return "\(name ?? "err") (now: \(originalName))"
                }
            } else {
                return "\(name ?? "err") (Deleted)"
            }
        } else {
            if let originalName = self.payable?.tag?.name {
                if self.name == originalName {
                    return name ?? "err"
                } else {
                    return "\(name ?? "err") (now: \(originalName))"
                }
            } else {
                return "\(name ?? "err") (Deleted)"
            }
        }
    }
}

