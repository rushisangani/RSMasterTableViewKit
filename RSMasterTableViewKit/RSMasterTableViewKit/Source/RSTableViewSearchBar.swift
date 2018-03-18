//
//  RSTableViewSearchBar.swift
//  RSMasterTableViewKit
//
//  Created by Rushi Sangani on 19/03/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import UIKit

/// SearchBarAttributes
open class SearchBarAttributes {

    // MARK: - Properties
    
    // placeHolder text
    public var searchPlaceHolder: String?
    
    // tint color
    public var tintColor: UIColor?
    
    // cancel button title & tint color
    public var cancelButtonAttributes: SearchBarCancelButtonAttributes?
    
    // MARK: - Init
    
    public init() {}
    
    public convenience init(searchPlaceHolder: String, tintColor: UIColor) {
        self.init()
        self.searchPlaceHolder = searchPlaceHolder
        self.tintColor = tintColor
    }
}

/// RSTableViewSearchBar
open class RSTableViewSearchBar: NSObject {
    
    // MARK: - Properties
    private var searchBar: UISearchBar?
    
    /// to execute on search event
    var didSearch: ((String) -> ())?
    
    /// SearchBar Attributes
    var searchBarAttributes: SearchBarAttributes = SearchBarAttributes() {
        didSet {
            searchBar?.tintColor = searchBarAttributes.tintColor ?? defaultSearchBarTintColor
            searchBar?.placeholder = searchBarAttributes.searchPlaceHolder ?? defaultSearchPlaceHolder
            cancelButtonAttributes = searchBarAttributes.cancelButtonAttributes
        }
    }
    
    /// cancel button attributes
    var cancelButtonAttributes: SearchBarCancelButtonAttributes?
    
    // MARK: - Initialize
    init(tableView: UITableView) {
        super.init()
        
        searchBar = UISearchBar()
        searchBar?.delegate = self
        searchBar?.sizeToFit()
        searchBar?.barTintColor = defaultSearchBarTintColor
        searchBar?.placeholder = defaultSearchPlaceHolder
        
        // add as tableHeaderView
        tableView.tableHeaderView = searchBar
    }
    
    /// search text handler
    func searchForText(text: String?) {
        if let search = didSearch {
            search(text ?? "")
        }
    }
    
    /// set cancel button attributes
    func setCancelButtonAttributes(attributes: SearchBarCancelButtonAttributes) {
        guard let firstSubView = searchBar?.subviews.first else { return }
        for view in firstSubView.subviews {
            if let cancelButton = view as? UIButton {
                cancelButton.setTitle(attributes.title, for: .normal)
                if let color = attributes.tintColor {
                    cancelButton.tintColor = color
                }
            }
        }
    }
}

// MARK:- UISearchBarDelegate
extension RSTableViewSearchBar : UISearchBarDelegate {
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
        guard let attributes = cancelButtonAttributes else { return }
        setCancelButtonAttributes(attributes: attributes)
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        searchBar.text = ""
        searchForText(text: "")
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchForText(text: searchText)
    }
}
