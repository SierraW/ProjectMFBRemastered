//
//  MFBAuthentication.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-07.
//

import Foundation

protocol MFBAuthenticationBaseProtocol: Codable {
    var access: String {get}
}

struct MFBAuthenticationAccess: MFBAuthenticationBaseProtocol {
    var access: String
    
}

struct MFBAuthentication: MFBAuthenticationBaseProtocol {
    var access: String
    
    var refresh: String
}
