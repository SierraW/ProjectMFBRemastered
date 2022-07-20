//
//  MembershipController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-14.
//

import Foundation

class MembershipDataAccessController: AuthenticatedDataAccessController<MFBPagedDataModel<MFBMembership>> {
    func list(override url: String? = nil) async -> (MFBPagedDataModel<MFBMembership>?, Int) {
        return await super.get(to: url ?? self.baseUrl + "membership_account/list/")
    }
    
    func search(for key: String) async -> (MFBPagedDataModel<MFBMembership>?, Int) {
        return await super.get(to: self.baseUrl + "membership_account/search/" + key)
    }
}
