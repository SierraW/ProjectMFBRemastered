//
//  BillNavigationView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-30.
//

import SwiftUI

struct BillNavigationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var appData: AppData
    
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
                ReportPreparationView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(appData)
            } label: {
                HStack {
                    Image(systemName: "square.text.square.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.purple)
                        .background(RoundedRectangle(cornerRadius: 4).fill(.white)
                                        .frame(width: 22, height: 22, alignment: .center))
                    Text("[TEST]Report")
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
