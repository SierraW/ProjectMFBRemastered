//
//  SBPCartFloatingView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-29.
//

import SwiftUI

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .scale.combined(with: .opacity))
    }
}

struct SBPCartFloatingView: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var data: BillData
    
    @State var showCartView = false
    
    @State var scaleValue: CGFloat = 0
    
    @Binding var cartProducts: [Payable: Int]
    @Binding var cartBillData: BillData?
    
    var body: some View {
        ZStack {
            if showCartView {
                Color.gray.opacity(0.5).ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showCartView.toggle()
                        }
                    }
                    .zIndex(1)
            }
            
            VStack {
                Spacer()
                if showCartView {
                    VStack {
                        shoppingCartView
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color(UIColor.systemGroupedBackground)))
                        .padding(.horizontal, 7)
                    }
                    .padding(.top, 50)
                    .padding(.vertical, 10)
                    .transition(.moveAndFade)
                    .zIndex(2)
                    
                    Button(role: .destructive) {
                        clearCart()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "trash")
                            Text("Clear Cart")
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemGray5)))
                    }
                    .padding(.horizontal)
                    
                    Button {
                        addToNewBill()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "plus")
                            Text("Make A New Bill")
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemGray5)))
                    }
                    .padding(.horizontal)
                    
                    if cartBillData != nil {
                        Button {
                            addToExistingBill()
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "cart.badge.plus")
                                Text("Add To Existing Bill")
                                Spacer()
                            }
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemGray5)))
                        }
                        .padding(.horizontal)
                    }
                    
                }
                
                HStack {
                    Button {
                        withAnimation {
                            showCartView.toggle()
                        }
                        scaleValue = 0
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "cart")
                            Text(showCartView ? "Hide Cart" : "View Cart\(cartProducts.isEmpty ? "" : " (\(cartProducts.count))")")
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemGray5)))
                    }
                    .padding(.horizontal)
                    
                    if !showCartView {
                        Button {
                            addToNewBill()
                        } label: {
                            Image(systemName: "plus")
                                .padding(10)
                                .background(Circle().fill(Color(UIColor.systemGray5)))
                        }
                        .scaleEffect(scaleValue)
                        .transition(.moveAndFade)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                scaleValue = 1
                            }
                        }
                        if cartBillData != nil {
                            Button {
                                addToExistingBill()
                            } label: {
                                Image(systemName: "cart.badge.plus")
                                    .padding(10)
                                    .background(Circle().fill(Color(UIColor.systemGray5)))
                            }
                            .scaleEffect(scaleValue)
                            .transition(.moveAndFade)
                        }
                        Button(role: .destructive) {
                            clearCart()
                        } label: {
                            Image(systemName: "trash")
                                .padding(10)
                                .background(Circle().fill(Color(UIColor.systemGray5)))
                        }
                        .scaleEffect(scaleValue)
                        .transition(.moveAndFade)
                        .padding(.trailing)
                    }
                   
                }
                .padding(.bottom)
            }
            .zIndex(3)
        }
    }
    
    var shoppingCartView: some View {
        VStack {
            if cartProducts.isEmpty {
                Text("Empty Cart")
                    .padding()
            }
            List {
                ForEach(cartProducts.keys.sorted()) { key in
                    HStack {
                        Text(key.toStringRepresentation)
                        Spacer()
                        Text(appData.majorCurrency.toStringRepresentation)
                        Text(key.pricePerUnit.toStringRepresentation)
                        Text("x\(cartProducts[key] ?? 0)")
                            .font(.title3)
                            .bold()
                    }
                }
            }
        }
    }
    
    func clearCart() {
        withAnimation {
            cartProducts.removeAll()
        }
    }
    
    func addToExistingBill() {
        if let cartBillData = cartBillData {
            cartBillData.sbpAddToCart(miniProductDict: cartProducts)
            clearCart()
        }
    }
    
    func addToNewBill() {
        if cartProducts.isEmpty {
            return
        }
        let billData = BillData(asChildOf: data)
        billData.sbpAddToCart(miniProductDict: cartProducts)
        clearCart()
        data.reloadChildren()
    }
}
