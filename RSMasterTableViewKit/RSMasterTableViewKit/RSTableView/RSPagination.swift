//
//  RSPagination.swift
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

/// Pagination request status
public enum PageRequestStatus {
    case none, started
}

/// PullToRefresh
public typealias PullToRefreshHandler = () -> ()

/// Pagination
public typealias PaginationHandler = (_ page: UInt) -> ()

/// Constants
let kDefaultStartPage    =   UInt(0)
let kDefaultPageSize     =   UInt(20)

/// Pagination Parameters to fetch page wise data from server
public struct PaginationParameters {
    
    // MARK: - Properties
    
    /// Indicates starting page, default is 0
    public var startPage: UInt = kDefaultStartPage
    
    /// Number of records to fetch per page, default is 20
    public var size: UInt = kDefaultPageSize
    
    /// Indicates current page
    public var currentPage: UInt = kDefaultStartPage
    
    // MARK: - Init
    public init() {}
    
    /// Init with values
    public init(page: UInt, size: UInt) {
        
        self.startPage = page
        self.currentPage = page
        self.size = size
    }
}
