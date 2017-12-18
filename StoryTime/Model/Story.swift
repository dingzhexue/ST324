//
//  Story.swift
//  StoryTime
//
//  Created by Administrator on 12/16/17.
//

import Foundation
import FirebaseDatabase

class Story {
    var levels: [Level] = []
    
    init(_ snapshot: DataSnapshot) {
        let levelEnumerator = snapshot.children
        while let levelSnapshot = levelEnumerator.nextObject() as? DataSnapshot {
            let level = Level(levelSnapshot)
            levels.append(level)
        }
    }
    
    class Level {
        var level: Int
        var books: [Book] = []
        
        class Book {
            var name: String
            var sentences: [String] = []
            
            init(_ snapshot: DataSnapshot) {
                name = snapshot.key
                
                let sentenceEnumerator = snapshot.children
                while let sentenceSnapshot = sentenceEnumerator.nextObject() as? DataSnapshot {
                    let sentence = sentenceSnapshot.value as? String ?? ""
                    sentences.append(sentence)
                }
            }
        }
        
        init(_ snapshot: DataSnapshot) {
            let index = snapshot.key.index(snapshot.key.endIndex, offsetBy: -(snapshot.key.count - 5))
            let levelString = snapshot.key.suffix(from: index)
            level = Int(levelString)!
            
            let bookEnumerator = snapshot.children
            while let bookSnapshot = bookEnumerator.nextObject() as? DataSnapshot {
                let book = Level.Book(bookSnapshot)
                books.append(book)
            }
        }
    }
}

// MARK: API
extension Story {
    static func loadStory(_ completionHandler: @escaping (_ story: Story) -> Swift.Void) {
        Firebase.shared.read("story") { (snapshot) in
            let story = Story(snapshot)
            completionHandler(story)
        }
    }
}
