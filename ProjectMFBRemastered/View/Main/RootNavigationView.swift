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
                    Image(systemName: "command.square.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.red)
                        .background(RoundedRectangle(cornerRadius: 4).fill(.white)
                                        .frame(width: 22, height: 22, alignment: .center))
                    Text("Resource Monitor")
                    Spacer()
                }
            }
            .listRowSeparator(.hidden)
            .padding()
        }
    }
}

struct RootNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        RootNavigationView()
    }
}
