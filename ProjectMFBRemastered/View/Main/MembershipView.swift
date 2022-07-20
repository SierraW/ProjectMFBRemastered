//
//  MembershipView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-11.
//

import SwiftUI

struct MembershipView: View {
    @EnvironmentObject private var appData: AppData
    
    var body: some View {
        Section {
            HStack {
                Text("Membership")
                    .bold()
                .foregroundColor(.gray)
                Spacer()
            }
            NavigationLink {
                MembershipMainView()
            } label: {
                HStack {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.green)
                        .background(RoundedRectangle(cornerRadius: 4).fill(.white)
                                        .frame(width: 22, height: 22, alignment: .center))
                    Text("Membership")
                    Spacer()
                }
            }
            .listRowSeparator(.hidden)
            .padding()
            
        }
    }
}
