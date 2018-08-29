//
//  JSONRequest.swift
//  ShowItBig
//
//  Created by Rushi Sangani on 11/07/18.
//  Copyright © 2018 Meditab Software Inc. All rights reserved.
//

import Foundation

/// JSON Resposne
typealias JSONResponse = ((Any) -> ())

/// JSONRequest
class JSONRequest: Request {
    
    /// Execute JSON Request
    func execute(success: @escaping JSONResponse, failure: ((ResponseError) -> ())? = nil) {
        NetworkManager.shared.execute(request: self, responseType: .json, success: success, failure: failure)
    }
}

