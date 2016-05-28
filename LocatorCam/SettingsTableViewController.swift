//
//  SettingsTableViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 5/16/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var stampLocationSwitch: UISwitch!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stampLocationSwitch.setOn(SharingManager.sharedInstance.locationStampEnabled, animated: false)
        usernameLabel.text = UserInfo.username
        emailLabel.text = UserInfo.email
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.toolbarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.toolbarHidden = false
        SharingManager.sharedInstance.locationStampEnabled = stampLocationSwitch.on
    }
}
