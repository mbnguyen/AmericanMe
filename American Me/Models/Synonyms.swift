//
//  Synonyms.swift
//  American Me
//
//  Created by Minh Nguyen on 9/17/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation

class Synonyms: Codable {
    
    var synonymsArr: [String: [String]]?
    
    func isReady() -> Bool {
        
        // Check if everything is ready
        if synonymsArr != nil {
            return true
        } else {
            return false
        }
    }
    
    func hasSynonym(key: String, word: String) -> Bool {
        
        // Check if the given word has synonym
        guard let synonyms = synonymsArr?[key] else {
            return false
        }
        if synonyms.contains(word.lowercased()) {
            return true
        }
        return false
    }
}

