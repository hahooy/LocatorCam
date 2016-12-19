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
    @IBAction func signinButton(_ sender: UIButton) {
        if let username = userIDTextField.text, let password = passcodeTextField.text {
            login_request(username.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), password: password.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        }
        
    }
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var passcodeTextField: UITextField!
    
    struct Constant {
        static let segueToApp = "login to app"
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.segueToApp {
            print("to app")
        }
    }
    
    // MARK: - Helper functions
    
    func login_request(_ username: String, password: String) {
        let url:URL = URL(string: SharingManager.Constant.loginURL)!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let paramString = "username=\(username)&password=\(password)"
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error: \(error)")
                return
            }
            
            // let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)

            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                
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
                DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: Constant.segueToApp, sender: self)
                })
            } catch {
                print("error serializing JSON: \(error)")
            }
            
        }) 
        
        task.resume()
    }
    
}
