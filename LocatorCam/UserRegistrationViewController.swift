//
//  UserRegistrationViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 5/28/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class UserRegistrationViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordAgainTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    struct Constant {
        static let passwordMismatchAlertMessage = "The passwords you entered don't match each other, please check your password." 
        static let segueToApp = "register and login to app"
        static let registerURL = SharingManager.Constant.baseServerURL + "register/"
    }
    
    
    @IBAction func registerButton(_ sender: AnyObject) {
        guard let username = usernameTextField.text, let password = passwordTextField.text, let passwordAgain = passwordAgainTextField.text, let email = emailTextField.text else {
            return
        }
        
        if password != passwordAgain {
            passwordTextField.text = ""
            passwordAgainTextField.text = ""
            showSimpleAlertMessage(Constant.passwordMismatchAlertMessage)
            return
        }
        
        register_request(username, password: password, email: email)
    }
    
    fileprivate func showSimpleAlertMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Helper functions
    
    func register_request(_ username: String, password: String, email: String) {
        let url:URL = URL(string: Constant.registerURL)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let paramString = "username=\(username)&password=\(password)&email=\(email)"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error: \(error)")
                return
            }
            
            do {

                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                
                if let message = json["message"] as? String {
                    DispatchQueue.main.async(execute: {
                        self.showSimpleAlertMessage(message)
                    })
                }
                
            } catch {
                print("error serializing JSON: \(error)")
            }
        }) 
        
        task.resume()
    }
    
}
