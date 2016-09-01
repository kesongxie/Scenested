//
//  EntryViewController.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/9/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
               // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
       
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        User.isUserCredentialKeyChainPresented({
            (valid, userId) in
            
            if valid && userId != nil{
                (UIApplication.sharedApplication().delegate as? AppDelegate)?.loggedInUser = User(id: userId!, completionHandler: {
                    (loggedInSucceed, responseData ) in
                    if loggedInSucceed{
                        self.presentTabBarViewController()
                    }else{
                        print("can't login the user")
                    }
                })
            }else{
                let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
                if let welcomeVC = loginStoryboard.instantiateViewControllerWithIdentifier(StoryboardIden.WelcomeViewControllerIden) as? WelcomeViewController{
                     self.presentViewController(welcomeVC, animated: false, completion: nil)
                }
            }
        })
        

        
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
