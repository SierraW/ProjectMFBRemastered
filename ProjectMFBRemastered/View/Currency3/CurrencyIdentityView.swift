//
//  CurrencyIdentityView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-20.
//

import SwiftUI

struct CurrencyIdentityView: View {
    var currency: MFBCurrency
    var selected = true
    
    var body: some View {
        HStack {
            if selected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
            Text(currency.name)
            Spacer()
            Text(currency.prefix)
            Text(currency.symbol)
        }
    }
}

struct CurrencyIdentityView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyIdentityView(currency: MFBCurrency(name: "Canadian Dollar", prefix: "CAD", symbol: "$", isMajorCurrency: true, exchangeRate: "1.0", id: 1, starred: true, disabled: true, dateCreated: "11", lastModified: "22"))
    }
}
