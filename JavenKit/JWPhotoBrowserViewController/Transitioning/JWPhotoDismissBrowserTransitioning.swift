//
//  JWPhotoBrowserTransitioning.swift
//  JWCoreImageBrowser
//
//  Created by 朱建伟 on 2016/11/29.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

class JWPhotoDismissBrowserTransitioning: NSObject,UIViewControllerAnimatedTransitioning {
    
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval{
        return 0.3
    }
    
    var directionIsTop =  true
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning){
        
        let fromView:UIView =  transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView:UIView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        let containerView:UIView = transitionContext.containerView
        
        //设置frame  适配
        containerView.frame = UIScreen.main.bounds
        fromView.frame = UIScreen.main.bounds
        toView.frame =  UIScreen.main.bounds
        
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
      
        
        //设置动画
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            ()-> Void in
            fromView.backgroundColor = UIColor.clear
             
        }, completion: {
            (isFinished) -> Void in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    
    public func animationEnded(_ transitionCompleted: Bool){
        
    }
    
    
 


}
