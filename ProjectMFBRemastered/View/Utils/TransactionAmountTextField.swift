//
//  TransactionAmountTextField.swift
//  ProjectMoneyFallsIntoBlackhole
//
//  Created by Yiyao Zhang on 2021-10-01.
//

import SwiftUI
import Combine

class TransactionAmountTextFieldData: ObservableObject {
    @Published var amountString: String = ""
    @Published var amountError: Bool = false
    @Published var lastDecimal: Decimal = 0
    
    init(_ amount: Decimal? = nil) {
        if let amount = amount {
            amountString = amount.toStringPresentation
            lastDecimal = amount
        }
    }
    
    func commitAmountString() {
        withAnimation {
            if let amount = Decimal(string: amountString) {
                if amount < 0 {
                    amountString = (-amount).toStringPresentation
                } else {
                    amountString = amount.toStringPresentation
                }
            } else {
                amountString = lastDecimal.toStringPresentation
            }
        }
    }
    
    func retrieve() -> Decimal? {
        if let decimal = Decimal(string: amountString), decimal > 0 {
            return decimal
        } else {
            amountError = true
        }
        return nil
    }
    
}

struct TransactionAmountTextField: View {
    @EnvironmentObject var data: TransactionAmountTextFieldData
    
    var placeholder: String = ""
    var font: Font?
    var extraInfomations: ((Decimal) -> AnyView)?
    
    var body: some View {
        VStack {
            TextField(placeholder, text: $data.amountString, onCommit: {
                data.commitAmountString()
            })
                .onChange(of: data.amountString) { newValue in
                    data.amountError = false
                    if let decimal = Decimal(string: newValue) {
                        data.lastDecimal = decimal.rounded(toPlaces: 2)
                        if data.lastDecimal < 0 {
                            data.lastDecimal = -data.lastDecimal
                        }
                    }
                }
                .font(font)
                .overlay(Rectangle().stroke(Color.red, lineWidth: data.amountError ? 1 : 0))
                .multilineTextAlignment(.center)
            if let extraInfomations = extraInfomations {
                extraInfomations(data.lastDecimal)
            }
        }
        
    }
    
    
}

