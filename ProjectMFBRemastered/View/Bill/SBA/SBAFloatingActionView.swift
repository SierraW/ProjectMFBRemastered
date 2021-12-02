//
//  SBAFloatingActionView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-30.
//

import SwiftUI

struct SBAFloatingActionView: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var data: BillData
    
    var ableToSubmit: Bool {
        data.children.first(where: {!$0.completed}) == nil
    }
    
    @Binding var selection: Set<Bill>
    
    var onPayment: () -> Void
    
    var onExit: () -> Void
    
    var body: some View {
        HStack {
            if !selection.isEmpty {
                Button {
                    onPayment()
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "tray.and.arrow.down")
                        Text("Make A Payment")
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemGray5)))
                }
                .transition(.moveAndFade)
            }
        }
    }
}
