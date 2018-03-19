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
    
    // searchBar style
    public var searchBarStyle: UISearchBarStyle?
    
    // cancel button title & tint color
    public var cancelButtonAttributes: SearchBarCancelButtonAttributes?
    
    // MARK: - Init
    
    public init() {}
    
    /// Initialize with search placeHolder and tint color
    public convenience init(searchPlaceHolder: String, style: UISearchBarStyle? = .default, tintColor: UIColor? = nil) {
        self.init()
        self.searchPlaceHolder = searchPlaceHolder
        self.tintColor = tintColor
        self.searchBarStyle = style
    }
}

/// RSTableViewSearchBar
open class RSTableViewSearchBar: NSObject {
    
    // MARK: - Properties
    
    /// UISearchBar
    var searchBar: UISearchBar?
    
    /// tableview for search bar
    weak var tableView: RSTableView?
    
    /// to execute on search event
    var didSearch: ((String) -> ())?
    
    /// SearchBar Attributes
    var searchBarAttributes: SearchBarAttributes = SearchBarAttributes() {
        didSet {
            searchBar?.barTintColor = searchBarAttributes.tintColor ?? defaultSearchBarTintColor
            searchBar?.placeholder = searchBarAttributes.searchPlaceHolder ?? defaultSearchPlaceHolder
            searchBar?.searchBarStyle = searchBarAttributes.searchBarStyle ?? .default
            cancelButtonAttributes = searchBarAttributes.cancelButtonAttributes
        }
    }
    
    /// cancel button attributes
    var cancelButtonAttributes: SearchBarCancelButtonAttributes?
    
    /// Search String
    var searchString: String = ""
    
    // MARK: - Initialize
    init(tableView: RSTableView) {
        super.init()
        
        searchBar = UISearchBar()
        searchBar?.searchBarStyle = .default
        searchBar?.delegate = self
        searchBar?.sizeToFit()
        searchBar?.barTintColor = defaultSearchBarTintColor
        searchBar?.placeholder = defaultSearchPlaceHolder
        self.tableView = tableView
    }
    
    /// search text handler
    func searchForText(text: String?) {
        searchString = text ?? ""
        
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
    
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return !(self.tableView?.isPullToRefreshAnimating())! 
    }
    
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
