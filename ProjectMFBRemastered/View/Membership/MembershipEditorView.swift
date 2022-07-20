//
//  MembershipEditorView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-18.
//

import SwiftUI

struct MembershipEditorView: View {
    @EnvironmentObject var membershipData: MembershipData
    var membershipIndex: Int
    
    // model fields
    @State var membership: MFBMembership?
    @State var cardNumber = ""
    @State var phoneNumber = ""
    @State var name = ""
    @State var disabled = false
    @State var starred = false
    
    
    // model fields controls
    @State var confirmDelete = false
    
    // warning controls
    @State var duplicatedWarning = false
    @State var failedToSaveWarning = false
    
    var emptyFieldExist: Bool {
        name.isEmpty || cardNumber.isEmpty || phoneNumber.isEmpty
    }
    
    var duplicatedObject: Bool {
        // TODO: implement duplicate check
        return false
    }
    
    // variables
    var onDelete: (MFBMembership) -> Void
    
    var onExit: () -> Void
    
    var body: some View {
        Form {
            Section {
                HStack {
                    HStack {
                        Text("Phone Number")
                        Spacer()
                    }
                    .frame(width: 200)
                    TextField("Requried", text: $phoneNumber, onCommit:  {
                        phoneNumber.trimmingWhitespacesAndNewlines()
                    })
                }
                HStack {
                    HStack {
                        Text("Card Number")
                        Spacer()
                    }
                    .frame(width: 200)
                    TextField("Optional", text: $cardNumber, onCommit:  {
                        cardNumber.trimmingWhitespacesAndNewlines()
                    })
                }
                HStack {
                    HStack {
                        Text("Name")
                        Spacer()
                    }
                    .frame(width: 200)
                    TextField("Optional", text: $name, onCommit:  {
                        name.trimmingWhitespacesAndNewlines()
                    })
                }
            } header: {
                Text("Membership")
            } footer: {
                VStack {
                    if duplicatedWarning {
                        HStack {
                            Text("Duplicated tag found.")
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
            
            Section {
                Toggle(isOn: $disabled) {
                    Text(disabled ? "Disabled" : "Enabled")
                }
                Toggle(isOn: $starred) {
                    Text(starred ? "Highlighted" : "Highlight")
                }
                .contextMenu {
                    Text("Highlighted Item")
                }
            } header: {
                Text("Settings")
            }
            
            Section {
                HStack {
                    HStack {
                        Text("ID")
                        Spacer()
                    }
                    .frame(width: 200)
                    TextField("Optional", text: $name, onCommit:  {
                        name.trimmingWhitespacesAndNewlines()
                    })
                }
            } header: {
                Text("Currency")
            }
            
            Section {
                Button {
                    save()
                } label: {
                    Text("Save")
                }
                .disabled(emptyFieldExist || failedToSaveWarning)
                Button(role: .destructive) {
                    handleDelete()
                } label: {
                    if confirmDelete {
                        Text("Confirm Delete")
                    } else {
                        Text("Delete")
                    }
                }
            }
            Section {
                Button(role: .cancel) {
                    onExit()
                } label: {
                    Text("Cancel")
                }
                
            }
        }
        .onAppear {
            if let membership = membership {
                cardNumber = membership.cardNumber ?? ""
                phoneNumber = membership.phoneNumber
                name = membership.name ?? ""
                starred = membership.starred
                disabled = membership.disabled
            }
        }
    }
    
    func handleDelete() {
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
        delete()
    }
    
    func delete() {
        
        onExit()
    }
    
    func save() {
        cardNumber.trimmingWhitespacesAndNewlines()
        phoneNumber.trimmingWhitespacesAndNewlines()
        name.trimmingWhitespacesAndNewlines()
        if emptyFieldExist {
            return
        }
        if duplicatedObject {
            withAnimation {
                duplicatedWarning = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    duplicatedWarning = false
                }
            }
            return
        }
        let modifiedMembership = MFBMembership(id: 0, membershipAccounts: [], cardNumber: cardNumber == "" ? nil : cardNumber, phoneNumber: phoneNumber, name: name == "" ? nil : name, starred: starred, disabled: disabled, dateCreated: "", lastModified: "")
        if let _ = membership {
            membershipData.updateMembership(item: modifiedMembership, with: membershipIndex) { success in
                if (!success) {
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
        } else {
            membershipData.createMembership(item: modifiedMembership, currency: 1) { success in
                if (!success) {
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
        }
    }
}
