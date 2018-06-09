//
//  Comment.swift
//  RSMasterTableViewKitExample
//
//  Created by Rushi Sangani on 09/06/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import Foundation
import ObjectMapper

/// Comment Model
struct Comment: Mappable {
    
    // MARK: - Properties
    
    var postId: UInt = 0
    var id: Int = 0
    var name: String = ""
    var email: String = ""
    var body: String = ""
    
    /// init
    init?(map: Map) {
    }
    
    /// mapping
    mutating func mapping(map: Map) {
        postId <- map["postId"]
        id <- map["id"]
        name <- map["name"]
        email <- map["email"]
        body <- map["body"]
    }
}
