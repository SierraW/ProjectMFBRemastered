//
//  TagManagementView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-12.
//

import SwiftUI

struct TagManagementView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)],
        animation: .default)
    private var fetchedTags: FetchedResults<Tag>
    
    var tags: [Tag] {
        fetchedTags.map({$0})
    }
    
    @State var editingIndex: Int? = nil
    
    var body: some View {
        Form {
            DisclosureGroup("Tag Tree") {
                VStack {
                    Text("Tree View")
                }
            }
            
            Section {
                ForEach(tags.indices, id:\.self) { index in
                    HStack {
                        Text(tags[index].toStringPresentation)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            editingIndex = index
                        }
                    }
                }
            } header: {
                Text("Tag List")
            }

        }
        .sheet(item: $editingIndex) { index in
            TagEditionView(tag: index == -1 ? nil : tags[index], allTags: tags)
        }
        .navigationTitle("Tags")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        editingIndex = -1
                    }
                } label: {
                    Text("Add")
                }

            }
        }
    }
}

struct TagManagementView_Previews: PreviewProvider {
    static var previews: some View {
        TagManagementView()
    }
}
