//
//  RequestProtocol.swift
//  NetworkKit
//
//  Created by Rushi Sangani on 09/04/19.
//  Copyright © 2019 Rushi Sangani. All rights reserved.
//

import Foundation

/// HTTP method
public enum HTTPMethod: String {
    case get, post, put, patch, delete
}

/// HTTPHeaders
public typealias HTTPHeaders        =   [String : String]

/// QueryParams
public typealias QueryParameters    =   [String : String]

/// BodyParams
public typealias BodyParameters     =   [String : Any]


/// RequestProtocol
public protocol RequestProtocol {
    
    associatedtype Response
    
    // MARK:- Properties
    
    /// URL
    var url: String { get set }
    
    /// HTTP Method
    var method: HTTPMethod { get set }
    
    /// Headers
    var headers: HTTPHeaders { get set }
    
    /// Query Parameters
    var queryParameters: QueryParameters { get set }
    
    /// Body Parameters
    var bodyParameters: BodyParameters { get set }
    
    /// Task Identifier
    var identifier: String { get set }
}
