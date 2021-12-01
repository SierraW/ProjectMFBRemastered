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
    var resultMode = false
    var hideAddOnItems = false
    
    var body: some View {
        VStack {
            HStack {
                Text(resultMode ? "\(bill.name) 🕓\(bill.openTimestamp?.timeStringRepresentation ?? "")" : bill.toStringRepresentation)
                Spacer()
                if bill.combined {
                    Image(systemName: "g.square")
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                if resultMode {
                    if let total = bill.proceedBalance as Decimal? {
                        Text(appData.majorCurrency.toStringRepresentation)
                        Text(total.toStringRepresentation)
                    } else {
                        Text("ON HOLD")
                            .foregroundColor(.blue)
                    }
                } else {
                    Text(appData.majorCurrency.toStringRepresentation)
                    if let total = bill.originalBalance as Decimal? {
                        Text(total.toStringRepresentation)
                    }
                }
                Image(systemName: resultMode ?  isExpanded ? "archivebox.fill" : "archivebox" : "chevron.right")
                    .rotationEffect(Angle(degrees: !resultMode && isExpanded ? 90 : 0))
                    .scaleEffect(isExpanded ? 1.2 : 1)
                    .padding(.leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isExpanded.toggle()
                    }
            }
            .frame(height: 50)
            if isExpanded, let billItems = bill.items?.allObjects as? [BillItem] {
                detailView(billItems)
                .padding(.leading)
            }
        }
    }
    
    func detailView(_ billItems: [BillItem]) -> some View {
        VStack {
            if let total = bill.total, let total = total.total as Decimal? {
                HStack {
                    Text("Carried On Subtotal")
                    Spacer()
                    Text(appData.majorCurrency.toStringRepresentation)
                    Text(total.toStringRepresentation)
                }
            }
            ForEach(
                billItems
                    .sorted(by: { BillItem.calculationOrderComparator(lhs: $0, rhs: $1) })
                    
            ) { item in
                if !hideAddOnItems || !item.is_add_on {
                    BillItemViewCell(majorCurrency: appData.majorCurrency, billItem: item)
                        .padding(.vertical, 5)
                }
            }
        }
    }
}
