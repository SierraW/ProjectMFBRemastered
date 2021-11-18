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
        sortDescriptors: [NSSortDescriptor(keyPath: \Payable.tag, ascending: true)],
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
    
    var controller: PayableController {
        PayableController(viewContext)
    }
    
    @State var editingPayableIndex: Int? = nil
    
    @State var sortType: SortType = .name
    
    enum SortType: String, CaseIterable {
        case name = "Product Name"
        case group = "Group Name"
    }
    
    var body: some View {
        VStack {
            Form {
                Section {
                    ForEach(payables.indices, id:\.self) { index in
                        HStack {
                            Text(payables[index].toStringPresentation)
                            Spacer()
                            if let amount = payables[index].amount as Decimal? {
                                Text(appData.majorCurrency.toStringPresentation)
                                Text(amount.toStringPresentation)
                                    .frame(width: 40)
                            }
                        }
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button(role: .destructive) {
                                controller.delete(payables[index])
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
                } header: {
                    Text("Product List")
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
