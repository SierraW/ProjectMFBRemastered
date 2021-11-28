//
//  PayableEditorView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-17.
//

import SwiftUI

struct PayableEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)],
        predicate: NSPredicate(format: "is_group = YES"),
        animation: .default)
    private var fetchedGroups: FetchedResults<Tag>
    var groups: [Tag] {
        fetchedGroups.map({$0})
    }
    
    @State var name = ""
    @State var amount = ""
    @State var selectedTagIndex = -1
    @State var discountable = false
    @State var is_deposit = false // todo seperate from payable
    @State var starred = false
    @State var confirmDelete = false
    
    @State var creatingNewGroup = false
    @State var groupName = ""
    @State var groupDuplicatedWarning = false
    
    @State var duplicatedWarning = false
    @State var failedToSaveWarning = false
    
    var emptyFieldExist: Bool {
        name.isEmpty
    }
    
    var duplicatedObject: Bool {
        if payable?.tag?.name == name {
            return false
        }
        if payables.contains(where: { payable in
            payable.tag?.name == name
        }) {
            return true
        }
        return false
    }
    
    var controller: PayableController
    
    var payable: Payable? = nil
    
    var payables: [Payable]
    
    var majorCurrency: Currency
    
    var onDelete: (Payable) -> Void
    
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
                        Text(majorCurrency.toStringRepresentation)
                        Spacer()
                    }
                    .frame(width: 70)
                    DecimalField(placeholder: "Required", value: $amount)
                }
            } header: {
                Text("Product")
            } footer: {
                VStack {
                    if duplicatedWarning {
                        HStack {
                            Text("Duplicated product found.")
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
                HStack {
                    HStack {
                        Text("Group")
                            .frame(width: 70, alignment: .leading)
                    }
                    Picker("", selection: $selectedTagIndex, content: {
                        Text("Not Set").tag(-1)
                        ForEach(groups.indices, id: \.self) { index in
                            Text(groups[index].toStringRepresentation).tag(index)
                        }
                    })
                        .pickerStyle(.menu)
                    Spacer()
                    Button {
                        creatingNewGroup.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .disabled(creatingNewGroup)
                }
                
                if creatingNewGroup {
                    TextField("Group name", text: $groupName, prompt: Text("New Group Name"))
                    Button {
                        submitNewGroup()
                    } label: {
                        Text("Save")
                    }
                    .disabled(groupName.isEmpty)
                }
                
                
            } header: {
                Text("Group")
            } footer: {
                if groupDuplicatedWarning {
                    Text("Duplicated name found.").foregroundColor(.red)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    groupDuplicatedWarning = false
                                }
                            }
                        }
                }
            }
            
            Section {
                Toggle(isOn: $discountable) {
                    Text("Can effect by promotions")
                }
                .contextMenu {
                    Text("Tag a product that is accepting any discount.")
                }
                .disabled(is_deposit)
                Toggle(isOn: $is_deposit) {
                    Text("Promotion Item")
                }
                .contextMenu {
                    Text("The value will make an negative effect on bill.")
                }
                .disabled(discountable)
                Toggle(isOn: $starred) {
                    Text("Highlight")
                }
                .contextMenu {
                    Text("Highlight a product so that you can find it faster!")
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
                if let _ = payable {
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
            if let payable = payable {
                name = payable.tag?.name ?? ""
                discountable = payable.discountable
                is_deposit = payable.is_deposit
                starred = payable.starred
                if let amount = payable.amount as Decimal? {
                    self.amount = amount.toStringRepresentation
                }
                if let parent = payable.tag?.parent, let index = groups.firstIndex(where: { tag in
                    tag == parent
                }) {
                    selectedTagIndex = index
                }
            }
            
        }
    }
    
    
    func submitNewGroup() {
        if groupName.isEmpty {
            return
        }
        let tagController = TagController(viewContext)
        if let group = tagController.modifyOrCreateIfNotExist(name: groupName, is_group: true) {
            if let index = groups.firstIndex(where: { tag in
                tag == group
            }) {
                withAnimation {
                    selectedTagIndex = index
                }
            }
        } else {
            groupDuplicatedWarning = true
        }
        creatingNewGroup = false
        groupName = ""
        
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
        if let currency = payable {
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
        
        if (controller.modifyOrCreateIfNotExist(name: name, amount: Decimal(string: amount) ?? 0, payable: payable, groupedBy: selectedTagIndex == -1 ? nil : groups[selectedTagIndex], discountable: discountable, is_deposit: is_deposit, starred: starred) != nil) {
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
