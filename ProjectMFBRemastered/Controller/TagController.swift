//
//  TagController.swift
//  ProjectMFBRemastered
//
//  Created by Yiyao Zhang on 2021-11-16.
//

import Foundation
import CoreData

class TagController: ModelController {
    
    func fetchTags() -> [Tag] {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: false)]
        do {
            let result = try viewContext.fetch(fetchRequest)
            return result
        } catch {
            print("Fetch error in Payment Method Controller")
        }
        return []
    }
    
    func modifyOrCreateIfNotExist(name: String, tag: Tag? = nil, is_group: Bool = false, is_room: Bool = false, is_payable: Bool = false, is_rated: Bool = false, is_associated: Bool = false, starred: Bool = false) -> Tag? {
        if tag?.name != name && fetchTags().contains(where: { tag in
            tag.name == name
        }) {
            return nil
        }
        if let tag = tag {
            return modifyTag(name: name, tag: tag, is_group: is_group, is_room: is_room, is_payable: is_payable, is_rated: is_rated, is_associated: is_associated, starred: starred)
        } else {
            return modifyTag(name: name, tag: Tag(context: viewContext), is_group: is_group, is_room: is_room, is_payable: is_payable, is_rated: is_rated, is_associated: is_associated, starred: starred)
        }
    }
    
    private func modifyTag(name: String, tag: Tag, is_group: Bool = false, is_room: Bool = false, is_payable: Bool = false, is_rated: Bool = false, is_associated: Bool = false, starred: Bool = false) -> Tag? {
        tag.name = name
        tag.is_room = is_room
        tag.is_group = is_group
        tag.is_payable = is_payable
        tag.is_rated = is_rated
        tag.is_associated = is_associated
        tag.starred = starred
        managedSave()
        return tag
    }
    
    func assignParent(for childTag: Tag, asChildrenOf parentTag: Tag) -> Bool {
        if Self.detectLoop(for: childTag, asChildrenOf: parentTag) {
            return false
        }
        childTag.parent = parentTag
        managedSave()
        return true
    }
    
    static func findRootTags(from tags: [Tag]) -> [Tag] {
        var rootTags: [Tag] = []
        var visitedTagSet = Set<Tag>()
        
        func findParent(of tag: Tag) -> Tag? {
            let (inserted, _) = visitedTagSet.insert(tag)
            if !inserted {
                return nil
            }
            if tag.parent == nil {
                return tag
            }
            return findParent(of: tag.parent!)
        }
        
        tags.forEach { tag in
            if let rootTag = findParent(of: tag) {
                rootTags.append(rootTag)
            }
        }
        
        return rootTags
    }
    
    static func detectLoop(for tag: Tag, asChildrenOf parentTag: Tag) -> Bool {
        if parentTag.parent == nil {
            return false
        } else if parentTag.parent == tag {
            return true
        } else {
            return detectLoop(for: tag, asChildrenOf: parentTag.parent!)
        }
    }
    
}
