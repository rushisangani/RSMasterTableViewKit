//
//  JSONExtension.swift
//  RSMasterTableViewKit
//
//  Created by Zensar on 29/08/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import Foundation

/// Encodable object to Data, Dictionary or String conversion
extension Encodable {
    
    /// Data
    var data: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    /// Dictionary
    var dictionary: [String: Any]? {
        guard let data = self.data else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap({ $0 as? [String: Any] })
    }
    
    /// String
    var JSONString: String? {
        guard let data = self.data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

/// Encodable objects Array to Dictionary (JSON) Array
extension Array where Element: Encodable {
    
    /// JSON Array
    var jsonArray: [[String: Any]] {
        
        var data = [[String: Any]]()
        self.forEach { (object) in
            if let value = object.dictionary {  data.append(value) }
        }
        return data
    }
}
