//
//  UINavigationViewControllerExtension.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/19/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

extension UINavigationController{
    func pushProfileWithUser(user: User?, requestedUsername: String? = nil){
        if let user = user{
            if let profileVC = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIden.ProfileViewControllerIden) as? ProfileViewController{
                profileVC.profileUser = user
                profileVC.title = user.username
                profileVC.navigationItem.leftBarButtonItem = getBackBtnAsUIBarBtnItem()
                profileVC.navigationItem.leftBarButtonItem?.target = self
                profileVC.navigationItem.leftBarButtonItem?.action = #selector(self.popProfile)
                self.pushViewController(profileVC, animated: true)
            }
        }else{
            //push a user profile page with default user not existed infomation
            if let userNotExistVC = storyboard?.instantiateViewControllerWithIdentifier(StoryboardIden.UserNotExistViewControllerIden) as? UserNotExistViewController{
                //userNotExistVC.title =
                userNotExistVC.navigationItem.leftBarButtonItem = getBackBtnAsUIBarBtnItem()
                userNotExistVC.navigationItem.leftBarButtonItem?.target = self
                userNotExistVC.navigationItem.leftBarButtonItem?.action = #selector(self.popProfile)
                userNotExistVC.title = requestedUsername?.uppercaseString
                self.pushViewController(userNotExistVC, animated: true)
            }
        }
    }
    
    func popProfile(){
//        if let commentVC = self.viewControllers[2] as? PostCommentViewController{
//            commentVC.tabBarController?.tabBar.hidden = true
//        }
        
        self.popViewControllerAnimated(true)
    }
}


