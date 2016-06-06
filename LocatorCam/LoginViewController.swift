//
//  LoginViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 5/28/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    @IBAction func signinButton(sender: UIButton) {
        if let username = userIDTextField.text, let password = passcodeTextField.text {
            login_request(username, password: password)
        }
        
    }
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var passcodeTextField: UITextField!
    
    struct Constant {
        static let segueToApp = "login to app"
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constant.segueToApp {
            print("to app")
        }
    }
    
    // MARK: - Helper functions
    
    func login_request(username: String, password: String) {
        let url:NSURL = NSURL(string: SharingManager.Constant.loginURL)!
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        
        let paramString = "username=\(username)&password=\(password)"
        request.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) {
            (let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error: \(error)")
                return
            }
            
            // let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)

            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                
                // login failed
                if let loginError = json["error"] as? String {
                    print(loginError)
                    return
                }
                
                // login successfully, save user information
                if let username = json["username"] as? String, let email = json["email"] as? String, let friends = json["friends"] as? [String] {
                    UserInfo.username = username
                    UserInfo.email = email
                    UserInfo.friends = friends
                    print("username: \(username), email: \(email), friends: \(friends)")
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
