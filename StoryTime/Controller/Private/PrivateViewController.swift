//
//  PrivateViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/15/17.
//

import UIKit

class PrivateViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SpeechRecognizer.shared.startRecording()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
