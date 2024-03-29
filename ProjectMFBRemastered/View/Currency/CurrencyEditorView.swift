//
//  CurrencyEditionView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-12.
//

import SwiftUI
import Combine

struct CurrencyEditorView: View {
    
    // model fields
    @State var name = ""
    @State var prefix = ""
    @State var symbol = ""
    @State var rate = "100"
    
    // model fields controls
    @State var confirmDelete = false
    
    // specialized controls
    @State var disableRateField = false
    
    // warning controls
    @State var duplicatedWarning = false
    @State var failedToSaveWarning = false
    
    var emptyFieldExist: Bool {
        name.isEmpty || prefix.isEmpty || symbol.isEmpty
    }
    
    var duplicatedObject: Bool {
        if currency?.name == name {
            return false
        }
        if currencies.contains(where: { currency in
            currency.name == name || currency.prefix == prefix
        }) {
            return true
        }
        return false
    }
    
    // variables
    var controller: CurrencyController
    
    var currency: Currency? = nil
    
    var currencies: [Currency]
    
    var onDelete: (Currency) -> Void
    
    var onExit: () -> Void
    
    var body: some View {
        Form {
            Section {
                HStack {
                    HStack {
                        Text("Name")
                        Spacer()
                    }
                    .frame(width: 70)
                    TextField("Requried", text: $name, onCommit:  {
                        name.trimmingWhitespacesAndNewlines()
                    })
                }
                HStack {
                    HStack {
                        Text("Prefix")
                        Spacer()
                    }
                    .frame(width: 70)
                    TextField("Requried", text: $prefix, onCommit:  {
                        prefix.trimmingWhitespacesAndNewlines()
                    })
                }
                HStack {
                    HStack {
                        Text("Symbol")
                        Spacer()
                    }
                    .frame(width: 70)
                    TextField("Requried", text: $symbol, onCommit:  {
                        symbol.trimmingWhitespacesAndNewlines()
                    })
                }
            } header: {
                Text("Currency")
            } footer: {
                VStack {
                    if duplicatedWarning {
                        HStack {
                            Text("Duplicated currency found.")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    if failedToSaveWarning {
                        HStack {
                            Text("Failed to save.")
                                .foregroundColor(.red)
                            Spacer()
                        }
                        
                    }
                }
            }
            
            if !disableRateField {
                Section {
                    HStack {
                        HStack {
                            if let currency = currencies.first(where: { currency in
                                currency.is_major
                            }) {
                                Text("\(currency.toStringRepresentation) 1 =")
                            } else {
                                Text("Rate")
                            }
                            Spacer()
                        }
                        DecimalField(placeholder: "Required", value: $rate)
                    }
                } header: {
                    Text("Exchange Rate")
                } footer: {
                    Text("Exchange rate must be greater than 0.")
                }
                
            }
            
            Section {
                Button {
                    save()
                } label: {
                    Text("Save")
                }
                .disabled(emptyFieldExist || failedToSaveWarning)
                if let currency = currency {
                    Button(role: .destructive) {
                        delete()
                    } label: {
                        if confirmDelete {
                            Text("Confirm Delete")
                        } else {
                            Text("Delete")
                        }
                        
                    }
                    .disabled(currency.is_major)
                }
            }
            
            Section {
                Button(role: .cancel) {
                    onExit()
                } label: {
                    Text("Cancel")
                }
                
            }
        }
        .onAppear {
            if let currency = currency {
                name = currency.name ?? ""
                prefix = currency.prefix ?? ""
                symbol = currency.symbol ?? ""
                rate = (currency.rate! as Decimal).toStringRepresentation
                if currency.is_major {
                    disableRateField = true
                }
            }
            if CurrencyController.getMajorCurrencyIndex(from: currencies) == nil {
                disableRateField = true
            }
        }
    }
    
    func delete() {
        if !confirmDelete {
            withAnimation {
                confirmDelete = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    confirmDelete = false
                }
                
            }
            return
        }
        if let currency = currency {
            onDelete(currency)
        } else {
            onExit()
        }
    }
    
    func save() {
        name.trimmingWhitespacesAndNewlines()
        prefix.trimmingWhitespacesAndNewlines()
        symbol.trimmingWhitespacesAndNewlines()
        if emptyFieldExist {
            return
        }
        if duplicatedObject {
            withAnimation {
                duplicatedWarning = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    duplicatedWarning = false
                }
            }
            return
        }
        
        if controller.modifyOrCreateIfNotExist(for: currency, name: name, prefix: prefix, symbol: symbol, rate: Decimal(string: rate) ?? 1) != nil {
            onExit()
            return
        }
        
        withAnimation {
            failedToSaveWarning = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                failedToSaveWarning = false
            }
        }
    }
}

