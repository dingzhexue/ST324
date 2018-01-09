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
    var levelStr = 0
    var i = 0, j = 0
    var arrWords:[[String]] = []
    var textview: UITextView!
    @IBOutlet weak var audioView: SwiftSiriWaveformView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var animatedScene: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    let speechRecognizer = SpeechRecognizer.shared
   
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.audioView.density = 1.0
        
        speechRecognizer.recognizerDelegate = self
        speechRecognizer.startRecording()
       
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(refreshAudioView(_:)),
                                     userInfo: nil,
                                     repeats: true)
        
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
        if let firstSentence = self.story?.sentences.first {
            MakescrollTextView(scrollView: scrollView, displayStr: firstSentence)
        } else {
            MakescrollTextView(scrollView: scrollView, displayStr: "sdfsdfsdfsdfb")
        }
        //Make Arrary of words...
        
        for sentence in (self.story?.sentences)! {
             arrWords.append(sentence.components(separatedBy: " "))
        }
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        speechRecognizer.stopRecording()
    }
    
    @objc internal func refreshAudioView(_:Timer) {
        
        if self.audioView.amplitude <= self.audioView.idleAmplitude || self.audioView.amplitude > 1.0 {
            self.change *= -1.0
        }
        
        // Simply set the amplitude to whatever you need and the view will update itself.
        self.audioView.amplitude += self.change
    }
   
    @IBAction func btnBackClicked(_ sender: Any) {
        let preView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PreviewViewController") as! PreviewViewController
        preView.isHeroEnabled = true
        preView.heroModalAnimationType = .pull(direction: .right)
        preView.story = self.story
        preView.levelStr = self.levelStr
        self.hero_replaceViewController(with: preView)
    }
    
}
//SpeechRecognizerDelegate Methods
extension ExperienceViewController: SpeechRecognizerDelegate {
    func onDetect(_ speech: String, _ isFinal: Bool) {
        // this is real time callback - you can analyze here
        if speech == self.arrWords[i][j] {
            j += 1
            if j >= arrWords[i].count {
                i += 1
                j = 0
                if i >= arrWords.count {
                    // finish reading....
                    print("completed reading text!")
                }
                // display new sentence...
                // MakescrollTextView(scrollView: self.scrollView, displayStr: (self.story?.sentences[i])!)
                self.textview.text = self.story?.sentences[i]
            }
        } else {
            // set red color for wrongly reading word..
            // MakescrollTextView(scrollView: self.scrollView, displayStr: SetRedColorForWrongWord(text: self.story?.sentences[i], word: arrWords[i][j]))
            self.textview.attributedText = GetRedColorForWrongWord(text: (self.story?.sentences[i])!, word: arrWords[i][j])
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            j = 0
            
        }
    }
}
// Self Definition Methods
extension ExperienceViewController {
    
    func MakescrollTextView(scrollView: UIScrollView, displayStr:String) {
        //Make Scroll Text View
        let maxSize = CGSize(width: 9999, height: 9999)
        let font = UIFont(name: "Menlo", size: 16)!
        //key function is coming!!!
        let strSize = (displayStr as NSString).boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : font], context: nil)
        
        let frame = CGRect(x: 10, y: 10, width: strSize.width+50, height: scrollView.frame.size.height)
        self.textview = UITextView(frame: frame)
        let textView = self.textview
        textView?.isEditable = false
        textView?.isScrollEnabled = false//let textView becomes unScrollable
        textView?.font = font
        textView?.text = displayStr
        
        scrollView.contentSize = CGSize(width: strSize.width, height: 50)
        
        scrollView.addSubview(textView!)
    }
    
    func GetRedColorForWrongWord(text: String, word: String) -> NSMutableAttributedString{
        
        var startPos = 0, endPos = 0
        if let range = text.range(of: word) {
            startPos = text.distance(from: text.startIndex, to: range.lowerBound)
            endPos = text.distance(from: text.startIndex, to: range.upperBound)
        }
        
        var myMutableString = NSMutableAttributedString()
        
        myMutableString = NSMutableAttributedString(string: text)
        
        myMutableString.setAttributes([NSAttributedStringKey.font : UIFont(name: "HelveticaNeue-Light", size: CGFloat(17.0))!
            , NSAttributedStringKey.foregroundColor : UIColor(red: 1.0, green: 0, blue: 0, alpha: 1.0)], range: NSRange(location:startPos,length:endPos - startPos))
        
        return myMutableString
    }
}














