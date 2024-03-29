//
//  MembershipMainView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-11.
//

import SwiftUI

struct MembershipMainView: View {
    @State var appData: MembershipAppData?
    @State var majorCurrency: MFBCurrency?
    
    var body: some View {
        Group {
            if let majorCurrency = majorCurrency {
                if let appData = appData {
                    MembershipManagementView()
                        .environmentObject(appData)
                        .environmentObject(MembershipData(profile: appData.authentication))
                } else {
                    MembershipAuthenticationView { authentication in
                        appData = MembershipAppData(profile: authentication, majorCurrency: majorCurrency, onLogout: {
                            withAnimation {
                                appData = nil
                            }
                        })
                    }
                }
            } else {
                Text("Major Currency is not assigned. App is not ready. If you have more question, email me at  me@yiyao.ca")
            }
            
        }
        .onAppear {
            Task {
                let controller = CurrencyDataAccessController()
                let (majorCurrency, _) = await controller.majorCurrency()
                if let majorCurrency = majorCurrency {
                    self.majorCurrency = majorCurrency
                }
            }
        }
    }
}

struct MembershipMainView_Previews: PreviewProvider {
    static var previews: some View {
        MembershipMainView()
    }
}
