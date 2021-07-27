//
//  FireBaseStorageManager.swift
//  American Me
//
//  Created by Minh Nguyen on 10/9/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation
import FirebaseStorage
import UIKit

protocol FireBaseStorageManagerProtocol {
    func urlRetrieved(url: String)
}

protocol FireBaseStorageManagerImageProtocol {
    func urlRetrieved(imageName: String, url: String)
}

class FireBaseStorageManager {
    
    var delegate: FireBaseStorageManagerProtocol?
    
    var delegateImage: FireBaseStorageManagerImageProtocol?
    
    func getUrlFromStorage(path: String?) {
        
        guard let path = path else {
            return
        }
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()

        // Create a reference to the file you want to download
        let storageRef = storage.reference().child(path)
        
        storageRef.downloadURL { (url, error) in
            if error == nil && url != nil {
                self.delegate?.urlRetrieved(url: url!.absoluteString)
            } else {
                print(error!)
            }
        }
    }
    
    func getUrlFromStorageImage(imageName: String?, path: String?) {
        
        guard let path = path else {
            return
        }
        guard let imageName = imageName else {
            return
        }
        
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()

        // Create a reference to the file you want to download
        let storageRef = storage.reference().child("\(path).png")
        
        storageRef.downloadURL { (url, error) in
            if error == nil && url != nil {
                self.delegateImage?.urlRetrieved(imageName: imageName, url: url!.absoluteString)
            } else {
                print(error!)
            }
        }
    }
}
