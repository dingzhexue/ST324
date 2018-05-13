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
            var summary = ""
            var keyMetrics = ""
            //var screenshotName = ""
            //var sentences: [String] = []
            var previewURL = ""
            var scenes : [Scene] = []
            
            
            struct StoryKey {
                static let nameKey = "name"
                static let summaryKey = "summary"
                static let keyMetricsKey = "keyMetrics"
                //static let screenshotNameKey = "screenshotName"
                //static let sentencesKey = "sentences"
                static let storyKey = "story"
                static let previewURLKey = "previewURL"
            }
            //Init Story
            init(_ snapshot: DataSnapshot) {
                refId = snapshot.key
                
                if let value = snapshot.value as? NSDictionary {
                    name = value[StoryKey.nameKey] as? String ?? ""
                    previewURL = value[StoryKey.previewURLKey] as? String ?? ""
                    summary = value[StoryKey.summaryKey] as? String ?? ""
                    keyMetrics = value[StoryKey.keyMetricsKey] as? String ?? ""
                    //screenshotName = value[StoryKey.screenshotNameKey] as? String ?? ""
                    //let sentencesString = value[StoryKey.sentencesKey] as? String ?? ""
                    //sentences = sentencesString.components(separatedBy: "\n")
                    
                    let storydata = value[StoryKey.storyKey] as? Dictionary<String, Any>
                    
                    if storydata != nil {
                        let sortedKeys = Array(storydata!.keys).sorted()
                        
                        for key in sortedKeys{
                            let scene = Level.Story.Scene(storydata![key] as! Dictionary<String, Any>)
                            scenes.append(scene)
                        }
                    }
                    /*while let storySnapshot = storyEnumerator.nextObject() as? DataSnapshot{
                        let scene = Level.Story.Scene(storySnapshot)
                        story.append(scene)
                    }*/
                }
            }
            
            class Scene {
                var sentence = ""
                var fPosEnd = 1.0
                var fPosStart = 0.0
                var sentences : [String] = []
                init(_ story: Dictionary<String, Any>){
                    sentence = story["sentence"] as? String ?? ""
                    fPosEnd = story["posend"] as? Double ?? 0.0
                    fPosStart = story["posstart"] as? Double ?? 1.0
                    sentences = sentence.components(separatedBy: "#")
                }
            }
        }
        
        //Init Level
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
    
//    static func loadStoryScreenshot(_ story: Library.Level.Story, _ completionHandler: @escaping (_ image: UIImage?) -> Swift.Void) {
//        Firebase.shared.download("storyScreenshot/\(story.screenshotName)") { (data) in
//            if let data = data {
//                completionHandler(UIImage(data: data))
//            } else {
//                completionHandler(nil)
//            }
//        }
//    }
}
