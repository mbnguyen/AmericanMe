//
//  TextToSpeechManager.swift
//  American Me
//
//  Created by Minh Nguyen on 9/17/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation
import AVFoundation

class TextToSpeechManager: NSObject {
    
    let synthesizer = AVSpeechSynthesizer()
    
    var isSpeaking = false
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func speak (string: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            // try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = GeneralData.speechRate
        
        // Detect if the synthesizer is speaking
        if isSpeaking == false {
            synthesizer.speak(utterance)
            self.isSpeaking = true
        }
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
}

extension TextToSpeechManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        //Speaking is done, enable speech UI for next round
        self.isSpeaking = false
    }
}
