//
//  SearchBar.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-18.
//

import SwiftUI

struct SearchBar: View {
    
    var textFieldNotEmpty: Bool {
        !text.isEmpty
    }
    
    @Binding var text: String
    
    var onCommit: () -> Void
    
    var body: some View {
        HStack {
            
            TextField("Search...", text: $text, onCommit: {
                onCommit()
            })
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 17)
                        if textFieldNotEmpty {
                            Button(action: {
                                clear()
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 20)
                            }
                        }
                    }
                )
        }
        
    }
    
    func clear() {
        DispatchQueue.main.async {
            text = ""
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant("")) {
            
        }
    }
}
