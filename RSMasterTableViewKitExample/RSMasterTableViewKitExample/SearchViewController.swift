//
//  SearchViewController.swift
//  RSMasterTableViewKitExample
//
//  Created by Rushi Sangani on 09/06/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import UIKit
import RSMasterTableViewKit
import Alamofire
import ObjectMapper

class SearchViewController: UIViewController {

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
        self.fetchDataFromServer(url: serverURL) { (comments) in
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
        tableView.setEmptyDataView(title: NSAttributedString(string: "No Results"), description: nil)
        
        // add search bar
        tableView.addSearchBar(viewController: self)
        
        // search handler
        dataSource?.searchResultHandler = { (text, data) in
            return data.filter({ $0.email.lowercased().starts(with: text.lowercased()) })
        }
    }
}
