//
//  DemoViewController.swift
//  RSMasterTableViewKitExample
//
//  Created by Rushi Sangani on 10/03/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import UIKit
import RSMasterTableViewKit
import Alamofire
import ObjectMapper

let cellIdentifier = "cell"
let defaultFetchCount = 100
let serverURL = "https://jsonplaceholder.typicode.com/comments"

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
        
        // show indicator
        tableView.showIndicator(title: NSAttributedString(string: "LOADING"), tintColor: UIColor.darkGray)
        
        // fetch and display data
        self.fetchDataFromServer(url: getFetchURLForPage(1)) { (comments) in
            self.dataSource?.setData(data: comments)
        }
    }
    
    // MARK: - TableView Setup
    func setupTableView() {
        
        // setup tableview and data source
        dataSource = RSTableViewDataSource<Comment>(tableView: tableView, identifier: cellIdentifier, cellConfiguration: { (cell, comment, indexPath) in
            
            cell.textLabel?.text = "\(indexPath.row+1). \(comment.email)"
            cell.detailTextLabel?.text = comment.body
        })
        
        // show empty data view when no data available
        tableView.setEmptyDataView(title: NSAttributedString(string: "NO COMMENTS AVAILABLE"), description: NSAttributedString(string: "Comments that you have posted will appear here."), image: #imageLiteral(resourceName: "posts-nodata"))
        
        // pagination parameters
        tableView.paginationParameters = PaginationParameters(page: 1, size: UInt(defaultFetchCount))
        
        // add pull to refresh
        tableView.addPullToRefresh {

            self.fetchDataFromServer(url: self.getFetchURLForPage(1), completion: { (comments) in
                
                // set data
                self.dataSource?.setData(data: comments)
            })
        }
        
        // pull to refresh tint color and text
        tableView.setPullToRefresh(tintColor: UIColor.darkGray, attributedText: NSAttributedString(string: "Fetching data"))
        
        // infinite scrolling
        tableView.addInfiniteScrolling { (page) in
            
            // get url for next page
            let url = self.getFetchURLForPage(page)
            
            self.fetchDataFromServer(url: url, completion: { (comments) in
                
                // append new data
                self.dataSource?.appendData(data: comments)
            })
        }
    }
    
    /// get url
    func getFetchURLForPage(_ page: UInt) -> String {
        return "\(serverURL)?_page=\(page)&_limit=\(tableView.paginationParameters?.size ?? UInt(defaultFetchCount))"
    }
}

extension UIViewController {
    
    /// fetch data from server
    func fetchDataFromServer(url: String, completion: @escaping ([Comment]) -> ()) {
        
        Alamofire.request(url).responseJSON { (response) in
            if let json = response.result.value, let comments = Mapper<Comment>().mapArray(JSONObject: json) {
                completion(comments)
            }
        }
    }
}

