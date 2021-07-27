//
//  LocalStorageManager.swift
//  American Me
//
//  Created by Minh Nguyen on 10/6/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation
import UIKit

protocol LocalStorageManagerProtocol {
    func dataRetrieved()
}

class LocalStorageManager {
    
    var delegate: LocalStorageManagerProtocol?
    
    static let fileNameGeneral = "AmericanMeData"
    static let fileNameQuestion = "AmericanMeQuestionData"
    static let directoryData = "Data"
    static let directoryImage = "Images"
    
    static func saveGeneralDataLocally() {
        
        // Get the file URL Component
        let fileURLComponents = FileURLComponents(fileName: fileNameGeneral,
                                               fileExtension: "json",
                                               directoryName: directoryData,
                                               directoryPath: .documentDirectory)

        // Create a Data package
        let data = LocalGeneralData()
        
        // Insert data
        data.speechRate = GeneralData.speechRate
        data.useImages = GeneralData.useImages
        data.questionsScore = ProgressManager.questionsScore
        data.questionsAskMore = ProgressManager.questionsAskMore
        data.questionsAskLess = ProgressManager.questionsAskLess
        data.currentIndex = QuestionData.currentIndex
        
        // Write data
        do {
            _ = try data.write(to: fileURLComponents)
        } catch {
            print(error)
        }
    }
    
    static func loadGeneralData() {
        
        // Get the file URL Component
        let fileURLComponents = FileURLComponents(fileName: fileNameGeneral,
                                               fileExtension: "json",
                                               directoryName: directoryData,
                                               directoryPath: .documentDirectory)
        
        do {
            // Get the data
            let data = try LocalGeneralData.read(LocalGeneralData.self, from: fileURLComponents)
            
            // Assign the data
            if data.speechRate != nil {
                GeneralData.speechRate = data.speechRate!
            }
            if data.useImages != nil {
                GeneralData.useImages = data.useImages!
            }
            if data.questionsScore != nil {
                ProgressManager.questionsScore = data.questionsScore!
            }
            if data.questionsAskLess != nil {
                ProgressManager.questionsAskLess = data.questionsAskLess!
            }
            if data.questionsAskMore != nil {
                ProgressManager.questionsAskMore = data.questionsAskMore!
            }
        } catch {
            print(error)
        }
    }
    
    static func saveQuestionDataLoacally() {
        
        // Get the file URL Component
        let fileURLComponents = FileURLComponents(fileName: fileNameQuestion,
                                               fileExtension: "json",
                                               directoryName: directoryData,
                                               directoryPath: .documentDirectory)

        // Create a Data package
        let data = LocalQuestionData()
        
        // Insert data
        data.questions = QuestionData.questions
        data.synonyms = QuestionData.synonyms
        data.imageKey = QuestionData.imageKey
        
        // Write data
        do {
            _ = try data.write(to: fileURLComponents)
        } catch {
            print(error)
        }
    }
    
    func downloadQuestionDataIfNeeded() {
        
        // Set up delegate
        let questionsData = QuestionData()
        questionsData.delegate = self
        
        // Get the file URL Component
        let fileURLComponents = FileURLComponents(fileName: LocalStorageManager.fileNameQuestion,
                                               fileExtension: "json",
                                               directoryName: LocalStorageManager.directoryData,
                                               directoryPath: .documentDirectory)
        do {
            if try File.exists(fileURLComponents) {
                LocalStorageManager.loadQuestionData()
                delegate?.dataRetrieved()
            } else {
                questionsData.retrieveData()
            }
        } catch {
            print(error)
        }
    }
    
    static func loadQuestionData() {
        
        // Get the file URL Component
        let fileURLComponents = FileURLComponents(fileName: fileNameQuestion,
                                               fileExtension: "json",
                                               directoryName: directoryData,
                                               directoryPath: .documentDirectory)
        
        do {
            // Get the data
            let data = try LocalQuestionData.read(LocalQuestionData.self, from: fileURLComponents)
            
            // Assign the data
            if data.questions != nil {
                QuestionData.questions = data.questions!
            }
            if data.synonyms != nil {
                QuestionData.synonyms = data.synonyms!
            }
            if data.imageKey != nil {
                QuestionData.imageKey = data.imageKey!
            }
        } catch {
            print(error)
        }
    }
    
    static func exist(imageName: String) -> Bool {
        
        let fileURLComponents = FileURLComponents(fileName: imageName,
                                               fileExtension: "data",
                                               directoryName: directoryImage,
                                               directoryPath: .documentDirectory)
        do {
            if try File.exists(fileURLComponents) {
                return true
            } else {
                return false
            }
        } catch {
            print(error)
            return false
        }
    }
    
    /*static func loadImage(fileURLComponents: FileURLComponents?) -> UIImage? {
        
        guard let fileURL = fileURLComponents else {
            return nil
        }
        
        do {
            // Get the data
            let data = try LocalImage.read(LocalImage.self, from: fileURL)
            
            // Assign the data
            if data.image != nil {
                return UIImage(data: data.image!)
            }
        } catch {
            print(error)
            return nil
        }
        
    }*/
    
    static func loadImageLocally(imageName: String?) -> UIImage? {
        
        guard let imageName = imageName else {
            return nil
        }
        
        let fileURLComponents = FileURLComponents(fileName: imageName,
                                               fileExtension: "data",
                                               directoryName: LocalStorageManager.directoryImage,
                                               directoryPath: .documentDirectory)
        
        do {
            if try File.exists(fileURLComponents) {
                let data = try LocalImage.read(LocalImage.self, from: fileURLComponents)
                
                // Assign the data
                if data.image != nil {
                    return UIImage(data: data.image!)
                }
                return nil
            } else {
                return nil
            }
        } catch {
            print(error)
            return nil
        }
        
    }
    
    func downloadImage(imageName: String?) {
        
        guard let imageName = imageName else {
            return
        }
        
        // Set up delegate
        let imageModel = ImageModel()
        imageModel.delegate = self
        
        imageModel.getImage(imageName: imageName)
    }
    
    static func saveImageLocally(imageName: String?, imageData: Data?) {
        
        guard let imageName = imageName else {
            return
        }
        
        guard let imageData = imageData else {
            return
        }
        
        // Get the file URL Component
        let fileURLComponents = FileURLComponents(fileName: imageName,
                                               fileExtension: "data",
                                               directoryName: directoryImage,
                                               directoryPath: .documentDirectory)

        // Create a Data package
        let data = LocalImage()
        
        // Insert data
        data.image = imageData
        
        // Write data
        do {
            _ = try data.write(to: fileURLComponents)
        } catch {
            print(error)
        }
    }
    
    // TODO: func to load the image from local storage
    // func to call a service to download the missing image
    // func to save the downloaded image to local storage then call the delegate to updateUI
    
}

extension LocalStorageManager: QuestionDataProtocol {
    
    func questionDataRetrieved() {
        LocalStorageManager.saveQuestionDataLoacally()
        delegate?.dataRetrieved()
    }
}

extension LocalStorageManager: ImageModelProtocol {
    
    func imageRetrieved(imageName: String, imageData: Data) {
        LocalStorageManager.saveImageLocally(imageName: imageName, imageData: imageData)
        delegate?.dataRetrieved()
    }
}
