//
//  MembershipTransactionView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-20.
//

import SwiftUI

enum MembershipTransactionType: String {
    case Deposit
    case Withdraw
    case Transact
}

struct MembershipTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var membershipData: MembershipData
    
    var membershipAccount: MFBMembershipAccount
    
    @State var membershipTransactionCase: MFBMembershipTransactionCase?
    
    var membershipTransactionType: MembershipTransactionType = .Deposit
    
    @State var amount: String = "0.00"
    
    @State var errorMessage: String?
    
    var onExit: (MFBMembershipTransactionResult) -> Void
    
    
    func submitTransaction(with transactionCase: MFBMembershipTransactionCase, for type: MembershipTransactionType) {
        switch type {
        case .Deposit:
            if let amount = Decimal(string: amount) {
                Task {
                    let result = await membershipData.deposit(for: transactionCase, amount: amount)
                    if let result = result {
                        dismiss()
                        onExit(result)
                    } else {
                        withAnimation {
                            errorMessage = "Request Failed"
                        }
                    }
                }
            }
        case .Withdraw:
            return
        case .Transact:
            return
        }
    }
    
    var body: some View {
        Group {
            if let membershipTransactionCase = membershipTransactionCase {
                VStack {
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .fontWeight(.bold)
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        self.errorMessage = nil
                                    }
                                }
                            }
                    } else {
                        Text(membershipTransactionType.rawValue)
                            .font(.system(size: 60))
                    }
                    
                    HStack {
                        Text("CAD$" + amount)
                            .font(.system(size: 60))
                    }
                    KeyPad(value: $amount, decimalPlaces: 2)
                        .frame(maxWidth: 300, maxHeight: 300)
                    if membershipTransactionType == .Deposit {
                        Button {
                            submitTransaction(with: membershipTransactionCase, for: .Deposit)
                        } label: {
                            SubmitButtonView(title: "DEPOSIT")
                        }
                    }
                }
            } else {
                VStack {
                    HStack {
                        ProgressView()
                            .onAppear {
                                Task {
                                    let transactionCase = await membershipData.createCase(for: membershipAccount.id)
                                    await MainActor.run {
                                        self.membershipTransactionCase = transactionCase
                                    }
                                }
                            }
                    }
                }
            }
        }
    }
}
