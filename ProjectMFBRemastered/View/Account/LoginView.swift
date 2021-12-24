//
//  LoginView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-10.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.is_highlighted, ascending: false),
                          NSSortDescriptor(keyPath: \User.lastLoginTimestamp, ascending: false)],
        predicate: NSPredicate(format: "disabled = NO"),
        animation: .default)
    private var fetchedUsers: FetchedResults<User>
    
    var users: [User] {
        fetchedUsers.map({$0})
    }
    
    @State var selectedUserIndex: Int = 0
    @State var password = ""
    
    @State var informationMismatched = false
    
    var expectedUser: User? = nil
    let onExit: (User?) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                    .frame(height: geometry.size.height / 10)
                HStack {
                    Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                    Text("MFB Cashier App")
                        .font(.title)
                }
                Spacer()
                    .frame(height: geometry.size.height / 10)
                
                Form {
                    Section {
                        HStack {
                            HStack {
                                Text("User")
                                Spacer()
                            }
                            .frame(width: 100)
                            Picker("User", selection: $selectedUserIndex) {
                                ForEach(users.indices, id:\.self) {index in
                                    Text(users[index].toStringRepresentation).tag(index)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.leading)
                            .onAppear {
                                if let expectedUser = expectedUser, let index = users.firstIndex(of: expectedUser) {
                                    withAnimation {
                                        selectedUserIndex = index
                                    }
                                }
                            }
                        }
                        
                        HStack {
                            HStack {
                                Text("Password")
                                Spacer()
                            }
                            .frame(width: 100)
                            SecureField("", text: $password) {
                                verify()
                            }
                            .padding(.leading)
                        }
                    } header: {
                        Text("Sign in")
                    } footer: {
                        if informationMismatched {
                            Text("Incorrect Password")
                                .foregroundColor(.red)
                        }
                    }

                    Section {
                        Button {
                            verify()
                        } label: {
                            Text("Log in")
                        }

                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    func verify() {
        withAnimation {
            let selectedUser = users[selectedUserIndex]
            if selectedUser.password == password.sha256() {
                selectedUser.lastLoginTimestamp = Date()
                let controller = ModelController(viewContext)
                controller.managedSave()
                onExit(selectedUser)
            } else {
                withAnimation {
                    informationMismatched = true
                }
            }
        }
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(onExit: { _ in
            
        })
    }
}
