//
//  DataModelRequest.swift
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

/// DataModelRequest
public class DataModelRequest<T: Codable>: Request {
    
    /// Execute request
    public func execute(success: @escaping DataModelResponse<T>, failure: ((ResponseError) -> ())? = nil) {
        
        NetworkManager.shared.execute(request: self, responseType: .dataModel, success: { [weak self] (response) in
            
            // convert to models
            if let data = (response as? Data) {
                self?.convertDataToObjects(data, success: success, failure: failure)
            }
            
        }, failure: failure)
    }
}

// MARK: - Private
extension DataModelRequest {
    
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
                failure(ResponseError(kModelConversionErrCode, mErrorInModelConversion))
            }
        }
    }
}
