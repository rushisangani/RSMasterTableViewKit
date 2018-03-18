//
//  ViewController.swift
//  RSMasterTableViewKitExample
//
//  Created by Rushi Sangani on 10/03/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import UIKit
import RSMasterTableViewKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: RSTableView!
    var dataArray = ["Rushi", "Sagar"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup tableview
        setupTableView()
    }

    func setupTableView() {
        
        // setup cell & data at indexPath
        tableView.setup { (cell, data, indexPath) in
            cell.textLabel?.text = data as? String
        }
        
        // empty data view
        tableView.setEmptyDataView(title: NSAttributedString(string: "No data found"), description: nil)
        
        // add pull to refresh
        tableView.addPullToRefresh {
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 2 , execute: {
                self.tableView.appendData(data: ["Darshak", "Rahul"])
            })
        }
        
        // pull to refresh tint color and text
        tableView.setPullToRefresh(tintColor: UIColor.blue, attributedText: NSAttributedString(string: "Fetching data"))
        
        // add search bar
        tableView.addSearchBar { (searchText) -> ([String]) in
            return self.dataArray.filter({ $0.lowercased().starts(with: searchText.lowercased()) })
        }
        
        // search bar attributes
        let attributes = SearchBarAttributes(searchPlaceHolder: "Search Name", tintColor: UIColor.blue.withAlphaComponent(0.6))
        tableView.setSearchbarAttributes(attributes: attributes)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show indicator
        tableView.showIndicator(title: NSAttributedString(string: "LOADING"))
        
        // set data
        DispatchQueue.global().asyncAfter(deadline: .now() + 2 , execute: {
            self.tableView.setData(data: self.dataArray)
        })
    }
}

