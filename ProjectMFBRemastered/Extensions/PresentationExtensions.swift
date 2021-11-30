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
    
    var dateStringRepresentation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd EEEE"
        return formatter.string(from: self)
    }
    
    var timeStringRepresentation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
    }
    
    var simpleStringRepresentation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd EEEE"
        return formatter.string(from: self)
    }
    
    var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
    
    func listGroupRepresentation(now: Date) -> String {
        "\(yearString == now.yearString ? "" : "\(yearString)-")\(simpleStringRepresentation)"
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
        var snapshotString = ""
        let maxCount = 1
        var count = 0
        if let total = self.total?.total as Decimal?, total > 0 {
            snapshotString += "Carried-on total"
            count += 1
        }
        if let items = self.items?.allObjects as? [BillItem] {
            let orderedItems = items.sorted()
            let maxItemsCount = orderedItems.count + count
            for item in orderedItems {
                if count > 0 && count < maxItemsCount {
                    snapshotString += ", "
                }
                snapshotString += item.toStringRepresentation
                if count > maxCount {
                    if maxItemsCount > count {
                        let diff = maxItemsCount - count
                        snapshotString += "... and \(diff) more item\(diff < 2 ? "" : "s")"
                    }
                    break
                }
                count += 1
            }
        }
        if snapshotString == "" {
            return "Preview Unavailable"
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

extension BillPayment {
    var toStringRepresentation: String {
        "\(self.paymentMethod?.toStringRepresentation ?? "err") \(self.currency?.toStringRepresentation ?? "err")"
    }
}
