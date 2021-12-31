//
//  ReportController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-26.
//

import Foundation
import CoreData

class ReportController: ModelController {
    func makeReport(_ selection: Set<Bill>) {
        if selection.isEmpty {
            return
        }
        let report = BillReport(context: viewContext)
        report.timestamp = Date()
        let reports = selection.map({$0})
        report.from = reports.first?.openTimestamp ?? Date()
        report.to = reports.last?.openTimestamp ?? Date()
        reports.forEach({report.addToBills($0)})
        managedSave()
    }
    
    func removeReport(_ report: BillReport) {
        viewContext.delete(report)
    }
}
