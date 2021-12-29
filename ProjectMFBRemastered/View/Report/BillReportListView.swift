//
//  BillReportListView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-26.
//

import SwiftUI

struct BillReportListView: View {
    var majorCurrency: Currency
    var bills: [Bill]
    @Binding var selection: Set<Bill>
    
    var body: some View {
        List(bills, id: \.self, selection: $selection) { bill in
            HStack {
                Text(bill.associatedTag?.toStringRepresentation ?? bill.tag?.toStringRepresentation ?? "NODATA")
                if let timestamp = bill.openTimestamp {
                    Text(timestamp.toStringRepresentation)
                }
                Spacer()
                if let pb = bill.proceedBalance as Decimal? {
                    Text(bill.majorCurrencyString ?? majorCurrency.toStringRepresentation)
                    Text(pb.toStringRepresentation)
                } else {
                    Text("ON HOLD")
                }
            }
        }
        .environment(\.editMode, .constant(EditMode.active))
    }
}
