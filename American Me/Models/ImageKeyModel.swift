//
//  ImageKeyModel.swift
//  American Me
//
//  Created by Minh Nguyen on 10/4/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation

protocol ImageKeyModelProtocol {
    func imageKeyRetrieved(_ imageKey:ImageKey)
}

class ImageKeyModel {
    
    var delegate: ImageKeyModelProtocol?
    
    func getImageKey() {
        
        // Get the url from Firebase Storage
        let db = FireBaseStorageManager()
        db.delegate = self
        db.getUrlFromStorage(path: GeneralData.pathImageKey)
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
                    let array = try decoder.decode(ImageKey.self, from: data!)
                    
                    // Use the main thread to notify the view controller for UI work
                    DispatchQueue.main.async {
                        
                        // Notify the delegate of the retrieved questions
                        self.delegate?.imageKeyRetrieved(array)
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

extension ImageKeyModel: FireBaseStorageManagerProtocol {
    func urlRetrieved(url: String) {
        getRemoteJsonFile(url: url)
    }
}
