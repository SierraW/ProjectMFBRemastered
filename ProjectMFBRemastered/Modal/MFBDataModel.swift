//
//  MFBDataModal.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-07.
//

import Foundation

protocol MFBDataModel: Codable {
    var id: Int64 {get set}
    
}

protocol MFBBasicModel: MFBDataModel {
    var starred: Bool {get set}
    var disabled: Bool {get set}
    var dateCreated: String {get set}
    var lastModified: String {get set}
}

protocol MFBPaginationModel: Codable {
    associatedtype DataModel = MFBDataModel
    var count: Int {get set}
    var next: Int? {get set}
    var previous: Int? {get set}
    var results: [DataModel] {get set}
}
