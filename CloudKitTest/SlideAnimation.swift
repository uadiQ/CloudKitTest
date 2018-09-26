//
//  SlideAnimation.swift
//  CloudKitTest
//
//  Created by Vadim Shoshin on 9/25/18.
//  Copyright © 2018 SoftwareStation. All rights reserved.
//

import UIKit

class SlideAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    let duration = 0.3
    var isPresenting = false
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting.toggle()
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting.toggle()
        return self
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView
        
        let targetSize = CGSize(width: 200, height: 200)
        let targetOrigin = CGPoint(x: (container.bounds.width - targetSize.width) / 2, y: (container.bounds.height - targetSize.height) / 2)
        let targetFrame = CGRect(origin: targetOrigin, size: targetSize)
        
        var originalFrame = targetFrame
        originalFrame.origin.y = container.bounds.maxY
        
        if isPresenting {
            guard let toView = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
            }
            
            container.addSubview(toView)
            toView.frame = originalFrame
            
            UIView.animate(withDuration: duration, animations: {
                toView.frame = targetFrame
            }) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        } else {
            guard let fromView = transitionContext.view(forKey: .from) else {
                transitionContext.completeTransition(false)
                return
            }
            
            UIView.animate(withDuration: duration, animations: {
                fromView.frame = originalFrame
            }) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
