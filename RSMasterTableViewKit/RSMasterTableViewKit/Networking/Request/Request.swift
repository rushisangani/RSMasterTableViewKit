//
//  Request.swift
//  RSMasterTableViewKit
//
//  Copyright (c) 2018 Rushi Sangani
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// Types of Response
public enum ResponseType {
    case json, dataModel
}

/// Request
open class Request {
    
    /// URL
    public var url: String
    
    /// HTTP Method
    public var method: HTTPMethod = .GET
    
    /// Requst Headers
    public var headers: [String: String]?
    
    /// Request Parameters
    public var parameters: [String: Any]?
    
    /// Response Keypath
    public var responeKeyPath: String?
    
    // MARK: - Init
    public init(url: String, method: HTTPMethod, headers: [String: String]? = nil, parameters: [String: Any]? = nil, responeKeyPath: String? = nil) {
        self.method = method
        self.url = url
        self.headers = headers
        self.parameters = parameters
        self.responeKeyPath = responeKeyPath
    }
    
    public convenience init(url: String, responeKeyPath: String) {
        self.init(url: url, method: .GET, responeKeyPath: responeKeyPath)
    }
    
    public convenience init(url: String) {
        self.init(url: url, method: .GET)
    }
}

