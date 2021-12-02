//
//  TagSearchView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-01.
//

import SwiftUI

struct TagSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)],
        predicate: NSPredicate(format: "is_associated = YES"),
        animation: .default)
    private var fetchedTags: FetchedResults<Tag>
    
    var tags: [Tag] {
        if searchString.isEmpty {
            return fetchedTags.sorted()
        } else {
            return fetchedTags.filter { tag in
                tag.name?.contains(searchString) ?? false
            }
        }
    }
    
    @State var searchString = ""
    
    var onSubmit: (Tag) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchString) {
                submitSearchString()
            }
            List {
                Section {
                    if !searchString.isEmpty {
                        Button {
                            submitSearchString()
                        } label: {
                            Text("Add \(searchString) as a new tag...")
                        }
                    }
                    ForEach(tags) { tag in
                        Button {
                            onSubmit(tag)
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text(tag.toStringRepresentation)
                                .foregroundColor(Color(uiColor: .label))
                        }
                        
                    }
                }
            }
//            .searchable(text: $searchString) {
//                ForEach(tags) { tag in
//                    Text("Do you mean \(tag.toStringRepresentation)?").searchCompletion(tag.toStringRepresentation)
//                }
//            }
        }
        .navigationTitle("Associated Tags")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    func submitSearchString() {
        searchString.trimmingWhitespacesAndNewlines()
        if let tag = tags.first(where: { tag in
            tag.name == searchString
        }) {
            onSubmit(tag)
            presentationMode.wrappedValue.dismiss()
        } else {
            let tagController = TagController(viewContext)
            if let tag = tagController.modifyOrCreateIfNotExist(name: searchString, is_associated: true) {
                onSubmit(tag)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
