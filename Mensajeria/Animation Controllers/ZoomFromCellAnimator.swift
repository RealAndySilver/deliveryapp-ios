//
//  ZoomFromCellAnimator.swift
//  Mensajeria
//
//  Created by Developer on 18/03/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class ZoomFromCellAnimator: NSObject {
    var openingFrame: CGRect?
}

extension ZoomFromCellAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()!
        
        let animationDuration = transitionDuration(transitionContext)
        
        let fromViewFrame = fromVC.view.frame
        UIGraphicsBeginImageContext(fromViewFrame.size)
        fromVC.view.drawViewHierarchyInRect(fromViewFrame, afterScreenUpdates: true)
        //let snaphshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshotView = toVC.view.resizableSnapshotViewFromRect(toVC.view.frame, afterScreenUpdates: true, withCapInsets: UIEdgeInsetsZero)
        snapshotView.frame = openingFrame!
        containerView.addSubview(snapshotView)
        
        toVC.view.alpha = 0.0
        containerView.addSubview(toVC.view)
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 20.0, options: [],
            animations: { () -> Void in
                snapshotView.frame = fromVC.view.frame
            }, completion: { (finished) -> Void in
                snapshotView.removeFromSuperview()
                toVC.view.alpha = 1.0
                transitionContext.completeTransition(finished)
        })
    }
}
