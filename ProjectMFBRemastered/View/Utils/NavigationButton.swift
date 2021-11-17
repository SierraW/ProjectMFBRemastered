//
//  NavigationButton.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-16.
//

import SwiftUI

struct NavigationButton: View {
    var title: String
    var selected: Bool
    var onSelect: () -> Void
    
    var body: some View {
        Button {
            onSelect()
        } label: {
            Text(title)
        }
        .padding(.horizontal)
        .padding(.vertical, 3)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color(selected ? UIColor.systemFill : UIColor.systemBackground)))


    }
}
