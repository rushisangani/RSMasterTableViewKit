//
//  NSManagedObjectRequest.swift
//  NetworkKit
//
//  Created by Rushi Sangani on 14/04/19.
//  Copyright © 2019 Rushi Sangani. All rights reserved.
//

import Foundation
import CoreData

/// NSManageObjectCodable
public typealias NSManageObjectCodable = (NSManagedObject & Codable)

/// Request
public class NSManagedObjectRequest<T: NSManageObjectCodable>: NSManagedObjectRequestProtocol {
    
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
    
    /// ManageObjectContext
    public var manageObjectContext: NSManagedObjectContext
    
    /// Task Identifier
    public var identifier: String = UUID().uuidString
    
    //MARK: - Init
    
    public init(url: String, method: HTTPMethod, headers: [String: String],
                queryParameters: QueryParameters, bodyParameters: BodyParameters, context: NSManagedObjectContext) {
        self.url = url
        self.method = method
        self.headers = headers
        self.queryParameters = queryParameters
        self.bodyParameters = bodyParameters
        self.manageObjectContext = context
    }
    
    /// Init - URL
    public convenience init(url: String, context: NSManagedObjectContext) {
        self.init(url: url, queryParameters: [:], context: context)
    }
    
    /// Init (URL, QueryParameters) - GET Request
    public convenience init(url: String, queryParameters: QueryParameters, context: NSManagedObjectContext) {
        self.init(url: url, method: .get, headers: [:],
                  queryParameters: queryParameters, bodyParameters: [:], context: context)
    }
    
    /// Init (URL, BodyParameters) - POST Request
    public convenience init(url: String, bodyParameters: BodyParameters, context: NSManagedObjectContext) {
        self.init(url: url, method: .post, headers: [:],
                  queryParameters: [:], bodyParameters: bodyParameters, context: context)
    }
    
    /// execute request
    /// returns codable model
    /// specify response keypath to get codable for specific path i.e. "data", "data.users", "data.content.message"
    public func execute(responseKeyPath: String? = nil,
                        completion: @escaping (Result<Response, ResponseError>) -> ()) {
        
        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.context!] = self.manageObjectContext
        
        NetworkManager.shared.request(self, responseKeyPath: responseKeyPath, decoder: decoder, completion: completion)
    }
    
    /// cancel request
    public func cancel() {
        NetworkManager.shared.cancelRequest(self)
    }
}
