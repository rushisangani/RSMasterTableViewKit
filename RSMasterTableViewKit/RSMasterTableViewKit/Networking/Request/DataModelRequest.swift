//
//  DataRequest.swift
//  ShowItBig
//
//  Created by Rushi on 11/07/18.
//  Copyright © 2018 Meditab Software Inc. All rights reserved.
//

import Foundation

/// DataModelResponse
typealias DataModelResponse<T> = ((T) -> ())

/// DataModelRequest
class DataModelRequest<T: Codable>: Request {
    
    /// Execute request
    func execute(success: @escaping DataModelResponse<T>, failure: ((ResponseError) -> ())? = nil) {
        
        NetworkManager.shared.execute(request: self, responseType: .dataModel, success: { (response) in
            
            // convert to models
            if let data = (response as? Data) {
                self.convertDataToObjects(data, success: success, failure: failure)
            }
            
        }, failure: failure)
    }
}

// MARK: - Private
extension DataModelRequest {
    
    /// Convert data to specified objects
    private func convertDataToObjects(_ data: Data, success: @escaping ((T) -> ()), failure: ((ResponseError) -> ())?) {
        
        do {
            guard let result = try? JSONDecoder().decode(T.self, from: data) else {
                return
            }
        } catch let error {
            failure(ResponseError(error, ErrorInJSONParsing))
        }
        
        // convert to specified type
        let result = try? JSONDecoder().decode(T.self, from: data)
        
        DispatchQueue.main.async {
            
            // success
            if let result = result {
                success(result)
            }
            
            // error
            else if let failure = failure {
                failure(ResponseError(0, ErrorInJSONParsing))
            }
        }
    }
}
