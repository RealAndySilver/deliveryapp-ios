//
//  CloseSessionAnimationController.swift
//  Mensajeria
//
//  Created by Developer on 4/03/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class CloseSessionAnimationController: NSObject {
   
}

//MARK: UIViewControllerAnimatedTransition

extension CloseSessionAnimationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        //let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        /*let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let finalFrame = transitionContext.finalFrameForViewController(toVC)
        
        let containerView = transitionContext.containerView()*/
        
    }
}
