//
//  Extensions.swift
//  NetworkKit
//
//  Created by Rushi Sangani on 14/04/19.
//  Copyright © 2019 Rushi Sangani. All rights reserved.
//

import Foundation

//MARK: - String
extension String {
    
    /// Get encoded url
    public func encodedURL() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
    
    /// Get ecoded url with query parameters
    public func appendQueryParamters(_ parameters: [String: String]) -> String {
        var components = URLComponents()
        components.queryItems = parameters.map {
            URLQueryItem(name: $0, value: $1)
        }
        return components.url?.absoluteString.encodedURL() ?? ""
    }
}

//MARK: - Data
extension Data {
    
    /// Data to JSON
    public func toJSON(keyPath: String? = nil, handler: (Result<Any, ResponseError>) -> ()) {
        
        guard let json = try? JSONSerialization.jsonObject(with: self, options: []) else {
            handler(.failure(.jsonParsing))
            return
        }
        
        // check if keypath is present
        guard let path = keyPath, !path.isEmpty else {
            handler(.success(json))
            return
        }
        
        // get value for specified keypath
        guard let dataObject = (json as! NSDictionary).value(forKeyPath: path) else {
            handler(.failure(.invalidResponseKeyPath))
            return
        }
        handler(.success(dataObject))
    }
}

//MARK: - CodingUserInfoKey
extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "managedObjectContext")
}
