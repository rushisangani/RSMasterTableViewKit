//
//  RSSectionedTableViewDataSource.swift
//  RSMasterTableViewKit
//
//  Created by Zensar on 09/10/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import Foundation
import UIKit

/// Section -> (title and data (rows))
public struct Section<T> {
    public let title: String?
    public var data: DataSource<T>
}

/// RSSectionedTableViewDataSource
open class RSSectionedTableViewDataSource<T>: NSObject, UITableViewDataSource {
    
    // MARK: - Properties
    
    /// sections datasource for tableview
    var sections: [Section<T>] = [] {
        didSet{
            filteredSections = sections
        }
    }
    
    /// filtered sectioned datasource
    var filteredSections: [Section<T>] = []
    
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
        return filteredSections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSections[section].data.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return filteredSections[section].title
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
    
    // MARK: - Retrive
    
    /// returns the title for specified indexPath
    public func titleAt(indexPath: IndexPath) -> String? {
        return filteredSections[indexPath.section].title
    }
    
    /// returns the object for specified indexPath
    public func objectAt(indexPath: IndexPath) -> T {
        return filteredSections[indexPath.section].data[indexPath.row]
    }
    
    // MARK: - Add/Update/Set
    
    /// sets sections data
    public func setData(data: [Section<T>]) {
        self.sections = data
    }
    
    /// append new sections or new rows in section
    public func appendData(data: [Section<T>]) {
        data.forEach { (section) in
            if let index = sectionIndexForTitle(section.title) {
                self.sections[index].data.append(contentsOf: section.data)
            }else {
                self.sections.append(section)
            }
        }
    }
    
    /// set rows to specified section title
    public func setRows(_ rows: DataSource<T>, forTitle title: String?) {
        if let index = sectionIndexForTitle(title) {
            self.sections[index].data = rows
        }
    }
    
    /// append rows in section
    public func appendRows(_ rows: DataSource<T>, forTitle title: String?) {
        if let index = sectionIndexForTitle(title) {
            self.sections[index].data.append(contentsOf: rows)
        }
    }
    
    /// update data at indexPath
    public func updateData(_ data: T, atIndexPath indexPath: IndexPath) {
        if isValid(indexPath: indexPath) {
            self.sections[indexPath.section].data[indexPath.row] = data
        }
    }
    
    // MARK: - Delete
    
    /// delete section for specified title
    public func deleteSectionFor(title: String?) {
        if let index = sectionIndexForTitle(title) {
            self.sections.remove(at: index)
        }
    }
    
    /// delete rows for specified section
    public func deleteRowsFor(sectionTitle: String?) {
        if let index = sectionIndexForTitle(sectionTitle) {
            self.sections[index].data.removeAll()
        }
    }
    
    /// delete data at indexPath
    public func deleteDataAt(indexPath: IndexPath) {
        if isValid(indexPath: indexPath){
            self.sections[indexPath.section].data.remove(at: indexPath.row)
        }
    }
    
    /// clear all data
    public func clearData(showEmptyState: Bool = true) {
        self.sections = []
    }
}

// MARK: - Private
extension RSSectionedTableViewDataSource {
    
    /// checks if section is present for title
    private func sectionIndexForTitle(_ title: String?) -> Int? {
        return self.filteredSections.firstIndex(where: { $0.title == title })
    }
    
    /// checks if specified indexPath is valid
    private func isValid(indexPath: IndexPath) -> Bool {
        return (indexPath.section < filteredSections.count && indexPath.row < filteredSections[indexPath.section].data.count)
    }
}
