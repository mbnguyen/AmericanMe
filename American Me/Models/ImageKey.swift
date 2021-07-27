//
//  ImageKey.swift
//  American Me
//
//  Created by Minh Nguyen on 10/4/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation

class ImageKey: Codable {
    
    var keys: [String: String]?
    
    func isReady() -> Bool {
        
        // Check if everything is ready
        if keys != nil {
            return true
        } else {
            return false
        }
    }
    
    func getImageName(key: String) -> String? {
        
        // Check if the given word has synonym
        guard let keys = keys else {
            return nil
        }
        guard let imageName = keys[key] else {
            return nil
        }
        return imageName
    }
}
