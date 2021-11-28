//
//  BillAnimationTestView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-27.
//

import SwiftUI

struct BillAnimationTestView: View {
    @State var left = false
    
    var body: some View {
        VStack {
            HStack {
                if !left {
                    Spacer()
                }
                Text("Hello, World!")
                    .frame(width: left ? 160 : nil)
                    .background(Color.red)
                Text("$5.00")
                if left {
                    Spacer()
                }
            }
            Button {
                withAnimation {
                    left.toggle()
                }
            } label: {
                Text("Click Me")
            }

        }
    }
}

struct BillAnimationTestView_Previews: PreviewProvider {
    static var previews: some View {
        BillAnimationTestView()
    }
}
