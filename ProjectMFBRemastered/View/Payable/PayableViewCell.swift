//
//  PayableViewCell.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-25.
//

import SwiftUI

struct PayableViewCell: View {
    
    var majorCurrency: Currency
    var payable: Payable
    
    var body: some View {
        HStack {
            Text(payable.toStringRepresentation)
            Spacer()
            if payable.starred {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            if payable.is_deposit {
                Menu {
                    Text("This is a Promotion Item")
                } label: {
                    Image(systemName: "p.square")
                        .foregroundColor(.green)
                }
            }
            if payable.discountable {
                Menu {
                    Text("This item can effect by promotion item")
                } label: {
                    Image(systemName: "d.square")
                        .foregroundColor(.blue)
                }
            }
            if let amount = payable.amount as Decimal? {
                HStack {
                    Text(majorCurrency.toStringRepresentation)
                    Text(amount.toStringRepresentation)
                        .frame(width: 60)
                }
                .padding(.leading)
            }
        }
    }
}
