//
//  NetworkManager.swift
//  NetworkKit
//
//  Created by Rushi Sangani on 09/04/19.
//  Copyright © 2019 Rushi Sangani. All rights reserved.
//

import Foundation

/// NetworkManager
public final class NetworkManager {
    
    /// Singleton
    public static let shared = NetworkManager()
    
    /// Init
    private init() {}
    
    // MARK:- Properties
    
    /// Tasks - currently executing tasks
    private var pendingTasks = [URLSessionDataTask]()
}

//MARK: - Internal

extension NetworkManager {
    
    /// JSON Request
    func requestJSON<T: RequestProtocol>(_ request: T, responseKeyPath: String?,
                                         completion: @escaping (Result<Any, ResponseError>) -> ()) {
        
        execute(request: request) { (response) in
            
            switch response {
            case .success(let data):
                
                // convert to json
                data.toJSON(keyPath: responseKeyPath, handler: { (result) in
                    
                    DispatchQueue.main.async {
                        
                        switch result {
                        case .success(let json):
                            print(json)
                            completion(.success(json))
                        case .failure(let err):
                            print(err.localizedDescription)
                            completion(.failure(err))
                        }
                    }
                })
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Data Request
    func requestData<T: RequestProtocol>(_ request: T, responseKeyPath: String?,
                                         completion: @escaping (Result<Data, ResponseError>) -> ()) {
        
        requestJSON(request, responseKeyPath: responseKeyPath) { (result) in
            
            switch result {
            case .success(let json):
                
                if let data = try? JSONSerialization.data(withJSONObject: json, options: []) {
                    completion(.success(data))
                }else {
                    fatalError("Failed to convert data from json at specified keypath")
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Decodable Request
    func request<P: RequestProtocol, T: Decodable>(_ request: P, responseKeyPath: String?,
                                                   decoder: JSONDecoder = JSONDecoder(),
                                                   completion: @escaping (Result<T, ResponseError>) -> ()) {
        
        requestData(request, responseKeyPath: responseKeyPath) { (response) in
            
            switch response {
            case .success(let jsonData):
                
                guard let result = try? decoder.decode(T.self, from: jsonData) else {
                    completion(.failure(.decodableConversion))
                    return
                }
                completion(.success(result))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Cancel Request
    @discardableResult
    func cancelRequest<T: RequestProtocol>(_ request: T) -> Bool {
        
        if let index = pendingTasks.firstIndex(where: { $0.taskDescription == request.identifier }) {
            let task = pendingTasks[index]
            task.cancel()
            pendingTasks.remove(at: index)
            return true
        }
        return false
    }
}

//MARK: - Private
extension NetworkManager {
    
    /// Execute Request
    private func execute<T: RequestProtocol>(request: T, completion: @escaping (Result<Data, ResponseError>) -> ()) {
        
        // add query parameters
        let url = request.url
        
        // validate url
        guard let httpURL = URL(string: url) else {
            print(url)
            completion(.failure(.invalidURL))
            return
        }
        
        // network check
        guard ReachabilityManager.isReachable else {
            completion(.failure(.internetNotConnected))
            return
        }
        
        // create request
        var urlRequest = URLRequest(url: httpURL)
        urlRequest.httpMethod = request.method.rawValue.uppercased()
        print(urlRequest.url?.absoluteString ?? "")
        
        // headers
        urlRequest.allHTTPHeaderFields = request.headers
        
        // parameters
        if !request.bodyParameters.isEmpty {
            do {
                let parameters = try JSONSerialization.data(withJSONObject: request.bodyParameters, options: [])
                urlRequest.httpBody = parameters
                
                let paramString = String(data: parameters, encoding: .utf8)
                print(paramString ?? "")
            }catch {
                print("Unable to add parameters in request.")
            }
        }
        
        // datatask
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            // remove completed task
            self.removeTask(identifier: request.identifier)
            
            // error check
            guard error == nil else {
                print(error!)
                completion(.failure(.httpError))
                return
            }
            
            // response data check
            guard let responseData = data else {
                completion(.failure(.noDataReturnedFromServer))
                return
            }
            
            // completion
            completion(.success(responseData))
        }
        
        task.taskDescription = request.identifier
        pendingTasks.append(task)
        task.resume()
    }
    
    /// Remove task
    private func removeTask(identifier: String) {
        if let index = pendingTasks.firstIndex(where: { $0.taskDescription == identifier }) {
            pendingTasks.remove(at: index)
        }
    }
}
