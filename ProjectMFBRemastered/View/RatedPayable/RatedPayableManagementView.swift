//
//  RatedPayableManagementView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-18.
//

import SwiftUI

struct RatedPayableManagementView: View {
    // environment
    @EnvironmentObject var appData: AppData
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    // fetch requests
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \RatedPayable.starred, ascending: true)],
        animation: .default)
    private var fetchedRatedPayables: FetchedResults<RatedPayable>
    
    var ratedPayables: [RatedPayable] {
        switch sortType {
        default:
            return fetchedRatedPayables.map({$0})
        }
    }
    
    // controller
    var controller: RatedPayableController {
        RatedPayableController(viewContext)
    }
    
    // edit control
    @State var editingRatedPayableIndex: Int? = nil
    
    // sort type
    @State var sortType: SortType = .name
    
    @State var isLoading = false
    
    enum SortType: String, CaseIterable {
        case name = "Name"
    }
    
    var body: some View {
        if isLoading {
            Rectangle()
                .fill(Color(UIColor.systemGroupedBackground))
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
                    // default section
                    Section {
                        ForEach(ratedPayables.indices, id:\.self) { index in
                            RatedPayableViewCell(ratedPayable: ratedPayables[index])
                                .contentShape(Rectangle())
                                .contextMenu {
                                    Button(role: .destructive) {
                                        controller.delete(ratedPayables[index])
                                    } label: {
                                        HStack {
                                            Image(systemName: "trash")
                                            Text("Delete")
                                        }
                                        
                                    }
                                }
                                .onTapGesture {
                                    if editingRatedPayableIndex == nil {
                                        editingRatedPayableIndex = index
                                    }
                                }
                        }
                    }
                }
                Spacer()
                
                HStack {
                    Button {
                        withAnimation {
                            editingRatedPayableIndex = -1
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add new tax & service")
                        }
                        
                    }
                    .padding()
                    Spacer()
                }
                
            }
            .background(Color(UIColor.systemGroupedBackground))
            .sheet(item: $editingRatedPayableIndex) { index in
                VStack {
                    HStack {
                        Image(systemName: "chevron.down.circle")
                            .foregroundColor(.gray)
                            .frame(width:50)
                        Spacer()
                        Text("Tax & Service Editor")
                            .bold()
                        Spacer()
                        Spacer()
                            .frame(width:50)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            editingRatedPayableIndex = nil
                        }
                    }
                    .padding()
                    RatedPayableEditorView(controller: controller, ratedPayable: index == -1 ? nil : ratedPayables[index], ratedPayables: ratedPayables, onDelete: { ratedPayable in
                        withAnimation {
                            editingRatedPayableIndex = nil
                            controller.delete(ratedPayable)
                            isLoading = true
                        }
                    }, onExit: {
                        withAnimation {
                            editingRatedPayableIndex = nil
                            isLoading = true
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
                                    isLoading = true
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
