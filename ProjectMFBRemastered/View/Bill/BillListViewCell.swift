//
//  BillListViewCell.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-29.
//

import SwiftUI

struct BillListViewCell: View {
    @EnvironmentObject var appData: AppData
    
    var bill: Bill
    
    @State var isExpanded = false
    
    var body: some View {
        VStack {
            HStack {
                Text(bill.toStringRepresentation)
                Spacer()
                if bill.combined {
                    Image(systemName: "g.square")
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                Text(appData.majorCurrency.toStringRepresentation)
                if let total = bill.originalBalance as Decimal? {
                    Text(total.toStringRepresentation)
                }
                Image(systemName: "chevron.right")
                    .rotationEffect(Angle(degrees: isExpanded ? 90 : 0))
                    .scaleEffect(isExpanded ? 1.2 : 1)
                    .padding(.leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
            }
            .animation(.none, value: isExpanded)
            if isExpanded, let billItems = bill.items?.allObjects as? [BillItem] {
                VStack {
                    ForEach(billItems) { item in
                        BillItemViewCell(majorCurrency: appData.majorCurrency, billItem: item)
                            .padding(.vertical, 5)
                    }
                }
                .padding(.leading)
            }
        }
    }
}
