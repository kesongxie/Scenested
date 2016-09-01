//
//  HorizontalSwipeAnimator.swift
//  scenested-experiment
//
//  Created by Xie kesong on 8/27/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import Foundation
import UIKit

class HorizontalSlideInPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning{
    let duration:Double = 0.25
    var presenting: Bool = true
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
//        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
//        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        

        
        
        let containerFrame = containerView.frame
        var toViewFinalFrame = containerFrame
        var fromViewFinalFrame = containerFrame
        if self.presenting{
            let toViewStartFrame = CGRect(x: containerView.bounds.size.width, y: 0, width: containerView.bounds.size.width, height: containerView.bounds.size.height)
            toViewFinalFrame = UIScreen.mainScreen().bounds
            toView.frame = toViewStartFrame
            
//            fromView.frame = UIScreen.mainScreen().bounds
//            fromViewFinalFrame = CGRect(x: -containerView.bounds.size.width, y: 0, width: containerView.bounds.size.width, height: containerView.bounds.size.height)
//            
            
            
            containerView.addSubview(fromView)
            containerView.addSubview(toView)
        }else{
            let fromViewStartFrame = UIScreen.mainScreen().bounds
            fromViewFinalFrame = CGRect(x: containerView.bounds.size.width, y: 0, width: containerView.bounds.size.width, height: containerView.bounds.size.height)
            fromView.frame = fromViewStartFrame
            
            
//            toView.frame = CGRect(x: -containerView.bounds.size.width, y: 0, width: containerView.bounds.size.width, height: containerView.bounds.size.height)
//            toViewFinalFrame = UIScreen.mainScreen().bounds
            
            
            containerView.addSubview(toView)
            containerView.addSubview(fromView)
        }
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
                if self.presenting{
                    //slide in
                    toView.frame = toViewFinalFrame
                   // fromView.frame = fromViewFinalFrame
                }else{
                    //slide out
                   // toView.frame = toViewFinalFrame
                    fromView.frame = fromViewFinalFrame
                }
            }, completion: {
                finished in
                if finished{
                    transitionContext.completeTransition(true)
            }
        })
    }
}

