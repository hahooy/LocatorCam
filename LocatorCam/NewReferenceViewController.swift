//
//  NewReferenceViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 5/21/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class NewReferenceViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lengthTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var measuringReference: MeasureReference?
    
    override func viewDidLoad() {
        nameTextField.delegate = self
        lengthTextField.delegate = self
        lengthTextField.addTarget(self, action: #selector(NewReferenceViewController.checkValidInput), forControlEvents: UIControlEvents.EditingChanged)
        checkValidInput()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        saveButton.enabled = false
    }
   
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidInput()
    }
    
    @objc private func checkValidInput() {
        let name = nameTextField.text ?? ""
        let length = lengthTextField.text ?? ""
        saveButton.enabled = !name.isEmpty && !length.isEmpty
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        measuringReference = MeasureReference(name: nameTextField.text!, length: Double(lengthTextField.text!)!, unit: "Inches")
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
}
