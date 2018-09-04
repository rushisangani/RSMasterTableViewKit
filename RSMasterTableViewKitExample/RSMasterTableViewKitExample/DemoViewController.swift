//
//  DemoViewController.swift
//  RSMasterTableViewKitExample
//
//  Created by Rushi Sangani on 10/03/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import UIKit
import RSMasterTableViewKit

/// Constants
let kServerURL = "https://jsonplaceholder.typicode.com/comments"
let kPaginationStartPage = UInt(1)
let kPaginationSize      = UInt(100)

class DemoViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: RSTableView!
    
    // MARK: - Properties
    var dataSource: RSTableViewDataSource<Comment>?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup tableview
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // fetch data
        fetchInitialData()
    }
    
    /// Fetch initial data
    func fetchInitialData() {
        
        // show indicator
        tableView.showIndicator(title: NSAttributedString(string: "LOADING"), tintColor: UIColor.darkGray)
        
        // fetch and display data
        let url = getURLForPage(kPaginationStartPage)
        
        self.fetchDataFromServer(url: url) { [weak self] (commentList) in
            self?.dataSource?.setData(data: commentList)
        }
    }
    
    // MARK: - TableView Setup
    func setupTableView() {
        
        // setup tableview and data source
        dataSource = RSTableViewDataSource<Comment>(tableView: tableView, identifier: "cell") { (cell, comment, indexPath) in
            
            cell.textLabel?.text = "\(indexPath.row+1). \(comment.email)"
            cell.detailTextLabel?.text = comment.body
        }
        
        // show empty data view when no data available
        tableView.setEmptyDataView(title: NSAttributedString(string: "NO COMMENTS AVAILABLE"), description:  NSAttributedString(string: "Comments that you've posted will appear here."), image: UIImage(named: "nodata-comments"), background: nil)
        
        // search bar
        tableView.addSearchBar(noResultMessage: NSAttributedString(string: "No result matching your search criteria"))
        dataSource?.searchResultHandler = { [weak self] (searchString, dataArray) in
            
            // filter
            let result = dataArray.filter({ $0.email.starts(with: searchString) })
            self?.dataSource?.setSearchResultData(result, replace: false)
        }                                                                 
        
        // add pull to refresh
        tableView.addPullToRefresh { [weak self] in
            DispatchQueue.global().asyncAfter(deadline: .now()+2, execute: {
                self?.dataSource?.setData(data: [])
            })
        }
        
        // pull to refresh tint color and text
        tableView.setPullToRefresh(tintColor: UIColor.darkGray, attributedText: NSAttributedString(string: "Fetching data"))
        
        let paginationParams = PaginationParameters(page: 1, size: 50)
        
        // Pagination
        tableView.addPagination(parameters: paginationParams) { [weak self] (page) in
            
            // url for next page
            let url = self?.getURLForPage(page)
            
            // fetch & append data
            self?.fetchDataFromServer(url: url!, completion: { (list) in
                self?.dataSource?.appendData(data: list)
            })
        }
    }
    
    /// get url
    func getURLForPage(_ page: UInt) -> String {
        return "\(kServerURL)?_page=\(page)&_limit=\(tableView.paginationParameters?.size ?? kPaginationSize)"
    }
    
    /// fetch data from server
    func fetchDataFromServer(url: String, completion: @escaping ([Comment]) -> ()) {
        
        // request
        let request = DataModelRequest<[Comment]>(url: url)
        
        // execute
        request.execute(success: { [weak self] (comments) in
            self?.dataSource?.appendData(data: comments)
            
        }) { [weak self] (error) in
            print(error.message)
            self?.tableView.hideAllAnimations()
        }
    }
}

