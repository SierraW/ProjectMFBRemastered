//
//  RoomNavigationView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-20.
//

import SwiftUI

struct RoomNavigationView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)],
        predicate: NSPredicate(format: "is_room = YES"),
        animation: .default)
    private var fetchedRooms: FetchedResults<Tag>
    
    
    
    var rooms: [Tag] {
        return fetchedRooms.sorted()
    }
    
    var body: some View {
        Section {
            HStack {
                Text("Rooms")
                    .bold()
                .foregroundColor(.gray)
                Spacer()
            }
            if rooms.isEmpty {
                Text("No Room Found")
                    .foregroundColor(.gray)
                    .padding(.leading)
            }
            ForEach(rooms.indices, id: \.self) { index in
                NavigationLink {
                    BillLandingView(room: rooms[index])
                } label: {
                    HStack {
                        if index < 50 {
                            Image(systemName: "\(index + 1).square")
                        } else {
                            Image(systemName: "ellipsis")
                        }
                        Text(rooms[index].toStringRepresentation)
                        Spacer()
                    }
                }
                .listRowSeparator(.hidden)
                .padding(.leading)
            }
        }
    }
}

struct RoomNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            RoomNavigationView()
        }
    }
}
