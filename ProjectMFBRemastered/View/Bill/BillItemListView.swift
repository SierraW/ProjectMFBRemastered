//
//  BillItemListView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-25.
//

import SwiftUI

struct BillItemListView: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var data: BillData
    @Environment(\.presentationMode) var presentationMode
    
    @State var selectRatedItems = false
    
    @State var payables: [Payable: Int] = [:]
    @State var ratedPayables: [RatedPayable: Int] = [:]
    
    @State var showCart = false
    
    var cartItemsCount : Int {
        var count = 0
        payables.forEach { count += $1}
        ratedPayables.forEach { count += $1}
        return count
    }
    
    var onSubmit: ([Payable: Int], [RatedPayable: Int]) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Fix Value Items")
                    .padding()
                    .foregroundColor(!selectRatedItems ? Color(UIColor.systemGray) : .blue)
                    .background(!selectRatedItems ?  Rectangle().foregroundColor(Color(UIColor.systemGroupedBackground)) : nil)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectRatedItems.toggle()
                    }
                Spacer()
                Text("Rate Items")
                    .padding()
                    .foregroundColor(selectRatedItems ? Color(UIColor.systemGray) : .blue)
                    .background(selectRatedItems ?  Rectangle().foregroundColor(Color(UIColor.systemGroupedBackground)) : nil)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectRatedItems.toggle()
                    }
            }
            .edgesIgnoringSafeArea(.bottom)
            Color(UIColor.systemGroupedBackground)
                .frame(height: 8)
            if !selectRatedItems {
                NavigationView {
                    PayableListView { payable in
                        payables[payable] = (payables[payable] ?? 0) + 1
                    }
                    .navigationBarHidden(true)
                }
                .navigationViewStyle(.stack)
                
            } else {
                NavigationView {
                    RatedPayableListView { ratedPayable in
                        ratedPayables[ratedPayable] = (ratedPayables[ratedPayable] ?? 0) + 1
                    }
                    .navigationBarHidden(true)
                }
                .navigationViewStyle(.stack)
                
            }
            Button  {
                showCart.toggle()
            } label: {
                VStack {
                    Image(systemName: "chevron.up")
                        .padding(.bottom, 1)
                    HStack {
                        Image(systemName: "cart")
                        Text("View Cart")
                        if cartItemsCount <= 50 {
                            Image(systemName: "\(cartItemsCount).square.fill")
                                .foregroundColor(.red)
                                .scaledToFit()
                        } else {
                            Image(systemName: "tablecells.fill.badge.ellipsis")
                                .foregroundColor(.red)
                                .scaledToFit()
                        }
                    }
                }
            }
            .padding(5)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    submit()
                } label: {
                    Text("Submit")
                }

            }
        })
        .sheet(isPresented: $showCart) {
            shoppingCartView
        }
    }
    
    var shoppingCartView: some View {
        VStack {
            HStack {
                Text("Cart")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            .padding(.top)
            .padding(.leading)
            Form {
                Section {
                    if payables.count == 0 {
                        Text("Empty...")
                            .foregroundColor(.gray)
                    }
                    ForEach(payables.keys.sorted()) { key in
                        HStack {
                            PayableViewCell(majorCurrency: appData.majorCurrency, payable: key)
                            Text("x \(payables[key] ?? 0)")
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let count = payables[key] {
                                if count < 2 {
                                    payables.removeValue(forKey: key)
                                } else {
                                    payables[key] = count - 1
                                }
                            }
                        }
                    }
                } header: {
                    Text("Fix Value Items")
                }
                Section {
                    if ratedPayables.count == 0 {
                        Text("Empty...")
                            .foregroundColor(.gray)
                    }
                    ForEach(ratedPayables.keys.sorted()) { key in
                        HStack {
                            RatedPayableViewCell(ratedPayable: key)
                            Text("x \(ratedPayables[key] ?? 0)")
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let count = ratedPayables[key] {
                                if count < 2 {
                                    ratedPayables.removeValue(forKey: key)
                                } else {
                                    ratedPayables[key] = count - 1
                                }
                            }
                        }
                    }
                } header: {
                    Text("Rate Items")
                }
            }
            Button {
                submit()
            } label: {
                SubmitButtonView(title: "Submit", foregroundColor: .white, backgroundColor: .blue)
            }
            .padding(.bottom)
            Button(role: .destructive) {
                payables.removeAll()
                ratedPayables.removeAll()
                showCart = false
            } label: {
                Text("Clear")
            }
            .padding(.bottom)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    func getItemViewCell(_ item: BillItem) -> some View {
        HStack {
            Text(item.toStringRepresentation)
            Spacer()
            Text("x \(item.count)")
                .padding(.trailing)
            if let amount = item.subtotal as Decimal? {
                Text(appData.majorCurrency.toStringRepresentation)
                Text(amount.toStringRepresentation)
                    .frame(width: 50, alignment: .trailing)
            }
        }
        .contentShape(Rectangle())
    }
    
    func submit() {
        if cartItemsCount > 0 {
            onSubmit(payables, ratedPayables)
        }
        presentationMode.wrappedValue.dismiss()
    }
}

struct BillItemListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BillItemListView() { _, _ in
                
            }
        }
    }
}
