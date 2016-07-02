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
    
    
    @IBAction func registerButton(sender: AnyObject) {
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
    
    private func showSimpleAlertMessage(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Helper functions
    
    func register_request(username: String, password: String, email: String) {
        let url:NSURL = NSURL(string: Constant.registerURL)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "username=\(username)&password=\(password)&email=\(email)"
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error: \(error)")
                return
            }
            
            do {

                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                
                if let message = json["message"] as? String {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showSimpleAlertMessage(message)
                    })
                }
                
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        
        task.resume()
    }
    
}
