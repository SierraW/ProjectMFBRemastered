//
//  BillItemViewCellControl.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-05-15.
//

import SwiftUI

struct BillItemViewCellControl: View {
    var value: String
    var onTapMinusControl: (() -> Void)?
    var onTapPlusControl: (() -> Void)?
    
    
    var body: some View {
        HStack {
            Image(systemName: "minus.circle")
                .foregroundColor(onTapMinusControl != nil ? .blue : .gray)
                .onTapGesture {
                    if let onTapMinusControl = onTapMinusControl {
                        onTapMinusControl()
                    }
                }
            Text(value)
                .frame(width: 50, alignment: .center)
            Image(systemName: "plus.circle")
                .foregroundColor(onTapPlusControl != nil ? .blue : .gray)
                .onTapGesture {
                    if let onTapPlusControl = onTapPlusControl {
                        onTapPlusControl()
                    }
                }
        }
        .padding(5)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color(UIColor.systemGroupedBackground)))
    }
}

struct BillItemViewCellControl_Previews: PreviewProvider {
    static var previews: some View {
        BillItemViewCellControl(value: "123", onTapMinusControl: {}, onTapPlusControl: {})
    }
}
