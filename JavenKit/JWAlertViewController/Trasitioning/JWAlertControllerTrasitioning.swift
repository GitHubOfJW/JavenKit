//
//  JWAlertControllerTrasitioning.swift
//  CarServer
//
//  Created by 朱建伟 on 2016/11/6.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

class JWAlertControllerTrasitioning: NSObject,UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView:UIView =  transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView:UIView =  transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        transitionContext.containerView.addSubview(fromView)
        transitionContext.containerView.addSubview(toView)
        
        transitionContext.completeTransition(true)
    }
}
