//
//  KeyPad.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-22.
//

import SwiftUI

struct KeyPad: View {
    @Binding var value: String
    var decimalPlaces: Int = 2

    var body: some View {
        VStack {
            KeyPadRow(keys: ["1", "2", "3"])
            KeyPadRow(keys: ["4", "5", "6"])
            KeyPadRow(keys: ["7", "8", "9"])
            KeyPadRow(keys: ["c", "0", "⌫"])
        }.environment(\.keyPadButtonAction, self.keyWasPressed(_:))
    }

    private func keyWasPressed(_ key: String) {
        switch key {
        case "c" where value != "0": value = "0"
        case "⌫":
            value.removeLast()
            if value.isEmpty { value = "0" }
        case _ where value == "0": value = key
        default: value += key
        }
        
        var editedString = value.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: "")
        
        
        if let correctedInt = Int(editedString) {
            editedString = "\(correctedInt)"
            if decimalPlaces <= 0 {
                value = editedString
                return
            }
            while(editedString.count <= decimalPlaces) {
                editedString.insert("0", at: editedString.startIndex)
            }
            let count = editedString.count
            editedString.insert(".", at: editedString.index(editedString.startIndex, offsetBy: count - decimalPlaces))
            value = editedString
        } else {
            value = "0"
            if decimalPlaces > 0 {
                value += "."
                for _ in 0..<decimalPlaces {
                    value += "0"
                }
            }
        }
    }
}

