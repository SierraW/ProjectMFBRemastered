//
//  CurrencyDataController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-12.
//

import Foundation

class CurrencyDataAccessController: AuthenticatedDataAccessController<MFBCurrency> {
    
    func list() async -> [MFBCurrency]? {
        if self.authenticationProfile == nil {
            print("[FATAL] CurrencyDataAccessController list: no auth profile given")
            return nil
        }
        guard let request = try? await self.buildRequest(for: self.baseUrl + "currency/"), let (data, _) = try? await URLSession.shared.data(for: request), let result = try? JSONDecoder().decode([MFBCurrency].self, from: data) else {
            return nil
        }
        return result
    }
    
    func majorCurrency() async -> (MFBCurrency?, Int) {
        return await get(to: self.baseUrl + "currency/major/")
    }
}

