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
    
    var toStringRepresentation: String {
        if let items = self.items?.allObjects as? [BillItem], items.filter({!$0.is_add_on}).count > 0 {
            var snapshotString = ""
            let maxCount = 1
            var count = 1
            let orderedItems = items.filter({ bi in
                !bi.is_add_on
            }).sorted()
            for item in orderedItems {
                snapshotString += item.toStringRepresentation
                if count > maxCount {
                    if orderedItems.count > count {
                        let diff = orderedItems.count - count
                        snapshotString += "... and \(diff) more item\(diff < 2 ? "" : "s")"
                    }
                    
                    break
                } else if count < orderedItems.count {
                    snapshotString += ", "
                }
                count += 1
            }
            return snapshotString
        }
        return "Preview Unavailable"
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

extension BillPayment {
    var toStringRepresentation: String {
        "\(self.paymentMethod?.toStringRepresentation ?? "err") \(self.currency?.toStringRepresentation ?? "err")"
    }
}
