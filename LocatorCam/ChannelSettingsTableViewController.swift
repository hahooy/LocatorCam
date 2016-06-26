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
    var channel: Channel?
    
    struct Constant {
        static let segueToSearchUserIdentifier = "to search user for invitation"
    }

    @IBOutlet weak var channelTitleLable: UILabel!
    @IBOutlet weak var channelDescriptionLabel: UILabel!
    @IBOutlet weak var numberOfMembersLabel: UILabel!
    @IBOutlet weak var numberOfAdministratorsLabel: UILabel!
    
    @IBAction func inviteOthersToChannel(sender: UIButton) {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        channelTitleLable.text = channel?.name
        channelDescriptionLabel.text = channel?.description
        if let numOfAdmins = channel?.numOfAdmins {
            numberOfAdministratorsLabel.text = "\(numOfAdmins)"
        }
        if let numOfMembers = channel?.numOfMembers {
            numberOfMembersLabel.text = "\(numOfMembers)"
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constant.segueToSearchUserIdentifier {
            if let searchUserVC = segue.destinationViewController as? ChannelInvitationTableViewController {
                searchUserVC.channelToJoin = channel
            }
        }
    }
    
}
