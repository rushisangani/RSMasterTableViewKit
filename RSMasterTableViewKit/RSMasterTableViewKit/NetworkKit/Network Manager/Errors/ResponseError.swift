//
//  ResponseError.swift
//  NetworkKit
//
//  Created by Rushi Sangani on 09/04/19.
//  Copyright © 2019 Rushi Sangani. All rights reserved.
//

import Foundation

/// ResponseError
public enum ResponseError: Error {
    
    /// error - device is not connected to internet
    case internetNotConnected
    
    /// error - HTTP
    case httpError
    
    /// error - invalid url
    case invalidURL
    
    /// error - no data returned from server
    case noDataReturnedFromServer
    
    /// error - json parsing error
    case jsonParsing
    
    /// error - invalid response keypath
    case invalidResponseKeyPath
    
    /// error - decodable conversion
    case decodableConversion
}
