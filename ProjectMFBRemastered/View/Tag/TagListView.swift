//
//  TagSeletView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-30.
//

import SwiftUI

struct TagListView: View {
    @State var searchString = ""
    
    @State var sortType: SortType = .name
    
    var tags: [Tag]
    
    var orderedTags: [Tag] {
        var resultTags: [Tag]
        
        switch sortType {
        case .highlighted:
            resultTags = tags.sorted { lhs, rhs in
                lhs.starred || lhs.starred == rhs.starred
            }
        default:
            resultTags = tags.map({$0})
        }
        if !searchString.isEmpty {
            return resultTags.filter { tag in
                tag.name?.lowercased().contains(searchString.lowercased()) ?? false
            }
        }
        return resultTags
    }
    
    var groups: [String: [Int]] {
        var groupIndices: [Int] = []
        var roomIndices: [Int] = []
        var payableIndices: [Int] = []
        var ratedPayableIndices: [Int] = []
        var associatedIndices: [Int] = []
        var disjointIndices: [Int] = []
        
        for index in orderedTags.indices {
            let tag = orderedTags[index]
            var belongsToAGroup = false
            if tag.is_group {
                groupIndices.append(index)
                belongsToAGroup = true
            }
            if tag.is_room {
                roomIndices.append(index)
                belongsToAGroup = true
            }
            if tag.is_payable {
                payableIndices.append(index)
                belongsToAGroup = true
            }
            if tag.is_rated {
                ratedPayableIndices.append(index)
                belongsToAGroup = true
            }
            if tag.is_associated {
                associatedIndices.append(index)
                belongsToAGroup = true
            }
            if !belongsToAGroup {
                disjointIndices.append(index)
            }
        }
        var dict: [String: [Int]] = [:]
        dict["Group"] = groupIndices
        dict["Room"] = roomIndices
        dict["Product"] = payableIndices
        dict["Tax & Service"] = ratedPayableIndices
        dict["Room Associated Tags"] = associatedIndices
        if !disjointIndices.isEmpty {
            dict["Ungrouped"] = disjointIndices
        }
        return dict
    }
    
    @State var productView = false
    
    var onSelect: (Int) -> Void
    
    enum SortType: String, CaseIterable {
        case name = "Name"
        case highlighted = "Highlighted"
    }
    
    var body: some View {
        VStack {
            SearchBar(text: $searchString) {

            }
            Form {
                if productView {
                    Section {
                        ForEach(orderedTags.indices, id: \.self) { index in
                            getTagViewCell(orderedTags[index])
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onSelect(index)
                                }
                        }
                    } header: {
                        Text(searchString.isEmpty ? "All Tags" : "Search Result")
                    }
                } else {
                    ForEach(groups.keys.sorted(), id:\.self) { groupName in
                        Section {
                            if let groupedPayableIndices = groups[groupName] {
                                ForEach(groupedPayableIndices, id:\.self) { index in
                                    getTagViewCell(orderedTags[index])
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            onSelect(index)
                                        }
                                }
                            }
                        } header: {
                            Text(groupName)
                        }
                    }
                }
                
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Menu {
                        ForEach(SortType.allCases, id:\.rawValue) { sortType in
                            Button {
                                self.sortType = sortType
                            } label: {
                                HStack {
                                    Text(sortType.rawValue)
                                    if self.sortType == sortType {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left.arrow.right")
                            Text("Alignment")
                        }
                    }
                    Button {
                        productView.toggle()
                    } label: {
                        Text("Group View")
                        if !productView {
                            Image(systemName: "checkmark")
                        }
                    }

                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    func getTagViewCell(_ tag: Tag) -> some View {
        HStack {
            Text(tag.toStringRepresentation)
            if tag.starred {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            Spacer()
            if productView {
                HStack(spacing: 10) {
                    if tag.is_group {
                        Text("Group")
                    }
                    if tag.is_room {
                        Text("Room")
                    }
                    if tag.is_payable {
                        Text("Product")
                    }
                    if tag.is_rated {
                        Text("Tax & Service")
                    }
                }
                .foregroundColor(.gray)
            }
        }
    }
}
