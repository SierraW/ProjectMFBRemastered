//
//  RegisterView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-10.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.username, ascending: true)],
        animation: .default)
    private var users: FetchedResults<User>
    
    @State var username: String = ""
    @State var isUsernameDuplicated: Bool = false
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var isSuperuser = false
    @State var isHighlighted = false
    
    @State var passwordMismatchError = false
    @State var userExistError = false
    
    var fieldsUnsatisfied: Bool {
        username.count < 3 || password.count < 3
    }
    
    var isSettingUpRootUser = false
    let onExit: (User?) -> Void
    
    var body: some View {
        VStack {
            registerForm
        }
    }
    
    var registerForm: some View {
        Form {
            Section {
                TextField("Username", text: $username, onCommit: {
                    username.trimmingWhitespacesAndNewlines()
                })
                SecureField("Password", text: $password) {
                    password.trimmingWhitespacesAndNewlines()
                }
                SecureField("Re-enter Password", text: $confirmPassword)
            } header: {
                Text("Account")
            } footer: {
                VStack(spacing: 10) {
                    HStack {
                        Text("Username and password must constain at least 3 characters")
                        Spacer()
                    }
                    if passwordMismatchError {
                        HStack {
                            Text("Password does not matched").foregroundColor(.red)
                            Spacer()
                        }
                    }
                    if userExistError {
                        HStack {
                            Text("User already exist").foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            
            Section {
                Toggle(isOn: $isHighlighted) {
                    Text("Always on top")
                }
                .disabled(self.isSettingUpRootUser)
                Toggle(isOn: $isSuperuser) {
                    Text("Superuser")
                        .font(.headline)
                }
                .disabled(self.isSettingUpRootUser)
            }
            
            Section {
                Button {
                    register()
                } label: {
                    Text("Submit")
                }
                .disabled(fieldsUnsatisfied || password.count != confirmPassword.count)
                Button {
                    onExit(nil)
                } label: {
                    Text("Cancel")
                        .foregroundColor(.red)
                }
            }
        }
        
    }
    
    
    func register() {
        if fieldsUnsatisfied {
            return
        }
        if password != confirmPassword {
            passwordMismatchError = true
            return
        }
        if let _ = users.first(where: { item in
            item.username == self.username
        }) {
            return
        }
        let newUser = User(context: viewContext)
        newUser.username = self.username
        newUser.password = self.password.sha256()
        newUser.is_superuser = self.isSuperuser
        newUser.is_root = self.isSettingUpRootUser
        newUser.is_highlighted = self.isHighlighted
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print(nsError)
        }
        onExit(newUser)
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView { _ in
            
        }
    }
}
