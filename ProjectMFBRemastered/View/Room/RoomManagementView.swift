//
//  RoomManagementView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-16.
//

import SwiftUI

struct RoomManagementView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)],
        predicate: NSPredicate(format: "is_room = YES"),
        animation: .default)
    private var fetchedRooms: FetchedResults<Tag>
    
    var rooms: [Tag] {
        switch sortType {
        default:
            return fetchedRooms.map({$0})
        }
    }
    
    var controller: TagController {
        TagController(viewContext)
    }
    
    @State var editingRoomIndex: Int? = nil
    
    @State var sortType: SortType = .name
    
    enum SortType: String, CaseIterable {
        case name = "Name"
    }
    
    var body: some View {
        Form {
            Section {
                ForEach(rooms.indices, id:\.self) { index in
                    HStack {
                        Text(rooms[index].toStringRepresentation)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .contextMenu {
                        Button(role: .destructive) {
                            controller.delete(rooms[index])
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete")
                            }
                            
                        }
                    }
                    .onTapGesture {
                        if editingRoomIndex == nil {
                            editingRoomIndex = index
                        }
                    }
                }
            } header: {
                Text("Room List")
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .sheet(item: $editingRoomIndex) { index in
            VStack {
                HStack {
                    Image(systemName: "chevron.down.circle")
                        .foregroundColor(.gray)
                        .frame(width:50)
                    Spacer()
                    Text("Room Editor")
                        .bold()
                    Spacer()
                    Spacer()
                        .frame(width:50)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        editingRoomIndex = nil
                    }
                }
                .padding()
                RoomEditorView(controller: controller, room: index == -1 ? nil : rooms[index], rooms: rooms, onDelete: { room in
                    withAnimation {
                        editingRoomIndex = nil
                        controller.delete(room)
                    }
                }, onExit: {
                    withAnimation {
                        editingRoomIndex = nil
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
                            editingRoomIndex = -1
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add new room")
                        }
                        
                    }
                    Spacer()
                }
            }
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
