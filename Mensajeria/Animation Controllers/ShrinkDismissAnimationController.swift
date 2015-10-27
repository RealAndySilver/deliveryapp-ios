//
//  ShrinkDismissAnimationController.swift
//  Mensajeria
//
//  Created by Developer on 26/02/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class ShrinkDismissAnimationController: NSObject {
   
}

//MARK: UIViewControllerAnimatedTransition

extension ShrinkDismissAnimationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let finalFrame = transitionContext.finalFrameForViewController(toViewController)
        
        let containerView = transitionContext.containerView()!
        toViewController.view.frame = finalFrame
        toViewController.view.alpha = 0.5
        
        containerView.addSubview(toViewController.view)
        containerView.sendSubviewToBack(toViewController.view)
        
        //Determine the intermediate and final frame for the "from" view
        let screenBounds = UIScreen.mainScreen().bounds
        let shrunkenFrame = CGRectInset(fromViewController.view.frame, fromViewController.view.frame.size.width/4.0, fromViewController.view.frame.size.height/4.0)
        let fromFinalFrame = CGRectOffset(shrunkenFrame, 0.0, screenBounds.size.height)
        
        let duration = transitionDuration(transitionContext)
        
        //Create a snapshot of the "from" view 
        let intermediateView = fromViewController.view.snapshotViewAfterScreenUpdates(false)
        intermediateView.frame = fromViewController.view.frame
        containerView.addSubview(intermediateView)
        
        //Remove the real "from" view 
        fromViewController.view.removeFromSuperview()
        
        //Animate with keyframes oís
        UIView.animateKeyframesWithDuration(duration,
            delay: 0.0,
            options: UIViewKeyframeAnimationOptions.CalculationModeCubic,
            animations: { () -> Void in
                //First keyframe
                UIView.addKeyframeWithRelativeStartTime(0.0,
                    relativeDuration: 0.5,
                    animations: { () -> Void in
                        intermediateView.frame = shrunkenFrame
                        toViewController.view.alpha = 0.5
                })
                
                //Second keyframe 
                UIView.addKeyframeWithRelativeStartTime(0.5,
                    relativeDuration: 0.5,
                    animations: { () -> Void in
                        intermediateView.frame = fromFinalFrame
                        toViewController.view.alpha = 1.0
                })
                
        }) { (succeded) -> Void in
            intermediateView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}
