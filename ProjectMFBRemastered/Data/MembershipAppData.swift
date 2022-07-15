//
//  MembershipAppData.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-11.
//

import Foundation
import Combine

class MembershipAppData: ObservableObject {
    @Published var authentication: MFBAuthentication
    @Published var majorCurrency: MFBCurrency
    var onLogout: () -> Void
    
    init (profile authentication: MFBAuthentication, majorCurrency: MFBCurrency, onLogout: @escaping () -> Void) {
        self.authentication = authentication
        self.majorCurrency = majorCurrency
        self.onLogout = onLogout
    }
}
