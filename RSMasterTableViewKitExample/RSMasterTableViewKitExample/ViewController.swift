//
//  ViewController.swift
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
let defaultPostFetchCount = 20
let serverURL = "https://jsonplaceholder.typicode.com/posts"

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: RSTableView!
    
    // MARK: - Properties
    var dataSource: RSTableViewDataSource<Post>?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup tableview
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show indicator
        tableView.showIndicator()
        
        self.fetchDataFromServer { (posts) in
            self.dataSource?.setData(data: posts)
        }
    }
    
    func setupTableView() {
        
        // setup tableview and data source
        dataSource = RSTableViewDataSource<Post>(tableView: tableView, identifier: cellIdentifier, cellConfiguration: { (cell, post, indexPath) in
            cell.textLabel?.text = post.title
            cell.detailTextLabel?.text = post.body
        })
        
        // show empty data view when no data
        tableView.setEmptyDataView(title: NSAttributedString(string: "NO POSTS AVAILABLE"), description: NSAttributedString(string: "Posts that you have uploaded will appear here."), image: #imageLiteral(resourceName: "posts-nodata"))
        
        // add pull to refresh
        tableView.addPullToRefresh {

            self.fetchDataFromServer(completion: { (posts) in
                self.dataSource?.setData(data: [])
            })
        }
        
        // pull to refresh tint color and text
        //tableView.setPullToRefresh(tintColor: UIColor.darkGray, attributedText: NSAttributedString(string: "Fetching data"))
        
        // show search bar
        //tableView.addSearchBar(viewController: self)
        
        // search result
        //dataSource?.searchResultHandler = { (searchText, data) in
        //    return data.filter({ $0.title.lowercased().starts(with: searchText.lowercased()) })
        //}
    }
}

extension ViewController {
    
    /// fetch data from server
    func fetchDataFromServer(completion: @escaping ([Post]) -> ()) {
        
        Alamofire.request(serverURL).responseJSON { (response) in
            if let json = response.result.value, let posts = Mapper<Post>().mapArray(JSONObject: json) {
                completion(posts)
            }
        }
    }
}

