//
//  ImageModel.swift
//  American Me
//
//  Created by Minh Nguyen on 10/10/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation
import UIKit

protocol ImageModelProtocol {
    func imageRetrieved(imageName: String, imageData: Data)
}

class ImageModel {
    
    var delegate: ImageModelProtocol?
    
    func getImage(imageName: String?) {
        
        guard let imageName = imageName else {
            return
        }
        
        // Get the url from Firebase Storage
        let db = FireBaseStorageManager()
        db.delegateImage = self
        db.getUrlFromStorageImage(imageName: imageName, path: "\(GeneralData.pathImage)\(imageName)")
    }
    
    func getRemoteFile(imageName: String?, url: String?) {
        
        if url == nil {
            return
        }
        if imageName == nil {
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
                DispatchQueue.main.async {
                    self.delegate?.imageRetrieved(imageName: imageName!, imageData: data!)
                }
            }
        }
        // Call resume on the data task
        dataTask.resume()
    }
}

extension ImageModel: FireBaseStorageManagerImageProtocol {
    func urlRetrieved(imageName: String, url: String) {
        getRemoteFile(imageName: imageName, url: url)
    }
}
