//
//  PayableManagementView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-17.
//

import SwiftUI

struct PayableManagementView: View {
    @EnvironmentObject var appData: AppData
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Payable.starred, ascending: true)],
        animation: .default)
    private var fetchedPayable: FetchedResults<Payable>
    
    var payables: [Payable] {
        switch sortType {
        case .group:
            return fetchedPayable.sorted { lhs, rhs in
                lhs.tag?.parent?.name ?? "" < rhs.tag?.parent?.name ?? ""
            }
        default:
            return fetchedPayable.map({$0})
        }
    }
    
    var groups: [String: [Int]] {
        Dictionary(grouping: payables.indices, by: {payables[$0].tag?.parent?.toStringRepresentation ?? "Ungrouped Products"})
    }
    
    var controller: PayableController {
        PayableController(viewContext)
    }
    
    @State var editingPayableIndex: Int? = nil
    @State var isLoading = false
    
    @State var sortType: SortType = .name
    
    enum SortType: String, CaseIterable {
        case name = "Product Name"
        case group = "Group Name"
    }
    
    var body: some View {
        if isLoading {
            Color(UIColor.systemGroupedBackground)
                .overlay(ProgressView())
                .onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            isLoading = false
                        }
                    }
                })
        } else {
            VStack {
                Form {
                    ForEach(groups.keys.sorted(), id:\.self) { groupName in
                        Section {
                            if let groupedPayableIndices = groups[groupName] {
                                ForEach(groupedPayableIndices, id:\.self) { index in
                                    PayableViewCell(majorCurrency: appData.majorCurrency, payable: payables[index])
                                    .contentShape(Rectangle())
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            controller.delete(payables[index])
                                            isLoading = true
                                        } label: {
                                            HStack {
                                                Image(systemName: "trash")
                                                Text("Delete")
                                            }
                                            
                                        }
                                    }
                                    .onTapGesture {
                                        if editingPayableIndex == nil {
                                            editingPayableIndex = index
                                        }
                                    }
                                }
                            }
                            
                        } header: {
                            Text(groupName)
                        }
                    }
                }
                Spacer()
                
                HStack {
                    Button {
                        withAnimation {
                            editingPayableIndex = -1
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add new product")
                        }
                        
                    }
                    .padding()
                    Spacer()
                }
                
            }
            .background(Color(UIColor.systemGroupedBackground))
            .sheet(item: $editingPayableIndex) { index in
                VStack {
                    HStack {
                        Image(systemName: "chevron.down.circle")
                            .foregroundColor(.gray)
                            .frame(width:50)
                        Spacer()
                        Text("Product Editor")
                            .bold()
                        Spacer()
                        Spacer()
                            .frame(width:50)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            editingPayableIndex = nil
                        }
                    }
                    .padding()
                    PayableEditorView(controller: controller, payable: index == -1 ? nil : payables[index], payables: payables, majorCurrency: appData.majorCurrency, onDelete: { payable in
                        withAnimation {
                            editingPayableIndex = nil
                            controller.delete(payable)
                        }
                    }, onExit: {
                        isLoading = true
                        withAnimation {
                            editingPayableIndex = nil
                        }
                        
                    })
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
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
    }
}
