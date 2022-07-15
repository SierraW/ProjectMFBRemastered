//
//  MembershipController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-14.
//

import Foundation

class MembershipDataAccessController: AuthenticatedDataAccessController<MFBPagedMembership> {
    func list() async -> MFBPagedMembership? {
        return await super.get(to: "membership_account/list/")
    }
}
