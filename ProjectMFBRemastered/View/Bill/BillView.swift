//
//  BillView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-20.
//

import SwiftUI

struct BillView: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var data: BillData
    
    var onExit: () -> Void
    
    var body: some View {
        switch data.viewState {
        case .bill:
            billView
        case .originalBillReview:
            originalBillReviewView
        case .splitByPayable:
            splitByPayableView
        case .splitByAmount:
            splitByAmountView
        case .completed:
            completedView
        }
    }
    
    var billView: some View {
        VStack {
            if data.items.count == 0 {
                Text("Empty Bill")
                    .foregroundColor(.gray)
                    .bold()
            }
            List {
                ForEach(data.items.indices, id:\.self) { index in
                    BillItemViewCell(majorCurrency: appData.majorCurrency, billItem: data.items[index])
                        .contentShape(Rectangle())
                        .contextMenu(menuItems: {
                            Button {
                                data.addItem(index)
                            } label: {
                                Text("Add One")
                            }
                            
                            Button {
                                data.removeItem(index)
                            } label: {
                                Text("Remove One")
                            }
                            
                            Button(role: .destructive) {
                                data.removeItem(index, all: true)
                            } label: {
                                Text("Remove All")
                            }

                        })
                }
                NavigationLink {
                    PayableListView(dismissOnExit: true) { payable in
                        data.addItem(payable)
                    }
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "plus.circle")
                        Text("Item")
                        Spacer()
                    }
                    .foregroundColor(.blue)
                }
            }
           
            HStack {
                VStack {
                    if let timestamp = data.openTimestamp {
                        HStack {
                            Text(timestamp.toStringRepresentation)
                            Spacer()
                        }
                    }
                    HStack {
                        Text("State:")
                        Text(data.viewState == .completed ? "Completed" : "Active")
                        Spacer()
                    }
                }
                Spacer()
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
            }
            .padding(.horizontal)
            HStack {
                NavigationLink {
                    BillItemListView { _, _ in
                        //
                    }
                } label: {
                    Text("Add")
                }
                Spacer()
                Button {
                    data.originalBillSubmit()
                } label: {
                    Text("Submit")
                }
            }
            .padding(.top, 5)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle(data.name)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    var originalBillReviewView: some View {
        BillTransactionView(enableSplitBill: true) {
            
        }
            .environmentObject(appData)
            .environmentObject(data)
    }
    
    var splitByPayableView: some View {
        Text("bill view")
    }
    
    var splitByAmountView: some View {
        BillSplitByAmountView()
            .environmentObject(appData)
            .environmentObject(data)
    }
    
    var completedView: some View {
        VStack {
            Text("bill view")
            Button {
                data.setInactive()
                onExit()
            } label: {
                Text("New...")
            }

        }
    }
}
