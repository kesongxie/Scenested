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
        self.delegate = self
        self.tabBar.translucent = StyleSchemeConstant.tabBarStyle.translucent
        self.tabBar.tintColor =  StyleSchemeConstant.tabBarStyle.tinkColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /* disable landscape presentation */
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
   
    
    

    
}

extension TabBarController: UITabBarControllerDelegate{
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if let profileNVC = viewController as? ProfileNavigationController{
            if let profileVC = profileNVC.viewControllers.first as? ProfileViewController{
                profileVC.profileUser = getLoggedInUser()
            }
        }
    }
}

