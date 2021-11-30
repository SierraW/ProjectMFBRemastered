//
//  CurrencyPickerView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-25.
//

import SwiftUI

struct CurrencyPickerView: View {
    enum Presentation {
        case full
        case normal
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Currency.name, ascending: true)],
        animation: .default)
    private var fetchedCurrencies: FetchedResults<Currency>
    
    @State private var selectedCurrencyIndex = -1
    
    @State private var allowNullValue = false
    
    @State private var disabled = false
    
    @State var presentation: Presentation = .normal
    
    var onChange: (Currency) -> Void
    
    var currencies: [Currency] {
        fetchedCurrencies.map({$0})
    }
    
    var body: some View {
        Picker("", selection: $selectedCurrencyIndex) {
            if allowNullValue || selectedCurrencyIndex == -1 {
                Text("Not Set").tag(-1)
            }
            ForEach(currencies.indices, id: \.self) {index in
                Text(presentation == .normal ? currencies[index].toStringRepresentation : currencies[index].name ?? "err").tag(index)
            }
        }
        .pickerStyle(.menu)
        .onChange(of: selectedCurrencyIndex, perform: { newValue in
            if allowNullValue || newValue >= 0 {
                onChange(currencies[newValue])
            }
        })
        .disabled(disabled)
    }
    
    func presentation(_ value: Presentation) -> CurrencyPickerView {
        self.presentation = value
        return self
    }
    
    func allowNull() -> CurrencyPickerView {
        self.allowNullValue = true
        return self
    }
    
    func disabled(_ disabled: Bool) -> CurrencyPickerView {
        self.disabled = disabled
        return self
    }
}

struct CurrencyPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyPickerView(onChange: { _ in
            
        })
    }
}
