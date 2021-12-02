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
    
    @State var isLoading = false
    
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
                if isLoading {
                    Color(UIColor.systemBackground)
                        .overlay(ProgressView())
                        .onAppear(perform: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isLoading = false
                            }
                        })
                } else {
                    ForEach(data.items.indices, id:\.self) { index in
                        BillItemViewCell(majorCurrency: appData.majorCurrency, billItem: data.items[index])
                            .listRowBackground(index + 1 == data.items.count ? Color.gray : nil)
                            .contentShape(Rectangle())
                            .contextMenu(menuItems: {
//                                Button {
//                                    data.addItem(index)
//                                } label: {
//                                    Text("Add One")
//                                }
//
//                                Button {
//                                    data.removeItem(index)
//                                } label: {
//                                    Text("Remove One")
//                                }
                                
                                Button(role: .destructive) {
                                    isLoading = true
                                    data.removeItem(index, all: true)
                                } label: {
                                    Text("Remove All")
                                }
                                
                            })
                    }
                }
                
                NavigationLink {
                    BillItemShoppingView(onSubmit: { payableDict, ratedPayableDict in
                        isLoading = true
                        data.addItems(payableDict: payableDict, ratedPayableDict: ratedPayableDict)
                    })
                        .environmentObject(appData)
                        .environmentObject(data)
                        .navigationTitle("Select items...")
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
                Button {
                    //
                } label: {
                    Text(data.associatedTag == nil ? "Add Tag" : data.associatedTag!.toStringRepresentation)
                }
                .disabled(true)

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
            onExit()
        }
        .environmentObject(appData)
        .environmentObject(data)
    }
    
    var splitByPayableView: some View {
        BillSplitByProductView {
            onExit()
        }
        .environmentObject(appData)
        .environmentObject(data)
    }
    
    var splitByAmountView: some View {
        BillSplitByAmountView {
            onExit()
        }
        .environmentObject(appData)
        .environmentObject(data)
    }
    
    var completedView: some View {
        HistoryBillPreview()
            .environmentObject(appData)
            .environmentObject(data)
    }
}
