//
//  RSTableView.swift
//  RSMasterTableViewKit
//
//  Created by Rushi Sangani on 10/03/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import UIKit

/// SearchResultUpdateDelegate to get filtered data based on search text
protocol SearchResultUpdateDelegate: class {
    
    /// To be called when user start typing on search box or to filter data based on search text
    func getResultForSearchString(_ text: String)
    
    /// To get total item count
    func getDataSourceCount() -> Int
}

/// RSTableView
open class RSTableView: UITableView {
    
    // MARK: - Properties
    
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
    private var shouldFetchMoreData: Bool = false
    
    /// This is to manage current status of the infinite scrolling
    private var fetchDataStatus: FetchDataStatus = .none
    
    /// Number of records to fetch for paging
    public var infiniteScrollingFetchCount: Int = 20
    
    /// Empty data view
    lazy private var emptyDataView: RSEmptyDataView = {
       
        let view: RSEmptyDataView = UIView.loadFromNib()
        view.frame = self.bounds
        backgroundView = view
        return view
    }()
    
    /// SearchController
    private var searchController: RSSearchController?
    
    /// SearchResult Update Delegate
    weak var searchResultUpdateDelegate: SearchResultUpdateDelegate?
    
    /// FooterView
    lazy private var footerIndicatorView: UIActivityIndicatorView = {
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.color = UIColor.darkGray
        indicator.hidesWhenStopped = true
        return indicator
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
    }
    
    // MARK: - Public
    
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
        tableFooterView = footerIndicatorView
        if #available(iOS 10.0, *) {
            prefetchDataSource = self
        }
    }
    
    /// Add Searchbar
    public func addSearchBar(viewController: UIViewController, attributes: SearchBarAttributes? = nil) {
        searchController = RSSearchController(viewController: viewController, tableView: self)
        
        // apply attributes
        if let searchBarAttributes = attributes {
            searchController?.searchBarAttributes = searchBarAttributes
        }
        
        // search handler
        searchController?.didSearch = { [weak self] (searchText) in
            
            // show search result
            self?.searchResultUpdateDelegate?.getResultForSearchString(searchText)
        }
    }
}

// MARK: - RSTableViewDataSourceUpdate

extension RSTableView: RSTableViewDataSourceUpdate {
    
    /// new data updated in dataSource
    func didSetDataSource(count: Int) {
        
        // update fetch more data flag
        updateShouldFetchMoreData(count: count)
        
        // reload data if no search
        guard needToFilterResultData() else {
            reloadTableView()
            return
        }
        
        // show result by search text
        self.searchResultUpdateDelegate?.getResultForSearchString((searchController?.searchString)!)
    }
    
    /// new data added in dataSource
    func didAddedToDataSource(start: Int, withTotalCount count: Int) {
        
        // update fetch more data flag
        updateShouldFetchMoreData(count: count)
        
        // check if search text is present
        if needToFilterResultData() {
            self.searchResultUpdateDelegate?.getResultForSearchString((searchController?.searchString)!)
            return
        }
        
        // add rows to tableView
        addRows(from: start, to: start + count, inSection: 0)
    }
    
    /// data updated at specified index in dataSource
    func didUpdatedDataSourceAt(index: Int) {
        updateDeleteRows(indexPaths: [IndexPath(row: index, section: 0)], isUpdate: true)
    }
    
    /// data deleted at specified index in dataSource
    func didDeletedDataDataSourceAt(index: Int) {
        updateDeleteRows(indexPaths: [IndexPath(row: index, section: 0)], isUpdate: false)
    }

    /// all data removed from dataSource
    func didRemovedData() {
        reloadTableView()
        fetchDataStatus = .none
    }
    
    /// reload
    func reload() {
        reloadTableView()
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
        emptyDataView.parentStackView.isHidden = (searchResultUpdateDelegate?.getDataSourceCount() ?? 0 > 0)
        emptyDataView.isHidden = emptyDataView.parentStackView.isHidden
    }
}

// MARK: - RefreshControl

extension RSTableView {
    
    /// Pull To Refresh Handler
    @objc private func handlePullToRefresh() {
        searchController?.searchController.searchBar.endEditing(true)
        
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
        searchController?.searchBarAttributes = attributes
    }
}

// MARK: - Infinite Scrolling and Prefetch

extension RSTableView: UITableViewDataSourcePrefetching {
    
    // prefetch rows
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard indexPaths.count > 0, shouldFetchMoreData else { return }
        self.fetchMoreData()
    }
    
    /// Fetch more data, if not already status
    private func fetchMoreData() {
        if fetchDataStatus == .started { return }
        
        // fetch next page data
        if let handler = self.infiniteScrollingHanlder {
            footerIndicatorView.startAnimating()
            fetchDataStatus = .started
            handler()
        }
    }
    
    /// Checks if need to fetch more data
    private func isInfiniteScrollingAdded() -> Bool {
        return (self.infiniteScrollingHanlder != nil)
    }
    
    /// updates the flag shouldFetchMoreData
    private func updateShouldFetchMoreData(count: Int) {
        shouldFetchMoreData = (isInfiniteScrollingAdded() && count >= infiniteScrollingFetchCount)
    }
}

// MARK: - Private

extension RSTableView {
    
    /// Checks if pull to refresh is animating
    private func isPullToRefreshAnimating() -> Bool {
        return pullToRefresh.isRefreshing
    }
    
    /// Checks if filter result by search string
    private func needToFilterResultData() -> Bool {
        if let searchViewController = searchController, !searchViewController.searchString.isEmpty {
            return true
        }
        return false
    }
    
    /// stop animations: hide refresh animation and indicator
    private func stopAnimations() {
        if self.isPullToRefreshAnimating() { self.endPullToRefresh() }
        footerIndicatorView.stopAnimating()
        self.hideIndicator()
    }
    
    /// reload tableview
    private func reloadTableView() {
        DispatchQueue.main.async {
            
            // stop animations
            self.stopAnimations()
            
            // reload without animation
            UIView.setAnimationsEnabled(false)
            self.reloadData()
            UIView.setAnimationsEnabled(true)
            
            // update fetch data status
            self.fetchDataStatus = .completed
        }
    }
    
    /// This function adds new rows to tableview
    private func addRows(from: Int, to: Int, inSection section:Int) {
        
        var indexPaths = [IndexPath]()
        for i in from..<to {
            indexPaths.append(IndexPath(row: i, section: section))
        }
        
        DispatchQueue.main.async {
            
            // stop animations
            self.stopAnimations()
            
            // insert without animation
            UIView.setAnimationsEnabled(false)
            
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
            
            // enable animations
            UIView.setAnimationsEnabled(true)
            
            // update fetch data status
            self.fetchDataStatus = .completed
        }
    }
    
    /// update or delete rows at IndexPaths
    private func updateDeleteRows(indexPaths: [IndexPath], isUpdate: Bool) {
        DispatchQueue.main.async {
            
            // stop animations
            self.stopAnimations()
            
            // reload without animation
            UIView.setAnimationsEnabled(false)
            
            self.beginUpdates()
            if isUpdate {
                self.reloadRows(at: indexPaths, with: .none)
            }else {
                self.deleteRows(at: indexPaths, with: .none)
            }
            self.endUpdates()
            
            UIView.setAnimationsEnabled(true)
        }
    }
}
