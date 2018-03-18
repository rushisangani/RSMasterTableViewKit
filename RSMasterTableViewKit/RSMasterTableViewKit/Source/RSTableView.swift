//
//  RSTableView.swift
//  RSMasterTableViewKit
//
//  Created by Rushi Sangani on 10/03/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import UIKit

/// RSTableView
open class RSTableView: UITableView {
    
    // MARK: - Properties
    
    /// datasource for tableView
    var tableViewDataSource: RSTableViewDataSource<Any>?
    
    /// pullToRefresh handler
    private var pullToRefreshHandler: PullToRefreshHandler?
    
    /// Pull To Refresh control
    lazy open var pullToRefresh: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    /// empty data view
    lazy open var emptyDataView: RSEmptyDataView = {
       
        let view: RSEmptyDataView = UIView.loadFromNib()
        view.frame = self.bounds
        backgroundView = view
        return view
    }()
    
    // MARK: - Life Cycle
    open override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    /// Initialize
    private func initialize() {
        
        estimatedRowHeight = 50
        rowHeight = UITableViewAutomaticDimension
        tableFooterView = UIView()
        register(RSTableViewCell.self, forCellReuseIdentifier: RSTableViewCell.reuseIdentifier)
    }
    
    // MARK: - Public
    
    /// This function is used for tableView cell configuration
    public func setup(cellConfiguration: @escaping UITableViewCellConfiguration) {

        tableViewDataSource = RSTableViewDataSource<Any>(cellConfiguration: cellConfiguration)
        dataSource = tableViewDataSource
    }
    
    /// Add PullToRefresh to tableview
    public func addPullToRefresh(handler: @escaping PullToRefreshHandler) {
        pullToRefreshHandler = handler
        
        if #available(iOS 10.0, *) {
            refreshControl = pullToRefresh
        } else {
            addSubview(pullToRefresh)
        }
    }
}

// MARK: - Data Update

extension RSTableView {
    
    /// sets data in tableview
    public func setData<T>(data: DataSource<T>) {
        tableViewDataSource?.dataSource = data
        reloadTableView()
    }
    
    /// append data in tableview
    public func appendData<T>(data: DataSource<T>, animated:Bool? = true) {
        
        // append data
        let startIndex = tableViewDataSource?.dataSource.count ?? 0
        for item in data {
            tableViewDataSource?.dataSource.append(item)
        }
        
        if !animated! {
            reloadTableView()
        }else {
            addRows(from: startIndex, to: startIndex + data.count, inSection: 0)
        }
    }
    
    /// insert data in tableview at top
    public func prependData<T>(data: DataSource<T>, animated:Bool? = true) {
        
        // add data at starting
        for i in 0..<data.count {
            tableViewDataSource?.dataSource.insert(data[i], at: i)
        }
        
        if !animated! {
            reloadTableView()
        }else {
            addRows(from: 0, to: data.count, inSection: 0)
        }
    }
    
    /// clear all data in tableview
    public func clearData() {
        tableViewDataSource?.dataSource = []
        reloadTableView()
    }
    
    /// reload tableview
    public func reloadTableView() {
        
        DispatchQueue.main.async {
            
            if self.isPullToRefreshAnimating() { self.endPullToRefresh() }
            self.hideIndicator()
            self.reloadData()
        }
    }
}

// MARK: - Indicator

extension RSTableView {
    
    /// Show loading indicator
    public func showIndicator() {
        emptyDataView.showLoadingIndicator()
    }
    
    /// Hide loading indicator
    public func hideIndicator() {
        emptyDataView.hideLoadingIndicator()
        emptyDataView.parentStackView.isHidden = (tableViewDataSource?.dataSource.count ?? 0 > 0)
    }
}

// MARK: - RefreshControl

extension RSTableView {
    
    /// Pull To Refresh Handler
    @objc private func handlePullToRefresh() {
        if let handler = pullToRefreshHandler {
            handler()
        }
    }
    
    /// Ends pull to refresh animating
    public func endPullToRefresh() {
        pullToRefresh.endRefreshing()
    }
}

// MARK: - EmptyDataView

extension RSTableView {
 
    // empty data view set title, description and image
    public func setEmptyDataView(title: NSAttributedString?, description: NSAttributedString?, image: UIImage?) {
        emptyDataView.setEmptyDataView(title: title, description: description, image: image)
    }
}

// MARK: - Customization

extension RSTableView {
    
    // pull to refresh
    public func setPullToRefresh(tintColor: UIColor, attributedText: NSAttributedString) {
        pullToRefresh.tintColor = tintColor
        pullToRefresh.attributedTitle = attributedText
    }
}

// MARK: - Private

extension RSTableView {
    
    /// Checks if pull to refresh is animating
    private func isPullToRefreshAnimating() -> Bool {
        return pullToRefresh.isRefreshing
    }
    
    /// This function adds new rows to tableview
    func addRows(from: Int, to: Int, inSection section:Int) {
        
        var indexPaths = [IndexPath]()
        for i in from..<to {
            indexPaths.append(IndexPath(row: i, section: section))
        }
        
        // hide refresh animation
        DispatchQueue.main.async {
            
            // Hide refresh animation and indicator
            if self.isPullToRefreshAnimating() { self.endPullToRefresh() }
            self.hideIndicator()
            
            // insert rows
            if #available(iOS 11.0, *) {
                self.performBatchUpdates({
                    self.insertRows(at: indexPaths, with: .none)
                }) { (success) in
                }
            } else {
                self.beginUpdates()
                self.insertRows(at: indexPaths, with: .none)
                self.endUpdates()
            }
        }
    }
}
