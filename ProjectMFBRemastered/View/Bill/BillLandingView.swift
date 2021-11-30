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
                BillView(data: data) {
                    self.data = nil
                }
                    .environmentObject(appData)
            } else {
                BillSetupView(room: room) { data = $0 }
            }
        }
        .onAppear {
            if let bill = room.activeBill {
                data = BillData(context: viewContext, bill: bill)
            }
        }
    }
}
