//
//  UserEditorView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-01.
//

import SwiftUI

struct UserEditorView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    // model fields
    @State var name = ""
    @State var is_root = false
    @State var is_superstar = false
    @State var is_disabled = false
    @State var starred = false
    
    // model fields controls
    @State var confirmDelete = false
    @State var enableEdit = false
    
    // warning controls
    @State var duplicatedWarning = false
    @State var failedToSaveWarning = false
    
    var emptyFieldExist: Bool {
        name.isEmpty
    }
    
    var duplicatedObject: Bool {
        if user.username == name {
            return false
        }
        if users.contains(where: { user in
            user.username == name
        }) {
            return true
        }
        return false
    }
    
    // variables
    var controller: AccountController
    
    var user: User
    
    var users: [User]
    
    var onDelete: (User) -> Void
    
    var disableAll: Bool {
        appData.user == user
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    HStack {
                        Text("Name")
                        Spacer()
                    }
                    .frame(width: 70)
                    TextField("Requried", text: $name, onCommit:  {
                        name.trimmingWhitespacesAndNewlines()
                        if checkDuplicate() {
                            controller.setUsername(user, value: name)
                        }
                    })
                        .disabled(user.is_root)
                }
                
            } header: {
                Text("User")
            } footer: {
                VStack {
                    if duplicatedWarning {
                        HStack {
                            Text("Duplicated user found.")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    if failedToSaveWarning {
                        HStack {
                            Text("Failed to save.")
                                .foregroundColor(.red)
                            Spacer()
                        }
                        
                    }
                }
            }
            
            Section { // TODO: make this look good
                Toggle(isOn: $is_root) {
                    Text("Root")
                }
                .contextMenu {
                    Text("<<<DEBUG ACCOUNT>>>")
                }
                .disabled(true)
                
                Toggle(isOn: $is_superstar) {
                    Text("Superstar")
                }
                .onChange(of: is_superstar, perform: { newValue in
                    controller.setSuperuser(user, value: newValue)
                })
                .contextMenu {
                    Text("This user is a manager")
                }
                .disabled(disableAll)
                
                Toggle(isOn: $is_disabled) {
                    Text("Disabled")
                }
                .onChange(of: is_disabled, perform: { newValue in
                    controller.setDisabled(user, value: newValue)
                })
                .disabled(user.is_root || disableAll)
                .contextMenu {
                    Text("Disable account.")
                }
                
                Toggle(isOn: $starred) {
                    Text("Highlight")
                }
                .onChange(of: starred, perform: { newValue in
                    controller.setHighlight(user, value: newValue)
                })
                .contextMenu {
                    Text("Highlighted Item")
                }
                .disabled(disableAll)
            } header: {
                Text("Settings")
            } footer: {
                if disableAll {
                    Text("You are not allow to change your own data.")
                        .foregroundColor(.red)
                }
            }
            
            Section {
                HStack {
                    Text("Create")
                    Spacer()
                    Text(user.timestamp?.toStringRepresentation ?? "No Data")
                }
                HStack {
                    Text("Last Login Time")
                    Spacer()
                    Text(user.lastLoginTimestamp?.toStringRepresentation ?? "No Data")
                }
            } header: {
                Text("Timestamp")
            }
            
            Section {
                Button(role: .destructive) {
                    delete()
                } label: {
                    if confirmDelete {
                        Text("Confirm Delete")
                    } else {
                        Text("Delete")
                    }
                }
                .disabled(user.is_root || !(user.transactions?.count == 0) || disableAll)
            }
            
            Section {
                Button(role: .cancel) {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Cancel")
                }
                
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            name = user.username ?? ""
            is_root = user.is_root
            is_superstar = user.is_superuser
            is_disabled = user.disabled
            starred = user.is_highlighted
        }
    }
    
    func delete() {
        if !confirmDelete {
            withAnimation {
                confirmDelete = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    confirmDelete = false
                }
                
            }
            return
        }
        onDelete(user)
        presentationMode.wrappedValue.dismiss()
    }
    
    func checkDuplicate() -> Bool {
        if duplicatedObject {
            withAnimation {
                duplicatedWarning = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    duplicatedWarning = false
                }
            }
            return false
        }
        return true
    }
    
    func warningMessage() {
        withAnimation {
            failedToSaveWarning = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                failedToSaveWarning = false
            }
        }
    }
}
