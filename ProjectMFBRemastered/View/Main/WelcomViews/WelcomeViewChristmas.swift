//
//  WelcomeView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-16.
//

import SwiftUI

struct WelcomeViewChristmas: View {
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            Text("🎄Happy Holiday❄️")
                                .bold()
                            .font(.system(size: 40))
                            Text("Warmest thoughts and Best wishes for a wonderful Holiday and a very Happy New Year.")
                                .font(.custom("Noteworthy-Bold", size: 20))
                                .padding()
                            HStack {
                                Spacer()
                                Text("- To Stella, Angela, and Linken")
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                        .frame(height: geometry.size.height * 0.4)
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("MFB Cashier © 2021 Yiyao Zhang")
                        .padding()
                }
            }
        }
        .ignoresSafeArea()
        .background(MFBBackground())
    }
}

struct WelcomeViewChristmas_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeViewChristmas()
    }
}
