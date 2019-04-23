//
//  Request.swift
//  NetworkKit
//
//  Created by Rushi Sangani on 13/04/19.
//  Copyright © 2019 Rushi Sangani. All rights reserved.
//

import Foundation

/// Request
public class Request<T: Decodable>: RequestProtocol {
    
    // MARK:- Properties
    
    public typealias Response = T
    
    /// URL
    public var url: String
    
    /// HTTP Method
    public var method: HTTPMethod = .get
    
    /// Headers
    public var headers: HTTPHeaders = [:]
    
    /// Query Parameters
    public var queryParameters: QueryParameters = [:]
    
    /// Body Parameters
    public var bodyParameters: BodyParameters = [:]
    
    /// Task Identifier
    public var identifier: String = UUID().uuidString
    
    //MARK: - Init
    
    public init(url: String, method: HTTPMethod, headers: [String: String],
                queryParameters: QueryParameters, bodyParameters: BodyParameters) {
        self.url = url
        self.method = method
        self.headers = headers
        self.queryParameters = queryParameters
        self.bodyParameters = bodyParameters
    }
    
    /// Init - URL
    public convenience init(url: String) {
        self.init(url: url, queryParameters: [:])
    }
    
    /// Init (URL, QueryParameters) - GET Request
    public convenience init(url: String, queryParameters: QueryParameters) {
        self.init(url: url, method: .get, headers: [:],
                  queryParameters: queryParameters, bodyParameters: [:])
    }
    
    /// Init (URL, BodyParameters) - POST Request
    public convenience init(url: String, bodyParameters: BodyParameters) {
        self.init(url: url, method: .post, headers: [:],
                  queryParameters: [:], bodyParameters: bodyParameters)
    }
    
    /// execute request
    /// returns codable model
    /// specify response keypath to get codable for specific path i.e. "data", "data.users", "data.content.message"
    public func execute(responseKeyPath: String? = nil,
                        completion: @escaping (Result<Response, ResponseError>) -> ()) {
        NetworkManager.shared.request(self, responseKeyPath: responseKeyPath, completion: completion)
    }
    
    /// cancel request
    public func cancel() {
        NetworkManager.shared.cancelRequest(self)
    }
}
