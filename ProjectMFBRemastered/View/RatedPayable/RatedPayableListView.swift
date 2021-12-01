//
//  RatedPayableListView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-25.
//

import SwiftUI

struct RatedPayableListView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \RatedPayable.starred, ascending: true)],
        animation: .default)
    private var fetchedRatedPayable: FetchedResults<RatedPayable>

    @State var searchString = ""
    
    @State var sortType: SortType = .name
    
    var ratedPayables: [RatedPayable] {
        var resultRatedPayables: [RatedPayable]
        
        switch sortType {
        case .rate:
            resultRatedPayables = fetchedRatedPayable.sorted { lhs, rhs in
                (lhs.rate as Decimal? ?? 0) < (rhs.rate as Decimal? ?? 0)
            }
        case .name:
            resultRatedPayables = fetchedRatedPayable.sorted { lhs, rhs in
                lhs.tag?.name ?? "" > rhs.tag?.name ?? ""
            }
        case .highlighted:
            resultRatedPayables = fetchedRatedPayable.sorted { lhs, rhs in
                lhs.starred || lhs.starred == rhs.starred
            }
        }
        if !searchString.isEmpty {
            return resultRatedPayables.filter { payable in
                payable.tag?.name?.lowercased().contains(searchString.lowercased()) ?? false
            }
        }
        return resultRatedPayables
    }
    
    var groups: [String: [Int]] {
        Dictionary(grouping: ratedPayables.indices, by: {ratedPayables[$0].tag?.parent?.toStringRepresentation ?? "Ungrouped Products"})
    }
    
    var dismissOnExit = false
    
    var onSelect: (RatedPayable) -> Void
    
    enum SortType: String, CaseIterable {
        case name = "Name"
        case rate = "Rate"
        case highlighted = "Highlighted"
    }
    
    var body: some View {
        VStack {
            SearchBar(text: $searchString) {

            }
            Form {
                Section {
                    ForEach(ratedPayables.indices, id: \.self) { index in
                        getRatedPayableViewCell(ratedPayables[index])
                    }
                } header: {
                    if !searchString.isEmpty {
                        Text("Search Result")
                    }
                }
            }
        }
        .navigationTitle("Rate Items")
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
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    func getRatedPayableViewCell(_ ratedPayable: RatedPayable) -> some View {
        Button {
            onSelect(ratedPayable)
            if dismissOnExit {
                presentationMode.wrappedValue.dismiss()
            }
        } label: {
            RatedPayableViewCell(ratedPayable: ratedPayable)
                .foregroundColor(Color(uiColor: .label))
        }
    }
}
