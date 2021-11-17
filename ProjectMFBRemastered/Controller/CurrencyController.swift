//
//  CurrencyController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-12.
//

import Foundation
import CoreData

class CurrencyController: ModelController {
    
    func fetchCurrencies() -> [Currency] {
        let fetchRequest: NSFetchRequest<Currency> = Currency.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Currency.is_major, ascending: false), NSSortDescriptor(keyPath: \Currency.name, ascending: false)]
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result
        } catch {
            print("Fetch error in Payment Method Controller")
        }
        return []
    }
    
    func getMajorCurrency() -> Currency? {
        CurrencyController.getMajorCurrency(from: viewContext)
    }
    
    static func getMajorCurrencyIndex(from currencies: [Currency]) -> Int? {
        currencies.firstIndex { currency in
            currency.is_major
        }
    }
    
    static func getMajorCurrency(from currencies: [Currency]) -> Currency? {
        currencies.first { currency in
            currency.is_major
        }
    }
    
    static func getMajorCurrency(from viewContext: NSManagedObjectContext) -> Currency? {
        let fetchRequest: NSFetchRequest<Currency> = Currency.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "is_major == YES")
        do {
            let majorCurrency = try viewContext.fetch(fetchRequest).first
            return majorCurrency
        } catch {
            print("Error fetching major currency")
        }
        return nil
    }
    
    static func exchangeToMajorCurrency(currency: Currency, amount: Decimal) -> Decimal {
        if let rate = currency.rate as Decimal?, !currency.is_major {
            return (amount / rate).rounded(toPlaces: 2)
        }
        return amount
    }
    
    static func exchangeFromMajorCurrency(currency: Currency, amount: Decimal) -> Decimal {
        if let rate = currency.rate as Decimal?, !currency.is_major {
            return (amount * rate).rounded(toPlaces: 2)
        }
        return amount
    }
    
    
    func assignMajorCurrency(with newMajorCurrency: Currency, from currencies: [Currency]) {
        for currency in currencies {
            currency.is_major = false
        }
        newMajorCurrency.is_major = true
        managedSave()
    }
    
    func modifyOrCreateIfNotExist(for currency: Currency?, name: String, prefix: String, symbol: String, rate: Decimal) -> Bool {
        if let currency = currency {
            return modify(currency, name: name, prefix: prefix, symbol: symbol, rate: rate)
        } else {
            return modify(Currency(context: viewContext), name: name, prefix: prefix, symbol: symbol, rate: rate)
        }
    }
    
    func modify(_ currency: Currency, name: String, prefix: String, symbol: String, rate: Decimal) -> Bool {
        if let oldName = currency.name, oldName != name {
            if fetchCurrencies().contains(where: { currency in
                currency.name == name
            }) {
                return false
            }
        }
        if name.isEmpty || prefix.isEmpty || symbol.isEmpty || rate <= 0  {
            return false
        }
        currency.name = name
        currency.prefix = prefix
        currency.symbol = symbol
        currency.rate = NSDecimalNumber(decimal: rate)
        
        managedSave()
        return true
    }
    
    func delete(_ currency: Currency) {
        if currency.is_major {
            return
        }
        
        viewContext.delete(currency)
        
        managedSave()
    }
    
}