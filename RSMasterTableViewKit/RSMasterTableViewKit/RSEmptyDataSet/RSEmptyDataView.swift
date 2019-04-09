//
//  RSEmptyDataView.swift
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

/// RSEmptyDataBackground
public enum RSEmptyDataBackground {
    case color(color: UIColor)
    case view(view: UIView)
}

/// RSEmptyDataView
open class RSEmptyDataView: UIView {

    // MARK: - Outlets
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var parentStackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
 
    // activity indicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var indicatorLabel: UILabel!
    @IBOutlet weak var indicatorStackView: UIStackView!
    
    // MARK: - Life Cycle
    open override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.stopAnimating()
        indicatorLabel.isHidden = true
        parentStackView.isHidden = true
    }
    
    // MARK: - Public
    
    /// set empty dataview title, description and image
    func setEmptyDataView(title: NSAttributedString?, description: NSAttributedString?, image: UIImage?, background: RSEmptyDataBackground?) {
        
        // title
        if let titleText = title {
            titleLabel.attributedText = titleText
        }else {
            titleLabel.isHidden = true
        }
        
        // description
        if let descText = description {
            descriptionLabel.attributedText = descText
        }else {
            descriptionLabel.isHidden = true
        }
        
        // image
        if let iconImage = image {
            imageView.image = iconImage
        }else {
            imageView.isHidden = true
        }
        
        // background
        if let background = background {
            switch background {
            case .color(let color):
                backgroundView.backgroundColor = color
            case .view(let view):
                view.frame = backgroundView.bounds
                backgroundView.addSubview(view)
                backgroundView.sendSubviewToBack(view)
            }
        }
    }
    
    /// Show loading indicator
    func showLoadingIndicator(title: NSAttributedString? = nil, tintColor: UIColor? = nil) {
        self.showEmptyDataState(false)
        
        // loading indicator
        if let color = tintColor {
            activityIndicator.tintColor = color
        }
        activityIndicator.startAnimating()
        
        // text
        indicatorLabel.isHidden = false
        indicatorLabel.attributedText = title
    }
    
    /// Hide loading indicator
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    /// Hide no search result
    func hideNoSearchLabel() {
        indicatorLabel.isHidden = true
    }
    
    /// Show empty data state
    func showEmptyDataState(_ state: Bool) {
        self.parentStackView.isHidden = !state
        self.backgroundView.isHidden = self.parentStackView.isHidden
        if state {
            self.hideLoadingIndicator()
            self.hideNoSearchLabel()
        }
    }
    
    /// Show No Search Result message
    func showNoSearchResultMessage(_ message: NSAttributedString? = nil) {
        self.showEmptyDataState(false)
        indicatorLabel.isHidden = false
        indicatorLabel.attributedText = message
    }
}

// MARK: - View From Nib
public extension UIView {

    /// Load view from nib
    class func loadFromNib<T: UIView>() -> T {
        
        let nib =  UINib(nibName: String(describing: T.self), bundle: Bundle(for: T.self))
        return nib.instantiate(withOwner: nil, options: nil).first as! T
    }
}
