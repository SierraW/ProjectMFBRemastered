//
//  BillCompleteViewDefault.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-02-27.
//

import SwiftUI

struct BillCompleteViewDefault: View {
    
    let onClick: () -> Void
    
    var body: some View {
        VStack {
            Text("This bill is completed")
            Button("Start new bill") {
                onClick()
            }
        }
    }
}

struct BillCompleteViewDefault_Previews: PreviewProvider {
    static var previews: some View {
        BillCompleteViewDefault {
            
        }
    }
}
