//
//  TransactionViewCell.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-30.
//

import SwiftUI

struct TransactionListViewCell: View {
    @EnvironmentObject var appData: AppData
    
    var transaction: Transaction
    
    @State var isExpanded = false
    
    var body: some View {
        VStack {
            HStack {
                if let timestamp = transaction.timestamp {
                    Text(timestamp.toStringRepresentation)
                }
                Spacer()
                if let paymentMethod = transaction.paymentMethod {
                    Text(paymentMethod.toStringRepresentation)
                }
                if let currency = transaction.currency {
                    Text(currency.toStringRepresentation)
                }
                if let total = transaction.amount as Decimal? {
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
            .frame(height: 50)
            .animation(.none, value: isExpanded)
            if isExpanded {
                detailView
                .padding(.leading)
            }
        }
    }
    
    var detailView: some View {
        VStack {
            HStack {
                Text("OPERATOR")
                Spacer()
                if let user = transaction.user {
                    Text(user.toStringRepresentation)
                }
            }
            HStack {
                Text("BILL")
                Spacer()
            }
            if let bill = transaction.bill {
                HStack {
                    BillListViewCell(bill: bill)
                        .environmentObject(appData)
                }
            } else {
                Text("Error Bill")
            }
            HStack {
                Text("Tags")
                Spacer()
            }
            if let tags = transaction.tags?.allObjects as? [Tag], tags.count > 0 {
                ForEach(tags) { tag in
                    HStack {
                        Spacer()
                        Text(tag.toStringRepresentation)
                    }
                }
            } else {
                Text("Empty")
            }
        }
    }
}
