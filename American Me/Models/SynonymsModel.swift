//
//  SynonymsModel.swift
//  American Me
//
//  Created by Minh Nguyen on 9/17/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation

protocol SynonymsModelProtocol {
    func synonymsRetrieved(_ synonyms: Synonyms)
}

class SynonymsModel {
    
    var delegate: SynonymsModelProtocol?
    
    func getSynonyms() {
        
        // Get the url from Firebase Storage
        let db = FireBaseStorageManager()
        db.delegate = self
        db.getUrlFromStorage(path: GeneralData.pathSynonyms)
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
                    let array = try decoder.decode(Synonyms.self, from: data!)
                    
                    // Use the main thread to notify the view controller for UI work
                    DispatchQueue.main.async {
                        
                        // Notify the delegate of the retrieved questions
                        self.delegate?.synonymsRetrieved(array)
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

extension SynonymsModel: FireBaseStorageManagerProtocol {
    func urlRetrieved(url: String) {
        getRemoteJsonFile(url: url)
    }
}
