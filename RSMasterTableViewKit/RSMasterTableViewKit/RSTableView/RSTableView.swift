//
//  RSTableView.swift
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

/// TableviewDataSourceDelegate to get values of RSTableViewDataSource
protocol RSTableviewDataSourceDelegate: class {
    
    /// To be called when user start typing on search box or to filter data based on search text
    func getResultForSearchString(_ text: String)
    
    /// To get total item count
    func getCount() -> Int
}

/// RSTableView
open class RSTableView: UITableView {
    
    // MARK: - Properties
    
    // MARK: - Private
    
    /// Pull To Refresh control
    lazy private var pullToRefresh: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    /// PullToRefresh handler
    private var pullToRefreshHandler: PullToRefreshHandler?
    
    /// Pagination handler
    private var paginationHanlder: PaginationHandler?
    
    /// checks if should fetch more data for pagination
    private var shouldFetchMoreData: Bool = false
    
    /// This is to manage current status of the infinite scrolling
    private var pageRequestStatus: PageRequestStatus = .none
    
    /// Empty data view
    lazy private var emptyDataView: RSEmptyDataView = {
       
        let view: RSEmptyDataView = UIView.loadFromNib()
        view.frame = self.bounds
        backgroundView = view
        return view
    }()
    
    /// SearchBar delegate
    private var searchBarDelegate: RSSearchBarDelegate?
    
    /// RSTableViewDataSource delegate
    weak var tableViewDataSourceDelegate: RSTableviewDataSourceDelegate!
    
    /// FooterView
    lazy private var footerIndicatorView: UIActivityIndicatorView = {
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.color = UIColor.darkGray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Public
    
    /// Pagination Parameters
    public var paginationParameters: PaginationParameters?
    
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
    
    /// Add Pagination
    public func addPagination(parameters: PaginationParameters? = PaginationParameters() , handler: @escaping PaginationHandler) {
        
        self.paginationParameters = parameters
        paginationHanlder = handler
        tableFooterView = footerIndicatorView
        if #available(iOS 10.0, *) {
            prefetchDataSource = self
        }
    }
    
    /// Add Searchbar
    @discardableResult
    public func addSearchBar(placeHolder: String? = mDefaultSearchPlaceHolder, tintColor: UIColor? = nil) -> UISearchBar? {
        self.searchBarDelegate = RSSearchBarDelegate(placeHolder: placeHolder!, tintColor: tintColor)
        self.tableHeaderView = self.searchBarDelegate?.searchBar
        
        // handler
        self.searchBarDelegate?.didSearch = { [weak self] searchText in
            self?.tableViewDataSourceDelegate.getResultForSearchString(searchText)
        }
        return self.searchBarDelegate?.searchBar
    }
}

// MARK: - RSTableViewDataSourceUpdate
extension RSTableView: RSTableViewDataSourceUpdate {
    
    /// new data updated in dataSource
    func didSetDataSource(count: Int) {
        
        // check if search text is present
        if needToFilterResultData() {
            self.tableViewDataSourceDelegate.getResultForSearchString(searchBarDelegate?.searchBar?.text ?? "")
            return
        }
        
        // reload tableview
        reloadTableView { [weak self] in
            
            // update empty data set
            self?.updateEmptyDataState()
            
            // update fetch more data flag
            self?.updateShouldFetchMoreData(count: count)
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
        updateOrDeleteRows(indexPaths: [IndexPath(row: index, section: 0)], isUpdate: true)
    }
    
    /// data deleted at specified index in dataSource
    func didDeletedDataDataSourceAt(index: Int) {
        updateOrDeleteRows(indexPaths: [IndexPath(row: index, section: 0)], isUpdate: false)
    }

    /// all data removed from dataSource
    func didRemovedData(showEmptyState: Bool) {
        
        resetPagination()
        refreshData()
        
        // update empty data set, if true
        if showEmptyState {
            self.updateEmptyDataState()
        }
    }
    
    /// refresh data
    func refreshData() {
        reloadTableView()
    }
}

// MARK: - Indicator
extension RSTableView {
    
    /// Show loading indicator
    public func showIndicator(title: NSAttributedString? = nil, tintColor: UIColor? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) { [weak self] in
            self?.emptyDataView.showLoadingIndicator(title: title)
        }
    }
    
    /// Hide loading indicator
    public func hideIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.emptyDataView.hideLoadingIndicator()
        }
    }
    
    /// Hides Loading Indicator, PullToRefresh, Load more
    public func hideAllAnimations() {
        
        // stop animations
        self.stopAnimations()
        
        // end pull to refresh
        self.endPullToRefresh()
    }
}

// MARK: - PullToRefresh
extension RSTableView {
    
    // pull to refresh customization
    public func setPullToRefresh(tintColor: UIColor, attributedText: NSAttributedString? = nil) {
        pullToRefresh.tintColor = tintColor
        pullToRefresh.attributedTitle = attributedText
    }
    
    /// Ends pull to refresh animating
    public func endPullToRefresh() {
        guard self.isPullToRefreshAnimating() else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: { [weak self] in
            self?.pullToRefresh.endRefreshing()
        })
    }
    
    /// Pull To Refresh Handler
    @objc private func handlePullToRefresh() {
        searchBarDelegate?.searchBar?.resignFirstResponder()
        
        // reset
        resetBeforePullToReresh()
        
        // call handler
        if let handler = pullToRefreshHandler {
            handler()
        }
    }
    
    /// Checks if pull to refresh is animating
    private func isPullToRefreshAnimating() -> Bool {
        return pullToRefresh.isRefreshing
    }
    
    /// This will reset flags and hides animations
    private func resetBeforePullToReresh() {
        stopAnimations()
        resetPagination()
    }
}

// MARK: - EmptyDataView
extension RSTableView {
 
    // empty data view set title, description and image
    public func setEmptyDataView(title: NSAttributedString?, description: NSAttributedString?, image: UIImage? = nil, background: RSEmptyDataBackground? = nil) {
        emptyDataView.setEmptyDataView(title: title, description: description, image: image, background: background)
    }
    
    /// Update empty data state
    private func updateEmptyDataState() {
        DispatchQueue.main.async { [weak self] in
            self?.emptyDataView.showEmptyDataState(self?.tableViewDataSourceDelegate.getCount() == 0)
        }
    }
}

// MARK: - Pagination
extension RSTableView: UITableViewDataSourcePrefetching {
    
    // prefetch rows
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        guard indexPaths.count > 0,
            indexPaths.last?.row == tableViewDataSourceDelegate.getCount()-1, shouldFetchMoreData
        else { return }
        
        self.fetchMoreData()
    }
    
    /// Fetch more data, if not already started status
    private func fetchMoreData() {
        if pageRequestStatus == .started { return }
        
        // fetch next page data
        if let handler = self.paginationHanlder, let parameters = paginationParameters {
            footerIndicatorView.startAnimating()
            pageRequestStatus = .started
            
            // calculate next page
            paginationParameters?.currentPage = parameters.currentPage+1
            
            // calling handler
            handler(self.paginationParameters?.currentPage ?? parameters.startPage)
        }
    }
    
    /// Checks if need to fetch more data
    private func isPaginationEnabled() -> Bool {
        return (self.paginationHanlder != nil)
    }
    
    /// updates the pagination parameters
    private func updateShouldFetchMoreData(count: Int) {
        guard isPaginationEnabled() else {
            shouldFetchMoreData = false
            return
        }
        shouldFetchMoreData = (UInt(count) >= (paginationParameters?.size)!)
    }
    
    /// reset current page
    private func resetPagination() {
        shouldFetchMoreData = false
        if let pagination = paginationParameters {
            paginationParameters?.currentPage = pagination.startPage
        }
    }
}

// MARK: - UI Update & Animations
extension RSTableView {
    
    /// Checks if filter result by search string
    func needToFilterResultData() -> Bool {
        if let searchText = searchBarDelegate?.searchBar?.text, !searchText.isEmpty {
            return true
        }
        return false
    }
    
    /// reload tableview
    private func reloadTableView(completion: (() -> ())? = nil) {
        DispatchQueue.main.async { [weak self] in
            
            // hide animations
            self?.hideAllAnimations()
            
            // reload without animation
            UIView.setAnimationsEnabled(false)
            self?.reloadData()
            UIView.setAnimationsEnabled(true)
            
            // update page request status
            self?.pageRequestStatus = .none
            
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
        
        DispatchQueue.main.async { [weak self] in
            
            // hide animations
            self?.hideAllAnimations()
            
            // insert without animation
            UIView.setAnimationsEnabled(false)
            
            // insert rows
            if #available(iOS 11.0, *) {
                self?.performBatchUpdates({
                    self?.insertRows(at: indexPaths, with: .none)
                }) { (success) in
                }
            } else {
                self?.beginUpdates()
                self?.insertRows(at: indexPaths, with: .none)
                self?.endUpdates()
            }
            
            // enable animations
            UIView.setAnimationsEnabled(true)
            
            // update page request status
            self?.pageRequestStatus = .none
            
            // call completion
            if let completion = completion {
                completion()
            }
        }
    }
    
    /// update or delete rows at IndexPaths
    private func updateOrDeleteRows(indexPaths: [IndexPath], isUpdate: Bool) {
        DispatchQueue.main.async { [weak self] in
            
            // stop animations
            self?.stopAnimations()
            
            // reload without animation
            UIView.setAnimationsEnabled(false)
            
            self?.beginUpdates()
            if isUpdate {
                self?.reloadRows(at: indexPaths, with: .none)
            }else {
                self?.deleteRows(at: indexPaths, with: .none)
            }
            self?.endUpdates()
            
            // enable animations
            UIView.setAnimationsEnabled(true)
        }
    }
    
    /// stop animations: hide refresh animation and indicator
    private func stopAnimations() {
        footerIndicatorView.stopAnimating()
        self.hideIndicator()
    }
}
