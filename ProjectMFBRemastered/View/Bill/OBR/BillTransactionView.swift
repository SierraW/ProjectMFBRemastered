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
    @State var showSBPMenu = false
    
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
    
    var body: some View {
        VStack {
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
                            Text("Submit Payment")
                        }
                    }
                }
            }
            totalsSectionView
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Color(UIColor.systemBackground)))
                .padding(.horizontal)
                .padding(.bottom)
        }
        .sheet(isPresented: $showSBAMenu, content: {
            BillSplitByAmountWizardView()
                .environmentObject(appData)
                .environmentObject(data)
        })
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Review Bill")
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
                            showSBPMenu.toggle()
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
    }
    
    var reviewSectionView: some View {
        Section {
            HStack {
                Text(data.controller.bill.toStringRepresentation)
                Spacer()
                Text(appData.majorCurrency.toStringRepresentation)
                if let originalBalance = data.originalBalance {
                    Text(originalBalance.toStringRepresentation)
                        .frame(width: 60, alignment: .trailing)
                }
                
            }
            .contextMenu {
                Button {
                    //
                } label: {
                    Text("View Original Bill")
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
            NavigationLink {
                PayableListView(dismissOnExit: true) { payable in
                    data.addItem(payable, isAddOn: true)
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
                        data.setComplete()
                        onExit()
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
        HStack {
            if data.payments.isEmpty {
                Spacer()
            }
            VStack {
                HStack {
                    Spacer()
                    Text("Subtotal")
                    Text(appData.majorCurrency.toStringRepresentation)
                    Text(data.subtotal.toStringRepresentation)
                        .frame(width: 60, alignment: .trailing)
                }
                HStack {
                    Spacer()
                    Text("Discount")
                    Text(appData.majorCurrency.toStringRepresentation)
                    Text(data.discount.toStringRepresentation)
                        .frame(width: 60, alignment: .trailing)
                }
                HStack {
                    Spacer()
                    Text("Tax & Service")
                    Text(appData.majorCurrency.toStringRepresentation)
                    Text(data.taxAndService.toStringRepresentation)
                        .frame(width: 60, alignment: .trailing)
                }
                HStack {
                    Spacer()
                    Text("Total")
                        .bold()
                    Text(appData.majorCurrency.toStringRepresentation)
                        .bold()
                    Text(data.total.toStringRepresentation)
                        .bold()
                        .frame(width: 60, alignment: .trailing)
                }
            }
            if !data.payments.isEmpty {
                Spacer()
                VStack {
                    HStack {
                        Spacer()
                        Text("Remaining")
                            .bold()
                        Text(appData.majorCurrency.toStringRepresentation)
                            .bold()
                        Text(remainingBalance.toStringRepresentation)
                            .bold()
                            .frame(width: 60, alignment: .trailing)
                    }
                    Spacer()
                }
                
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
