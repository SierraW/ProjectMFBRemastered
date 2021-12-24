//
//  BillNavigationView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-30.
//

import SwiftUI

struct BillNavigationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        Section {
            HStack {
                Text("Bills")
                    .bold()
                .foregroundColor(.gray)
                Spacer()
            }
            NavigationLink {
                HistoryBillListView()
                    .environment(\.managedObjectContext, viewContext)
            } label: {
                HStack {
                    Text("Histories")
                    Spacer()
                }
            }
            .listRowSeparator(.hidden)
            .padding()
        }
    }
}

struct BillNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        BillNavigationView()
    }
}
