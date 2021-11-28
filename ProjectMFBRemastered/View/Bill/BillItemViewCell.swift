//
//  BillItemViewCell.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-25.
//

import SwiftUI

struct BillItemViewCell: View {
    var majorCurrency: Currency
    var billItem: BillItem
    
    var body: some View {
        HStack {
            Text(billItem.toStringRepresentation)
            Spacer()
            if billItem.is_deposit {
                Menu {
                    Text("Discount Item")
                } label: {
                    Image(systemName: "d.square")
                        .foregroundColor(.green)
                }
                .padding(.horizontal)
            }
            if billItem.is_rated {
                HStack {
                    Menu {
                        Text("Rate Item")
                    } label: {
                        Image(systemName: "r.square")
                    }
                    if let rate = billItem.value as Decimal? {
                        Text(rate.toStringRepresentation)
                    }
                }
                .padding(.horizontal)
                
            } else {
                Text("x \(billItem.count)")
                    .padding(.trailing)
                    
            }
            if let amount = billItem.subtotal as Decimal? {
                Text(majorCurrency.toStringRepresentation)
                Text(amount.toStringRepresentation)
                    .frame(width: 60, alignment: .trailing)
            }
        }
    }
}
