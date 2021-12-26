//
//  ReportController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-25.
//

import Foundation

protocol BillReportPrinter {
    func extract(from bill: Bill) -> String
}

class BillReportPrintingController {
    private var printers: [BillReportPrinter] = []
    private var bills: [Bill]
    private var header = ""
    
    var toStringRepresentation: String {
        var resultString = "RECORDED BILL FROM \(bills.first?.openTimestamp?.toStringRepresentation ?? "ND") TO \(bills.last?.openTimestamp?.toStringRepresentation ?? "ND")\nTOTAL BILLS: \(bills.count)\n\(header)<= REPORT START\n"
        bills.forEach({
            for printer in printers {
                resultString.append(printer.extract(from: $0))
            }
        })
        resultString.append("<= REPORT END\nPrint Date: \(Date().toStringRepresentation)\n==============================")
        return resultString
    }
    
    init(bills: [Bill], printers: [BillReportPrinter] = []) {
        self.printers = printers
        self.bills = bills
    }
    
    func addPrinter(_ printer: BillReportPrinter) -> BillReportPrintingController {
        printers.append(printer)
        return self
    }
    
    func setHeaderCustomContent(_ header: String) -> BillReportPrintingController{
        self.header = header
        return self
    }
}


