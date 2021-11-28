//
//  PaymentMethodPickerView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-25.
//

import SwiftUI

struct PaymentMethodPickerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PaymentMethod.name, ascending: true)],
        animation: .default)
    private var fetchedPaymentMethods: FetchedResults<PaymentMethod>
    
    @State private var selectedPaymentMethodIndex = -1
    
    @State private var allowNullValue = false
    
    @State private var disabled = false
    
    var assignInitialValue = false
    
    var onChange: (PaymentMethod) -> Void
    
    var paymentMethods: [PaymentMethod] {
        fetchedPaymentMethods.map({$0})
    }
    
    var body: some View {
        Picker("", selection: $selectedPaymentMethodIndex) {
            if allowNullValue || selectedPaymentMethodIndex == -1 {
                Text("Not Set").tag(-1)
            }
            ForEach(paymentMethods.indices, id: \.self) {index in
                Text(paymentMethods[index].toStringRepresentation).tag(index)
            }
        }
        .pickerStyle(.menu)
        .onChange(of: selectedPaymentMethodIndex, perform: { newValue in
            if allowNullValue || newValue >= 0 {
                onChange(paymentMethods[newValue])
            }
        })
        .disabled(disabled)
        .onAppear {
            if assignInitialValue, paymentMethods.count > 0 {
                selectedPaymentMethodIndex = 0
            }
        }
    }
    
    func allowNull() -> PaymentMethodPickerView {
        self.allowNullValue = true
        return self
    }
    
    func disabled(_ disabled: Bool) -> PaymentMethodPickerView {
        self.disabled = disabled
        return self
    }
}

struct PaymentMethodPickerView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentMethodPickerView { _ in
            
        }
    }
}
