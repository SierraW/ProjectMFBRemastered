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
            if payable.starred {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            Spacer()
            if payable.is_deposit {
                Image(systemName: "d.square")
                    .foregroundColor(.green)
                    .contextMenu {
                        Text("This is a promotion item.")
                    }
                    .padding(.trailing)
            }
            if let amount = payable.amount as Decimal? {
                Text(majorCurrency.toStringRepresentation)
                Text(amount.toStringRepresentation)
                    .frame(width: 60)
            }
        }
    }
}
