//
//  ChannelSettingsTableViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 6/19/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class ChannelSettingsTableViewController: UITableViewController {
    
    // MARK: - Properties
    var channelTitle: String?
    var channelDescription: String?
    var numOfMembers: Int?
    var numOfAdmins: Int?

    @IBOutlet weak var channelTitleLable: UILabel!
    @IBOutlet weak var channelDescriptionLabel: UILabel!
    @IBOutlet weak var numberOfMembersLabel: UILabel!
    @IBOutlet weak var numberOfAdministratorsLabel: UILabel!
    
    @IBAction func inviteOthersToChannel(sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        channelTitleLable.text = channelTitle
        channelDescriptionLabel.text = channelDescription
        if let numOfMembers = numOfMembers {
            numberOfMembersLabel.text = "\(numOfMembers)"
        }
        if let numOfAdmins = numOfAdmins {
            numberOfAdministratorsLabel.text = "\(numOfAdmins)"
        }
    }
    
}
