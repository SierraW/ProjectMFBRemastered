//
//  TransactionView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-25.
//

import SwiftUI

struct TransactionView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var additionalDescription = ""
    @State var paymentMethod: PaymentMethod? = nil
    @State var currency: Currency? = nil
    var disableCurrency: Bool {
        paymentMethod?.assignedCurrency != nil
    }
    
    @State var amount = ""
    
    @State var equivalentAmountStringList: [String] = []
    
    @State var warningEmptyPaymentMethod = false
    @State var warningEmptyCurrency = false
    
    var amountDue: Decimal? = nil
    var onSubmit: (PaymentMethod, Currency, Decimal, Decimal, String?) -> Void
    
    var body: some View {
        Form {
            if let _ = amountDue {
                balanceSectionView
            }
            paymentMethodAndCurrencySectionView
            amountSectionView
            additionalDescriptionSectionView
            actionSectionView
        }
        .navigationBarTitle("Transaction")
        .onAppear {
            if let amountDue = amountDue {
                amount = amountDue.toStringRepresentation
                let controller = CurrencyController(viewContext)
                equivalentAmountStringList = controller.getExchangeStringList(majorCurrency: amountDue)
            }
        }
    }
    
    var balanceSectionView: some View {
        Section {
            HStack {
                Text("Amount Due")
                Spacer()
                Text(appData.majorCurrency.toStringRepresentation)
                Text(amountDue?.toStringRepresentation ?? "err")
            }
        } footer: {
            VStack {
                ForEach(equivalentAmountStringList) { amountString in
                    HStack {
                        Spacer()
                        Text(amountString)
                            .bold()
                    }
                }
            }
        }
    }
    
    var paymentMethodAndCurrencySectionView: some View {
        Section {
            HStack {
                Text("Payment Method")
                Spacer()
                PaymentMethodPickerView(assignInitialValue: true) { pm in
                    paymentMethod = pm
                    if let currency = pm.assignedCurrency {
                        setCurrency(currency)
                    }
                }
            }
            HStack {
                Text("Currency")
                Spacer()
                if disableCurrency {
                    Text(currency?.toStringRepresentation ?? "Err")
                } else {
                    CurrencyPickerView { cu in
                        setCurrency(cu)
                    }
                }
            }
        } footer: {
            VStack {
                if warningEmptyCurrency {
                    HStack {
                        Text("Payment Method Not Set")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                if warningEmptyPaymentMethod {
                    HStack {
                        Text("Currency Not Set")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
        }
    }
    
    var additionalDescriptionSectionView: some View {
        Section {
            DisclosureGroup {
                TextEditor(text: $additionalDescription)
            } label: {
                HStack {
                    Text("Description")
                    Spacer()
                }
            }
        }
    }
    
    var amountSectionView: some View {
        Section {
            HStack {
                Text("Amount")
                Spacer()
                if let currency = currency {
                    Text(currency.toStringRepresentation)
                }
                DecimalField(placeholder: "", textAlignment: .trailing, value: $amount) { _ in
                    
                }
                .frame(width: 70)
            }
        } footer: {
            if let currency = currency, !currency.is_major, let amount = Decimal(string: amount) {
                HStack {
                    Spacer()
                    Text(appData.majorCurrency.toStringRepresentation)
                    Text(CurrencyController.exchangeToMajorCurrency(currency: currency, amount: amount).toStringRepresentation)
                        .bold()
                }
                .foregroundColor(.gray)
            }
            
        }
    }
    
    var actionSectionView: some View {
        Section {
            Button {
                submit()
            } label: {
                HStack {
                    Spacer()
                    Text("Submit")
                    Spacer()
                }
            }
            Button(role: .destructive) {
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack {
                    Spacer()
                    Text("Cancel")
                    Spacer()
                }
            }
        }
    }
    
    func setCurrency(_ currency: Currency?) {
        if currency == self.currency {
            return
        }
        if let currency = currency, let amount = Decimal(string: amount), let oldCurrency = self.currency, currency.is_major || oldCurrency.is_major {
            DispatchQueue.main.async {
                if currency.is_major {
                    self.amount = CurrencyController.exchangeToMajorCurrency(currency: oldCurrency, amount: amount).toStringRepresentation
                } else if oldCurrency.is_major {
                    self.amount = CurrencyController.exchangeFromMajorCurrency(currency: currency, amount: amount).toStringRepresentation
                }
            }
        }
        self.currency = currency
    }
    
    func submit() {
        if let paymentMethod = paymentMethod, let currency = currency, let amount = Decimal(string: amount) {
            presentationMode.wrappedValue.dismiss()
            var majorCurrencyEquivalent: Decimal = amount
            if !currency.is_major {
                majorCurrencyEquivalent = CurrencyController.exchangeToMajorCurrency(currency: currency, amount: amount)
            }
            onSubmit(paymentMethod, currency, amount, majorCurrencyEquivalent, additionalDescription == "" ? nil : additionalDescription)
        }
    }
}
