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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(SharingManager.sharedInstance.locationStampEnabled)
        stampLocationSwitch.setOn(SharingManager.sharedInstance.locationStampEnabled, animated: false)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        SharingManager.sharedInstance.locationStampEnabled = stampLocationSwitch.on
    }
}
