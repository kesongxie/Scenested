//
//  TabBarController.swift
//  Scenested
//
//  Created by Xie kesong on 3/31/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.translucent = StyleSchemeConstant.tabBarStyle.translucent
        self.tabBar.tintColor =  StyleSchemeConstant.tabBarStyle.tinkColor
        
        
        if let profileNVC = self.viewControllers?.first as? ProfileNavigationController{
            if let profileVC = profileNVC.viewControllers.first as? ProfileViewController{
                profileVC.profileUser = getLoggedInUser()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /* disable landscape presentation */
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
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
