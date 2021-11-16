//
//  DecimalField.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-15.
//

import SwiftUI
import Combine

struct DecimalField: View {
    @State var lastValue: String = "0"
    
    var placeholder = "Optional"
    
    @Binding var value: String
    
    let limitToPlaces = 2
    
    var onCommit: ((String) -> Void)?
    
    var body: some View {
        TextField(placeholder, text: $value, onCommit:  {
            if let onCommit = onCommit {
                onCommit(lastValue)
            }
        })
            .keyboardType(.decimalPad)
            .onReceive(Just(value)) { newValue in
                
                var editedString = newValue.replacingOccurrences(of: ".", with: "")
                if let correctedInt = Int(editedString) {
                    editedString = "\(correctedInt)"
                    while(editedString.count <= limitToPlaces) {
                        editedString.insert("0", at: editedString.startIndex)
                    }
                    let count = editedString.count
                    editedString.insert(".", at: editedString.index(editedString.startIndex, offsetBy: count - limitToPlaces))
                    value = editedString
                    lastValue = editedString
                } else {
                    value = lastValue
                }
                
            }
    }
}

struct DecimalField_Previews: PreviewProvider {
    static var previews: some View {
        DecimalField(value: .constant("0"))
    }
}
