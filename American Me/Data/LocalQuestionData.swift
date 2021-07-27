//
//  LocalQuestionData.swift
//  American Me
//
//  Created by Minh Nguyen on 10/10/20.
//  Copyright © 2020 Minh Nguyen. All rights reserved.
//

import Foundation

class LocalQuestionData: Codable, FileWritable, FileReadable{
    
    var questions: [Question]?
    var synonyms: Synonyms?
    var imageKey: ImageKey?
    
    func write(to fileURLComponents: FileURLComponents) throws -> URL {
        // Encode the object to JSON data.
        let data = try JSONEncoder().encode(self)
        // Write the data to a file using the File class.
        return try File.write(data, to: fileURLComponents)
    }
    
    static func read<T>(_ type: T.Type, from fileURLComponents: FileURLComponents) throws -> T where T : Decodable {
        // Read the file data using the File class.
        let data = try File.read(from: fileURLComponents)
        // Decode the JSON data into an object.
        return try JSONDecoder().decode(type, from: data)
    }
}
