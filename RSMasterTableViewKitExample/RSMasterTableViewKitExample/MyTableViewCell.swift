//
//  MyTableViewCell.swift
//  RSMasterTableViewKitExample
//
//  Created by Rushi Sangani on 17/03/18.
//  Copyright © 2018 Rushi Sangani. All rights reserved.
//

import UIKit
import RSMasterTableViewKit

class MyTableViewCell: RSTableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
