//
//  Post.swift
//  RSMasterTableViewKitExample
//
//  Created by Rushi on 07/06/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import Foundation
import ObjectMapper

/// Post Model
struct Post: Mappable {
    
    // MARK: - Properties
    
    var userId: UInt = 0
    var id: Int = 0
    var title: String = ""
    var body: String = ""
    
    /// init
    init?(map: Map) {
    }
    
    /// mapping
    mutating func mapping(map: Map) {
        userId <- map["userId"]
        id <- map["id"]
        title <- map["title"]
        body <- map["body"]
    }
}
