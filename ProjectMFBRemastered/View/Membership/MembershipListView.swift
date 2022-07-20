//
//  MembershipListView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-14.
//

import SwiftUI

struct MembershipListView: View {
    @EnvironmentObject var membershipData: MembershipData
    @State var searchString = ""
    @State var isLoading = false
    
    var onSelect: (Int) -> Void
    
    func refresh(_ newValue: String? = nil) {
        var value = newValue ?? searchString
        value.trimmingWhitespacesAndNewlines()
        if value.isEmpty {
            let _ = membershipData.fetchAll()
        } else {
            let _ = membershipData.search(for: value)
        }
    }
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                if (membershipData.memberships.isEmpty) {
                    List([0], id: \.self) { val in
                        Text("No Data")
                    }
                    .refreshable {
                        withAnimation {
                            refresh()
                        }
                    }
                } else {
                    List(membershipData.memberships.indices, id: \.self) { index in
                        MembershipIdentityView(membership: membershipData.memberships[index])
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onSelect(index)
                            }
                    }
                    .refreshable {
                        withAnimation {
                            refresh()
                        }
                    }
                }
            }
        }
        .searchable(text: $searchString)
        .navigationBarTitle("Membership")
        .onChange(of: searchString, perform: { newValue in
            refresh(newValue)
        })
        .onAppear {
            refresh()
        }
    }
}
