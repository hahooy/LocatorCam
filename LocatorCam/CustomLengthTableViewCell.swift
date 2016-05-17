//
//  CustomLengthTableViewCell.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 5/17/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class CustomLengthTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var customLengthInput: UITextField! {
        didSet {
            print(customLengthInput.text)
        }
    }
    @IBOutlet weak var customUnitInput: UITextField! {
        didSet {
            print(customUnitInput.text)
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true;
    }
}
