//
//  TagManagementView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-12.
//

import SwiftUI

struct TagManagementView: View {
    // environment
    @EnvironmentObject var appData: AppData
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    // fetch requests
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)],
        animation: .default)
    private var fetchedTags: FetchedResults<Tag>
    
    var tags: [Tag] {
        switch sortType {
        default:
            return fetchedTags.map({$0})
        }
    }
    
    // controller
    var controller: TagController {
        TagController(viewContext)
    }
    
    // edit control
    @State var editingTagIndex: Int? = nil
    
    // sort type
    @State var sortType: SortType = .name
    
    enum SortType: String, CaseIterable {
        case name = "Name"
        case symbol = "Symbol"
    }
    
    var body: some View {
        VStack {
            TagListView(tags: fetchedTags.map({$0})) { index in
                withAnimation {
                    editingTagIndex = index
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
        .sheet(item: $editingTagIndex) { index in
            VStack {
                HStack {
                    Image(systemName: "chevron.down.circle")
                        .foregroundColor(.gray)
                        .frame(width:50)
                    Spacer()
                    Text("Tag Editor")
                        .bold()
                    Spacer()
                    Spacer()
                        .frame(width:50)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        editingTagIndex = nil
                    }
                }
                .padding()
                TagEditorView(controller: controller, tag: index == -1 ? nil : tags[index], tags: tags, onDelete: { tag in
                    withAnimation {
                        editingTagIndex = nil
                        controller.delete(tag)
                    }
                }, onExit: {
                    withAnimation {
                        editingTagIndex = nil
                    }
                })
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                        withAnimation {
                            editingTagIndex = -1
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add new tag")
                        }
                        
                    }
                    Spacer()
                }
            }
        }
    }
}
