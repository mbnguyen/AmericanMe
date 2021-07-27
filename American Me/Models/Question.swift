//
//  Question.swift
//  American Me
//
//  Created by Minh Nguyen on 9/14/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation

class Patterns {
    
    // The pattern of the individual answer
    var answers: String?
    // The pattern of each matched words
    var words: String?
}

class Question: Codable {
    
    var question: String?
    var answers: [String]?
    var answerKeys: [[String]]?
    var numberAnswerNeed: Int?
    
    func isReady() -> Bool {
        
        // Check if everything is ready
        if question != nil && answers != nil && answerKeys != nil && numberAnswerNeed != nil {
            return true
        } else {
            return false
        }
    }
    
    func getCorrectRange(attemp: String, synonyms: Synonyms) -> [NSTextCheckingResult]? {
        
        guard answerKeys != nil && numberAnswerNeed != nil else {
            print("Couldn't load the question")
            return nil
        }
        
        var countCorrectAnswer = 0
        let userAnswer = attemp.lowercased()
        
        guard let patterns = createRegularExpression(synonyms: synonyms.synonymsArr) else {
            print("Couldn't create Regex")
            return nil
        }
        
        var arrayResults = [NSTextCheckingResult]()
        
        for pattern in patterns {
            
            let range = NSRange(location: 0, length: userAnswer.utf16.count)
            
            guard let patternAnswer = pattern.answers else {
                return nil
            }
            
            guard let patternWords = pattern.words else {
                return nil
            }
            
            let regexAnswer = try! NSRegularExpression(pattern: patternAnswer)
            let regexWords = try! NSRegularExpression(pattern: patternWords)
            
            // Find the range of the individual answer first
            let rangeAnswer = regexAnswer.rangeOfFirstMatch(in: userAnswer, options: [], range: range)
            // Length > 0 means found an answer
            if rangeAnswer.length > 0 {
                
                // Increase the count
                countCorrectAnswer += 1
                // Get the ranges of the matched words
                arrayResults.append(contentsOf: regexWords.matches(in: userAnswer, options: [], range: rangeAnswer))
            }
            // If we found enough answers, return the ranges of the matched words for UI
            if countCorrectAnswer == numberAnswerNeed {
                return arrayResults
            }
        }
        return nil
    }
    
    // Create Regular Expression
    func createRegularExpression(synonyms: [String: [String]]?) -> [Patterns]? {
        
        guard answerKeys != nil else {
            print("Couldn't load the question")
            return nil
        }
        
        var regexString = [Patterns]()
        
        
        for setOfKeys in answerKeys! {
            
            let pattern = Patterns()
            pattern.answers = ""
            pattern.words = "\\b("
            
            for (index, key) in setOfKeys.enumerated() {
                
                var keyWithSynonyms = key
                let listSynonyms = synonyms?[key]
                
                if listSynonyms != nil {
                    for syn in listSynonyms! {
                        keyWithSynonyms += "|\(syn)"
                    }
                }
                
                if index == setOfKeys.count - 1 {
                    pattern.answers! += "\\b(\(keyWithSynonyms))\\b"
                    pattern.words! += "\(keyWithSynonyms)"
                } else {
                    pattern.answers! += "\\b(\(keyWithSynonyms))\\b(.*)"
                    pattern.words! += "\(keyWithSynonyms)|"
                }
            }
            pattern.words! += ")\\b"
            regexString.append(pattern)
        }
        return regexString
    }
    
}
