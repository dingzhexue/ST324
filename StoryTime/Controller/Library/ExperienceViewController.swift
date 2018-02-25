//
//  ExperienceViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/20/17.
//

import UIKit
import AVFoundation
import MBProgressHUD

enum EndState : Int{
    case normal = 0
    case backscreen = 1
    case replay = 2
    case next = 3
}

class ExperienceViewController: BaseViewController {
    
    var timer = Timer()
    var counter:Int = 0
    var wrongCnt = 0
    
    var isTimerRunning = false
    var story: Library.Level.Story?
    var levelStr = 0
    var nIdxSentence = 0
    var arrWords: [[String]] = []
    var arrSpeech: [String] = []
    var textview: UITextView!
    @IBOutlet weak var lblSpeaking: UILabel!

    @IBOutlet weak var waveformView: WaveformView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var animatedScene: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    var audioRecorder: AVAudioRecorder!
    
    let speechRecognizer = SpeechRecognizer.shared
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        speechRecognizer.recognizerDelegate = self
        speechRecognizer.startRecording()
        
        //Get Animated Scene
        if let  story = self.story {
            Library.loadStoryScreenshot(story, { (image) in
                if image != nil {
                    self.animatedScene.image = image!
                }
            })
        }
        //Get User Photo
        /*if let currentPlayer = GameCenter().currentPlayer {
            currentPlayer.loadPhoto(for: .normal, withCompletionHandler: {(image, error) in
                if image != nil && error != nil {
                    self.userImage.image = image
                }
            })
        }*/
        userImage.layer.cornerRadius = userImage.frame.width / 2
        userImage.layer.borderWidth = 2
        userImage.clipsToBounds = true
        userImage.sd_setImage(with: URL(string: g_sProfileImgURL), completed: nil)
        
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        audioRecorder = audioRecorder(URL(fileURLWithPath:"/dev/null"))
        audioRecorder.record()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(updateMeters))
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    //100 is go back screen
    //101 is next sentence
    //102 is replay sentence
    @IBAction func btnBackClicked(_ sender: Any) {
        //navigationController?.popViewController(animated: true)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        stopTimer()
        if speechRecognizer.isStarted{
            speechRecognizer.stopRecording(status: EndState.backscreen.rawValue)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func gotoComplete(){
        stopTimer()
        if let completeVC = storyboard?.instantiateViewController(withIdentifier: "CompleteVC") as? CompleteViewController {
            completeVC.story = self.story
            completeVC.levelStr = self.levelStr
            completeVC.timeCnt = self.counter
            completeVC.wrongCnt = self.wrongCnt
            navigationController?.pushViewController(completeVC, animated: true)
        }
    }
    
    func stopTimer(){
        timer.invalidate()
    }
    
    func prepareNextSentence(){
        if nIdxSentence < arrWords.count-1
        {
            nIdxSentence += 1
            MakescrollTextView(scrollView: scrollView, displayStr: (self.story?.sentences[nIdxSentence])!)
            speechRecognizer.startRecording()
        }else{ //Read All Senteces!!
            MakescrollTextView(scrollView: scrollView, displayStr: "Great! You finished all read!")
            print("Finished Reading")
            gotoComplete()
        }
    }
    
    func replaySentence(){
        MakescrollTextView(scrollView: scrollView, displayStr: (self.story?.sentences[nIdxSentence])!)
        speechRecognizer.startRecording()
    }
    
    @objc func updateMeters() {
        audioRecorder.updateMeters()
        let normalizedValue = pow(5, audioRecorder.averagePower(forChannel: 0) / 20)
        waveformView.updateWithLevel(CGFloat(normalizedValue))
    }
    
    func audioRecorder(_ filePath: URL) -> AVAudioRecorder {
        let recorderSettings: [String : AnyObject] = [
            AVSampleRateKey: 44100.0 as AnyObject,
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey: 2 as AnyObject,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue as AnyObject
        ]
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        let audioRecorder = try! AVAudioRecorder(url: filePath, settings: recorderSettings)
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        
        return audioRecorder
    }
    
    @objc func updateTimer(){
        counter += 1
    }
    
    func startTimer(){
        if !isTimerRunning{
            isTimerRunning = true
            wrongCnt = 0
            counter = 0
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
    }
}
//SpeechRecognizerDelegate Methods
extension ExperienceViewController: SpeechRecognizerDelegate {
    func onDetect(_ speech: String, _ isFinal: Bool) {
        // this is real time callback - you can analyze here
        // Get last word of speech
        startTimer()
        
        arrSpeech = speech.components(separatedBy: " ")
        lblSpeaking.text = speech;
        
        var isAllCorrect = true
        
        if arrSpeech.count > arrWords[nIdxSentence].count {
            isAllCorrect = false
        }
        else{
            for i in 0 ..< min(arrWords[nIdxSentence].count, arrSpeech.count){
                if arrSpeech[i].caseInsensitiveCompare(self.arrWords[nIdxSentence][i]) != ComparisonResult.orderedSame {
                    isAllCorrect = false
                    break
                }
            }
        }
        
        if isAllCorrect{
            if arrSpeech.count == self.arrWords[nIdxSentence].count{ //Whole Sentence Correct
                //Prepare next sentence
                speechRecognizer.stopRecording(status: EndState.next.rawValue)
                print("correct sentence")
            }else{ //Just spoke partial
                
            }
        }
        else{ //incorrect
            speechRecognizer.stopRecording(status: EndState.replay.rawValue)
            wrongCnt += 1
            print("incorrect")
        }
    }
    
    func onEnd(_ status: Int){
        print("Speech End Status: \(status)")
        lblSpeaking.text = ""
        
        if status == EndState.normal.rawValue{
            speechRecognizer.startRecording()
        }
        else if status == EndState.backscreen.rawValue {
            self.navigationController?.popViewController(animated: true)
        }else if status == EndState.replay.rawValue{
            replaySentence()
        }else if status == EndState.next.rawValue{
            prepareNextSentence()
        }
    }
}
// Self Definition Methods
extension ExperienceViewController {
    
    func MakescrollTextView(scrollView: UIScrollView, displayStr:String) {
        //Make Scroll Text View
        let maxSize = CGSize(width: 9999, height: 9999)
        let font = UIFont(name: "Menlo", size: 24)!
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














