//
//  RSTableView.swift
//  RSMasterTableViewKit
//
//  Created by Rushi Sangani on 10/03/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import UIKit

/// TableviewDataSourceDelegate to get values of RSTableViewDataSource
protocol RSTableviewDataSourceDelegate: class {
    
    /// To be called when user start typing on search box or to filter data based on search text
    func getResultForSearchString(_ text: String)
    
    /// To get total item count
    func getCount() -> Int
}

/// Pagination Parameters to fetch page wise data from server
public struct PaginationParameters {
    
    /// Indicates current page, default is 1
    public var page: UInt = 1
    
    /// Number of records to fetch per page, default is 20
    public var size: UInt = 20
    
    /// Init
    public init() {}
    
    /// Init with values
    public init(page: UInt, size: UInt) {
        self.page = page
        self.size = size
    }
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
    
    /// Pagination Parameters
    public var paginationParameters: PaginationParameters?
    
    /// Empty data view
    lazy private var emptyDataView: RSEmptyDataView = {
       
        let view: RSEmptyDataView = UIView.loadFromNib()
        view.frame = self.bounds
        backgroundView = view
        return view
    }()
    
    /// SearchController
    private var searchController: RSSearchController?
    
    /// RSTableViewDataSource delegate
    weak var tableViewDataSourceDelegate: RSTableviewDataSourceDelegate!
    
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
    public func addInfiniteScrolling(parameters: PaginationParameters? = PaginationParameters() , handler: @escaping InfiniteScrollingHandler) {
        
        self.paginationParameters = paginationParameters!
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
            searchController?.setSearchBarAttributes(searchBarAttributes)
        }
        
        // search handler
        searchController?.didSearch = { [weak self] (searchText) in
            
            // show search result
            self?.tableViewDataSourceDelegate.getResultForSearchString(searchText)
        }
    }
}

// MARK: - RSTableViewDataSourceUpdate

extension RSTableView: RSTableViewDataSourceUpdate {
    
    /// new data updated in dataSource
    func didSetDataSource(count: Int) {
        
        // check if search text is present
        if needToFilterResultData() {
            self.tableViewDataSourceDelegate.getResultForSearchString((searchController?.searchString)!)
            return
        }
        
        // reload tableview
        reloadTableView {
            
            // update fetch more data flag
            self.updateShouldFetchMoreData(count: count)
        }
    }
    
    /// new data added in dataSource
    func didAddedToDataSource(start: Int, withTotalCount count: Int) {
        didSetDataSource(count: count)
        
        /*
        // add rows to tableView
        addRows(from: start, to: start + count, inSection: 0) {
            
            // scroll to new row
            if start < self.tableViewDataSourceDelegate.getCount() {
                self.scrollToRow(at: IndexPath(row: start, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
            }
            
            // update fetch more data flag
            self.updateShouldFetchMoreData(count: count)
        }
        */
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
        emptyDataView.parentStackView.isHidden = (tableViewDataSourceDelegate.getCount() > 0)
        emptyDataView.isHidden = emptyDataView.parentStackView.isHidden
    }
}

// MARK: - RefreshControl

extension RSTableView {
    
    /// Pull To Refresh Handler
    @objc private func handlePullToRefresh() {
        searchController?.searchController.searchBar.endEditing(true)
        
        // reset
        resetBeforePullToReresh()
        
        if let handler = pullToRefreshHandler {
            handler()
        }
    }
    
    /// This will reset flags and hides animations
    private func resetBeforePullToReresh() {
        stopAnimations()
        shouldFetchMoreData = false
        paginationParameters?.page = 1
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

// MARK: - Infinite Scrolling and Prefetch

extension RSTableView: UITableViewDataSourcePrefetching {
    
    // prefetch rows
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        guard indexPaths.count > 0,
              indexPaths.last?.row == tableViewDataSourceDelegate.getCount()-1,
              shouldFetchMoreData
        else { return }
        
        self.fetchMoreData()
    }
    
    /// Fetch more data, if not already status
    private func fetchMoreData() {
        if fetchDataStatus == .started { return }
        
        // fetch next page data
        if let handler = self.infiniteScrollingHanlder, let parameters = paginationParameters {
            footerIndicatorView.startAnimating()
            fetchDataStatus = .started
            
            // calculate next page
            let page = (tableViewDataSourceDelegate.getCount() / Int(parameters.size)) + 1
            paginationParameters?.page = UInt(page)
            
            // calling handler
            handler(self.paginationParameters?.page ?? 1)
        }
    }
    
    /// Checks if need to fetch more data
    private func isInfiniteScrollingAdded() -> Bool {
        return (self.infiniteScrollingHanlder != nil)
    }
    
    /// updates the pagination parameters
    private func updateShouldFetchMoreData(count: Int) {
        guard isInfiniteScrollingAdded() else {
            shouldFetchMoreData = false
            return
        }
        shouldFetchMoreData = (UInt(count) >= (paginationParameters?.size)!)
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
    private func reloadTableView(completion: (() -> ())? = nil) {
        DispatchQueue.main.async {
            
            // stop animations
            self.stopAnimations()
            
            // reload without animation
            UIView.setAnimationsEnabled(false)
            self.reloadData()
            UIView.setAnimationsEnabled(true)
            
            // update fetch data status
            self.fetchDataStatus = .completed
            
            // call completion
            if let completion = completion {
                completion()
            }
        }
    }
    
    /// This function adds new rows to tableview
    private func addRows(from: Int, to: Int, inSection section:Int, completion: (() -> ())? = nil) {
        
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
            
            // call completion
            if let completion = completion {
                completion()
            }
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
