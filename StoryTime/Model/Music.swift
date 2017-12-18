//
//  Music.swift
//  StoryTime
//
//  Created by Administrator on 12/15/17.
//

import Foundation
import FirebaseDatabase

class Music {
    let refId: String!
    let name: String
    let purchaseItemId: String
    
    struct MusicKey {
        static let nameKey = "name"
        static let purchaseItemIdKey = "purchaseItemId"
    }
    
    init(_ snapshot: DataSnapshot) {
        refId = snapshot.key
        if let value = snapshot.value as? NSDictionary {
            name = value[MusicKey.nameKey] as? String ?? ""
            purchaseItemId = value[MusicKey.purchaseItemIdKey] as? String ?? ""
        } else {
            name = ""
            purchaseItemId = ""
        }
    }
}

// MARK: API
extension Music {
    static func loadMusics(_ completionHandler: @escaping (_ : [Music]) -> Swift.Void) {
        Firebase.shared.read("store/music") { (snapshot) in
            var musics: [Music] = []
            let enumerator = snapshot.children
            while let childSnapshot = enumerator.nextObject() as? DataSnapshot {
                let music = Music(childSnapshot)
                musics.append(music)
            }
            completionHandler(musics)
        }
    }
}
