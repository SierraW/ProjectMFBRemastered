//
//  BillHeadLinePrinter.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-25.
//

import Foundation

struct BillHeadlinePrinter: BillReportPrinter {
    func extract(from bill: Bill) -> String {
        "\(bill.name)\nOpen: \(bill.openTimestamp?.toStringRepresentation ?? "NODATA")\nClosed: \(bill.closeTimestamp?.toStringRepresentation ?? "ON HOLD")\nMajorCurrency: \(bill.majorCurrencyString ?? "NODATA")\n"
    }
}
