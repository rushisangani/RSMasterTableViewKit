//
//  RSTableViewDataSource.swift
//  RSMasterTableViewKit
//
//  Created by Rushi Sangani on 17/03/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import UIKit

/// RSTableViewDataSourceUpdate to handle data source updating
protocol RSTableViewDataSourceUpdate: class {
    
    /// To be called when new dataSource value is set
    func didSetDataSource(count: Int)
    
    /// To be called when new data is added to dataSource
    func didAddedToDataSource(start: Int, withTotalCount count: Int)
    
    /// To be called when data is updated at index in dataSource
    func didUpdatedDataSourceAt(index: Int)
    
    /// To be called when data is deleted at index in dataSource
    func didDeletedDataDataSourceAt(index: Int)
    
    /// To be called when all data is removed from dataSource
    func didRemovedData()
    
    /// To be called when dataSourced is updated
    func reload()
}

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
    
    /// datasource update delegate
    private weak var dataSourceUpdateDelegate: RSTableViewDataSourceUpdate?
    
    /// cell configuration - (cell, dataObject, indexPath)
    private var cellConfiguration: UITableViewCellConfiguration<T>?
    
    /// cell identifier
    private var cellIdentifier: String!
    
    /// tableview for datasource
    private weak var tableView: RSTableView?
    
    /// SearchBar Result Handler
    public var searchResultHandler: UISearchBarResult<T>?
    
    /// get datasource count
    public var count: Int {
        return dataSource.count
    }
    
    // MARK: - Initialize
    
    public init(tableView: RSTableView, identifier: String, cellConfiguration: @escaping UITableViewCellConfiguration<T>) {
        super.init()
        
        tableView.dataSource = self
        tableView.tableViewDataSourceDelegate = self
        dataSourceUpdateDelegate = tableView
        
        self.tableView = tableView
        self.cellIdentifier = identifier
        self.cellConfiguration = cellConfiguration
    }
    
    // MARK: - UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredDataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // deque tableview cell
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        
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
    
    /// sets data in datasource
    public func setData(data: DataSource<T>) {
        self.dataSource = data
        self.dataSourceUpdateDelegate?.didSetDataSource(count: data.count)
    }
    
    /// append data in datasource
    public func appendData(data: DataSource<T>) {
        
        let startIndex = self.dataSource.count
        self.dataSource.append(contentsOf: data)
        self.dataSourceUpdateDelegate?.didAddedToDataSource(start: startIndex, withTotalCount: data.count)
    }
    
    /// insert data at top
    public func prependData(data: DataSource<T>) {
        for i in 0..<data.count {
            self.dataSource.insert(data[i], at: i)
        }
        self.dataSourceUpdateDelegate?.didAddedToDataSource(start: 0, withTotalCount: data.count)
    }
    
    /// update data at index
    public func updateData(_ data: T, atIndex index: Int) {
        self.dataSource[index] = data
        self.dataSourceUpdateDelegate?.didUpdatedDataSourceAt(index: index)
    }
    
    /// delete data at index
    public func deleteData(_ data: T, atIndex index: Int) {
        self.dataSource.remove(at: index)
        self.dataSourceUpdateDelegate?.didDeletedDataDataSourceAt(index: index)
    }
    
    /// clear all data
    public func clearData() {
        self.dataSource = []
        self.dataSourceUpdateDelegate?.didRemovedData()
    }
}

// MARK:- RSTableviewDataSourceDelegate

extension RSTableViewDataSource: RSTableviewDataSourceDelegate {
    
    /// called to be filter result
    func getResultForSearchString(_ text: String) {
        
        var data = self.dataSource
        if let handler = searchResultHandler, !text.isEmpty {
            data = handler(text, data)
        }
        self.filteredDataSource = data
        
        // update
        self.dataSourceUpdateDelegate?.reload()
    }
    
    /// called to get data count
    func getCount() -> Int {
        return count
    }
}
