//
//  MembershipManagementView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-18.
//

import SwiftUI

struct MembershipManagementView: View {
    // environment
    @EnvironmentObject var membershipData: MembershipData
    
    @Environment(\.presentationMode) var presentationMode
    
    
    var memberships: [MFBMembership] {
        switch sortType {
        default:
            return membershipData.memberships.map({$0})
        }
    }
    
    // edit control
    @State var editingTagIndex: Int? = nil
    
    // sort type
    @State var sortType: SortType = .name
    
    enum SortType: String, CaseIterable {
        case name = "Name"
    }
    
    var body: some View {
        VStack {
            MembershipListView { index in
                withAnimation {
                    editingTagIndex = index
                }
            }
                .environmentObject(membershipData)
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
        .sheet(item: $editingTagIndex) { index in
            VStack {
                MembershipEditorView(membershipIndex: index, onDelete: { membership in
                    //
                }, onExit: {
                    withAnimation {
                        editingTagIndex = nil
                    }
                })
                    .environmentObject(membershipData)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                        withAnimation {
                            editingTagIndex = -1
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add new membership")
                        }
                        
                    }
                    Spacer()
                }
            }
        }
    }
}
