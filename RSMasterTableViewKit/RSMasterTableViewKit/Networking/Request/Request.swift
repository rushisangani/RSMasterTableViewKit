//
//  Request.swift
//  ShowItBig
//
//  Created by Rushi on 11/07/18.
//  Copyright © 2018 Meditab Software Inc. All rights reserved.
//

import Foundation

/// Request
class Request {
    
    /// URL
    var url: String
    
    /// HTTP Method
    var method: HTTPMethod = .GET
    
    /// Requst Headers
    var headers: [String: String]?
    
    /// Request Parameters
    var parameters: [String: Any]?
    
    /// Response Keypath
    var responeKeyPath: String?
    
    // MARK: - Init
    init(url: String, method: HTTPMethod, headers: [String: String]? = nil, parameters: [String: Any]? = nil, responeKeyPath: String? = nil) {
        self.method = method
        self.url = url
        self.headers = headers
        self.parameters = parameters
        self.responeKeyPath = responeKeyPath
    }
    
    convenience init(url: String, responeKeyPath: String) {
        self.init(url: url, method: .GET, responeKeyPath: responeKeyPath)
    }
    
    convenience init(url: String) {
        self.init(url: url, method: .GET)
    }
}

