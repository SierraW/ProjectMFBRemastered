//
//  BillTransactionView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-25.
//

import SwiftUI

struct BillTransactionView: View {
    enum SplitMode {
        case full
        case amountOnly
        case none
    }
    
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var data: BillData
    @EnvironmentObject var shoppingData: PayableRatedPayableSelectionController
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var showEquivalentAmount = false
    
    @State var showSBAMenu = false
    
    var controller: CurrencyController {
        CurrencyController(viewContext, staticContent: true)
    }
    
    var splitMode: SplitMode = .none
    
    var onExit: () -> Void
    
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
                Spacer()
                    .frame(height: 150)
                    .listRowBackground(Color(uiColor: .systemGroupedBackground))
            }
            
            VStack {
                Spacer()
                totalsSectionView
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color(UIColor.secondarySystemGroupedBackground)))
                    .padding(.horizontal)
                    .padding(.bottom)
                    .frame(height: 150)
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
            BillListViewCell(bill: data.controller.bill, hideTotal: true, isExpanded: true, hideAddOnItems: true)
                .environmentObject(appData)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            if splitMode == .amountOnly || splitMode == .full {
                                Button {
                                    showSBAMenu.toggle()
                                } label: {
                                    Text("Split by totals")
                                }
                            }
                            if splitMode == .full {
                                Button {
                                    data.showSplitByProductView()
                                } label: {
                                    Text("Split by products")
                                }
                            }
                            if splitMode == .none {
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
                if splitMode != .none {
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
            ForEach(data.items, id: \.smartId) { item in
                if item.is_add_on {
                    BillItemViewCellV2(selection: .constant([BillItem:Int]()), billItem: item)
                        .environmentObject(appData)
                        .environmentObject(data)
                }
            }
            NavigationLink {
                BillItemShoppingViewV2(mode: .ratedPayable, controller: shoppingData) { payableDict, ratedPayableDict in
                    data.addItems(payableDict: payableDict, ratedPayableDict: ratedPayableDict, isAddOn: true)
                }
                .environmentObject(appData)
                .environmentObject(data)
                .navigationTitle("Select")
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                    Text("Item")
                    Image(systemName: "circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(shoppingData.status == .loading ? .yellow : shoppingData.status == .succeeded ? .green: .red)
                    Spacer()
                }
                .foregroundColor(.blue)
            }
            .disabled(shoppingData.status != .succeeded)
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
                            Button(role: .destructive) {
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
                    autoSubmit()
                }
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "dollarsign.circle")
                    Text("Payment")
                    Spacer()
                }
                .foregroundColor(.green)
            }
            OneClickTransactionView(amountDue: remainingBalance) {
                if $2 > 0 {
                    data.submitBillPayment(paymentMethod: $0, currency: $1, amount: $2, majorCurrencyEquivalent: $3, additionalDescription: nil)
                    autoSubmit()
                }
            }
            .environmentObject(data)
        } header: {
            Text("Payments")
        }
    }
    
    var totalsSectionView: some View {
        GeometryReader { geometry in
            HStack {
                VStack {
                    ForEach(remainingExchangedBalance.keys.sorted()) { key in
                        HStack {
                            Text(key.toStringRepresentation)
                            Spacer()
                            if let amount = remainingExchangedBalance[key] {
                                HStack {
                                    Spacer()
                                    Text(amount.toStringRepresentation)
                                }
                                .frame(width: 70)
                            }
                        }
                        .foregroundColor(.gray)
                    }
                    HStack {
                        Spacer()
                        Text("Due")
                            .bold()
                        Text(appData.majorCurrency.toStringRepresentation)
                            .bold()
                        Text(remainingBalance.toStringRepresentation)
                            .bold()
                    }
                }
                .padding(.trailing)
                .frame(width: geometry.size.width / 2)
                Divider()
                VStack {
                    HStack {
                        Text("Subtotal")
                        Spacer()
                        Text(data.subtotal.toStringRepresentation)
                    }
                    HStack {
                        Text("Discount")
                        Spacer()
                        Text(data.discount.toStringRepresentation)
                    }
                    HStack {
                        Text("Tax & Service")
                        Spacer()
                        Text(data.taxAndService.toStringRepresentation)
                    }
                    HStack {
                        Text("Total")
                            .bold()
                        Text(appData.majorCurrency.toStringRepresentation)
                            .bold()
                        Spacer()
                        Text(data.total.toStringRepresentation)
                            .bold()
                    }
                }
                .padding(.horizontal)
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
                    Text(amount.toStringRepresentation)
                        .frame(width: 60, alignment: .trailing)
                }
            }
        }
    }
    
    func autoSubmit() {
        if data.currentBillPaymentBalance >= data.total {
            if splitMode != .none {
                data.submitBill(appData)
            } else {
                data.setComplete()
                onExit()
            }
        }
    }
}
