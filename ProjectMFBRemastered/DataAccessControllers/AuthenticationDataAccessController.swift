//
//  AuthenticationController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-07.
//

import Foundation


class AuthenticationDataAccessController: DataAccessController<MFBAuthentication> {
    func authenticate(with username: String, _ password: String) async -> (MFBAuthentication?, Int) {
        let parameters: [String: Any] = [
            "username": username,
            "password": password
        ]
        guard let request = try? await self.buildRequest(for: self.baseUrl + "api/token/", with: parameters, using: .POST) else {
            return (nil, 500)
        }
        return await self.send(request: request)
    }
    
    func authenticate(with currentAuthenticationProfile: MFBAuthentication) async -> MFBAuthentication? {
        let parameters: [String: Any] = [
            "refresh": currentAuthenticationProfile.refresh
        ]
        guard let request = try? await self.buildRequest(for: self.baseUrl + "api/token/refresh/", with: parameters, using: .POST), let (data, _) = try? await URLSession.shared.data(for: request), let result = try? JSONDecoder().decode(MFBAuthenticationAccess.self, from: data) else {
            return nil
        }
        return MFBAuthentication(access: result.access, refresh: currentAuthenticationProfile.refresh)
    }
}

