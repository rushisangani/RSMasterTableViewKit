//
//  RSTableViewDataSource.swift
//  RSMasterTableViewKit
//
//  Created by Rushi Sangani on 17/03/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import UIKit

/// RSTableViewDataSource
open class RSTableViewDataSource<T>: NSObject, UITableViewDataSource {
    
    // MARK: - Properties
    
    /// data source for tableview
    public var dataSource: DataSource<T> = [] {
        didSet {
            filteredDataSource = dataSource
        }
    }
    
    /// filtered data source for tableView
    private var filteredDataSource: FilteredDataSource<T> = []
    
    /// cell configuration - (cell, dataObject, indexPath)
    private var cellConfiguration: UITableViewCellConfiguration?
    
    // MARK: - Initialize
    
    init(cellConfiguration: @escaping UITableViewCellConfiguration) {
        self.cellConfiguration = cellConfiguration
    }
    
    // MARK: - UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredDataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // deque tableview cell
        let cell = tableView.dequeueReusableCell(at: indexPath) as RSTableViewCell
        
        // cell configuration
        if let config = cellConfiguration {

            let dataObject = self.objectAt(indexPath: indexPath)
            config(cell, dataObject, indexPath)
        }
        
        return cell
    }
}

// MARK: - Public
extension RSTableViewDataSource {
    
    /// returns the object present in dataSourceArray at specified indexPath
    public func objectAt(indexPath: IndexPath) -> T {
        return self.filteredDataSource[indexPath.row]
    }
}
