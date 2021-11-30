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
    
    @State var selectRatedItems = false
    
    @State var payables: [Payable: Int] = [:]
    @State var ratedPayables: [RatedPayable: Int] = [:]
    
    @State var showCart = false
    
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
                    PayableListView { _ in
                        //
                    }
                    .navigationBarHidden(true)
                }
                .navigationViewStyle(.stack)
                
            } else {
                NavigationView {
                    RatedPayableListView { _ in
                        //
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
                    }
                }
            }
            .padding(5)
        }
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
                    }
                } header: {
                    Text("Rate Items")
                }
            }
            Button {
                //
            } label: {
                SubmitButtonView(title: "Submit", foregroundColor: .white, backgroundColor: .blue)
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
}

struct BillItemListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BillItemListView() { _, _ in
                
            }
        }
    }
}
