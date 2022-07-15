//
//  MembershipAuthenticationView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-11.
//

import SwiftUI

struct MembershipAuthenticationView: View {
    @State var username: String = ""
    @State var password: String = ""
    
    @State var warningMessage: String = ""
    @State var loginSuccess = false
    
    let urlInvalid = "Internal Error"
    let decodeFailed = "Username and password does not matched"
    let authenticationController = AuthenticationDataAccessController()
    
    var onAuthenticate: (MFBAuthentication) -> Void

    
    var body: some View {
        Form {
            Section {
                TextField("Username", text: $username)
                    .autocapitalization(.none)
                SecureField("password", text: $password)
            } header: {
                Text("Login")
            } footer: {
                HStack (alignment: .top) {
                    VStack (alignment: .leading) {
                        if username.isEmpty {
                            Text("Username cannot be empty.")
                        }
                        if password.isEmpty {
                            Text("Password cannot be empty.")
                        }
                    }
                    Spacer()
                    if loginSuccess {
                        Text("SUCCESS")
                            .foregroundColor(.green)
                    }
                }
                
            }
            Section {
                Button("Submit") {
                    authenticate()
                }.disabled(username.isEmpty || password.isEmpty)
            }
        }
    }
    
    func authenticate() {
        Task {
            let authProfile = await authenticationController.authenticate(with: username, password)
            if let authProfile = authProfile {
                loginSuccess = true
                onAuthenticate(authProfile)
            } else {
                warningMessage = decodeFailed
            }
        }
    }
}

struct MembershipAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        MembershipAuthenticationView { auth in
            print(auth)
        }
    }
}
