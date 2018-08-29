//
//  NetworkConstants.swift
//  RSMasterTableViewKit
//
//  Created by Rushi Sangani on 29/08/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import Foundation

/************* Enums *****************/

/// Types of HTTP requests
enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

/// Types of Response
enum ResponseType {
    case json, dataModel
}


/************* typealias **************/

/// Response Error
typealias ResponseError = (code: UInt, message: String)


/************* Constants **************/

/// Key-Values
let kContentType          = "Content-Type"
let kApplicationJSON      = "application/json"


/************* Strings **************/

/// Messages
let mNoInternetConnection   = "No Internet Connection!"
let mkInternetConnected     = "Internet Connected!"
let mURLNotValid            = "Invalid URL!"
let mErrorInJSONParsing     = "Error in json parsing"
let mErrorInModelConversion = "Error in data model conversion"
let mNoDataReturned         = "No data returned from server"
let mNoDataFoundForKeyPath  = "No data found for specified KeyPath"



