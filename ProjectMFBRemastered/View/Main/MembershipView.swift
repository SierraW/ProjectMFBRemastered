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
                    Image(systemName: "bookmark.square.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.orange)
                        .background(RoundedRectangle(cornerRadius: 4).fill(.white)
                                        .frame(width: 22, height: 22, alignment: .center))
                    Text("Histories")
                    Spacer()
                }
            }
            .listRowSeparator(.hidden)
            .padding()
            NavigationLink {
                IndividualBillReportView()
                    .environmentObject(appData)
                    .navigationTitle("Individual Report")
            } label: {
                HStack {
                    Image(systemName: "star.square.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.purple)
                        .background(RoundedRectangle(cornerRadius: 4).fill(.white)
                                        .frame(width: 22, height: 22, alignment: .center))
                    Text("Individual Report")
                    Spacer()
                }
            }
            .listRowSeparator(.hidden)
            .padding()
            NavigationLink {
                FormalBillReportView()
                    .environmentObject(appData)
                    .navigationTitle("Formal Report")
            } label: {
                HStack {
                    Image(systemName: "square.text.square.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.red)
                        .background(RoundedRectangle(cornerRadius: 4).fill(.white)
                                        .frame(width: 22, height: 22, alignment: .center))
                    Text("Formal Report")
                    Spacer()
                }
            }
            .listRowSeparator(.hidden)
            .padding()
        }
    }
}
