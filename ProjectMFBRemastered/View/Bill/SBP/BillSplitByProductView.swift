//
//  BillSplitByProductView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-28.
//

import SwiftUI

struct BillSplitByProductView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var data: BillData
    
    var allProducts: [Payable: Int] {
        extractProductFromBillItems(data.items)
    }
    
    var billedProducts: [Payable: Int] {
        var billItems = [BillItem]()
        func extractBillItemFromBill(_ bill: Bill) {
            if let items = bill.items?.allObjects as? [BillItem] {
                billItems.append(contentsOf: items.filter({ bi in
                    !bi.is_add_on
                }))
            }
            if let children = bill.children?.allObjects as? [Bill] {
                for child in children {
                    extractBillItemFromBill(child)
                }
            }
        }
        for child in data.children {
            extractBillItemFromBill(child)
        }
        return extractProductFromBillItems(billItems)
    }
    
    var products: [Payable: Int] {
        var products = allProducts
        let billedProducts = billedProducts
        
        for key in products.keys {
            let count = (billedProducts[key] ?? 0) + (cartProducts[key] ?? 0)
            if count > 0 {
                let newCount = (products[key] ?? 0) - count
                if newCount <= 0 {
                    products.removeValue(forKey: key)
                } else {
                    products[key] = newCount
                }
            }
        }
        return products
    }
    
    var children: [Bill] {
        data.children.sorted { lhs, rhs in
            (lhs.completed && lhs.combined) || lhs.completed || lhs.combined
        }
    }
    
    var disableSubmitButton: Bool {
        cartProducts.isEmpty
    }
    
    var ableToSubmit: Bool {
        children.first(where: {!$0.completed}) == nil && cartProducts.isEmpty && products.isEmpty
    }
    
    @State var cartProducts: [Payable: Int] = [:]
    @State var showCartView = false
    
    @State var selection: BillData? = nil
    @State var isLoading = false
    
    var onExit: () -> Void
    
    var body: some View {
        ZStack {
            let activeTransaction = Binding {
                selection != nil
            } set: {
                if !$0 {
                    selection = nil
                }
            }
            
            NavigationLink("", isActive: activeTransaction) {
                if let billData = selection {
                    BillTransactionView {
                        selection = nil
                        if ableToSubmit {
                            submit()
                        }
                    }
                    .environmentObject(appData)
                    .environmentObject(billData)
                    .environmentObject(PayableRatedPayableSelectionController(viewContext))
                    .onDisappear {
                        isLoading = true
                    }
                } else {
                    Text("Error Occurred")
                }
            }
            .hidden()
            
            if isLoading {
                Spacer()
                    .overlay(ProgressView())
                    .onAppear(perform: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            isLoading = false
                        }
                    })
                
            } else {
                Form {
                    remainingBillSection
                    billListSection
                    proceedPaymentSection
                }
                .zIndex(0)
                .navigationTitle("Split By Product")
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            data.sbpResign()
                        } label: {
                            Text("Discard")
                                .foregroundColor(.red)
                        }
                        
                    }
                })
            }
            
            if !cartProducts.isEmpty {
                SBPCartFloatingView(cartProducts: $cartProducts, isLoading: $isLoading)
                    .environmentObject(appData)
                    .environmentObject(data)
                    .transition(.moveAndFade)
            }
            
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    var remainingBillSection: some View {
        Section {
            if products.isEmpty {
                Text("Empty...")
                    .foregroundColor(.gray)
            }
            ForEach(products.keys.sorted()) { key in
                HStack {
                    Text(key.toStringRepresentation)
                    Spacer()
                    Text(appData.majorCurrency.toStringRepresentation)
                    Text(key.pricePerUnit.toStringRepresentation)
                    Text("x\(products[key] ?? 0)")
                        .font(.title3)
                        .bold()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    addToCart(key)
                }
            }
            
        } footer: {
            actionSection
        }
    }
    
    var billListSection: some View {
        Section {
            
            if children.isEmpty {
                Text("Empty...")
                    .foregroundColor(.gray)
            }
            ForEach(children) { bill in
                BillListViewCell(bill: bill)
                    .contextMenu(menuItems: {
                        Button(role: .destructive) {
                            data.controller.delete(bill)
                            data.reloadChildren()
                        } label: {
                            Text("Remove Bill")
                        }
                        
                        if bill.completed {
                            Button {
                                data.splitByAmountUndoPayments(bill: bill)
                            } label: {
                                Text("Undo Payments")
                            }
                        } else if bill.combined {
                            Button {
                                data.splitByAmountUngroup(bill: bill)
                                isLoading = true
                            } label: {
                                Text("Undo Group of \(bill.children?.count ?? 0)")
                            }
                        }
                    })
                    .listRowBackground(getSubBillViewCellColor(subBill: bill))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if bill.completed {
                            return
                        }
                        if selection?.controller.bill == bill {
                            selection = nil
                        } else {
                            selection = BillData(context: data.controller.viewContext, bill: bill)
                        }
                    }
            }
            
        } header: {
            Text("Bills")
        }
    }
    
    var proceedPaymentSection: some View {
        Section {
            DisclosureGroup("Proceed Payments (\(data.allPayments.count))") {
                ForEach(data.allPayments) { billPayment in
                    PaymentViewCell(billPayment: billPayment)
                }
            }
        }
    }
    
    var actionSection: some View {
        HStack {
            Spacer()
            if !data.controller.bill.isOnHold {
                Button {
                    data.setInactive()
                    onExit()
                } label: {
                    Text("Hold")
                        .foregroundColor(.red)
                }
                .padding(.horizontal)
            }
            if ableToSubmit {
                Button {
                    submit()
                } label: {
                    Text("Submit")
                        .bold()
                }
            }
        }
    }
    
    func addToCart(_ product: Payable) {
        cartProducts[product] = (cartProducts[product] ?? 0) + 1
        data.reloadChildren()
    }
    
    func extractProductFromBillItems(_ billItems: [BillItem]) -> [Payable : Int] {
        var products = [Payable: Int]()
        billItems.filter({ bi in
            !bi.is_rated
        }).forEach { bi in
            if let payable = bi.payable {
                products[payable] = (products[payable] ?? 0) + Int(bi.count)
            }
        }
        return products
    }
    
    func getSubBillViewCellColor(subBill: Bill) -> Color? {
        if subBill.completed {
            return Color.green
        } else {
            return nil
        }
    }
    
    func submit() {
        data.submitBill(appData)
        onExit()
    }
    
}
