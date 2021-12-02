//
//  TagSearchView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-01.
//

import SwiftUI

struct TagSearchView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)],
        predicate: NSPredicate(format: "is_associated = YES"),
        animation: .default)
    private var fetchedTags: FetchedResults<Tag>
    
    var tags: [Tag] {
        fetchedTags.filter { tag in
            tag.name?.contains(searchString) ?? false
        }
    }
    
    @State var searchString = ""
    
    var onSubmit: (Tag) -> Void
    
    var body: some View {
        VStack {
            Text("Choose a tag...")
                .listRowSeparator(.hidden)
            SearchBar(text: $searchString) {
                submitSearchString()
            }
            if !searchString.isEmpty {
                Button {
                    submitSearchString()
                } label: {
                    Text("Add new tag")
                        .foregroundColor(Color(uiColor: .label))
                }
            }
            ForEach(tags) { tag in
                Divider()
                Button {
                    onSubmit(tag)
                } label: {
                    Text(tag.toStringRepresentation)
                        .foregroundColor(Color(uiColor: .label))
                }
                
            }
            if !searchString.isEmpty {
                Divider()
            }
        }
    }
    
    func submitSearchString() {
        searchString.trimmingWhitespacesAndNewlines()
        if let tag = tags.first(where: { tag in
            tag.name == searchString
        }) {
            onSubmit(tag)
        } else {
            let tagController = TagController(viewContext)
            if let tag = tagController.modifyOrCreateIfNotExist(name: searchString, is_associated: true) {
                onSubmit(tag)
            }
        }
    }
}
