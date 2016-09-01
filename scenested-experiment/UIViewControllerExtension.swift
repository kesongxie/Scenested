//
//  UIViewControllerExtension.swift
//  scenested-experiment
//
//  Created by Xie kesong on 6/17/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit

extension UIViewController{
    func dismissKeyBoardWhenTapped(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    
    func presentTabBarViewController(){
        let globalStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarVC = globalStoryboard.instantiateViewControllerWithIdentifier(StoryboardIden.GlobalTabBarControllerIden) as? TabBarController{
                self.presentViewController(tabBarVC, animated: false, completion: nil)
        }
    }
    
        
    func getHeaderHeight() -> CGFloat{
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height ?? 0
        return statusBarHeight + navigationBarHeight
    }
    
    
    //get the visible content rect exculue the header and tabbar
    func getVisibleContentRectSize() -> CGSize{
        let height = view.bounds.size.height - (self.tabBarController?.tabBar.frame.size.height ?? 0) - getHeaderHeight()
        return CGSize(width: self.view.frame.size.width, height: height)
    }
    
    
    
    
}
