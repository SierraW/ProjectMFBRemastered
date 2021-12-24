//
//  IdentifierableExtensions.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-12.
//

import Foundation

extension Int: Identifiable {
    public var id: String {
        "\(self)"
    }
}

extension BillItem {
    public var smartId: String {
        "\(self.name ?? "err")\(self.count)"
    }
}
