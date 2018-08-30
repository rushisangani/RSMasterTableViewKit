//
//  NetworkManager.swift
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

/************* Enums *****************/

/// Types of HTTP requests
public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

/************* Error Codes **************/

/// Error codes
let kNoInternetErrCode      = -1
let kInvalidURLErrCode      = -2
let kJSONParsingErrCode     = -3
let kModelConversionErrCode = -4
let kHTTPErrCode            = -5
let kNoDataReturnedErrCode  = -6
let kDataConversionErrCode  = -7


/************* Strings **************/

/// Messages
let mNoInternetConnection   = "No Internet Connection!"
let mkInternetConnected     = "Internet Connected!"
let mURLNotValid            = "Invalid URL!"
let mErrorInJSONParsing     = "Error in json parsing"
let mErrorInDataConversion  = "Error in data conversion"
let mErrorInModelConversion = "Error in data model conversion"
let mNoDataReturned         = "No data returned from server"
let mNoDataFoundForKeyPath  = "No data found for specified KeyPath"


/// Network manager to handler all network requests
open class NetworkManager {
    
    // MARK: - Singleton
    public static let shared = NetworkManager()
    
    // MARK: - Init
    private init() {
        ReachabilityManager.shared.initialize()
    }
    
    // MARK: - Properties
    
    /// Array of current tasks
    public var currentTasks: [URLSessionDataTask] = []
}

// MARK:- Public
extension NetworkManager {
    
    /**
     Execute Network Request
     */
     public func execute(request: Request, responseType: ResponseType, success: @escaping ((Any) -> ()), failure: ((ResponseError) -> ())?) {
        
        // check for network reachability
        guard ReachabilityManager.isReachable else {
            self.showError(ResponseError(kNoInternetErrCode, mNoInternetConnection), failure: failure)
            return
        }
        
        // check for URL
        guard !request.url.isEmpty, let httpURL = URL(string: request.url) else {
            self.showError(ResponseError(kInvalidURLErrCode, mURLNotValid), failure: failure)
            return
        }
        
        // cancel previous request if same is exists
        self.cancelTaskForURL(httpURL.absoluteString)
        
        // create request
        var urlRequest = URLRequest(url: httpURL)
        urlRequest.httpMethod = request.method.rawValue
        print(urlRequest.url?.absoluteString ?? "")
        
        // headers
        var httpHeaders = [String: String]()
        
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
                print(paramString ?? "")
            }catch {
                print("Unable to add parameters in request.")
            }
        }
        
        // start data task
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            
            // remove completed task
            self?.removeTaskForURL(urlRequest.url?.absoluteString ?? "")
            
            // http error check
            if let httpError = error {
                self?.showError(ResponseError(kHTTPErrCode, httpError.localizedDescription), failure: failure)
                return
            }
            
            // response data check
            guard let responseData = data else {
                self?.showError(ResponseError(kNoDataReturnedErrCode, mNoDataReturned), failure: failure)
                return
            }
            
            // Get data as JSON
            guard var json = try? JSONSerialization.jsonObject(with: responseData, options: []) else {
                self?.showError(ResponseError(kJSONParsingErrCode, mErrorInJSONParsing), failure: failure)
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
                self?.showError(ResponseError(kDataConversionErrCode, mErrorInDataConversion), failure: failure)
            }
        }
        
        // set data task properties
        dataTask.taskDescription = request.url
        
        // add to current tasks
        self.currentTasks.append(dataTask)
        
        // start
        dataTask.resume()
    }
    
    /// Cancel Data Task
    public func cancelTaskForURL(_ url: String) {
        
        // find task for url and cancel it
        if let index = currentTasks.index(where: { $0.taskDescription == url }) {
            
            let dataTask = currentTasks[index]
            dataTask.cancel()
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
        }
    }
    
    /// Show error message
    private func showError(_ error: ResponseError, failure: ((ResponseError) -> ())?) {
        guard let failure = failure else { return }
        
        DispatchQueue.main.async {
            failure(error)
        }
    }
}
