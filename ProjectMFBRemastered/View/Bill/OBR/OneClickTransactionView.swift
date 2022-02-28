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
        data.remainingBalance <= 0
    }
    
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
                        let amount = getAmount(with: currency)
                        Button("\(paymentMethod.toStringRepresentation) - \(currency.toStringRepresentation) \(amount.toStringRepresentation)") {
                            onComplete(paymentMethod, currency, amount, data.remainingBalance)
                        }
                    }
                }
            }
        }
        
    }
    
    func getAmount(with currency: Currency) -> Decimal {
        currency.is_major ? data.remainingBalance : CurrencyController.exchangeFromMajorCurrency(currency: currency, amount: data.remainingBalance)
    }
}
