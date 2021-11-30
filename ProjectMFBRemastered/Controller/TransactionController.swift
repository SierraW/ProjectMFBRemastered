//
//  TransactionController.swift
//  ProjectMoneyFallsIntoBlackhole
//
//  Created by Yiyao Zhang on 2021-09-28.
//

import Foundation
import CoreData

class TransactionController: ModelController {
    
    var user: User
    var majorCurrency: Currency
    
    init(_ viewContext: NSManagedObjectContext, user: User, majorCurrency: Currency) {
        self.user = user
        self.majorCurrency = majorCurrency
        super.init(viewContext)
    }
    
    func makeTransaction(amount: Decimal, description additionalDescription: String?, paymentMethod: PaymentMethod, currency: Currency, tags: [Tag]?) -> Transaction {
        let transaction = Transaction(context: viewContext)
        let roundedAmount = amount.rounded(toPlaces: 2)
        transaction.amount = roundedAmount as NSDecimalNumber
        transaction.additionalDescription = additionalDescription
        transaction.paymentMethod = paymentMethod
        transaction.currency = currency
        transaction.user = user
        if let tags = tags {
            for tag in tags {
                transaction.addToTags(tag)
            }
        }
        transaction.timestamp = Date()
        return transaction
    }
    
    func transact(amount: Decimal, description additionalDescription: String?, paymentMethod: PaymentMethod, currency: Currency,  tags: [Tag]?) {
        let transaction = makeTransaction(amount: amount, description: additionalDescription, paymentMethod: paymentMethod, currency: currency, tags: tags)
        managedSave(for: transaction)
    }
    
    func managedSave(for transaction: Transaction) {
        do {
            try report(for: transaction)
            try viewContext.save()
        } catch {
            print("Error saving transaction within transaction controller.")
        }
    }
    
    func report(for transaction: Transaction) throws {
        let fetchRequest: NSFetchRequest<TransactionReport> = TransactionReport.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionReport.timestamp, ascending: false)]
        let lastReport = try viewContext.fetch(fetchRequest).first
        let today = Date()
        if let lastReport = lastReport, isSameDay(date1: today, date2: lastReport.timestamp!) {
            lastReport.lastModified = today
            transaction.report = lastReport
        } else {
            let newReport = TransactionReport(context: viewContext)
            newReport.timestamp = today
            newReport.lastModified = today
            transaction.report = newReport
        }
    }
    
    private func isSameDay(date1: Date, date2: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.day], from: date1, to: date2)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
}
