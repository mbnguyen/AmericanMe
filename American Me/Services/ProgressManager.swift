//
//  ProgressManager.swift
//  American Me
//
//  Created by Minh Nguyen on 10/6/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation

enum questionType {
    case learned
    case unlearned
    case answerCorrect
    case answerWrong
}

class ProgressManager {
    
    static var questionsScore = [Int: Int]()
    static var questionsAskMore = Set<Int>()
    static var questionsAskLess = Set<Int>()
    
    static private let MaxQuestion: Int = QuestionData.getQuestionCount()
    static private let MaxScore: Int = 10
    static private let MeanScore: Int = 7
    static private let PercentMoreOverTotal = 0.7
    
    static func updateQuestion(indexQuestion: Int, questionType: questionType) {
        
        // If we have not had this question info
        if questionsScore[indexQuestion] == nil {
            // -1 means this question has been never learned
            questionsScore[indexQuestion] = -1
        }
            
        // We already had this question info
        switch questionType {
        case .learned:
            questionsScore[indexQuestion] = 0
        case .unlearned:
            questionsScore[indexQuestion] = -1
            questionsAskLess.remove(indexQuestion)
            questionsAskMore.remove(indexQuestion)
        case .answerCorrect:
            // If the user answer correct for the very first time
            if questionsScore[indexQuestion]! <= 0 {
                questionsScore[indexQuestion] = MeanScore
            }
            questionsScore[indexQuestion] = min(questionsScore[indexQuestion]! + 1, MaxScore)
        case .answerWrong:
            questionsScore[indexQuestion] = max(questionsScore[indexQuestion]! - 1, 1)
        }
        
        // If this question's score is greater than MeanScore
        if questionsScore[indexQuestion]! > MeanScore {
                
            // Move it from askMore to askLess
            questionsAskMore.remove(indexQuestion)
            if !questionsAskLess.contains(indexQuestion){
                questionsAskLess.insert(indexQuestion)
            }
        } else if questionsScore[indexQuestion]! > -1 {
                
            // We don't want to ask the question that is unlearned
            // Move it from askLess to askMore
            questionsAskLess.remove(indexQuestion)
            if !questionsAskMore.contains(indexQuestion){
                questionsAskMore.insert(indexQuestion)
            }
        }
        LocalStorageManager.saveGeneralDataLocally()
    }
    
    static func isLearned(indexQuestion: Int) -> Bool {
        if questionsScore[indexQuestion] == nil {
            questionsScore[indexQuestion] = -1
            return false
        }
        if questionsScore[indexQuestion] == -1 {
            return false
        }
        return true
    }
    
    // TODO: Get question from askMore, askLess randomly and sorted
    static func getQuestionsAskMoreRandom() -> [Int]? {
        return Array(questionsAskMore).shuffled()
    }
    
    static func getQuestionsAskMoreSorted() -> [Int]? {
        return Array(questionsAskMore.sorted())
    }
    
    static func getQuestionsAskLessRandom() -> [Int]? {
        return Array(questionsAskLess).shuffled()
    }
    
    static func getQuestionsAskLessSorted() -> [Int]? {
        return Array(questionsAskLess.sorted())
    }
    
    static func getIndexesQuestionsRandom(numberOfQuestions: Int) -> [Int]? {
        
        var questionsNotAsked = Set<Int>(0 ..< QuestionData.getQuestionCount())
        var array = [Int]()
        let moreOverTotal = Int(Double(numberOfQuestions) * PercentMoreOverTotal)
        var askMore = Set(questionsAskMore)
        var askLess = Set(questionsAskLess)
        
        for i in askMore.intersection(askLess) {
            print("Intersection: \(i)")
        }
        
        while array.count < numberOfQuestions {
            var inserted: Bool = false
            let randomNum = Int.random(in: (0 ..< numberOfQuestions))
            
            if randomNum < moreOverTotal {
                
                // Insert from Ask More Questions
                if !askMore.isEmpty {
                    // Get an index for question
                    var indexQuestion = askMore.removeFirst()
                    while !questionsNotAsked.contains(indexQuestion) {
                        indexQuestion = askMore.removeFirst()
                    }
                    questionsNotAsked.remove(indexQuestion)
                    array.append(indexQuestion)
                    inserted = true
                }
            } else {
                
                // Insert from Ask Less Questions
                if !askLess.isEmpty {
                    // Get an index for question
                    var indexQuestion = askLess.removeFirst()
                    while !questionsNotAsked.contains(indexQuestion) {
                        indexQuestion = askLess.removeFirst()
                    }
                    questionsNotAsked.remove(indexQuestion)
                    array.append(indexQuestion)
                    inserted = true
                }
            }
            if !inserted {
                
                // If we could not insert from askMore or askLess
                let indexQuestion = questionsNotAsked.removeFirst()
                array.append(indexQuestion)
            }
        }
        
        return array
    }
    
    static func getProgressPercent() -> Int {
        
        var count = 0
        // We count the number of questions that the user is not confident at
        for key in questionsScore.keys {
            if questionsScore[key]! < MeanScore {
                count = count + 1
            }
        }
        return MaxQuestion - count
    }
    
    
}
