//
//  Library.swift
//  StoryTime
//
//  Created by Administrator on 12/16/17.
//

import Foundation
import UIKit
import FirebaseDatabase

class Library {
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
        var stories: [Story] = []
        
        class Story {
            var refId: String
            var name = ""
            var screenshotName = ""
            var summary = ""
            var keyMetrics = ""
            var sentences: [String] = []
            
            struct StoryKey {
                static let nameKey = "name"
                static let screenshotNameKey = "screenshotName"
                static let summaryKey = "summary"
                static let keyMetricsKey = "keyMetrics"
                static let sentencesKey = "sentences"
            }
            
            init(_ snapshot: DataSnapshot) {
                refId = snapshot.key
                
                if let value = snapshot.value as? NSDictionary {
                    name = value[StoryKey.nameKey] as? String ?? ""
                    screenshotName = value[StoryKey.screenshotNameKey] as? String ?? ""
                    summary = value[StoryKey.summaryKey] as? String ?? ""
                    keyMetrics = value[StoryKey.keyMetricsKey] as? String ?? ""
                    let sentencesString = value[StoryKey.sentencesKey] as? String ?? ""
                    sentences = sentencesString.components(separatedBy: "\n")
                }
            }
        }
        
        init(_ snapshot: DataSnapshot) {
            let index = snapshot.key.index(snapshot.key.endIndex, offsetBy: -(snapshot.key.count - 5))
            let levelString = snapshot.key.suffix(from: index)
            level = Int(levelString)!
            
            let storyEnumerator = snapshot.children
            while let storySnapshot = storyEnumerator.nextObject() as? DataSnapshot {
                let book = Level.Story(storySnapshot)
                stories.append(book)
            }
        }
    }
}

// MARK: API
extension Library {
    static func loadLibrary(_ completionHandler: @escaping (_ library: Library) -> Swift.Void) {
        Firebase.shared.read("library") { (snapshot) in
            let story = Library(snapshot)
            completionHandler(story)
        }
    }
    
    static func loadStoryScreenshot(_ story: Library.Level.Story, _ completionHandler: @escaping (_ image: UIImage?) -> Swift.Void) {
        Firebase.shared.download("storyScreenshot/\(story.screenshotName)") { (data) in
            if let data = data {
                completionHandler(UIImage(data: data))
            } else {
                completionHandler(nil)
            }
        }
    }
}
