//
//  LineViewController.swift
//  LocatorCam
//
//  Created by Yongzheng Huang on 3/31/16.
//  Copyright © 2016 Yongzheng Huang. All rights reserved.
//

import UIKit

class LineViewController: UIViewController {


    @IBOutlet weak var lineView: LineView1! {
        didSet {
            lineView.addGestureRecognizer(UIPanGestureRecognizer(target: lineView, action: Selector("move:")))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
