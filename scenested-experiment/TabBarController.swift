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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.newComeAccrossProfileVCRequested(_:)), name: NotificationLocalizedString.ComeAcrossUserProfileViewRequestNotificationName, object: nil)
        self.delegate = self
        self.tabBar.translucent = StyleSchemeConstant.tabBarStyle.translucent
        self.tabBar.tintColor =  StyleSchemeConstant.tabBarStyle.tinkColor
    }

   
    func newComeAccrossProfileVCRequested(notification: NSNotification){
        guard let comeAccrossUser = notification.userInfo!["comeAccrossUser"] as? User else{
            return
        }
        
        guard let applicationStateRawValue = notification.userInfo!["ApplicationStateRawValue"] as? Int else{
            return
        }
        
        if let applicationState = UIApplicationState.init(rawValue: applicationStateRawValue){
            switch applicationState{
            case .Inactive:
                print("inactive")
                //the user swipe to open the notification, this should push the profile
                if let nvc = self.selectedViewController as? UINavigationController{
                    nvc.pushProfileWithUser(comeAccrossUser)
                    print("notification received, pushing profile...")
                }
            case .Active:
                //requires to show at the ranging tab
                print("--------------active--------------")
            case .Background:
                print("--------------background--------------")
                
                //if the app is transitioning from background to foreground, ex. the user swipe the notification to open the app
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

