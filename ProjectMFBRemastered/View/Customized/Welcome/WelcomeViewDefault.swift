//
//  WelcomeViewDefault.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-29.
//

import SwiftUI

struct WelcomeViewDefault: View {
    var body: some View {
        VStack {
            Spacer()
            Text("MFB Cashier")
                .bold()
                .font(.largeTitle)
            Text("Infinity Black Mississauga")
            Spacer()
            HStack {
                Spacer()
                Text("MFB Cashier © 2021 Yiyao Zhang")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }
}

struct WelcomeViewDefault_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeViewDefault()
    }
}
