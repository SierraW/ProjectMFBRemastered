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
    
    @State var showPayableRatedPayableListView = false
    
    var body: some View {
        switch data.viewState {
        case .bill:
            billView
                .sheet(isPresented: $showPayableRatedPayableListView) {
                    PayableListView(dismissOnExit: true) { payable in
                        data.addPayable(payable)
                    }
                }

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
            List(data.items.indices, id:\.self) { index in
                getItemViewCell(data.items[index])
                    .contextMenu(menuItems: {
                        Button(role: .destructive) {
                            data.removePayable(index)
                        } label: {
                            Text("Delete")
                        }

                        
                        Button(role: .destructive) {
                            data.removePayable(index, all: true)
                        } label: {
                            Text("Delete All")
                        }

                    })
            }
            HStack {
                VStack {
                    if let timestamp = data.openTimestamp {
                        HStack {
                            Text("Start Time")
                            Text(timestamp.toStringRepresentation)
                        }
                    }
                    HStack {
                        Text("State")
                        Text(data.viewState == .completed ? "Completed" : "Active")
                    }
                }
                Spacer()
                VStack {
                    HStack {
                        Text("Subtotal")
                        Text(appData.majorCurrency.toStringRepresentation)
                        Text(data.subtotal.toStringRepresentation)
                    }
                    HStack {
                        Text("Discount")
                        Text(appData.majorCurrency.toStringRepresentation)
                        Text(data.discount.toStringRepresentation)
                    }
                    HStack {
                        Text("Tax & Service")
                        Text(appData.majorCurrency.toStringRepresentation)
                        Text(data.taxAndService.toStringRepresentation)
                    }
                    HStack {
                        Text("Total")
                        Text(appData.majorCurrency.toStringRepresentation)
                        Text(data.total.toStringRepresentation)
                    }
                }
            }
            
            HStack {
                Button {
                    showPayableRatedPayableListView = true
                } label: {
                    Text("Add")
                }
                Spacer()
                Button {
                    //
                } label: {
                    Text("Pay")
                }
            }
        }
        .navigationTitle(data.name)
    }
    
    var originalBillReviewView: some View {
        Text("bill view")
    }
    
    var splitByPayableView: some View {
        Text("bill view")
    }
    
    var splitByAmountView: some View {
        Text("bill view")
    }
    
    var completedView: some View {
        Text("bill view")
    }
    
    func getItemViewCell(_ item: BillItem) -> some View {
        HStack {
            Text(item.toStringRepresentation)
            Spacer()
            Text("count: \(item.count)")
            if let amount = item.subtotal as Decimal? {
                Text(appData.majorCurrency.toStringRepresentation)
                Text(amount.toStringRepresentation)
                    .frame(width: 50)
            }
        }
        .contentShape(Rectangle())
    }
}
