//
//  PaymentMethodEditorView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-16.
//

import SwiftUI

struct PaymentMethodEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Currency.name, ascending: true)],
        animation: .default)
    private var fetchedCurrencies: FetchedResults<Currency>
    var currencies: [Currency] {
        fetchedCurrencies.map({$0})
    }
    
    @State var name = ""
    @State var selectedCurrencyIndex = -1
    @State var confirmDelete = false
    
    @State var duplicatedWarning = false
    @State var failedToSaveWarning = false
    
    var emptyFieldExist: Bool {
        name.isEmpty
    }
    
    var duplicatedObject: Bool {
        if paymentMethod?.name == name {
            return false
        }
        if paymentMethods.contains(where: { paymentMethod in
            paymentMethod.name == name
        }) {
            return true
        }
        return false
    }
    
    var controller: PaymentMethodController
    
    var paymentMethod: PaymentMethod? = nil
    
    var paymentMethods: [PaymentMethod]
    
    var onDelete: (PaymentMethod) -> Void
    
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
            } header: {
                Text("Payment Method")
            } footer: {
                VStack {
                    if duplicatedWarning {
                        HStack {
                            Text("Duplicated payment method name found.")
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
            
            Section {
                HStack {
                    Text("Assigned Currency")
                    Spacer()
                    Picker("", selection: $selectedCurrencyIndex) {
                        Text("Not Set").tag(-1)
                        ForEach(currencies.indices, id: \.self) { index in
                            Text(currencies[index].toStringPresentation).tag(index)
                        }
                    }
                    .pickerStyle(.menu)
                }
            } header: {
                Text("Support Fields")
            }
            
            Section {
                Button {
                    save()
                } label: {
                    Text("Save")
                }
                .disabled(emptyFieldExist || failedToSaveWarning)
                if let _ = paymentMethod {
                    Button(role: .destructive) {
                        delete()
                    } label: {
                        if confirmDelete {
                            Text("Confirm Delete")
                        } else {
                            Text("Delete")
                        }
                        
                    }
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
            if let paymentMethod = paymentMethod {
                name = paymentMethod.name ?? ""
                
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
        if let currency = paymentMethod {
            onDelete(currency)
        } else {
            onExit()
        }
    }
    
    func save() {
        name.trimmingWhitespacesAndNewlines()
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
        if controller.modifyOrCreateIfNotExist(paymentMethod, name: name, assignmentCurrency: selectedCurrencyIndex < 0 ? nil : currencies[selectedCurrencyIndex]) {
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
