//
//  PaymentViewCell.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-30.
//

import SwiftUI

struct PaymentViewCell: View {
    var billPayment: BillPayment
    
    var body: some View {
        HStack {
            Text(billPayment.toStringRepresentation)
            Spacer()
            if let currency = billPayment.currency {
                Text(currency.toStringRepresentation)
            }
            if let amount = billPayment.amount as Decimal? {
                Text(amount.toStringRepresentation)
            }
        }
    }
}
