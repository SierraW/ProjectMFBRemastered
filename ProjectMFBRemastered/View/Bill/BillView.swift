//
//  BillView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-20.
//

import SwiftUI

struct BillView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var data: BillData
    
    @State var isLoading = false
    @State var isShowSearchTagView = false
    
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
            if isLoading {
                Color(UIColor.systemBackground)
                    .overlay(ProgressView())
                    .frame(height: 100)
                    .onAppear(perform: {
                        DispatchQueue.main.async {
                            isLoading = false
                        }
                    })
                Spacer()
            } else {
                if data.items.count == 0 {
                    Text("Empty Bill")
                        .foregroundColor(.gray)
                        .bold()
                }
                List {
                    
                    ForEach(data.items, id:\.smartId) { item in
                        BillItemViewCell(majorCurrency: appData.majorCurrency, billItem: item)
                            //.listRowBackground(index + 1 == data.items.count ? Color.gray : nil)
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
                                    //data.removeItem(index, all: true)
                                    isLoading = true
                                } label: {
                                    Text("Remove All")
                                }
                                
                            })
                    }
                    
                    
                    NavigationLink {
                        BillItemShoppingView(onSubmit: { payableDict, ratedPayableDict in
                            data.addItems(payableDict: payableDict, ratedPayableDict: ratedPayableDict)
                        })
                            .environment(\.managedObjectContext, viewContext)
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
            }
            
            VStack {
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
                                .frame(width: 70, alignment: .trailing)
                        }
                        HStack {
                            Spacer()
                            Text("Discount")
                            Text(appData.majorCurrency.toStringRepresentation)
                            Text(data.discount.toStringRepresentation)
                                .frame(width: 70, alignment: .trailing)
                        }
                        HStack {
                            Spacer()
                            Text("Tax & Service")
                            Text(appData.majorCurrency.toStringRepresentation)
                            Text(data.taxAndService.toStringRepresentation)
                                .frame(width: 70, alignment: .trailing)
                        }
                        HStack {
                            Spacer()
                            Text("Total")
                                .bold()
                            Text(appData.majorCurrency.toStringRepresentation)
                                .bold()
                            Text(data.total.toStringRepresentation)
                                .bold()
                                .frame(width: 70, alignment: .trailing)
                        }
                        
                    }
                }
                HStack {
                    NavigationLink("", isActive: $isShowSearchTagView) {
                        TagSearchView { tag in
                            data.setAssociatedTag(tag)
                        }
                    }
                    .hidden()
                    Button {
                        isShowSearchTagView.toggle()
                    } label: {
                        Text(data.associatedTag == nil ? "Add Tag" : data.associatedTag!.toStringRepresentation)
                    }
                    
                    Spacer()
                    Button {
                        data.originalBillSubmit()
                    } label: {
                        Text("Submit")
                    }
                }
                .padding(.top, 5)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).fill(Color(UIColor.secondarySystemGroupedBackground)))
            .padding(.horizontal)
            .padding(.bottom)
            .frame(height: 150)
            
        }
        .navigationTitle(data.name)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    var originalBillReviewView: some View {
        BillTransactionView(splitMode: .full) {
            onExit()
        }
        .environment(\.managedObjectContext, viewContext)
        .environmentObject(appData)
        .environmentObject(data)
        .environmentObject(PayableRatedPayableSelectionController(viewContext))
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
        VStack {
            Text("This bill is completed")
            Button("Start new bill") {
                data.setInactive()
            }
        }
    }
}
