//
//  PaymentMethodManagementView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-16.
//

import SwiftUI

struct PaymentMethodManagementView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PaymentMethod.name, ascending: true)],
        animation: .default)
    private var fetchPaymentMethods: FetchedResults<PaymentMethod>
    
    var paymentMethods: [PaymentMethod] {
        switch sortType {
        case .currency:
            return fetchPaymentMethods.sorted { lhs, rhs in
                lhs.assignedCurrency?.name ?? "" < rhs.assignedCurrency?.name ?? ""
            }
        default:
            return fetchPaymentMethods.map({$0})
        }
    }
    
    var controller: PaymentMethodController {
        PaymentMethodController(viewContext)
    }
    
    @State var editingPaymentMethodIndex: Int? = nil
    
    @State var sortType: SortType = .name
    
    enum SortType: String, CaseIterable {
        case name = "Name"
        case currency = "Currency"
    }
    
    var body: some View {
        Form {
            Section {
                ForEach(paymentMethods.indices, id:\.self) { index in
                    HStack {
                        Text(paymentMethods[index].toStringRepresentation)
                        Spacer()
                        if let currency = paymentMethods[index].assignedCurrency {
                            Text("Assigned Currency:")
                            Text(currency.toStringRepresentation)
                                .frame(width: 60)
                        }
                    }
                    .contentShape(Rectangle())
                    .contextMenu {
                        Button(role: .destructive) {
                            controller.delete(paymentMethods[index])
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete")
                            }
                            
                        }
                    }
                    .onTapGesture {
                        if editingPaymentMethodIndex == nil {
                            editingPaymentMethodIndex = index
                        }
                    }
                }
            } header: {
                Text("Payment Method List")
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .sheet(item: $editingPaymentMethodIndex) { index in
            VStack {
                HStack {
                    Image(systemName: "chevron.down.circle")
                        .foregroundColor(.gray)
                        .frame(width:50)
                    Spacer()
                    Text("Payment Method Editor")
                        .bold()
                    Spacer()
                    Spacer()
                        .frame(width:50)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        editingPaymentMethodIndex = nil
                    }
                }
                .padding()
                PaymentMethodEditorView(controller: controller, paymentMethod: index == -1 ? nil : paymentMethods[index], paymentMethods: paymentMethods, onDelete: { paymentMethod in
                    withAnimation {
                        editingPaymentMethodIndex = nil
                        controller.delete(paymentMethod)
                    }
                }, onExit: {
                    withAnimation {
                        editingPaymentMethodIndex = nil
                    }
                })
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                        withAnimation {
                            editingPaymentMethodIndex = -1
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add new payment method")
                        }
                        
                    }
                    Spacer()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Menu {
                        ForEach(SortType.allCases, id:\.rawValue) { sortType in
                            Button {
                                self.sortType = sortType
                            } label: {
                                HStack {
                                    Text(sortType.rawValue)
                                    if self.sortType == sortType {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left.arrow.right")
                            Text("Alignment")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    
}

struct PaymentMethodManagementView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentMethodManagementView()
    }
}
