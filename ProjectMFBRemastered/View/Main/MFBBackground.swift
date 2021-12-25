//
//  MFBBackground.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-12-25.
//

import SwiftUI

struct MFBBackground: View {
    var body: some View {
        LinearGradient(colors: [.init(red: 0.1, green: 0.25, blue: 0.5), .init(red: 0.75, green: 0.8, blue: 0.9)], startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea()
    }
}

struct MFBBackground_Previews: PreviewProvider {
    static var previews: some View {
        MFBBackground()
    }
}
