//
//  ExperienceViewController.swift
//  StoryTime
//
//  Created by Administrator on 12/20/17.
//

import UIKit
import AVFoundation
import ProgressHUD
import Lottie

enum EndState : Int{
    case normal = 0
    case backscreen = 1
    case speakword = 4
    case incorrect = 5
    case complete = 6
}

class ExperienceViewController: BaseViewController {
    struct WordInfo{
        var pos : Int   //Letter Position
        var index : Int //Word index
        var word : String //Fresh word
        var wordOrg : String //Original word with special characters
    }
    
    struct WordIndexInfo{
        var scene: Int
        var sentence: Int
        var word : Int
    }
    
    @IBOutlet var longpressGesture: UILongPressGestureRecognizer!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblSpeaking: UILabel!
    //@IBOutlet weak var lblSpeakCorrect: UILabel!
    
    @IBOutlet weak var waveformView: WaveformView!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var animatedView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    private var storyAnimation: LOTAnimationView?
    
    var audioRecorder: AVAudioRecorder!
    let speechRecognizer = SpeechRecognizer.shared
    
    //Reading duration calcuate
    var timer = Timer()
    var counter:Int = 0
    var wrongCnt = 0
    var isTimerRunning = false
    
    var story: Library.Level.Story?
    var textview: UITextView!
    var levelStr = 0
    var nIdxSentence = 0
    
    //New reading style
    var sStorySentence = ""
    var arrSWords: [[[String]]] = [] // Story Word by remove special characters - Scene/Sentence/Word
    var arrWords = [String]() //Whole story words without special
    var arrRawWords: [String] = [] //Raw story words
    var nReadWordIdx = 0
    var nAllCorrectCnt = 0
    
    var lastWordIndexInfo = WordIndexInfo(scene: 0, sentence: 0, word: 0)
    
    //For dictionary and speak, when tap and long press
    var m_sWord = ""
    var m_bIsSpeak = false
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    
    let txtSize = CGFloat(36.0)
    let txtFont = "HelveticaNeue-Light"
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.text = story?.name
        synth.delegate = self
        speechRecognizer.recognizerDelegate = self
        speechRecognizer.startRecording()
        
        //User Image
        userImage.layer.cornerRadius = userImage.frame.width / 2
        userImage.layer.borderWidth = 2
        userImage.clipsToBounds = true
        userImage.sd_setImage(with: URL(string: g_sProfileImgURL), completed: nil)
        
        prepareStory()
        
        createAnimation(name: "lv1_story1")
        startSAnimation(loop: false, start: (story?.scenes[0].fPosStart)!, end: (story?.scenes[0].fPosEnd)!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startWaveForm()
    }

    //For the Speech Sentences
    func prepareStory(){
        for scene in (self.story?.scenes)!{
            var aScene = [[String]]()
            for sentence in scene.sentences{
                let sentence_trimmed = sentence.trimmingCharacters(in: .whitespaces)
                sStorySentence += sentence_trimmed + " "
                let words = sentence_trimmed.components(separatedBy: " ")
                
                var aSentense = [String]()
                for word in words{
                    let w = removeSpecialCharFrom(string: word).lowercased()
                    aSentense.append(w)
                    
                    arrWords.append(w)
                }
                
                aScene.append(aSentense)
            }
            
            arrSWords.append(aScene)
        }
        
        sStorySentence = sStorySentence.trimmingCharacters(in: .whitespaces)
        arrRawWords = sStorySentence.components(separatedBy: " ")
        
        makeScrollTextView(scrollView: scrollView, displayStr: sStorySentence)
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
    
    //For the Animation
    func createAnimation(name: String){
        storyAnimation = LOTAnimationView(name: name)
        storyAnimation!.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        storyAnimation!.contentMode = .scaleAspectFill
        storyAnimation!.frame.origin = CGPoint.zero
        storyAnimation!.frame.size = animatedView.frame.size
        animatedView.addSubview(storyAnimation!)
    }
    
    func startSAnimation(loop: Bool, start: Double, end: Double){
        storyAnimation!.loopAnimation = loop
        storyAnimation!.play(fromProgress: CGFloat(start), toProgress: CGFloat(end), withCompletion: nil)
    }
    
    //For the Wave form view
    func startWaveForm(){
        waveformView.bUseCustomColor = true
        
        //waveformView.numberOfWaves = 18
        //waveformView.secondaryWaveLineWidth = 1.0
        waveformView.numberOfWaves = 12
        waveformView.secondaryWaveLineWidth = 1.5
        waveformView.colorsCustom = [
            UIColor(red: 195/255.0, green: 47/255.0, blue: 91/255.0, alpha: 1),
            UIColor(red: 240/255.0, green: 179/255.0, blue: 84/255.0, alpha: 1),
            UIColor(red: 151/255.0, green: 196/255.0, blue: 85/255.0, alpha: 1),
            UIColor(red: 244/255.0, green: 129/255.0, blue: 230/255.0, alpha: 1),
            UIColor(red: 79/255.0, green: 175/255.0, blue: 206/255.0, alpha: 1),
            UIColor(red: 47/255.0, green: 111/255.0, blue: 182/255.0, alpha: 1),
        ]
        
        //input
        audioRecorder = audioRecorder(URL(fileURLWithPath:"/dev/null"))
        audioRecorder.record()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(updateMeters))
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    @objc func updateMeters() {
        audioRecorder.updateMeters()
        let normalizedValue = pow(5, audioRecorder.averagePower(forChannel: 0) / 20)
        waveformView.updateWithLevel(CGFloat(normalizedValue))
    }
    
    //For the Wave form view
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
    
    //Count the total elapsed time.
    @objc func updateTimer(){
        counter += 1
    }

    func startTimer(){ //Start the timer calculation for the reading story
        if !isTimerRunning{
            isTimerRunning = true
            wrongCnt = 0
            counter = 0
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
    }

    func stopTimer(){
        timer.invalidate()
    }

    
    @IBAction func btnBackClicked(_ sender: Any) {
        //navigationController?.popViewController(animated: true)
        ProgressHUD.show("Loading...", interaction: false)
        stopTimer()
        if speechRecognizer.isStarted{
            speechRecognizer.stopRecording(status: EndState.backscreen.rawValue)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //Long press gesture recognizer for speak touched word
    @IBAction func onLongpress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let sWord = getWordFromGesture(gesture: sender)
            if sWord != "" {
                if(speechRecognizer.isStarted){
                    if !m_bIsSpeak{
                        m_bIsSpeak = true
                        ProgressHUD.show("Loading...", interaction: false)
                        m_sWord = sWord
                        speechRecognizer.stopRecording(status: EndState.speakword.rawValue)
                    }
                }else{
                    self.speakWith(word: sWord)
                }
            }
        }
    }
    
    //Tap guesture recognizer for show dictionary
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        let sWord = getWordFromGesture(gesture: sender)
        if sWord != "" {
            openDicWith(word: sWord)
        }
    }
}

extension ExperienceViewController: AVSpeechSynthesizerDelegate{
    //Speech Delegate to proceed for end of speaking word and start speed recognition.
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        m_bIsSpeak = false
        speechRecognizer.startRecording()
        ProgressHUD.dismiss()
    }
}

//SpeechRecognizerDelegate Methods
extension ExperienceViewController: SpeechRecognizerDelegate {
    func onDetect(_ speech: String, _ isFinal: Bool) {
        // this is real time callback - you can analyze here
        // Get last word of speech
        startTimer()
        
        processSentence(speech: speech)
    }
    
    func onEnd(_ status: Int){
        print("Speech End Status: \(status)")
        lblSpeaking.text = ""
        
        if status == EndState.normal.rawValue{
            speechRecognizer.startRecording()
        }else if status == EndState.backscreen.rawValue {
            ProgressHUD.dismiss()
            self.navigationController?.popViewController(animated: true)
        }else if status == EndState.speakword.rawValue{
            speakWith(word: m_sWord)
        }else if status == EndState.incorrect.rawValue{
            speechRecognizer.startRecording()
        }else if status == EndState.complete.rawValue{
            gotoComplete()
        }
    }
    
    func processSentence(speech: String){
        let aSpeech = speech.components(separatedBy: " ")
        lblSpeaking.text = speech;
        
        var posIncorrect = 0
        
        var isAllCorrect = true
        
        var nCompareCnt = aSpeech.count
        if nReadWordIdx + nCompareCnt > arrWords.count{
            nCompareCnt = arrWords.count - nReadWordIdx
        }
        
        for i in 0..<nCompareCnt{
            let wordIndex = nReadWordIdx + i
            
            let speechWord = removeSpecialCharFrom(string: aSpeech[i].lowercased())
            
            if speechWord.caseInsensitiveCompare(self.arrWords[wordIndex]) != ComparisonResult.orderedSame{
                posIncorrect = i
                isAllCorrect = false
                break
            }
        }
        
        var nRealReadCnt = 0
        
        if isAllCorrect {
            nAllCorrectCnt = nCompareCnt
            setBlueText(readCnt: nCompareCnt)
            
            nRealReadCnt = nReadWordIdx + nAllCorrectCnt - 1
        }else{
            if posIncorrect > 0{
                nReadWordIdx += posIncorrect
            }else if nAllCorrectCnt > 0{
                nReadWordIdx += nAllCorrectCnt
            }
            
            nRealReadCnt = nReadWordIdx - 1
            
            setRedText(wrongIdx: nReadWordIdx)
            speechRecognizer.stopRecording(status: EndState.incorrect.rawValue)
            nAllCorrectCnt = 0
        }
        
        print("readWord: \(nReadWordIdx), incorrectPos: \(posIncorrect)")
        
        checkProgressFrom(wordIdx: nRealReadCnt)
    }
    
    func checkProgressFrom(wordIdx: Int){
        let wordIndexInfo = getWordIndexInfo(byWordIndex: wordIdx)
        print("word: \(wordIdx) scene:\(wordIndexInfo.scene) sentence:\(wordIndexInfo.sentence) word:\(wordIndexInfo.word)")
        
        if wordIdx == arrWords.count - 1{ //Last word of whole story
            speechRecognizer.stopRecording(status: EndState.complete.rawValue)
            return
        }
        
        if wordIndexInfo.scene != lastWordIndexInfo.scene{ //New Scene
            startSAnimation(loop: false, start: (story?.scenes[wordIndexInfo.scene].fPosStart)!, end: (story?.scenes[wordIndexInfo.scene].fPosEnd)!)
        }
        lastWordIndexInfo = wordIndexInfo
    }
}

// Self Definition Methods
extension ExperienceViewController {
    //Gesture Part
    func getWordFromGesture(gesture:UIGestureRecognizer) -> String{
        var text = ""
        if let textView = gesture.view as? UITextView {
            let layoutManager = textView.layoutManager
            var location = gesture.location(in: textView)
            location.x -= textView.textContainerInset.left
            location.y -= textView.textContainerInset.top
            
            let characterIndex = layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            
            if(characterIndex < textView.textStorage.length){
                //print("character index: \(characterIndex)")
                
                //print the character at the index successfully
                //let myRange = NSRange(location: characterIndex, length: 1)
                //let substring = (textView.attributedText.string as NSString).substring(with: myRange)
                //print("character at index: \(substring)")
                
                let tapPosition: UITextPosition? = textView.closestPosition(to: location)
                //fetch the word at this position (or nil, if not available)
                if let textRange = textView.tokenizer.rangeEnclosingPosition(tapPosition!, with: .word, inDirection: 1) {
                    if let tappedWord = textView.text(in: textRange) {
                        print("selected word :\(tappedWord)")
                        //This only prints when I seem to tap the first letter of word.
                        text = tappedWord
                    }
                }
            }
        }
        return text
    }
    
    func openDicWith(word:String){
        if UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: word) {
            ProgressHUD.show("Loading...", interaction: false)
            let ref: UIReferenceLibraryViewController = UIReferenceLibraryViewController(term: word)
            self.present(ref, animated: true, completion: {
                ProgressHUD.dismiss()
            })
        }
    }
    
    func speakWith(word:String) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        }catch {
            print("audioSession properties weren't set because of an error.")
            ProgressHUD.dismiss()
        }
        myUtterance = AVSpeechUtterance(string: word)
        myUtterance.volume = 1
        //myUtterance.rate = 0.3
        synth.speak(myUtterance)
    }
    
    //Scroll Part
    func makeScrollTextView(scrollView: UIScrollView, displayStr:String) {
        //Make Scroll Text View
        let maxSize = CGSize(width: Int.max, height: 60)
        let font = UIFont(name: txtFont, size: txtSize)!
        //key function is coming!!!
        let strSize = (displayStr as NSString).boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : font], context: nil)
        
        let frame = CGRect(x: 10, y: 10, width: strSize.width+10, height: scrollView.frame.size.height)
        self.textview = UITextView(frame: frame)
        let textView = self.textview
        //textView?.textContainer.maximumNumberOfLines = 1
        textView?.isEditable = false
        textView?.isScrollEnabled = false//let textView becomes unScrollable
        textView?.isSelectable = false
        textView?.font = font
        textView?.text = displayStr
        textView?.backgroundColor = UIColor.clear
        textView?.addGestureRecognizer(tapGesture)
        textView?.addGestureRecognizer(longpressGesture)
        scrollView.contentSize = CGSize(width: strSize.width+20, height: scrollView.frame.size.height)
        
        scrollView.addSubview(textView!)
    }
    
    func setBlueText(readCnt: Int){
        let startWordInfo = getWordInfo(byWordIndex: nReadWordIdx)
        let endWordInfo = getWordInfo(byWordIndex: nReadWordIdx + readCnt - 1)
        
        setTextColor(startPos: startWordInfo.pos, length: endWordInfo.pos+endWordInfo.wordOrg.count - startWordInfo.pos, color: UIColor.blue)
        
        var nScrollIdx = nReadWordIdx + readCnt - 2
        if nScrollIdx < 0{
            nScrollIdx = 0
        }
        scrollTo(wordIndex: nScrollIdx)
    }
    
    func setRedText(wrongIdx: Int){
        let wordInfo = getWordInfo(byWordIndex: wrongIdx)
        
        setTextColor(startPos: wordInfo.pos, length: wordInfo.wordOrg.count, color: UIColor.red)
        
        var nScrollIdx = nReadWordIdx - 1
        if nScrollIdx < 0{
            nScrollIdx = 0
        }
        scrollTo(wordIndex: nScrollIdx)
    }
    
    func setTextColor(startPos: Int, length: Int, color: UIColor){
        var mutableString = NSMutableAttributedString()
        mutableString = NSMutableAttributedString(string: sStorySentence)
        
        //read
        if startPos > 0{
            mutableString.setAttributes([NSAttributedStringKey.font : UIFont(name: txtFont, size: txtSize)!, NSAttributedStringKey.foregroundColor : UIColor.lightGray], range: NSRange(location: 0, length: startPos))
        }
        
        //correct or wrong
        mutableString.setAttributes([NSAttributedStringKey.font : UIFont(name: txtFont, size: txtSize)!, NSAttributedStringKey.foregroundColor : color], range: NSRange(location: startPos, length: length))
        
        //will read
        mutableString.setAttributes([NSAttributedStringKey.font : UIFont(name: txtFont, size: txtSize)!, NSAttributedStringKey.foregroundColor : UIColor.black], range: NSRange(location: startPos+length, length: sStorySentence.count - (startPos+length)))
        
        textview.attributedText = mutableString
    }
    
    func scrollTo(wordIndex: Int){
        let maxSize = CGSize(width: Int.max, height: 60)
        let font = UIFont(name: txtFont, size: txtSize)!
        let wordInfo = getWordInfo(byWordIndex: wordIndex)
        let subStr = sStorySentence.prefix(wordInfo.pos)
        let strSize = (subStr as NSString).boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : font], context: nil)
        scrollView.setContentOffset(CGPoint(x: strSize.width, y: 0), animated: true)
    }
    
    func getWordIndexInfo(byWordIndex: Int) -> WordIndexInfo{
        var nTotalWordCount = 0
        for i in 0..<arrSWords.count{
            for j in 0..<arrSWords[i].count{
                if byWordIndex < nTotalWordCount + arrSWords[i][j].count{
                    let nWord = byWordIndex - nTotalWordCount
                    
                    return WordIndexInfo(scene: i, sentence: j, word: nWord)
                }else{
                    nTotalWordCount += arrSWords[i][j].count
                }
            }
        }
        return WordIndexInfo(scene: 0, sentence: 0, word: 0)
    }
    
    func getWordInfo(byWordIndex: Int) -> WordInfo{
        return getWordInfoFromWordList(words: arrRawWords, byWordIndex: byWordIndex)
    }
    
    func getWordInfo(fromString:String, byWordIndex: Int) -> WordInfo{
        let aWords = fromString.components(separatedBy: " ")
        return getWordInfoFromWordList(words: aWords, byWordIndex: byWordIndex)
    }
    
    func getWordInfoFromWordList(words:[String], byWordIndex: Int) -> WordInfo{
        let myWord = words[byWordIndex]
        let newWord = removeSpecialCharFrom(string: myWord)
        
        var letterPostion = 0
        //if(byWordIndex > 0){
            for i in 0..<byWordIndex{
                letterPostion += words[i].count
                letterPostion += 1 //For Space
            }
        //}
        
        return WordInfo(pos: letterPostion, index:byWordIndex, word: newWord, wordOrg: myWord)
    }
    
    func removeSpecialCharFrom(string:String)->String{
        return string.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
    }
}
