//
//  Helpers.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 4/10/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import Foundation
import UIKit

class Helpers {
    static func showLocationFailAlert(_ viewController: UIViewController) {
        let locationFailAlert = UIAlertController(title: "Enable Location Services", message: "Open Settings\nTap Location\nSelect 'While Using the App'", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(appSettings)
            }
        }
        
        locationFailAlert.addAction(settingsAction)
        locationFailAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        viewController.present(locationFailAlert, animated: true, completion: nil)
    }
}
