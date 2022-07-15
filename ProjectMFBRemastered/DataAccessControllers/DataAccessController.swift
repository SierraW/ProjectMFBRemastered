//
//  DataAccessController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-12.
//

import Foundation

enum RequestMethod: String {
    case POST
    case GET
    case PUT
}

class DataAccessController<T: Decodable> {
    let baseUrl = "http://127.0.0.1:8000/"
    
    func buildRequest(for uri: String, with parameters: [String: Any]? = nil, using method: RequestMethod = .GET) async throws -> URLRequest {
        guard let url = URL(string: baseUrl + uri) else {
            print("[FATAL] AuthenticationController authenticate URL invalid.")
            throw DataLinkError.URLInvalid
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let parameters = parameters {
            request.httpBody = parameters.percentEncoded()
        }
        return request
    }
    
    func send(request: URLRequest) async throws -> T {
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let result = try? JSONDecoder().decode(T.self, from: data) else {
            throw DataLinkError.DecodeFailed
        }
        return result
    }
}

class AuthenticatedDataAccessController<T: Decodable>: DataAccessController<T> {
    let authenticationProfile: MFBAuthentication?
    
    init(_ authenticationProfile: MFBAuthentication? = nil) {
        self.authenticationProfile = authenticationProfile
    }
    
    override func buildRequest(for uri: String, with parameters: [String : Any]? = nil, using method: RequestMethod = .GET) async throws -> URLRequest {
        var request = try await super.buildRequest(for: uri, with: parameters, using: method)
        if let authenticationProfile = authenticationProfile {
            request.setValue("Bearer \(authenticationProfile.access)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    func get(to url: String = "") async -> T? {
        guard let request = try? await self.buildRequest(for: url), let result = try? await self.send(request: request) else {
            return nil
        }
        return result
    }
    
    func post(to url: String = "", with parameters: [String : Any]? = nil) async -> T? {
        guard let request = try? await self.buildRequest(for: url, with: parameters, using: .POST), let result = try? await self.send(request: request) else {
            return nil
        }
        return result
    }
}
