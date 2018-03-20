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
    var dataSource: DataSource<T> = [] {
        didSet {
            filteredDataSource = dataSource
        }
    }
    
    /// filtered data source for tableView
    var filteredDataSource: FilteredDataSource<T> = []
    
    /// cell configuration - (cell, dataObject, indexPath)
    private var cellConfiguration: UITableViewCellConfiguration?
    
    /// tableview for datasource
    weak private var tableView: RSTableView?
    
    /// indexPath location to fetch more data
    private var indexPathToFetchData: IndexPath
    
    // MARK: - Initialize
    
    init(cellConfiguration: @escaping UITableViewCellConfiguration, forTableView tableView: RSTableView) {
        
        self.cellConfiguration = cellConfiguration
        self.tableView = tableView
        indexPathToFetchData =  IndexPath(row: filteredDataSource.count-3, section: 0)
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
        
        // if no data to fetch then return cell
        guard (self.tableView?.shouldFetchMoreData)! else {
            return cell
        }
        
        // fetch more data when current tableview cell is in last 3 cells
        if indexPath.row == indexPathToFetchData.row {
            self.tableView?.fetchMoreData()
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
