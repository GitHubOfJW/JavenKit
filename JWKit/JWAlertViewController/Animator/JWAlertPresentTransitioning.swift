//
//  JWAlertTransitioning.swift
//  JWAlertViewController_Demo
//
//  Created by 朱建伟 on 2016/12/17.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

class JWAlertPresentTransitioning: NSObject,UIViewControllerAnimatedTransitioning ,CAAnimationDelegate{
    
    
    var preferredStyle:JWAlertControllerStyle = JWAlertControllerStyle.alert
    
    //返回动画之行的时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if  self.preferredStyle == .alert {
            return 0.25
        }else if self.preferredStyle == .actionSheet{
            return 0.3
        }
        return 0.4
    }
    
    //执行动画
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        //动画容器
        let containerView = transitionContext.containerView
        
        //fromView
        let fromView  = transitionContext.view(forKey: UITransitionContextViewKey.from)
        
        //toView 
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        
        //添加到容器上
    
        if let fromV = fromView {
            fromV.frame = UIScreen.main.bounds
            containerView.addSubview(fromV)
        }
        
        if let toV =  toView{
            toV.frame = UIScreen.main.bounds
            containerView.addSubview(toV)
            
            if self.preferredStyle == .alert{
                //动画
                let animation:CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
                animation.values = [0.8,1.2,1.0]
                animation.isRemovedOnCompletion = false
                animation.duration = self.transitionDuration(using: transitionContext)
                animation.fillMode = kCAFillModeForwards
                animation.delegate = self
                animation.setValue(transitionContext, forKey: "transitionContext")
                toV.layer.add(animation, forKey: "alertAnimator")
            }else if self.preferredStyle == .actionSheet{
                //动画
                let animation:CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
                animation.values = [toV.bounds.height,-20,20,0]
//                animation.fromValue = toV.bounds.height
//                animation.toValue = 0
                animation.isRemovedOnCompletion = false
                animation.duration = self.transitionDuration(using: transitionContext)
                animation.fillMode = kCAFillModeForwards
                animation.delegate = self
                animation.setValue(transitionContext, forKey: "transitionContext")
                toV.layer.add(animation, forKey: "actionsheetAnimator")
            }else if self.preferredStyle == .popover{
                //动画
                let animation:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
                animation.fromValue = 0
                animation.toValue = 1
                animation.isRemovedOnCompletion = false
                animation.duration = self.transitionDuration(using: transitionContext)
                animation.fillMode = kCAFillModeForwards
                animation.delegate = self
                animation.setValue(transitionContext, forKey: "transitionContext")
                toV.layer.add(animation, forKey: "opacityAnimator")
            }
        }else{
            transitionContext.completeTransition(false)
        }
        
        
        
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let value = anim.value(forKeyPath: "transitionContext"){
            if let transitionContext:UIViewControllerContextTransitioning = value as? UIViewControllerContextTransitioning{
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        
    }
    
}
