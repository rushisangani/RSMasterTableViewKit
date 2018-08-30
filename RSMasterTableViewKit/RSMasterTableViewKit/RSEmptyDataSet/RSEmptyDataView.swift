//
//  RSEmptyDataView.swift
//  RSMasterTableViewKit
//
//  Created by Rushi Sangani on 17/03/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
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
                backgroundView.sendSubview(toBack: view)
            }
        }
    }
    
    /// Show loading indicator
    func showLoadingIndicator(title: NSAttributedString? = nil, tintColor: UIColor? = nil) {
        self.showEmptyDataState(false)
        activityIndicator.isHidden = false
        
        // loading indicator
        if let color = tintColor {
            activityIndicator.tintColor = color
        }
        activityIndicator.startAnimating()
        
        // text
        indicatorLabel.attributedText = title
    }
    
    /// Hide loading indicator
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        indicatorLabel.text = ""
    }
    
    /// Show empty data state
    func showEmptyDataState(_ state: Bool) {
        
        self.parentStackView.isHidden = !state
        self.backgroundView.isHidden = self.parentStackView.isHidden
        if state { self.hideLoadingIndicator() }
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
