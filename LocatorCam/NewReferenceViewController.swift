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
        lengthTextField.addTarget(self, action: #selector(NewReferenceViewController.checkValidInput), for: UIControlEvents.editingChanged)
        checkValidInput()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
   
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidInput()
    }
    
    @objc fileprivate func checkValidInput() {
        let name = nameTextField.text ?? ""
        let length = lengthTextField.text ?? ""
        saveButton.isEnabled = !name.isEmpty && !length.isEmpty
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        measuringReference = MeasureReference(name: nameTextField.text!, length: Double(lengthTextField.text!)!, unit: "Inches")
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
}
