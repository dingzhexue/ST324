//
//  Theme.swift
//  StoryTime
//
//  Created by Administrator on 12/15/17.
//

import Foundation
import FirebaseDatabase

class Theme {
    let refId: String!
    let type: ThemeType
    let name: String
    let purchaseItemId: String
    
    struct ThemeKey {
        static let nameKey = "name"
        static let purchaseItemIdKey = "purchaseItemId"
    }
    
    init(_ snapshot: DataSnapshot) {
        refId = snapshot.key
        if let value = snapshot.value as? NSDictionary {
            name = value[ThemeKey.nameKey] as? String ?? ""
            purchaseItemId = value[ThemeKey.purchaseItemIdKey] as? String ?? ""
        } else {
            name = ""
            purchaseItemId = ""
        }
        
        type = ThemeType(rawValue: name)!
    }
    
    enum ThemeType: String {
        case Bright = "bright"
        case Monochrome = "monochrome"
        case Dark = "dark"
        case Subtle = "subtle"
    }
}

// MARK: API
extension Theme {
    static func loadThemes(_ completionHandler: @escaping (_ themes: [Theme]) -> Swift.Void) {
        Firebase.shared.read("store/theme") { (snapshot) in
            var themes: [Theme] = []
            let enumerator = snapshot.children
            while let childSnapshot = enumerator.nextObject() as? DataSnapshot {
                let theme = Theme(childSnapshot)
                themes.append(theme)
            }
            completionHandler(themes)
        }
    }
}
