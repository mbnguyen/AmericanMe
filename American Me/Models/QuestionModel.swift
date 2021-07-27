//
//  QuestionModel.swift
//  American Me
//
//  Created by Minh Nguyen on 9/14/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation

protocol QuestionModelProtocol {
    func questionRetrieved(_ questions:[Question])
}

class QuestionModel {
    
    var delegate: QuestionModelProtocol?
    
    func getQuestions() {
        
        // Get the url from Firebase Storage
        let db = FireBaseStorageManager()
        db.delegate = self
        db.getUrlFromStorage(path: GeneralData.pathQuestions)
    }
    
    func getRemoteJsonFile(url: String?) {
        
        if url == nil {
            return
        }
        
        // Get a URL object
        guard let url = URL(string: url!) else {
            print("Couldn't create URL object")
            return
        }
        
        // Get a URL Session object
        let session = URLSession.shared
        
        // Get a data task object
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            
            // Check that there wasn't an error
            if error == nil && data != nil {
                
                // Parse the JSON
                do {

                    // Create a JSON Decoder object
                    let decoder = JSONDecoder()
                    
                    // Try to decode the data into objects
                    let array = try decoder.decode([Question].self, from: data!)
                    
                    // Use the main thread to notify the view controller for UI work
                    DispatchQueue.main.async {
                        
                        // Notify the delegate of the retrieved questions
                        self.delegate?.questionRetrieved(array)
                    }
                } catch {
                    // Error: Couldn't download the data
                }
            }
        }
        // Call resume on the data task
        dataTask.resume()
    }
}

extension QuestionModel: FireBaseStorageManagerProtocol {
    func urlRetrieved(url: String) {
        getRemoteJsonFile(url: url)
    }
}
