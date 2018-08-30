//
//  ReachabilityManager.swift
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

/// Reachability Notification
let kReachabilityChangedNotification = "ReachabilityChangedNotification"

/// Reachability Status
let kReachabilityStatus              = "ReachabilityStatus"

/// ReachabilityManager
open class ReachabilityManager {
    
    // MARK: - Singleton
    public static let shared = ReachabilityManager()
    
    // MARK: - Properties
    
    /// Reachability Instance
    public let reachability = Reachability()!
    
    /// Reachability Flag
    public static var isReachable: Bool {
        return ReachabilityManager.shared.connected
    }
    
    /// Checks if connected to network
    private var connected: Bool = true {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name.init(kReachabilityChangedNotification), object: reachability, userInfo: [kReachabilityStatus: connected])
        }
    }
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Initialize
    func initialize() {
        
        // when reachable
        reachability.whenReachable = { [weak self] status in
            self?.connected = true
        }
        
        // when unreachable
        reachability.whenUnreachable = { [weak self] status in
            self?.connected = false
        }
        
        // start
        try? reachability.startNotifier()
    }
}
