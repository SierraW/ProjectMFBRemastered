//
//  OneClickTransactionView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-30.
//

import SwiftUI

struct OneClickTransactionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var data: BillData
    
    var controller: PaymentMethodController {
        PaymentMethodController(viewContext)
    }
    var paymentMethods: [PaymentMethod] {
        controller.fetchPaymentMethods()
    }
    
    var disabled: Bool {
        amountDue <= 0
    }
    
    var amountDue: Decimal
    
    var onComplete: (PaymentMethod, Currency, Decimal, Decimal) -> Void
    
    var body: some View {
        if disabled {
            HStack(alignment: .center) {
                Spacer()
                Image(systemName: "nosign")
                Text("SpeedPay™")
                Spacer()
            }
            .foregroundColor(.gray)
        } else {
            HStack(alignment: .center) {
                Spacer()
                Image(systemName: "hand.tap.fill")
                Text("SpeedPay™")
                Spacer()
            }
            .contextMenu {
                ForEach(paymentMethods) { paymentMethod in
                    if let currency = paymentMethod.assignedCurrency {
                        Button("\(paymentMethod.toStringRepresentation) - \(currency.toStringRepresentation) \(getAmount(with: currency).toStringRepresentation)") {
                            onComplete(paymentMethod, currency, currency.is_major ? amountDue : CurrencyController.exchangeFromMajorCurrency(currency: currency, amount: amountDue), amountDue)
                        }
                    }
                }
            }
        }
        
    }
    
    func getAmount(with currency: Currency) -> Decimal {
        currency.is_major ? amountDue : CurrencyController.exchangeFromMajorCurrency(currency: currency, amount: amountDue)
    }
}
