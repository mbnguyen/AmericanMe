//
//  Data.swift
//  American Me
//
//  Created by Minh Nguyen on 10/3/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation

class GeneralData {
    
    static var speechRate: Float = 0.4
    
    static var sizeImageMini: Int = 30
    
    static var useImages: Bool = true
    
    static var flipSpeed: Double = 0.3
    
    static var maxTimeInSecond: Int = 300
    
    static var maxQuestionsAsk: Int = 5
    
    
    // MARK: Strings
    static let learnText = "Got it!"
    static let unlearnText = "I'm not sure.."
    static let waitingToStartRegconizer = "Press the microphone when you're ready"
    static let waitingForAnswer = "(Go ahead, I'm listening)"
    static let passedTitle = "Congratulation!"
    static let failedTitle = "Bad news..."
    
    
    
    // Download url for question on FireBase
    static let pathQuestions = "QuestionData/QuestionsData.json"
    
    // Download url for synonyms on FireBase
    static let pathSynonyms = "QuestionData/Synonyms.json"
    
    // Download url for ImageKey on FireBase
    static let pathImageKey = "QuestionData/ImageKey.json"
    
    static let pathImage = "Images/"
    
    static let imageError = "error"
}
