//
//  MajorCurrencyWidzardView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-17.
//

import SwiftUI

struct MajorCurrencyWidzardView: View {
    
    var onExit: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("Your app need a major currency to")
                    .bold()
                Button {
                    onExit()
                } label: {
                    Text("countinue...")
                        .bold()
                }

            }
            .contextMenu(menuItems: {
                Text("Major Currency")
                Text("Currency that your products going to be priced.")
            })
            .padding(.top, 30)
            
            CurrencyManagementView(initialSetup: true)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}
