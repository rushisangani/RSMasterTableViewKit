//
//  DefaultHeader.swift
//  ShowItBig
//
//  Created by Rushi on 19/07/18.
//  Copyright © 2018 Meditab Software Inc. All rights reserved.
//

import Foundation

/// Keys
let keyXTanent          =   "x_tenant"
let keyAuthorization    =   "Authorization"


/// Headers to pass in request
struct DefaultHeader {
    
    // MARK: - Properties
    
    var contentType: String     = ApplicationJSON
    var tanent: String          = "SIB0001"
    var token: String           = AuthenticationManager.shared.accessToken ?? kDefaultToken
    
    /// value
    var value: [String: String] {
        return [ContentType: ApplicationJSON, keyXTanent: tanent, keyAuthorization: "Bearer \(token)"]
    }
}
