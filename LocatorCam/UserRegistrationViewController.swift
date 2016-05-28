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
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBAction func registerButton(sender: AnyObject) {
        if let username = usernameTextField.text,
            let password = passwordTextField.text,
            let email = emailTextField.text {
            register_request(username, password: password, email: email)
        }
    }
    
    struct Constant {
        static let segueToApp = "register and login to app"
        static let registerURL = SharingManager.Constant.baseServerURL + "register/"
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
            
            //let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                
                // registration failed
                if let registrationError = json["error"] as? String {
                    print(registrationError)
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.performSegueWithIdentifier(Constant.segueToApp, sender: self)
                })
                
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        
        task.resume()
    }
    
}
