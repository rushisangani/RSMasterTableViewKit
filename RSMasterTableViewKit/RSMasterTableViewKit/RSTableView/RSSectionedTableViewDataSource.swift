//
//  RSSectionedTableViewDataSource.swift
//  RSMasterTableViewKit
//
//  Created by Zensar on 09/10/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import Foundation
import UIKit

public struct Section<T> {
    public let title: String?
    public let data: DataSource<T>
}

open class RSSectionedTableViewDataSource<T>: NSObject, UITableViewDataSource {
    
    // MARK: - Properties
    
    var sections: [Section<T>] = [Section<T>]()
    
    // MARK: - Private
    
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
        
        self.tableView = tableView
        self.cellIdentifier = identifier
        self.cellConfiguration = cellConfiguration
    }
    
    // MARK: - UITableViewDataSource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].data.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
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
extension RSSectionedTableViewDataSource {
    
    /// returns the title for specified indexPath
    public func titleAt(indexPath: IndexPath) -> String? {
        return sections[indexPath.section].title
    }
    
    /// returns the object for specified indexPath
    public func objectAt(indexPath: IndexPath) -> T {
        return sections[indexPath.section].data[indexPath.row]
    }
    
    /// sets sections data
    public func setData(data: [Section<T>]) {
        self.sections = data
    }
    
    /// append new sections or new rows in section
    public func appendData(data: [Section<T>]) {
        
    }
}
