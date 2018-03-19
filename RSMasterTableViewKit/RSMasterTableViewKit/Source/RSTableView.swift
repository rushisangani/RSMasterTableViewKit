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
    public var tableViewDataSource: RSTableViewDataSource<Any>?
    
    /// Pull To Refresh control
    lazy private var pullToRefresh: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    /// PullToRefresh handler
    private var pullToRefreshHandler: PullToRefreshHandler?
    
    /// Infinite Scrolling handler
    private var infiniteScrollingHanlder: InfiniteScrollingHandler?
    
    /// checks if should fetch more data for infinite scrolling
    var shouldFetchMoreData: Bool = false
    
    /// This sets to true when tableview is fetching next page data for infinite scrolling
    private var isFetchingNextData: Bool = false
    
    /// Number of records to fetch for paging
    public var infiniteScrollingFetchCount: Int = 20
    
    /// Empty data view
    lazy private var emptyDataView: RSEmptyDataView = {
       
        let view: RSEmptyDataView = UIView.loadFromNib()
        view.frame = self.bounds
        backgroundView = view
        return view
    }()
    
    /// SearchBar
    lazy private var tableViewSearchBar: RSTableViewSearchBar = {
       
        let searchBar = RSTableViewSearchBar(tableView: self)
        return searchBar
        
    }()
    
    /// checks if searchBar is added
    private var searchBarAdded: Bool = false
    
    /// SearchBar Result Handler
    private var searchResultHandler: UISearchBarResult?
    
    // MARK: - Life Cycle
    open override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    /// Initialize
    private func initialize() {
        
        estimatedRowHeight = 50
        tableFooterView = UIView()
        rowHeight = UITableViewAutomaticDimension
        register(RSTableViewCell.self, forCellReuseIdentifier: RSTableViewCell.reuseIdentifier)
    }
    
    // MARK: - Public
    
    /// This function is used for tableView cell configuration
    public func setup(cellConfiguration: @escaping UITableViewCellConfiguration) {

        tableViewDataSource = RSTableViewDataSource<Any>(cellConfiguration: cellConfiguration, forTableView: self)
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
    
    /// Add Infinite Scrolling
    public func addInfiniteScrolling(fetchCount:Int? = 20 , handler: @escaping InfiniteScrollingHandler) {
        infiniteScrollingFetchCount = fetchCount!
        infiniteScrollingHanlder = handler
    }
    
    /// Add Searchbar
    public func addSearchBar(onTextDidSearch completion: @escaping UISearchBarResult) {
        
        // add as tableHeaderView
        tableHeaderView = tableViewSearchBar.searchBar
        searchBarAdded = true
        searchResultHandler = completion
        
        // search handler
        tableViewSearchBar.didSearch = { [weak self] (searchText) in
            
            // show search result
            self?.showSearchResults(searchText: searchText, with: completion)
        }
    }
}

// MARK: - Data Update

extension RSTableView {
    
    /// sets data in tableview
    public func setData<T>(data: DataSource<T>) {
        tableViewDataSource?.dataSource = data
        
        // update fetch more data flag
        updateShouldFetchMoreData(data: data)
        
        // reload data if no search
        guard needToFilterResultData() else {
            reloadTableView()
            return
        }
        
        // show result by search text
        showSearchResults(searchText: tableViewSearchBar.searchString, with: searchResultHandler!)
        
        // update fetch more data flag
        updateShouldFetchMoreData(data: data)
    }
    
    /// append data in tableview
    public func appendData<T>(data: DataSource<T>, animated:Bool? = true) {
        
        // append data
        let startIndex = tableViewDataSource?.dataSource.count ?? 0
        for item in data {
            tableViewDataSource?.dataSource.append(item)
        }
        
        // update fetch more data flag
        updateShouldFetchMoreData(data: data)
        
        // check if search text is present
        if needToFilterResultData() {
            showSearchResults(searchText: tableViewSearchBar.searchString, with: searchResultHandler!)
            return
        }
        
        // show in tableView
        if !animated! {
            reloadTableView()
        }else {
            addRows(from: startIndex, to: startIndex + data.count, inSection: 0)
        }
        
        // update fetch more data flag
        updateShouldFetchMoreData(data: data)
    }
    
    /// insert data in tableview at top
    public func prependData<T>(data: DataSource<T>, animated:Bool? = true) {
        
        // add data at starting
        for i in 0..<data.count {
            tableViewDataSource?.dataSource.insert(data[i], at: i)
        }
        
        // update fetch more data flag
        updateShouldFetchMoreData(data: data)
        
        // check if search text is present
        if needToFilterResultData() {
            showSearchResults(searchText: tableViewSearchBar.searchString, with: searchResultHandler!)
            return
        }
        
        // show in tableView
        if !animated! {
            reloadTableView()
        }else {
            addRows(from: 0, to: data.count, inSection: 0)
        }
    }
    
    /// clear all data in tableview
    public func clearData() {
        
        shouldFetchMoreData = false
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
    public func showIndicator(title: NSAttributedString? = nil, tintColor: UIColor? = nil) {
        emptyDataView.showLoadingIndicator(title: title)
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
        tableViewSearchBar.searchBar?.endEditing(true)
        
        if let handler = pullToRefreshHandler {
            handler()
        }
    }
    
    /// Ends pull to refresh animating
    public func endPullToRefresh() {
        pullToRefresh.endRefreshing()
    }
    
    // pull to refresh customization
    public func setPullToRefresh(tintColor: UIColor, attributedText: NSAttributedString) {
        pullToRefresh.tintColor = tintColor
        pullToRefresh.attributedTitle = attributedText
    }
}

// MARK: - EmptyDataView

extension RSTableView {
 
    // empty data view set title, description and image
    public func setEmptyDataView(title: NSAttributedString?, description: NSAttributedString?, image: UIImage? = nil, backgroundColor: UIColor? = nil) {
        emptyDataView.setEmptyDataView(title: title, description: description, image: image, background: backgroundColor)
    }
}

// MARK: - SearchBar

extension RSTableView {
    
    /// set searchbar atttibutes
    public func setSearchbarAttributes(attributes: SearchBarAttributes) {
        tableViewSearchBar.searchBarAttributes = attributes
    }
}

// MARK: - Infinite Scrolling

extension RSTableView {
    
    /// Fetch more data
    func fetchMoreData() {
        if isFetchingNextData { return }
        
        // fetch next page data
        if let handler = self.infiniteScrollingHanlder {
            isFetchingNextData = true
            handler()
        }
    }
}

// MARK: - Private

extension RSTableView {
    
    /// Checks if pull to refresh is animating
    func isPullToRefreshAnimating() -> Bool {
        return pullToRefresh.isRefreshing
    }
    
    /// Checks if filter result by search string
    func needToFilterResultData() -> Bool {
        return searchBarAdded && !tableViewSearchBar.searchString.isEmpty
    }
    
    /// Checks if need to fetch more data
    func isInfiniteScrollingAdded() -> Bool {
        return (self.infiniteScrollingHanlder != nil)
    }
    
    /// updates the flag shouldFetchMoreData
    func updateShouldFetchMoreData<T>(data: [T]) {
        shouldFetchMoreData = (isInfiniteScrollingAdded() && data.count >= infiniteScrollingFetchCount)
    }
    
    /// This function is used to show search results for searched text
    private func showSearchResults(searchText: String, with completion: UISearchBarResult) {
        
        // set main datasource if seachText is empty
        var data = self.tableViewDataSource?.dataSource
        
        if !searchText.isEmpty {
            data = completion(searchText)
        }
        self.tableViewDataSource?.filteredDataSource = data ?? []
        self.reloadTableView()
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
