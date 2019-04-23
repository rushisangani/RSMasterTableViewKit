//
//  NSManagedObjectRequestProtocol.swift
//  NetworkKit
//
//  Created by Rushi Sangani on 14/04/19.
//  Copyright © 2019 Rushi Sangani. All rights reserved.
//

import Foundation
import CoreData

/// NSManagedObjectRequestProtocol
public protocol NSManagedObjectRequestProtocol : RequestProtocol {
    
    /// NSManagedObjectContext
    var manageObjectContext: NSManagedObjectContext { get set }
}
