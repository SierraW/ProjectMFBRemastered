//
//  StateExtension.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-27.
//

import Foundation

extension Bill {
    var completed: Bool {
        self.proceedBalance != nil
    }
    
    var combined: Bool {
        self.children?.count != 0
    }
}
