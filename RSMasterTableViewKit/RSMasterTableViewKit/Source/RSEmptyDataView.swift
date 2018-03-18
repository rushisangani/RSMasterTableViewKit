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
    @IBOutlet weak var indicatorLabel: UILabel!
    @IBOutlet weak var indicatorStackView: UIStackView!
    
    // MARK: - Life Cycle
    open override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Public
    
    /// set empty dataview title, description and image
    func setEmptyDataView(title: NSAttributedString?, description: NSAttributedString?, image: UIImage?, background: UIColor?) {
        
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
        
        // background color
        if let bgColor = background {
            backgroundColor = bgColor
        }
    }
    
    /// Show loading indicator
    func showLoadingIndicator(title: NSAttributedString? = nil, tintColor: UIColor? = nil) {
        self.parentStackView.isHidden = true
        
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
}
