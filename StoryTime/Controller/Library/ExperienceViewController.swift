//
//  ExperienceViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/20/17.
//

import UIKit
import SwiftSiriWaveformView
class ExperienceViewController: BaseViewController {
    
    var timer:Timer?
    var change:CGFloat = 0.01
    var story: Library.Level.Story?
    
    
    @IBOutlet weak var btnStartRecog: UIButton!
    @IBOutlet weak var audioView: SwiftSiriWaveformView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var animatedScene: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    let speechRecognizer = SpeechRecognizer.shared
    var isStart = true
    var sentenceCount = 0
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.audioView.density = 1.0
        
        timer = Timer.scheduledTimer(timeInterval: 100,
                                     target: self,
                                     selector: #selector(refreshAudioView(_:)),
                                     userInfo: nil,
                                     repeats: true)
        //Round Button
        btnStartRecog.layer.cornerRadius = 10
        btnStartRecog.layer.borderWidth = 2
        //Get Animated Scene
        if let  story = self.story {
            Library.loadStoryScreenshot(story, { (image) in
                self.animatedScene.image = image!
            })
        }
        //Get User Photo
        if let currentPlayer = GameCenter().currentPlayer {
            currentPlayer.loadPhoto(for: .normal, withCompletionHandler: {(image, error) in
                if image != nil && error != nil {
                    self.userImage.image = image
                }
                
            })
        }
        //Make Horizontal TextView
        if let firstSentence = self.story?.sentences[sentenceCount] {
            MakescrollTextView(scrollView: scrollView, displayStr: firstSentence)
        } else {
            MakescrollTextView(scrollView: scrollView, displayStr: "I am a student")
        }
        btnStartRecog.setTitle("Start", for: .normal)
        
    }
    
    @objc internal func refreshAudioView(_:Timer) {
        if self.audioView.amplitude <= self.audioView.idleAmplitude || self.audioView.amplitude > 1.0 {
            self.change *= -1.0
        }
        
        // Simply set the amplitude to whatever you need and the view will update itself.
        self.audioView.amplitude += self.change
    }
    
    func MakescrollTextView(scrollView: UIScrollView, displayStr:String) {
        //Make Scroll Text View
        let maxSize = CGSize(width: 9999, height: 9999)
        let font = UIFont(name: "Menlo", size: 16)!
        //key function is coming!!!
        let strSize = (displayStr as NSString).boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : font], context: nil)
        
        let frame = CGRect(x: 10, y: 0, width: strSize.width+50, height: scrollView.frame.size.height)
        let textView = UITextView(frame: frame)
        textView.isEditable = false
        textView.isScrollEnabled = false//let textView becomes unScrollable
        textView.font = font
        textView.text = displayStr
        
        scrollView.contentSize = CGSize(width: strSize.width, height: 50)
        
        scrollView.addSubview(textView)
    }
    @IBAction func btnStartStopClicked(_ sender: Any) {
        if isStart {
            btnStartRecog.setTitle("Stop", for: .normal)
            speechRecognizer.startRecording()
            isStart = false
        } else {
            btnStartRecog.setTitle("Start", for: .normal)
            speechRecognizer.stopRecording()
            isStart = true
            print(speechRecognizer.speechText)
            
            //Check Reading Correctly..
            
            if let text = self.story?.sentences[self.sentenceCount] {
                if speechRecognizer.speechText == text {
                    self.sentenceCount += 1
                    //If final sententce then go to Complete Screen..
                    if self.sentenceCount  >= (self.story?.sentences.count)! {
                        print("go to complete view!")
                    } else {
                        //Else Next Sentence will be Printed in TextView
                        MakescrollTextView(scrollView: scrollView, displayStr: (self.story?.sentences[self.sentenceCount])!)
                    }
                }
            }
        }
    }
    @IBAction func btnBackClicked(_ sender: Any) {
        let preView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
        preView.isHeroEnabled = true
        preView.heroModalAnimationType = .pull(direction: .right)
        
        self.hero_replaceViewController(with: preView)
    }
    
}
