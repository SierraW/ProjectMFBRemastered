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
        return fetchedRooms.map({$0})
    }
    
    var body: some View {
        DisclosureGroup("Rooms") {
            ForEach(rooms) { room in
                NavigationLink {
                    BillLandingView(room: room)
                } label: {
                    Text(room.toStringPresentation)
                }
            }
        }
    }
}

struct RoomNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        RoomNavigationView()
    }
}
