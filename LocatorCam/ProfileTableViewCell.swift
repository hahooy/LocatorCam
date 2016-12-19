//
//  ProfileTableViewCell.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 4/3/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
