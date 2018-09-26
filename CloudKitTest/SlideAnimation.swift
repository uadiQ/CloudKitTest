//
//  SlideAnimation.swift
//  CloudKitTest
//
//  Created by Vadim Shoshin on 9/25/18.
//  Copyright © 2018 SoftwareStation. All rights reserved.
//

import UIKit

class SlideAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    let duration = 0.5
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
        
        guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from),
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
                return
        }
        let container = transitionContext.containerView
        let screenOffUp = CGAffineTransform(translationX: 0, y: -container.frame.height) // положение над экраном, чтоб вью "выпало сверху"
        let screenOffDown = CGAffineTransform(translationX: 0, y: container.frame.height) // положение, куда оно должно "свалиться"
        

        if isPresenting {
            container.addSubview(fromView)
            container.addSubview(toView)
//            toView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 350)
            toView.transform = screenOffUp
        }

        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8,  options:.curveEaseInOut, animations: {
            if self.isPresenting {
            toView.transform = CGAffineTransform.identity
                toView.alpha = 1 } else {
                fromView.transform = screenOffDown
            }
        }) { success in
            transitionContext.completeTransition(success)
        }
    }
}
