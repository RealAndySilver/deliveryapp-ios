//
//  ZoomTransitionDelegate.swift
//  Mensajeria
//
//  Created by Developer on 18/03/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

import UIKit

class ZoomTransitionDelegate: NSObject {
    var openingFrame: CGRect?
}

extension ZoomTransitionDelegate: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let zoomAnimator = ZoomFromCellAnimator()
        zoomAnimator.openingFrame = openingFrame
        return zoomAnimator
    }
}
