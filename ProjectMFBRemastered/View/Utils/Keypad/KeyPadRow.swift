//
//  KeyPadRow.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-22.
//

import SwiftUI

struct KeyPadRow: View {
    var keys: [String]

    var body: some View {
        HStack {
            ForEach(keys, id: \.self) { key in
                KeyPadButton(key: key)
            }
        }
    }
}
