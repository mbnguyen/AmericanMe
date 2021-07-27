//
//  QuestionData.swift
//  American Me
//
//  Created by Minh Nguyen on 10/3/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation
import UIKit

protocol QuestionDataProtocol {
    func questionDataRetrieved()
}

class QuestionData {
    
    var delegate: QuestionDataProtocol?
    
    static var questions = [Question]()
    static var synonyms = Synonyms()
    static var imageKey = ImageKey()
    static var currentIndex: Int = 0
    
    private var model = QuestionModel()
    private var modelSynonyms = SynonymsModel()
    private var modelImageKey = ImageKeyModel()
    
    func retrieveData() {
        
        // Set up delegates
        model.delegate = self
        modelSynonyms.delegate = self
        modelImageKey.delegate = self
        
        // Get the quesions data
        model.getQuestions()
        
        // Get the synonyms
        modelSynonyms.getSynonyms()
        
        // Get the image key
        modelImageKey.getImageKey()
    }
    
    func downloadIfNeeded() {
        
        // Check if the questions are downloaded
        if QuestionData.questions.count == 0 || !QuestionData.synonyms.isReady() || !QuestionData.imageKey.isReady() {
            retrieveData()
        }
    }
    
    static func getCorrectRange(currentIndexQuestion: Int, attempt: String) -> [NSTextCheckingResult]? {
        
        // Check if currentIndexQuestion is valid
        if currentIndexQuestion >= QuestionData.questions.count {
            return nil
        }
        
        return QuestionData.questions[currentIndexQuestion].getCorrectRange(attemp: attempt, synonyms: QuestionData.synonyms)
    }
    
    static func getQuestion(currentIndexQuestion: Int) -> String? {
        
        // Check if currentIndexQuestion is valid
        if currentIndexQuestion >= QuestionData.questions.count {
            return nil
        }
        return QuestionData.questions[currentIndexQuestion].question
    }
    
    static func getQuestionCount() -> Int {
        
        //downloadIfNeeded()
        return QuestionData.questions.count
    }
    
    static func getAnswers(currentIndexQuestion: Int) -> [String]? {
        if currentIndexQuestion < 0 || currentIndexQuestion >= questions.count {
            return nil
        }
        return QuestionData.questions[currentIndexQuestion].answers
    }
    
    static func getAnswersCount(currentIndexQuestion: Int) -> Int {
        
        //downloadIfNeeded()
        guard let answersCount = QuestionData.questions[currentIndexQuestion].answers?.count else {
            return 0
        }
        
        return answersCount
    }
    
    static func getAnswer(currentIndexQuestion: Int, indexAnswer: Int) -> String? {
        
        //downloadIfNeeded()
        // Get the list of answers
        guard let answers = QuestionData.questions[currentIndexQuestion].answers else {
            return nil
        }
        
        // Check if indexAnswer is valid
        if indexAnswer >= answers.count {
            return nil
        }
        
        // Return the answer
        return answers[indexAnswer]
    }
    
    static func getTextWithImage(text: String?, sender: LocalStorageManagerProtocol?) -> NSMutableAttributedString? {
        
        guard let text = text else {
            return nil
        }
        
        //downloadIfNeeded()
        // Create an NSMutableAttributedString that we'll append everything to
        let attributedString = NSMutableAttributedString(string: text)
        
        // Make sure keys is not nil
        guard let keys = QuestionData.imageKey.keys else {
            return nil
        }
        
        // Check for every key in keys
        for (key, imageName) in keys {
            
            // Create pattern
            let pattern = "\\b\(key)\\b"
            let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            
            // Try finding matches
            if let matches = regex?.matches(in: attributedString.string, options: [],
                                            range: NSRange(location: 0, length: attributedString.string.utf16.count)) {
                for aMatch in matches.reversed() {
                    
                    let attachment = NSTextAttachment()
                    
                    // Check if the image exists
                    if LocalStorageManager.exist(imageName: imageName) {
                        // TODO: Load image from local storage
                        attachment.image = LocalStorageManager.loadImageLocally(imageName: imageName)
                    } else {
                        // TODO: Insert a placeHolderImage instead
                        attachment.image = UIImage(named: GeneralData.imageError)
                        // Download the missing image
                        if sender != nil {
                            let localStorage = LocalStorageManager()
                            localStorage.delegate = sender
                            localStorage.downloadImage(imageName: imageName)
                        }
                    }
                    attachment.bounds = CGRect(x: 0, y: 0, width: GeneralData.sizeImageMini, height: GeneralData.sizeImageMini)
                    let string = NSMutableAttributedString(string: " ")
                    string.append(NSAttributedString(attachment: attachment))
                    string.append(NSAttributedString(string: " "))
                    //attributedString.replaceCharacters(in: aMatch.range, with: replacement)
                    attributedString.insert(string, at: NSMaxRange(aMatch.range))
                }
            }
        }

        return attributedString
    }
    
    func downloadedSucceed() {
        
        if QuestionData.questions.count > 0 && QuestionData.synonyms.isReady() && QuestionData.imageKey.isReady() {
            delegate?.questionDataRetrieved()
        }
    }
}

// MARK: QuestionModel Delegate
extension QuestionData: QuestionModelProtocol{
    func questionRetrieved(_ questions: [Question]) {
        QuestionData.questions = questions
        downloadedSucceed()
    }
}

// MARK: QuestionModel Delegate
extension QuestionData: SynonymsModelProtocol{
    func synonymsRetrieved(_ synonyms: Synonyms) {
        QuestionData.synonyms = synonyms
        downloadedSucceed()
    }
}

// MARK: ImageKeyModel Delegate
extension QuestionData: ImageKeyModelProtocol{
    func imageKeyRetrieved(_ imageKey: ImageKey) {
        QuestionData.imageKey = imageKey
        downloadedSucceed()
    }
}
