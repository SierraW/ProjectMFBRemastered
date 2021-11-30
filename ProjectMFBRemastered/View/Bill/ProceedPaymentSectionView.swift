//
//  ProceedPaymentListView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-28.
//

import SwiftUI

struct ProceedPaymentSectionView: View {
    @EnvironmentObject var data: BillData
    
    var body: some View {
        Section {
            DisclosureGroup("Proceed Payments (\(data.allPayments.count))") {
                ForEach(data.allPayments) { billPayment in
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
        }
    }
}
