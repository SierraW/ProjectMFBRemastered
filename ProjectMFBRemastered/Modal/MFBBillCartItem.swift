//
// Created by Yiyao Zhang on 2022-08-10.
//

import Foundation


struct MFBBillCartItem: MFBDataModel {
    var id: Int64

    var item: MFBItem

    var count: Int

    var dateCreated: String

    var lastModified: String
}