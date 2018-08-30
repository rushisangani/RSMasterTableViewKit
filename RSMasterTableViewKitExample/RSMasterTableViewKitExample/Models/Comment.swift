//
//  Comment.swift
//  RSMasterTableViewKitExample
//
//  Created by Rushi Sangani on 09/06/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import Foundation

/// Comment Model
struct Comment: Codable {
    
    // MARK: - Properties
    
    var postId: UInt = 0
    var id: Int = 0
    var name: String = ""
    var email: String = ""
    var body: String = ""
}
