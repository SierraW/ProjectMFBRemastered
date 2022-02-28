//
//  BillCompleteView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-02-27.
//

import SwiftUI

struct BillCompleteView: View {
    
    let onClick: () -> Void
    
    var body: some View {
        BillCompleteViewStella {
            onClick()
        }
    }
}
