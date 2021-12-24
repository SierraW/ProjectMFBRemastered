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
    
    @State var isLoading = false
    
    var children: [Bill] {
        data.children.sorted { lhs, rhs in
            (lhs.completed && lhs.combined) || lhs.completed || lhs.combined
        }
    }
    
    var ableToSubmit: Bool {
        data.children.first(where: {!$0.completed}) == nil
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
                        if ableToSubmit {
                            submit()
                        }
                    }
                    .environmentObject(appData)
                    .environmentObject(billData)
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
                splitByAmountFormView
            }
            
            VStack {
                Spacer()
                SBAFloatingActionView(selection: $selection) {
                    makePayment()
                } onExit: {
                    onExit()
                }
                .environmentObject(appData)
                .environmentObject(data)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Split By Total")
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
            Section {
                BillListViewCell(bill: data.controller.bill, total: data.total)
                    .environmentObject(appData)
            } footer: {
                actionSection
            }
            
            
            Section {
                ForEach(children) { bill in
                    BillListViewCell(bill: bill)
                        .environmentObject(appData)
                        .contextMenu(menuItems: {
                            if bill.completed {
                                Button {
                                    data.splitByAmountUndoPayments(bill: bill)
                                    isLoading = true
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
                            withAnimation {
                                if selection.contains(bill) {
                                    selection.remove(bill)
                                } else {
                                    selection.insert(bill)
                                }
                            }
                            
                        }
                }
            }
            
            
            proceedPaymentSection
            
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
                    if ableToSubmit {
                        submit()
                    }
                } label: {
                    Text("Submit")
                        .bold()
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
        
        var rps = Set<RatedPayable>()
        
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
            if let ratedBillItems = bill.items?.allObjects as? [BillItem]{
                for ratedBillItem in ratedBillItems.filter({$0.is_rated}) {
                    if let ratedPayable = ratedBillItem.ratedPayable {
                        if !rps.contains(ratedPayable) {
                            rps.insert(ratedPayable)
                            let _ = data.controller.createBillItem(from: ratedBillItem, to: newBill)
                        }
                    }
                }
            }
            
        }
        selection.removeAll()
        
        newBill.isSubmitted = true
        newBillTotal.total = NSDecimalNumber(decimal: newTotal)
        newBillTotal.discountableTotal = NSDecimalNumber(decimal: newDiscountableTotal)
        
        data.controller.managedSave()
        
        data.reloadChildren()
        
        let billData = BillData(context: data.controller.viewContext, bill: newBill)
        
        billData.calculateRatedSubtotals()
        
        activeTransaction = billData
    }
    
    func submit() {
        data.submitBill(appData)
        onExit()
    }
}
