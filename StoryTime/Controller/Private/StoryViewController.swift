//
//  StoryViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/16/17.
//

import UIKit

class StoryViewController: BaseViewController {
    
    var story: Story!

    override func viewDidLoad() {
        super.viewDidLoad()

        loadStory()
    }
    
    func loadStory() {
        Story.loadStory { (story) in
            
            print("Story max level: \(story.levels.count)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
