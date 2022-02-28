//
//  WelcomeViewStella.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-02-27.
//

import SwiftUI

struct WelcomeViewStella: View {
    var body: some View {
        VStack {
            Spacer()
            Text("今天辛苦啦～明天依旧光芒万丈哦~")
            Text("宝贝～❤️")
            HStack {
                Spacer()
                Text("- Stella")
                    .padding(.trailing, 50)
            }
            Spacer()
            Divider()
            VStack {
                Text("MFB Cashier")
                    .bold()
                    .font(.largeTitle)
                Text("Infinity Black Mississauga")
            }
            .padding(.bottom)
        }
        .background(Color(red: 250 / 255, green: 218 / 255, blue: 221 / 255))
        .ignoresSafeArea()
    }
}

struct WelcomeViewStella_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeViewStella()
    }
}
