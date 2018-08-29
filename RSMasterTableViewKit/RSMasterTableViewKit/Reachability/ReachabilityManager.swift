//
//  ReachabilityManager.swift
//  RSMasterTableViewKit
//
//  Created by Rushi Sangani on 29/08/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import Foundation

/// ReachabilityManager
open class ReachabilityManager {
    
    // MARK: - Singleton
    public static let shared = ReachabilityManager()
    
    // MARK: - Properties
    
    let reachability = Reachability()!
    var isReachable: Bool = true
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Initialize
    func initialize() {
        
        // when reachable
        reachability.whenReachable = { [weak self] status in
            self?.isReachable = true
        }
        
        // when unreachable
        reachability.whenUnreachable = { [weak self] status in
            self?.isReachable = false
        }
        
        // start
        try? reachability.startNotifier()
    }
}
