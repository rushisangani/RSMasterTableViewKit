//
//  RSReusableTableViewCell.swift
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

import UIKit

/// UITableViewCellConfiguration
public typealias UITableViewCellConfiguration<T> = ((_ cell: UITableViewCell, _ dataObject: T, _ indexPath: IndexPath) -> ())

/// Reusable TableViewCell
public protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

/// Classname as cell identifier
extension Reusable {
    public static var reuseIdentifier: String { return String(describing: self) }
}

/// RSTableViewCell
open class RSTableViewCell: UITableViewCell, Reusable { }

/// UITableView Deque Cell
extension UITableView {
    
    /// Deque reusable cell with default identifier at indexPath
    public func dequeueReusableCell<T: Reusable>(at indexPath: IndexPath) -> T {
       return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}

