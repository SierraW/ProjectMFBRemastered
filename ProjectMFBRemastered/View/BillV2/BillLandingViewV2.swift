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
                BillViewV2 {
                    self.data = nil
                }
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(appData)
                    .environmentObject(data)
            } else {
                BillSetupView(room: room) {
                    if let taxItem = RatedPayableController.firstTaxRatedPayable(viewContext) {
                        $0.addItem(taxItem)
                    }
                    data = $0
                }
            }
        }
        .onAppear {
            if let bill = room.activeBill, !bill.completed {
                data = BillData(context: viewContext, bill: bill)
            }
        }
    }
}
