//
//  Icon.swift
//  StoryTime
//
//  Created by Administrator on 12/15/17.
//

import Foundation
import UIKit
import FirebaseDatabase

class Icon {
    let refId: String!
    let purchaseItemId: String
    
    struct IconKey {
        static let purchaseItemIdKey = "purchaseItemId"
    }
    
    init(_ snapshot: DataSnapshot) {
        refId = snapshot.key
        if let value = snapshot.value as? NSDictionary {
            purchaseItemId = value[IconKey.purchaseItemIdKey] as? String ?? ""
        } else {
            purchaseItemId = ""
        }
    }
}

// MARK: API
extension Icon {
    static func loadIcons(_ completionHandler: @escaping (_ icons: [Icon]) -> Swift.Void) {
        Firebase.shared.read("store/icon") { (snapshot) in
            var icons: [Icon] = []
            let enumerator = snapshot.children
            while let childSnapshot = enumerator.nextObject() as? DataSnapshot {
                let icon = Icon(childSnapshot)
                icons.append(icon)
            }
            completionHandler(icons)
        }
    }
    
    static func loadIconImage(_ filename: String, _ completionHandler: @escaping (_ image: UIImage?) -> Swift.Void) {
        Firebase.shared.download("icon/\(filename)") { (data) in
            if let data = data {
                completionHandler(UIImage(data: data))
            } else {
                completionHandler(nil)
            }
        }
    }
}
