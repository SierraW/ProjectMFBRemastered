//
//  UserManagementView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-01.
//

import SwiftUI

struct UserManagementView: View {
    // environment
    @EnvironmentObject var appData: AppData
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    // fetch requests
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.username, ascending: true)],
        animation: .default)
    private var fetchedUsers: FetchedResults<User>
    
    var users: [User] {
        switch sortType {
        default:
            return fetchedUsers.map({$0})
        }
    }
    
    // controller
    var controller: AccountController {
        AccountController(viewContext)
    }
    
    // sort type
    @State var sortType: SortType = .name
    
    enum SortType: String, CaseIterable {
        case name = "Name"
    }
    
    var body: some View {
        Form {
            // default section
            Section {
                ForEach(users) { user in
                    NavigationLink {
                        UserEditorView(controller: controller, user: user, users: users, onDelete: { user in
                            withAnimation {
                                controller.delete(user)
                            }
                        })
                    } label: {
                        HStack {
                            Text(user.toStringRepresentation)
                            Spacer()
                            Text(user.disabled ? "Disabled" : "Active")
                                .foregroundColor(user.disabled ? .red : .green)
                        }
                    }
                }
            } header: {
                Text("User List")
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
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}
