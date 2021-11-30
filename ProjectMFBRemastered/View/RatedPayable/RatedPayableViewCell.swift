//
//  RatedPayableViewCell.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-26.
//

import SwiftUI

struct RatedPayableViewCell: View {
    var ratedPayable: RatedPayable
    
    var body: some View {
        HStack {
            Text(ratedPayable.toStringRepresentation)
            if ratedPayable.starred {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            Spacer()
            if ratedPayable.is_deposit {
                Image(systemName: "d.square")
                    .foregroundColor(.green)
                    .contextMenu {
                        Text("This is a promotion item.")
                    }
                    .padding(.trailing)
            }
            if let rate = ratedPayable.rate as Decimal? {
                Text("Rate:")
                Text(rate.toStringRepresentation)
                    .frame(width: 50)
            }
        }
    }
}
