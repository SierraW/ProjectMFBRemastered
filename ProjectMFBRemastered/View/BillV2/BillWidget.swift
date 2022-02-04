//
//  BillWidget.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-21.
//

import SwiftUI

struct BillWidget: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var data: BillData
    
    var empty: Bool = true
    
    var body: some View {
        ZStack {
            if empty {
                Group {
                    Rectangle()
                        .frame(width: 38, height: 7)
                    Rectangle()
                        .frame(width: 38, height: 7)
                        .rotationEffect(Angle(degrees: 90))
                }
                .foregroundColor(Color(UIColor.systemGray5))
            } else {
                VStack {
                    Text(appData.majorCurrency.toStringRepresentation)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                    if let total = data.proceedBalance {
                        Text(total.toStringRepresentation)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text(data.total.toStringRepresentation)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .foregroundColor(data.completed ? .white : .gray)
            }
        }
        .padding()
        .frame(width: 130, height: 100)
        .background(
            !empty ? nil :
            RoundedRectangle(cornerRadius: 15)
                .stroke(style: StrokeStyle(lineWidth: 4, dash: [7]))
                .foregroundColor(Color(UIColor.systemGray5))
        )
        .background(
            empty ? nil :
                data.completed ?
            RoundedRectangle(cornerRadius: 15).foregroundColor(.green) :
            RoundedRectangle(cornerRadius: 15).foregroundColor(Color(UIColor.systemGray5))
        )
        .contentShape(Rectangle())

    }
    

}

struct BillWidget_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                BillWidget()
                BillWidget()
                BillWidget()
                BillWidget()
            }
            .padding()
        }
    }
}
