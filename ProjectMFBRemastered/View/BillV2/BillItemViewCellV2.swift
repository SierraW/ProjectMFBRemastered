//
//  BillItemViewCellV2.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-24.
//

import SwiftUI

struct BillItemViewCellV2: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var data: BillData
    
    @Binding var selection: [BillItem: Int]
    var billItem: BillItem
    var isAddOn: Bool {
        billItem.is_add_on
    }
    
    var count: Int {
        Int(billItem.count)
    }
    
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
            if let count = selection[billItem]{
                HStack {
                    Image(systemName: "doc.fill.badge.plus")
                    Text("\(count) / \(self.count)")
                    Image(systemName: "minus.circle")
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(RoundedRectangle(cornerRadius: 15).foregroundColor(Color(UIColor.systemGray5)))
                .contentShape(Rectangle())
                .onTapGesture {
                    if count == 1 {
                        selection.removeValue(forKey: billItem)
                    } else {
                        selection[billItem] = count - 1
                    }
                }
            } else {
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
                    
                }
                Image(systemName: "minus.circle")
                    .foregroundColor(.blue)
                    .padding(billItem.is_rated ? .trailing : .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        data.removeItem(billItem)
                    }
                if !billItem.is_rated {
                    Text("\(count)")
                        .frame(width: 20)
                    Image(systemName: "plus.circle")
                        .foregroundColor(.blue)
                        .padding(.trailing)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            data.addItem(billItem)
                        }
                }
            }
            
            HStack {
                if let amount = billItem.subtotal as Decimal? {
                    Text(appData.majorCurrency.toStringRepresentation)
                    Text(amount.toStringRepresentation)
                        .frame(width: 60, alignment: .trailing)
                }
            }
        }
    }
}
