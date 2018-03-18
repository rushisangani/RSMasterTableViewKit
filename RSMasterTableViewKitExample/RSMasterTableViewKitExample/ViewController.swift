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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }

    func setupTableView() {
        
        tableView.setup { (cell, data, indexPath) in
            cell.textLabel?.text = data as? String
        }
        
        tableView.setEmptyDataView(title: NSAttributedString(string: "No data found"), description: nil, image: nil)
        
        
        tableView.addPullToRefresh {
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 2 , execute: {
                self.tableView.appendData(data: ["Hello", "How are you"], animated: false)
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.showIndicator()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2 , execute: {
            self.tableView.setData(data: [])
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

