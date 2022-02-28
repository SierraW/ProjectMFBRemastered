//
//  BillCompleteViewStella.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-02-27.
//

import SwiftUI

struct BillCompleteViewStella: View {
    
    let onClick: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            Text("今天辛苦啦～明天依旧光芒万丈哦~")
            Text("宝贝～❤️")
            Divider()
            Button("Start A New Bill") {
                onClick()
            }
            Spacer()
        }
        .background(Color(red: 250 / 255, green: 218 / 255, blue: 221 / 255))
        .ignoresSafeArea()
    }
}

struct BillCompleteViewStella_Previews: PreviewProvider {
    static var previews: some View {
        BillCompleteViewStella {
            
        }
    }
}
