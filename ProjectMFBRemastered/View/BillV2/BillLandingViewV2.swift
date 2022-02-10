//
//  BillLandingViewV2.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-24.
//

import SwiftUI

struct BillLandingViewV2: View {
    @EnvironmentObject var appData: AppData
    @Environment(\.managedObjectContext) private var viewContext
    
    var room: Tag
    
    @State var data: BillData? = nil
    
    var body: some View {
        Group {
            if let data = data {
                BillViewV2() {
                    self.data = nil
                }
                    .environmentObject(appData)
                    .environmentObject(data)
                    .environmentObject(PayableRatedPayableSelectionController(viewContext))
            } else {
                BillSetupView(room: room) { data = $0 }
                .navigationTitle(room.name ?? "ERR")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let bill = room.activeBill, !bill.completed {
                data = BillData(context: viewContext, bill: bill)
            }
        }
    }
}
