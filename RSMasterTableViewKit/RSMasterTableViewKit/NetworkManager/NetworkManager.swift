//
//  File.swift
//  ShowItBig
//
//  Created by Rushi on 09/07/18.
//  Copyright © 2018 Meditab Software Inc. All rights reserved.
//

import Foundation

/// Key-Values
let ContentType          = "Content-Type"
let ApplicationJSON      = "application/json"

/// Messages
let NoInternetConnection = "No Internet Connection!"
let InternetConnected    = "Internet Connected!"
let URLNotValid          = "URL is not valid"
let ErrorInJSONParsing   = "Error in JSON Parsing"
let NoDataReturned       = "No data returned from server"
let NoDataFoundForKeyPath = "No data found for specified KeyPath"

/// Types of HTTP requests
enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

/// Types of Response
enum ResponseType {
    case json, data
}

/// Response Error
typealias ResponseError = (code: UInt, message: String)


/// Network manager to handler all network requests
class NetworkManager {
    
    // MARK: - Singleton
    public static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - Properties
    var currentTasks: [URLSessionDataTask] = []
}

// MARK:- Public
extension NetworkManager {
    
    /**
     Execute Request
     */
     func execute(request: Request, responseType: ResponseType, success: @escaping ((Any) -> ()), failure: ((ResponseError) -> ())?) {
        
        // check for network reachability
        guard ReachabilityManager.shared.isReachable else {
            ReachabilityManager.shared.showInternetConnectionUpdatedMessage()
            self.showError(ResponseError(0, NoInternetConnection), failure: failure)
            return
        }
        
        // check for URL
        guard !request.url.isEmpty, let httpURL = URL(string: request.url) else {
            self.showError(ResponseError(0, URLNotValid), failure: failure)
            return
        }
        
        // cancel previous request if same is exists
        self.cancelTaskForURL(httpURL.absoluteString)
        
        // create request
        var urlRequest = URLRequest(url: httpURL)
        urlRequest.httpMethod = request.method.rawValue
        print(urlRequest.url?.absoluteString ?? "")
        
        // headers
        var httpHeaders = DefaultHeader().value
        
        if let headers = request.headers, !headers.isEmpty {
            httpHeaders.merge(headers) { (_, new) in new }
        }
        urlRequest.allHTTPHeaderFields = httpHeaders
        
        // parameters
        if let params = request.parameters, !params.isEmpty {
            do {
                let jsonParameters = try JSONSerialization.data(withJSONObject: params, options: [])
                urlRequest.httpBody = jsonParameters
                
                let paramString = String(data: jsonParameters, encoding: .utf8)
                print(paramString ?? kEmpty)
            }catch {
                print("Unable to add parameters in request.")
            }
        }
        
        // data task
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            // remove completed task
            print("task completed")
            self.removeTaskForURL(urlRequest.url?.absoluteString ?? "")
            
            // http error check
            if let httpError = error {
                self.showError(ResponseError(0, httpError.localizedDescription), failure: failure)
                return
            }
            
            // response data check
            guard let responseData = data else {
                self.showError(ResponseError(0, NoDataReturned), failure: failure)
                return
            }
            
            // Get data as JSON
            guard var json = try? JSONSerialization.jsonObject(with: responseData, options: []) else {
                self.showError(ResponseError(0, ErrorInJSONParsing), failure: failure)
                return
            }
            
            // print response
            print(json)
            
            // get value for specified keypath if exists
            if let path = request.responeKeyPath,
                !path.isEmpty, let dataObject = (json as! NSDictionary).value(forKeyPath: path) {
                json = dataObject
            }

            // send response if type is JSON
            if responseType == .json {
                success(json)
                return
            }
            
            /// convert json to data
            if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) {
                success(jsonData)
            }else {
                self.showError(ResponseError(0, ErrorInJSONParsing), failure: failure)
            }
        }
        
        // set data task properties
        dataTask.taskDescription = request.url
        
        // add to current tasks
        currentTasks.append(dataTask)
        
        // start
        dataTask.resume()
    }
    
    /// Cancel Data Task
    func cancelTaskForURL(_ url: String) {
        
        // find task for url and cancel it
        if let index = currentTasks.index(where: { $0.taskDescription == url }) {
            
            let dataTask = currentTasks[index]
            dataTask.cancel()
            print("task cancelled")
            currentTasks.remove(at: index)
        }
    }
}

// MARK:- Private
extension NetworkManager {
    
    /// Remove task from currentTasks
    private func removeTaskForURL(_ url: String) {
        
        // find task for url and remove it
        if let index = currentTasks.index(where: { $0.taskDescription == url }) {
            currentTasks.remove(at: index)
            print("task removed")
        }
    }
    
    /// Show Response Error
    func showError(_ error: ResponseError, failure: ((ResponseError) -> ())?) {
        if let failure = failure {
            DispatchQueue.main.async {
                failure(error)
            }
        }
    }
}
