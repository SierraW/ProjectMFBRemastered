//
//  ContentWrapperView.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-12.
//

import SwiftUI

struct ContentWrapperView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var title: String
    var content: () -> AnyView
    
    var body: some View {
        content()
            .navigationTitle(title)
    }
}

struct ContentWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        ContentWrapperView(title: "gugubird") {
            AnyView(Text("here"))
        }
    }
}
