//
//  BillSplitByAmountView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-26.
//

import SwiftUI

struct BillSplitByAmountView: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var data: BillData
    
    @State var selection = Set<Bill>()
    
    @State var activeTransaction: BillData? = nil
    
    var children: [Bill] {
        data.children.sorted { lhs, rhs in
            (lhs.completed && lhs.combined) || lhs.completed || lhs.combined
        }
    }
    
    var ableToSubmit: Bool {
        children.first(where: {!$0.completed}) == nil
    }
    
    var onExit: () -> Void
    
    var body: some View {
        ZStack {
            let showBillTransactionView = Binding  {
                activeTransaction != nil
            } set: { newValue in
                if !newValue {
                    activeTransaction = nil
                }
            }
            
            NavigationLink("", isActive: showBillTransactionView) {
                if let billData = activeTransaction {
                    BillTransactionView {
                        activeTransaction = nil
                    }
                    .environmentObject(appData)
                    .environmentObject(billData)
                } else {
                    Text("Error Occurred")
                }
            }
            .hidden()
            
            VStack {
                splitByAmountFormView
                actionSection
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
        .navigationTitle("Split Bill")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    data.splitByAmountResign()
                } label: {
                    Text("Discard")
                        .foregroundColor(.red)
                        .bold()
                }
            }
        }

    }
    
    var splitByAmountFormView: some View {
        Form {
            NavigationLink {
                Text("Hello World!") // TODO: change this
            } label: {
                HStack {
                    Text("View Original Bill")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(appData.majorCurrency.toStringRepresentation)
                    Text(data.total.toStringRepresentation)
                }
            }
            
            
            
            
            Section {
                ForEach(children) { bill in
                    HStack {
                        Text(bill.toStringRepresentation)
                        Spacer()
                        if bill.combined {
                            Image(systemName: "g.square")
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                        Text(appData.majorCurrency.toStringRepresentation)
                        if let total = bill.total?.total as Decimal? {
                            Text(total.toStringRepresentation)
                        }
                    }
                    .contextMenu(menuItems: {
                        if bill.completed {
                            Button {
                                data.splitByAmountUndoPayments(bill: bill)
                            } label: {
                                Text("Undo Payments")
                            }
                        } else if bill.combined {
                            Button {
                                data.splitByAmountUngroup(bill: bill)
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
                        if selection.contains(bill) {
                            selection.remove(bill)
                        } else {
                            selection.insert(bill)
                        }
                    }
                }
                if !selection.isEmpty {
                    Button {
                        makePayment()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Make a Payment (\(selection.count))")
                            Spacer()
                        }
                    }

                }
            }
            
            ProceedPaymentSectionView()
                .environmentObject(data)

        }
    }
    
    var actionSection: some View {
        HStack {
            if !data.controller.bill.isOnHold {
                Button {
                    data.setInactive()
                    onExit()
                } label: {
                    Text("Hold")
                }
            }
            Spacer()
            if ableToSubmit {
                Button {
                    submit()
                } label: {
                    Text("Submit")
                }
            }
        }
    }
    
    func getSubBillViewCellColor(subBill: Bill) -> Color? {
        if subBill.completed {
            return Color.green
        } else if selection.contains(subBill) {
            return Color(UIColor.systemGray5)
        } else {
            return nil
        }
    }
    
    func makePayment() {
        if selection.count == 0 {
            return
        } else if selection.count == 1{
            if let bill = selection.first {
                activeTransaction = BillData(context: data.controller.viewContext, bill: bill)
            }
            selection.removeAll()
            return
        }
        let newBill = data.controller.createChildBill()
        let newBillTotal = data.controller.createBillTotal(for: newBill)
        var newTotal: Decimal = 0
        var newDiscountableTotal: Decimal = 0
        
        for bill in selection {
            bill.parent = newBill
            if let billTotal = bill.total {
                if let discountableTotal = billTotal.discountableTotal as Decimal? {
                    newDiscountableTotal += discountableTotal
                }
                if let total = billTotal.total as Decimal? {
                    newTotal += total
                }
            }
            
        }
        selection.removeAll()
        
        newBill.originalBalance = NSDecimalNumber(decimal: newTotal)
        newBillTotal.total = NSDecimalNumber(decimal: newTotal)
        newBillTotal.discountableTotal = NSDecimalNumber(decimal: newDiscountableTotal)
        
        data.controller.managedSave()
        
        data.reloadChildren()
        
        activeTransaction = BillData(context: data.controller.viewContext, bill: newBill)
    }
    
    func submit() {
        data.submitBill(appData)
    }
}
