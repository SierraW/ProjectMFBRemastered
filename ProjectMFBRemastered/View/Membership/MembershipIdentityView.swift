//
//  MembershipIdentityView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-15.
//

import SwiftUI

struct MembershipIdentityView: View {
    var membership: MFBMembership
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "lanyardcard")
                    Text(membership.cardNumber ?? "--")
                    Spacer()
                }
                .frame(width: 50)
                HStack {
                    Image(systemName: "phone.circle")
                    Text(membership.phoneNumber)
                }
                HStack {
                    Image(systemName: "note.text")
                    Text(membership.name ?? "--")
                }
                Spacer()
                HStack {
                    Image(systemName: "creditcard.and.123")
                    Text("\(membership.membershipAccounts.count)")
                }
            }
            if membership.membershipAccounts.isEmpty {
                HStack {
                    Text("No Accounts")
                        .foregroundColor(.gray)
                }
            } else {
                ForEach(membership.membershipAccounts, id: \.id) { membershipAccount in
                    HStack(alignment: .center) {
                        Spacer()
                        if membershipAccount.disabled {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.red)
                        } else {
                            Image(systemName: "lock.open.fill")
                                .foregroundColor(.green)
                        }
                        Text(membershipAccount.currency.stringRepresentation)
                        Text(membershipAccount.amount)
                            .frame(minWidth: 100, alignment: .trailing)
                    }
                }
            }
        }
    }
}

struct MembershipIdentityView_Previews: PreviewProvider {
    
    static var previews: some View {
        MembershipIdentityView(membership: MFBMembership(id: 1, membershipAccounts: [
            MFBMembershipAccount(id: 11, currency: MFBCurrencyIdentity(id: 12, stringRepresentation: "CAD$"), amount: "100.00", starred: true, disabled: true, dateCreated: "1122", lastModified: "2233"),
            MFBMembershipAccount(id: 13, currency: MFBCurrencyIdentity(id: 12, stringRepresentation: "USD$"), amount: "100.00", starred: true, disabled: false, dateCreated: "1122", lastModified: "2233")
        ], cardNumber: "1", phoneNumber: "1234567890", name: "Sb", starred: true, disabled: true, dateCreated: "11", lastModified: "11"))
    }
}
