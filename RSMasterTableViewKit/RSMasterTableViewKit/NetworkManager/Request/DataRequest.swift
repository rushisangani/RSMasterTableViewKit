//
//  DataRequest.swift
//  ShowItBig
//
//  Created by Rushi on 11/07/18.
//  Copyright © 2018 Meditab Software Inc. All rights reserved.
//

import Foundation

/// DataResponse
typealias DataResponse<T> = ((T) -> ())

/// DataRequest
class DataRequest<T: Codable>: Request {
    
    /// Execute request
    func execute(success: @escaping DataResponse<T>, failure: ((ResponseError) -> ())? = nil) {
        
        NetworkManager.shared.execute(request: self, responseType: .data, success: { (response) in
            
            // convert to models
            if let data = (response as? Data) {
                self.convertDataToObjects(data, success: success, failure: failure)
            }
            
        }, failure: failure)
    }
}

// MARK: - Private
extension DataRequest {
    
    /// Convert data to specified objects
    private func convertDataToObjects(_ data: Data, success: @escaping ((T) -> ()), failure: ((ResponseError) -> ())?) {
        
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
