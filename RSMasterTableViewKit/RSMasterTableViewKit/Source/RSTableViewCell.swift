//
//  RSReusableTableViewCell.swift
//  RSMasterTableViewKit
//
//  Created by Rushi Sangani on 17/03/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import UIKit

/// Reusable TableViewCell
protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

/// Classname as cell identifier
extension Reusable {
    static var reuseIdentifier: String { return String(describing: self) }
}

/// RSTableViewCell
open class RSTableViewCell: UITableViewCell, Reusable { }

/// UITableView Deque Cell
extension UITableView {
    
    /// Deque reusable cell with default identifier at indexPath
    func dequeueReusableCell<T: Reusable>(at indexPath: IndexPath) -> T {
       return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}

