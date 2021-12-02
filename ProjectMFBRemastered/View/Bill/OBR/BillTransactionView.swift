//
//  BillTransactionView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-25.
//

import SwiftUI

struct BillTransactionView: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var data: BillData
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var showEquivalentAmount = false
    
    @State var showSBAMenu = false
    
    @State var isLoading = false
    
    var controller: CurrencyController {
        CurrencyController(viewContext, staticContent: true)
    }
    
    var enableSplitBill = false
    
    var onExit: () -> Void
    
    var addOnsIndices: [Int] {
        data.items.indices.filter { index in
            data.items[index].is_add_on
        }
    }
    
    var remainingBalance: Decimal {
        let result = data.total - data.currentBillPaymentBalance
        return result > 0 ? result : 0
    }
    
    var remainingExchangedBalance: [Currency: Decimal] {
        controller.getExchangedCurrencyDict(majorCurrency: remainingBalance)
    }
    
    var body: some View {
        ZStack {
            Form {
                reviewSectionView
                addOnSectionView
                paymentSectionView
                if data.payments.count > 0 {
                    Section {
                        Button {
                            data.setComplete()
                            onExit()
                        } label: {
                            Text("Submit Bill")
                        }
                    }
                }
            }
            
            VStack {
                Spacer()
                totalsSectionView
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color(UIColor.systemBackground)))
                    .padding(.horizontal)
                    .padding(.bottom)
                    .frame(maxHeight: 170)
            }
        }
        .sheet(isPresented: $showSBAMenu, content: {
            BillSplitByAmountWizardView()
                .environmentObject(appData)
                .environmentObject(data)
        })
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Review Bill")
    }
    
    var reviewSectionView: some View {
        Section {
            BillListViewCell(bill: data.controller.bill, hideTotal: true, hideAddOnItems: true)
                .environmentObject(appData)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            if enableSplitBill {
                                Button {
                                    showSBAMenu.toggle()
                                } label: {
                                    Text("Split by totals")
                                }
                                Button {
                                    data.showSplitByProductView()
                                } label: {
                                    Text("Split by products")
                                }
                            } else {
                                Text("Split Bill Unavailable")
                            }
                        } label: {
                            Image(systemName: "rectangle.split.3x1.fill")
                        }
                    }
                }
        } footer: {
            HStack {
                Text("Bill State:")
                Text(data.completed ? "Completed" : "Active")
                    .bold()
                if enableSplitBill {
                    Spacer()
                    Button {
                        data.setInactive()
                        onExit()
                    } label: {
                        Text("Hold")
                    }
                    .padding(.trailing)
                    
                    Button {
                        data.originalBillResign()
                    } label: {
                        Text("Discard")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    var addOnSectionView: some View {
        Section {
            if isLoading {
                Color(UIColor.secondarySystemGroupedBackground)
                    .overlay(ProgressView())
                    .frame(height: 100)
                    .onAppear(perform: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isLoading = false
                        }
                    })
            } else {
                ForEach(addOnsIndices, id: \.self) { index in
                    BillItemViewCell(majorCurrency: appData.majorCurrency, billItem: data.items[index])
                    .contentShape(Rectangle())
                    .contextMenu {
                        Button(role: .destructive) {
                            data.removeItem(index, all: true)
                        } label: {
                            Text("Delete")
                        }

                    }
                }
            }
            NavigationLink {
                BillItemShoppingView(onSubmit: { payableDict, ratedPayableDict in
                    data.addItems(payableDict: payableDict, ratedPayableDict: ratedPayableDict, isAddOn: true)
                })
                    .environmentObject(appData)
                    .environmentObject(data)
                    .navigationTitle("Select items...")
                    .onDisappear {
                        isLoading = true
                    }
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "plus.circle")
                    Text("Add-On")
                    Spacer()
                }
                .foregroundColor(.blue)
            }
        } header: {
            Text("Add-On")
        }
    }
    
    var paymentSectionView: some View {
        Section {
            Group {
                ForEach(data.payments) { payment in
                    getPaymentViewCell(payment)
                        .contextMenu {
                            Button {
                                data.undoPayment(payment)
                            } label: {
                                Text("Undo Payment")
                            }

                        }
                }
            }
            .onTapGesture {
                showEquivalentAmount.toggle()
            }
            NavigationLink {
                TransactionView(amountDue: remainingBalance) { paymentMethod, currency, amount, majorCurrencyEquivalent, additionalDescription in
                    data.submitBillPayment(paymentMethod: paymentMethod, currency: currency, amount: amount, majorCurrencyEquivalent: majorCurrencyEquivalent, additionalDescription: additionalDescription)
                    if data.currentBillPaymentBalance >= data.total {
                        if enableSplitBill {
                            data.submitBill(appData)
                        } else {
                            data.setComplete()
                            onExit()
                        }
                    }
                }
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "plus.circle")
                    Text("Payment")
                    Spacer()
                }
                .foregroundColor(.blue)
            }
        } header: {
            Text("Payments")
        }
    }
    
    var totalsSectionView: some View {
        GeometryReader { geometry in
            HStack {
                VStack {
                    Text("Bill")
                        .padding(.bottom, 2)
                    Spacer()
                    HStack {
                        Text("Subtotal")
                        Text(appData.majorCurrency.toStringRepresentation)
                        Spacer()
                        Text(data.subtotal.toStringRepresentation)
                            .frame(width: 60, alignment: .trailing)
                    }
                    HStack {
                        Text("Discount")
                        Text(appData.majorCurrency.toStringRepresentation)
                        Spacer()
                        Text(data.discount.toStringRepresentation)
                            .frame(width: 60, alignment: .trailing)
                    }
                    HStack {
                        Text("Tax & Service")
                        Text(appData.majorCurrency.toStringRepresentation)
                        Spacer()
                        Text(data.taxAndService.toStringRepresentation)
                            .frame(width: 60, alignment: .trailing)
                    }
                    HStack {
                        Text("Total")
                            .bold()
                        Text(appData.majorCurrency.toStringRepresentation)
                            .bold()
                        Spacer()
                        Text(data.total.toStringRepresentation)
                            .bold()
                            .frame(width: 60, alignment: .trailing)
                    }
                    Spacer()
                }
                .frame(width: geometry.size.width / 2)
                Divider()
                VStack {
                    Text("Remaining")
                        .padding(.vertical, 2)
                    Spacer()
                    HStack {
                        Text("Due")
                        Text(appData.majorCurrency.toStringRepresentation)
                            .bold()
                        Text(remainingBalance.toStringRepresentation)
                            .bold()
                    }
                    .padding(2)
                    ForEach(remainingExchangedBalance.keys.sorted()) { key in
                        HStack {
                            Text(key.toStringRepresentation)
                            if let amount = remainingExchangedBalance[key] {
                                Text(amount.toStringRepresentation)
                            }
                        }
                        .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .frame(width: geometry.size.width / 2)
            }
        }
    }
    
    func getPaymentViewCell(_ payment: BillPayment) -> some View {
        HStack {
            if let paymentMethod = payment.paymentMethod {
                Text(paymentMethod.toStringRepresentation)
                Text("-")
            }
            if let currency = payment.currency {
                Text(currency.toStringRepresentation)
            }
            Spacer()
            if let amount = payment.amount as Decimal? {
                if payment.currency == appData.majorCurrency || showEquivalentAmount {
                    if payment.currency != appData.majorCurrency {
                        Text("Equiv.")
                    }
                    Text(appData.majorCurrency.toStringRepresentation)
                    
                    if let equiv = payment.majorCurrencyEquivalent as Decimal? {
                        Text(equiv.toStringRepresentation)
                            .frame(width: 60, alignment: .trailing)
                    } else if payment.currency == appData.majorCurrency {
                        Text(amount.toStringRepresentation)
                            .frame(width: 60, alignment: .trailing)
                    }
                    
                } else {
                    Text(appData.majorCurrency.toStringRepresentation)
                    Text(amount.toStringRepresentation)
                        .frame(width: 60, alignment: .trailing)
                }
            }
        }
    }
    
}
