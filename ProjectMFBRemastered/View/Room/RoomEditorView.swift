//
//  RoomEditorView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-16.
//

import SwiftUI

struct RoomEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var name = ""
    @State var confirmDelete = false
    
    @State var duplicatedWarning = false
    @State var failedToSaveWarning = false
    
    var emptyFieldExist: Bool {
        name.isEmpty
    }
    
    var duplicatedObject: Bool {
        if let room = room, let oldName = room.name, oldName == name {
            return false
        }
        if rooms.contains(where: { room in
            room.name == name
        }) {
            return true
        }
        return false
    }
    
    var controller: TagController
    
    var room: Tag? = nil
    
    var rooms: [Tag]
    
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
                Text("Room")
            } footer: {
                VStack {
                    if duplicatedWarning {
                        HStack {
                            Text("Duplicated currency found.")
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
                Button {
                    save()
                } label: {
                    Text("Save")
                }
                .disabled(emptyFieldExist)
                if let _ = room {
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
            if let currency = room {
                name = currency.name ?? ""
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
        if let currency = room {
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
        
        if controller.modifyOrCreateIfNotExist(name: name, tag: room, is_room: true) != nil {
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
