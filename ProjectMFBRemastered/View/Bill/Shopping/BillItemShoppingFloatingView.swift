//
//  BillItemShoppingFloatingView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-01.
//

import SwiftUI

struct BillItemShoppingFloatingView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var payables: [Payable: Int]
    @Binding var ratedPayables: [RatedPayable: Int]
    @Binding var showCart: Bool
    
    var onSubmit: () -> Void
    
    var isCartNotEmpty: Bool {
        !payables.isEmpty || !ratedPayables.isEmpty
    }
    
    var cartItemsCount : Int {
        var count = 0
        payables.forEach { count += $1}
        ratedPayables.forEach { count += $1}
        return count
    }
    
    var body: some View {
        HStack {
            if isCartNotEmpty {
                Button {
                    showCart = true
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "cart.fill")
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
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemGray5)))
                }
                .transition(.moveAndFade)
                
                Button {
                    payables.removeAll()
                    ratedPayables.removeAll()
                } label: {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                        .padding(10)
                        .background(Circle().fill(Color(UIColor.systemGray5)))
                }
                .padding(.leading)

            } else {
                Spacer()
            }
            
            
            
            Button(action: {
                onSubmit()
            }, label: {
                Image(systemName: isCartNotEmpty ? "checkmark" : "arrowshape.turn.up.backward")
                    .padding(10)
                    .background(Circle().fill(Color(UIColor.systemGray5)))
            })
            .padding(.leading)
        }
    }
}
