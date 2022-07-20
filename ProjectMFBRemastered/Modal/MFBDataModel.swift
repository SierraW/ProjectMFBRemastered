//
//  MFBDataModal.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2022-07-07.
//

import Foundation

protocol MFBDataModel: Codable {
    var id: Int64 {get set}
    
    var toDict: [String: Any] { get }
    
}

protocol MFBBasicModel: MFBDataModel {
    var starred: Bool {get set}
    var disabled: Bool {get set}
    var dateCreated: String {get set}
    var lastModified: String {get set}
}

protocol MFBPagination: Codable {
    associatedtype DataModel = MFBDataModel
    var count: Int {get set}
    var next: String? {get set}
    var previous: String? {get set}
    var results: [DataModel] {get set}
}


struct MFBPagedDataModel<T: MFBDataModel>: MFBPagination {
    var count: Int
    
    var next: String?
    
    var previous: String?
    
    var results: [T]
    
}
