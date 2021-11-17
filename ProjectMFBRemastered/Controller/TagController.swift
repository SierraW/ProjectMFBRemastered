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
    
    func modifyOrCreateIfNotExist(_ tag: Tag?, name: String, is_room: Bool = false, starred: Bool = false) -> Bool {
        if let tag = tag {
            return modifyTag(tag, with: name, is_room: is_room, starred: starred)
        } else {
            return modifyTag(Tag(context: viewContext), with: name, is_room: is_room, starred: starred)
        }
    }
    
    func modifyTag(_ tag: Tag, with name: String, is_room: Bool = false, starred: Bool = false) -> Bool {
        if let oldName = tag.name, oldName != name, fetchTags().contains(where: { tag in
            tag.name == name
        }) {
            return false
        }
        tag.name = name
        tag.is_room = is_room
        tag.starred = starred
        managedSave()
        return true
    }
    
    func delete(_ tag: Tag) {
        viewContext.delete(tag)
        managedSave()
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