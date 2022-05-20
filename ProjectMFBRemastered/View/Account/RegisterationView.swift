//
//  RegisterView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-10.
//

import SwiftUI

struct RegisterationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.username, ascending: true)],
        animation: .default)
    private var users: FetchedResults<User>
    
    @State var firstname = ""
    @State var lastname = ""
    @State var isUsernameDuplicated: Bool = false
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var isSuperuser = false
    @State var isHighlighted = false
    
    @State var passwordMismatchError = false
    @State var userExistError = false
    
    @State var isSuccess = false
    
    var fieldsUnsatisfied: Bool {
        firstname.isEmpty || lastname.isEmpty || password.count < 3
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
                TextField("Firstname", text: $firstname, onCommit: {
                    firstname.trimmingWhitespacesAndNewlines()
                })
                TextField("Lastname", text: $lastname, onCommit: {
                    lastname.trimmingWhitespacesAndNewlines()
                })
                SecureField("Password", text: $password) {
                    password.trimmingWhitespacesAndNewlines()
                }
                SecureField("Re-enter Password", text: $confirmPassword)
            } header: {
                Text("Account")
            } footer: {
                VStack(spacing: 10) {
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
                    if isSuccess {
                        HStack {
                            Text("Success!").foregroundColor(.green)
                            Spacer()
                        }
                    }
                }
            }
            .onAppear {
                if isSettingUpRootUser {
                    isSuperuser = true
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
        firstname.trimmingWhitespacesAndNewlines()
        lastname.trimmingWhitespacesAndNewlines()
        let name = self.firstname + " " + self.lastname
        
        if fieldsUnsatisfied {
            return
        }
        if password != confirmPassword {
            passwordMismatchError = true
            return
        }
        if let _ = users.first(where: { item in
            item.username == name
        }) {
            return
        }
        let newUser = User(context: viewContext)
        newUser.username = name
        newUser.password = self.password.sha256()
        newUser.is_superuser = self.isSuperuser
        newUser.is_root = self.isSettingUpRootUser
        newUser.is_highlighted = self.isHighlighted
        newUser.timestamp = Date()
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print(nsError)
        }
        isSuccess = true
        resetFields()
        onExit(newUser)
    }
    
    func resetFields() {
        firstname = ""
        lastname = ""
        isUsernameDuplicated = false
        password = ""
        confirmPassword = ""
        isSuperuser = false
        isHighlighted = false
        
        passwordMismatchError = false
        userExistError = false
    }
}

struct RegisterationView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterationView { _ in
            
        }
    }
}
