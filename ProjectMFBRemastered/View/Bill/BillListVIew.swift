//
//  BillListVIew.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-23.
//

import SwiftUI

struct BillListVIew: View {
    @EnvironmentObject var data: BillData
    
    @Binding var selection: Set<BillItem>?

    var body: some View {
        List(data.items, selection: $selection) { item in
            HStack {
                Text(item.toStringRepresentation)
                Spacer()
                Text(data.controller.bill.majorCurrenctString ?? "?$")
                if let subtotal = item.subtotal as Decimal? {
                    Text(subtotal.toStringRepresentation)
                        .frame(width: 200)
                }
            }
        }
    }
}
