//
//  PayableListView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-18.
//

import SwiftUI

struct PayableListView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Payable.starred, ascending: true)],
        animation: .default)
    private var fetchedPayable: FetchedResults<Payable>

    @State var searchString = ""
    
    @State var sortType: SortType = .name
    @State var productView = false
    
    var payables: [Payable] {
        var resultPayables: [Payable]
        
        switch sortType {
        case .price:
            resultPayables = fetchedPayable.sorted { lhs, rhs in
                (lhs.amount as Decimal? ?? 0) < (rhs.amount as Decimal? ?? 0)
            }
        case .name:
            resultPayables = fetchedPayable.sorted { lhs, rhs in
                lhs.tag?.name ?? "" > rhs.tag?.name ?? ""
            }
        case .highlighted:
            resultPayables = fetchedPayable.sorted { lhs, rhs in
                lhs.starred || lhs.starred == rhs.starred
            }
        }
        if !searchString.isEmpty {
            return resultPayables.filter { payable in
                payable.tag?.name?.lowercased().contains(searchString.lowercased()) ?? false
            }
        }
        return resultPayables
    }
    
    var groups: [String: [Int]] {
        Dictionary(grouping: payables.indices, by: {payables[$0].tag?.parent?.toStringRepresentation ?? "Ungrouped Products"})
    }
    
    var dismissOnExit = false
    
    var onSelect: (Payable) -> Void
    
    enum SortType: String, CaseIterable {
        case name = "Name"
        case price = "Price"
        case highlighted = "Highlighted"
    }
    
    var body: some View {
        VStack {
            SearchBar(text: $searchString) {

            }
            Form {
                if productView {
                    Section {
                        ForEach(payables.indices, id: \.self) { index in
                            getPayableViewCell(payables[index])
                        }
                    } header: {
                        Text(searchString.isEmpty ? "All Products" : "Search Result")
                    }
                } else {
                    ForEach(groups.keys.sorted(), id:\.self) { groupName in
                        Section {
                            if let groupedPayableIndices = groups[groupName] {
                                ForEach(groupedPayableIndices, id:\.self) { index in
                                    getPayableViewCell(payables[index])
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
    
    func getPayableViewCell(_ payable: Payable) -> some View {
        HStack {
            Text(payable.toStringRepresentation)
            if payable.starred {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            Spacer()
            if let amount = payable.amount as Decimal? {
                Text(appData.majorCurrency.toStringRepresentation)
                Text(amount.toStringRepresentation)
                    .frame(width: 50)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect(payable)
            if dismissOnExit {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
