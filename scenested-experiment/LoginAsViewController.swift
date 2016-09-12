//
//  LoginAsViewController.swift
//  scenested-experiment
//
//  Created by Xie kesong on 9/1/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

class LoginAsViewController: UIViewController {
    @IBOutlet weak var welcomeAvatorImageview: UIImageView!{
        didSet{
            welcomeAvatorImageview.layer.cornerRadius = 45.0
            welcomeAvatorImageview.clipsToBounds = true
        }
    }

    @IBOutlet weak var loginAsBtn: UIButton!{
        didSet{
            loginAsBtn.layer.borderColor = UIColor(red: 240 / 255.0, green: 240 / 255.0, blue: 240 / 255.0, alpha: 1).CGColor
            loginAsBtn.layer.borderWidth = 1
            loginAsBtn.layer.cornerRadius = 4
            loginAsBtn.clipsToBounds = true
        }
        
    }
    
    @IBAction func loginAsBtnTapped(sender: UIButton) {
         User.isUserCredentialKeyChainPresented({
         (valid, userId) in
             if valid && userId != nil{
                 (UIApplication.sharedApplication().delegate as? AppDelegate)?.loggedInUser = User(id: userId!, completionHandler: {
                 (loggedInSucceed, responseData ) in
                    
                    print(loggedInSucceed)
                 if loggedInSucceed{
                    self.presentTabBarViewController()
                 }else{
                    print("can't login the user")
                    }
                })
            }
        })
    }
    
    var welcomeAvatorImage: UIImage?{
        didSet{
            welcomeAvatorImageview?.image = welcomeAvatorImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileManager = NSFileManager()
        if fileManager.fileExistsAtPath(AppWelcomeAvatorFileDirectoryPath){
            let welcomeAvatorImage = UIImage(contentsOfFile: AppWelcomeAvatorFileDirectoryPath)
            //present logged in as scene
            self.welcomeAvatorImage = welcomeAvatorImage
        }
        if welcomeAvatorImage != nil{
            welcomeAvatorImageview?.image = welcomeAvatorImage
        }
        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
