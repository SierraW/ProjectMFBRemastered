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
                    Text("This is a Promotion Item")
                } label: {
                    Image(systemName: "p.square")
                        .foregroundColor(.green)
                }
            }
            if billItem.is_tax {
                Menu {
                    Text("This is a Tax Item")
                } label: {
                    Image(systemName: "t.square")
                        .foregroundColor(.purple)
                }
            }
            if billItem.is_rated {
                Menu {
                    Text("This is a Rate Item")
                } label: {
                    Image(systemName: "r.square")
                        .foregroundColor(.red)
                }
                if let rate = billItem.value as Decimal? {
                    Text(rate.toStringRepresentation)
                }
            } else {
                Text("x \(billItem.count)")
                    
            }
            HStack {
                if let amount = billItem.subtotal as Decimal? {
                    Text(majorCurrency.toStringRepresentation)
                    Text(amount.toStringRepresentation)
                        .frame(width: 60, alignment: .trailing)
                }
            }
            .padding(.leading)
        }
    }
}
