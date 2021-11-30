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
            Spacer()
            if ratedPayable.starred {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            if ratedPayable.is_deposit {
                Menu {
                    Text("This is a Promotion Item")
                } label: {
                    Image(systemName: "p.square")
                        .foregroundColor(.green)
                }
            }
            if ratedPayable.is_tax {
                Menu {
                    Text("This is a Tax Item")
                } label: {
                    Image(systemName: "t.square")
                        .foregroundColor(.purple)
                }
            }
            if let rate = ratedPayable.rate as Decimal? {
                HStack {
                    Text("Rate:")
                    Text(rate.toStringRepresentation)
                        .frame(width: 60)
                }
                .padding(.leading)
            }
        }
    }
}
