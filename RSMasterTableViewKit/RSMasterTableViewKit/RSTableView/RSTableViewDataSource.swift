//
//  RSTableViewDataSource.swift
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

/// DataSource
public typealias DataSource<T> = [T]

/// FilteredDataSource
public typealias FilteredDataSource<T> = [T]

/// SearchHandler
public typealias SearchResultHandler<T> = ((String, DataSource<T>) -> ())

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
    func didRemovedData(showEmptyState: Bool)
    
    /// To be called when dataSourced is updated
    func refreshData()
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
    
    // MARK: - Public
    
    /// get datasource array
    public var array: FilteredDataSource<T> {
        return Array(arrayLiteral: self.filteredDataSource) as! FilteredDataSource
    }
    
    /// Search Result Handler
    public var searchResultHandler: SearchResultHandler<T>?
    
    /// get datasource count
    public var count: Int {
        return filteredDataSource.count
    }
    
    // MARK: - Private
    
    /// datasource update delegate
    private weak var dataSourceUpdateDelegate: RSTableViewDataSourceUpdate?
    
    /// cell configuration - (cell, dataObject, indexPath)
    private var cellConfiguration: UITableViewCellConfiguration<T>?
    
    /// cell identifier
    private var cellIdentifier: String!
    
    /// tableview for datasource
    private weak var tableView: RSTableView?
    

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
    public func setData(data: DataSource<T>, replace: Bool = true) {
        if replace {
            self.dataSource = data
        }else {
            self.filteredDataSource = data
        }
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
    public func clearData(showEmptyState: Bool = true) {
        self.dataSource = []
        self.dataSourceUpdateDelegate?.didRemovedData(showEmptyState: showEmptyState)
    }
}

// MARK:- RSTableviewDataSourceDelegate
extension RSTableViewDataSource: RSTableviewDataSourceDelegate {
    
    /// Update search
    func updateSearch(_ searchText: String) {
        if let handler = searchResultHandler {
            handler(searchText, self.dataSource)
        }
    }
    
    /// To get datasource array count
    func getCount() -> Int {
        return count
    }
}
