//
//  SpeechRecognizer.swift
//  StoryTime
//
//  Created by Administrator on 12/15/17.
//

import Foundation
import Speech

protocol SpeechRecognizerDelegate: NSObjectProtocol {
    func onDetect(_ speech: String, _ isFinal: Bool)
    func onEnd(_ status: Int)
}

class SpeechRecognizer: NSObject {
    var isStarted : Bool = false
    var nEndStatus : Int = 0
    private override init() {
        super.init()
        
        requestAuthorization()
        speechRecognizer.delegate = self
    }
    
    static let shared = SpeechRecognizer()
    public weak var recognizerDelegate: SpeechRecognizerDelegate?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            //try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        self.isStarted = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil, let text = result?.bestTranscription.formattedString {
                print("Speech Recognized Text: \(text)")
                isFinal = (result?.isFinal)!
                self.recognizerDelegate?.onDetect(text, isFinal)
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.isStarted = false
                self.recognizerDelegate?.onEnd(self.nEndStatus)
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    func stopRecording(status:Int = 0) {
        //if audioEngine.isRunning {
        if(isStarted || audioEngine.isRunning){
            do {
            try AVAudioSession.sharedInstance().setMode(AVAudioSessionModeSpokenAudio)
            }catch{
                print("audioSession properties weren't set because of an error.")
            }
            nEndStatus = status
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            recognitionRequest?.endAudio()
        }
        //}
    }
    
    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            switch authStatus {
            case .authorized:
                print("User allowed access to speech recognition")
                
            case .denied:
                print("User denied access to speech recognition")
                
            case .restricted:
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                print("Speech recognition not yet authorized")
            }
        }
    }
}

extension SpeechRecognizer: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            print("Speech Recognizer is not available")
        }
    }
    
    
}

