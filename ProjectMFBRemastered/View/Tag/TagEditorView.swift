//
//  TagEditorView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-30.
//

import SwiftUI

struct TagEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // model fields
    @State var name = ""
    @State var is_group = false
    @State var is_room = false
    @State var is_payable = false
    @State var is_rated = false
    @State var is_associated = false
    @State var starred = false
    
    
    // model fields controls
    @State var confirmDelete = false
    
    // warning controls
    @State var duplicatedWarning = false
    @State var failedToSaveWarning = false
    
    var emptyFieldExist: Bool {
        name.isEmpty
    }
    
    var duplicatedObject: Bool {
        if tag?.name == name {
            return false
        }
        if tags.contains(where: { tag in
            tag.name == name
        }) {
            return true
        }
        return false
    }
    
    // variables
    var controller: TagController
    
    var tag: Tag? = nil
    
    var tags: [Tag]
    
    var onDelete: (Tag) -> Void
    
    var onExit: () -> Void
    
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
                    })
                }
            } header: {
                Text("Tag")
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
            
            Section { // TODO: make this look good
                Toggle(isOn: $is_group) {
                    Text("Group")
                }
                .contextMenu {
                    Text("The value will make an negative effect on bill.")
                }
                Toggle(isOn: $is_room) {
                    Text("Room")
                }
                .contextMenu {
                    Text("Highlight a product so that you can find it faster!")
                }
                Toggle(isOn: $is_payable) {
                    Text("Fix Value Item")
                }
                .contextMenu {
                    Text("The value will make an negative effect on bill.")
                }
                Toggle(isOn: $is_rated) {
                    Text("Rated Item")
                }
                .contextMenu {
                    Text("The value will make an negative effect on bill.")
                }
                Toggle(isOn: $is_associated) {
                    Text("Associated Item")
                }
                .contextMenu {
                    Text("The value will make an negative effect on bill.")
                }
                Toggle(isOn: $starred) {
                    Text("Highlight")
                }
                .contextMenu {
                    Text("Highlighted Item")
                }
            } header: {
                Text("Settings")
            }
            
            Section {
                Button {
                    save()
                } label: {
                    Text("Save")
                }
                .disabled(emptyFieldExist || failedToSaveWarning)
                if let _ = tag {
                    Button(role: .destructive) {
                        delete()
                    } label: {
                        if confirmDelete {
                            Text("Confirm Delete")
                        } else {
                            Text("Delete")
                        }
                        
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
            if let tag = tag {
                name = tag.name ?? ""
                is_group = tag.is_group
                is_room = tag.is_room
                is_payable = tag.is_payable
                is_rated = tag.is_rated
                is_associated = tag.is_associated
                starred = tag.starred
                
            }
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
        if let currency = tag {
            onDelete(currency)
        } else {
            onExit()
        }
    }
    
    func save() {
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
        
        
        
        if controller.modifyOrCreateIfNotExist(name: name, tag: tag, is_group: is_group, is_room: is_room, is_payable: is_payable, is_rated: is_rated, is_associated: is_associated, starred: starred) != nil {
            onExit()
            return
        }
        
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
