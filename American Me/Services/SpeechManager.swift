//
//  SpeechManager.swift
//  American Me
//
//  Created by Minh Nguyen on 9/15/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation
import Speech
import UIKit

enum AuthStats {
    case authorized, denied, restricted, notDetermined, unknown
}

protocol SpeechManagerProtocol{
    func authStatsRetrieved(auth: AuthStats)
    func answerRetrieved(text: String?, questionIndex: Int)
    func correctedAnswerRetrieved(ranges: [NSTextCheckingResult], questionIndex: Int)
}

class SpeechManager {
    
    var delegate: SpeechManagerProtocol?
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    public func requestAuth() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                self.delegate?.authStatsRetrieved(auth: AuthStats.authorized)
            case .denied:
                self.delegate?.authStatsRetrieved(auth: AuthStats.denied)
            case .restricted:
                self.delegate?.authStatsRetrieved(auth: AuthStats.restricted)
            case .notDetermined:
                self.delegate?.authStatsRetrieved(auth: AuthStats.notDetermined)
            default:
                self.delegate?.authStatsRetrieved(auth: AuthStats.unknown)
            }
        }
    }
    
    public func startRecording(currentIndexQuestion: Int) throws {
        
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode

        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                // Update the text view with the results.
                self.delegate?.answerRetrieved(text: result.bestTranscription.formattedString, questionIndex: currentIndexQuestion)
                isFinal = result.isFinal
                let rangeMatched = QuestionData.getCorrectRange(currentIndexQuestion: currentIndexQuestion, attempt: result.bestTranscription.formattedString)
                if rangeMatched != nil {
                    isFinal = true
                    self.stop()
                    self.delegate?.correctedAnswerRetrieved(ranges: rangeMatched!, questionIndex: currentIndexQuestion)
                }
                
                //print("Text \(result.bestTranscription.formattedString)")
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

            }
        }

        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
    }
    
    public func isRunning() -> Bool {
        return self.audioEngine.isRunning
    }
    
    public func stop() {
        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()
    }
    
    
}
