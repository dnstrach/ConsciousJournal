//
//  Quote.swift
//  ConsciousJournal
//
//  Created by Dominique Strachan on 10/10/23.
//

import Foundation

//conforming to codable which includes encodable/decodable - needed for encoding and decoding API call
class Quote: Codable {
    
    //variable name used throughout the app
    var quote: String
    var author: String
    
    //keys for key names in JSON object
    enum CodingKeys: String, CodingKey {
        case quote = "q"
        case author = "a"
    }
}
