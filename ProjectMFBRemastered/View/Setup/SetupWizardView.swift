//
//  SetupWizardView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-10.
//

import SwiftUI

struct SetupWizardView: View {
    @State var viewState: ViewState? = .Welcome
    @State var rootUser: User? = nil
    
    enum ViewState: Int {
        case Welcome
        case RootUserRegistration
        case MajorCurrencySetup
    }
    
    var body: some View {
        Group {
            switch(viewState) {
            case .RootUserRegistration:
                registrationView
            case .MajorCurrencySetup:
                majorCurrencySetupView
            default:
                welcomeView
            }
        }
    }
    
    var welcomeView: some View {
        VStack {
            Spacer()
            Text("Welcome to MFB Cashier @ iOS")
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewState = .RootUserRegistration
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                viewState = .RootUserRegistration
            }
        }
    }
    
    var registrationView: some View {
        VStack {
            if let rootUser = rootUser {
                Text("Root User: \(rootUser.username ?? "")")
                Button {
                    withAnimation {
                        viewState = .MajorCurrencySetup
                    }
                } label: {
                    Text("Next")
                }

            } else {
                RegisterView { user in
                    withAnimation {
                        if let user = user {
                            rootUser = user
                            viewState = .MajorCurrencySetup
                        } else {
                            viewState = .Welcome
                        }
                    }
                    
                }
            }
        }
    }
    
    var majorCurrencySetupView: some View {
        CurrencyManagementView()
    }
}

struct SetupWizardView_Previews: PreviewProvider {
    static var previews: some View {
        SetupWizardView()
    }
}
