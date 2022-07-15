//
//  MembershipTestView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-12.
//

import SwiftUI

struct MembershipTestView: View {
    @State var majorCurrency: MFBCurrency?
    @State var currencies: [MFBCurrency] = []
    @State var membershipPaged: MFBPagedMembership?
    @State var message: String = ""
    @EnvironmentObject var appData: MembershipAppData
    
    var currencyController: CurrencyDataAccessController {
        return CurrencyDataAccessController(appData.authentication)
    }
    
    var membershipController: MembershipDataAccessController {
        return MembershipDataAccessController(appData.authentication)
    }
    
    var body: some View {
        Group {
            ScrollView {
                LazyVStack {
                    Text("Message \(message)")
                    Text("Major Currency")
                    if let majorCurrency = majorCurrency {
                        Text(majorCurrency.name)
                    }
                    ForEach(currencies, id: \.id) { currency in
                        Text(currency.name)
                    }
                    Text("Membership")
                    if let membershipPaged = membershipPaged {
                        ForEach(membershipPaged.results, id: \.id) { membership in
                            Text(membership.cardNumber)
                            ForEach(membership.membershipAccounts, id: \.id) { membershipAccount in
                                Text(membershipAccount.currency.stringRepresentation)
                                Text(membershipAccount.amount)
                            }
                        }
                    } else {
                        Text("No Data")
                    }
                }
            }
        }
        .onAppear {
            Task {
                if let result = await currencyController.list() {
                    currencies = result
                }
                if let majorCurrency = await currencyController.majorCurrency() {
                    self.majorCurrency = majorCurrency
                }
                if let mfbPagedMembership = await membershipController.list() {
                    self.membershipPaged = mfbPagedMembership
                } else {
                    print("decode failed")
                }
            }
        }
    }
}

