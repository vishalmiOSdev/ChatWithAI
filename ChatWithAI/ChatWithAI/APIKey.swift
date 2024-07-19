//
//  APIKey.swift
//  ChatWithAI
//
//  Created by Vishal Manhas on 17/07/24.
//

import Foundation
enum APIKey{
    
    static var defaultKey: String {
        guard let filePath = Bundle.main.path(forResource: "Chat_Info", ofType: "plist") else {
            fatalError("Error: Could not find the info.plist file.")
        }

        guard let plist = NSDictionary(contentsOfFile: filePath) else {
            fatalError("Error: Could not read the info.plist file.")
        }

        guard let value = plist.object(forKey: "API-KEY") as? String else {
            fatalError("Error: API_KEY not found in info.plist.")
        }

        if value.starts(with: "_") {
            fatalError("Error: API_KEY in info.plist is invalid. It starts with an underscore.")
        }

        return value
    }
}
