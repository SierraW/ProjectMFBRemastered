//
//  RatedPayableEditorView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-17.
//

import SwiftUI

struct RatedPayableEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // model fields
    @State var name = ""
    @State var rate = ""
    @State var starred = false
    @State var taxed = false
    
    // model fields controls
    @State var confirmDelete = false
    
    // specialized controls
    @State var creatingNewGroup = false
    @State var groupName = ""
    @State var groupDuplicatedWarning = false
    
    // warning controls
    @State var duplicatedWarning = false
    @State var failedToSaveWarning = false
    
    var emptyFieldExist: Bool {
        name.isEmpty
    }
    
    var duplicatedObject: Bool {
        if ratedPayable?.tag?.name == name {
            return false
        }
        if ratedPayables.contains(where: { ratedPayable in
            ratedPayable.tag?.name == name
        }) {
            return true
        }
        return false
    }
    
    // variables
    var controller: RatedPayableController
    
    var ratedPayable: RatedPayable? = nil
    
    var ratedPayables: [RatedPayable]
    
    var onDelete: (RatedPayable) -> Void
    
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
                HStack {
                    HStack {
                        Text("Rate")
                        Spacer()
                    }
                    .frame(width: 70)
                    DecimalField(placeholder: "Required", value: $rate)
                }
            } header: {
                Text("Tax & Service")
            } footer: {
                VStack {
                    if duplicatedWarning {
                        HStack {
                            Text("Duplicated tax & service found.")
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
                Toggle(isOn: $starred) {
                    Text("Highlight")
                }
                .contextMenu {
                    Text("Highlight a product so that you can find it faster!")
                }
                Toggle(isOn: $taxed) {
                    Text("Tax")
                }
                .contextMenu {
                    Text("Tax will always comes the last during calculation.")
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
                if let _ = ratedPayable {
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
            if let ratedPayable = ratedPayable {
                name = ratedPayable.tag?.name ?? ""
                rate = (ratedPayable.rate! as Decimal).toStringRepresentation
                starred = ratedPayable.starred
                taxed = ratedPayable.is_tax
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
        if let currency = ratedPayable {
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
        
        if (controller.modifyOrCreateIfNotExist(name: name, ratedPayable: ratedPayable, rate: Decimal(string: rate) ?? 0, is_deposit: true, is_tax: taxed, starred: starred) != nil) {
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
