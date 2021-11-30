//
//  RoundedButton.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-29.
//

import SwiftUI

struct RoundedButton: View {
    
    var action: (() -> Void)?
    
    var image: Image?
    var title: String
    
    var body: some View {
        Button {
            if let action = action {
                action()
            }
        } label: {
            HStack {
                if let image = image {
                    image
                }
                Text(title)
            }
                .frame(width: 120)
                .padding(.horizontal, 50)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(UIColor.systemGray4)))
        }

    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundedButton(image: Image(systemName: "3.circle"), title: "Submit")
    }
}
