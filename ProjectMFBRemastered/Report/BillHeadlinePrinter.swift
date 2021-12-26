//
//  BillHeadLinePrinter.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-25.
//

import Foundation

struct BillHeadlinePrinter: BillReportPrinter {
    func extract(from bill: Bill) -> String {
        "\(bill.name)\nOpen: \(bill.openTimestamp?.toStringRepresentation ?? "NODATA")\nClose: \(bill.closeTimestamp?.toStringRepresentation ?? "ONHOLD")\nMajorCurrency: \(bill.majorCurrencyString ?? "NODATA")\n\(bill.additionalDescription?.isEmpty ?? true ? "" : "MESSAGE:\n\(bill.additionalDescription ?? "NODATA")\n")"
    }
}
