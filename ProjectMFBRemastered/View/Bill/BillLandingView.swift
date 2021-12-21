//
//  BillSetupView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-24.
//

import SwiftUI

struct BillLandingView: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.managedObjectContext) private var viewContext
    
    var room: Tag
    
    @State var data: BillData? = nil
    
    var body: some View {
        Group {
            if let data = data {
                BillView {
                    self.data = nil
                }
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(appData)
                    .environmentObject(data)
            } else {
                BillSetupView(room: room) { data = $0 }
            }
        }
        .onAppear {
            if let bill = room.activeBill, !bill.completed {
                data = BillData(context: viewContext, bill: bill)
            }
        }
    }
}
