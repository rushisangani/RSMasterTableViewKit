//
//  RSEmptyDataView.swift
//  RSMasterTableViewKit
//
//  Created by Rushi Sangani on 17/03/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import UIKit

open class RSEmptyDataView: UIView {

    // MARK: - Outlets
    
    @IBOutlet weak var parentStackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
 
    // activity indicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Life Cycle
    open override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Public
    
    /// set empty dataview title, description and image
    public func setEmptyDataView(title: NSAttributedString?, description: NSAttributedString?, image: UIImage?) {
        
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
    }
    
    /// Show loading indicator
    public func showLoadingIndicator() {
        self.parentStackView.isHidden = true
        activityIndicator.startAnimating()
    }
    
    /// Hide loading indicator
    public func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
}
