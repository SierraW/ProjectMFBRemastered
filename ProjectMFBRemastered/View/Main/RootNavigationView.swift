//
//  RootNavigationView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-01.
//

import SwiftUI

struct RootNavigationView: View {
    var body: some View {
        Section {
            HStack {
                Text("Root Only")
                    .bold()
                .foregroundColor(.gray)
                Spacer()
            }
            NavigationLink {
                DatabaseMonitor()
            } label: {
                HStack {
                    Text("Resource Monitor")
                    Spacer()
                }
            }
            .listRowSeparator(.hidden)
            .padding(.leading)
        }
    }
}

struct RootNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        RootNavigationView()
    }
}
