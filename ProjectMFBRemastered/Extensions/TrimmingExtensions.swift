//
//  TrimmingExtensions.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-12.
//

import Foundation

extension String {
    mutating func trimmingWhitespacesAndNewlines() {
        self = self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
