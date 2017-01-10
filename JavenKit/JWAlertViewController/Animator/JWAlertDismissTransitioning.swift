//
//  JWAlertDismissTransitioning.swift
//  JWAlertViewController_Demo
//
//  Created by 朱建伟 on 2016/12/17.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

class JWAlertDismissTransitioning: NSObject,UIViewControllerAnimatedTransitioning,CAAnimationDelegate{
    
    
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
            
            if self.preferredStyle == .alert{
                //动画
                let animation:CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
                animation.values = [1.0,1.2,0.8]
                animation.isRemovedOnCompletion = false
                animation.duration = self.transitionDuration(using: transitionContext)
                animation.fillMode = kCAFillModeForwards
                animation.delegate = self
                animation.setValue(transitionContext, forKey: "transitionContext")
                fromV.layer.add(animation, forKey: "scaleAnimator")
            }else if self.preferredStyle == .actionSheet{
                //动画
                let animation:CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
                animation.values = [0,-20,-20,fromV.bounds.height]
//                animation.fromValue = 0
//                animation.toValue = fromV.bounds.height
                animation.isRemovedOnCompletion = false
                animation.duration = self.transitionDuration(using: transitionContext)
                animation.fillMode = kCAFillModeForwards
                animation.delegate = self
                animation.setValue(transitionContext, forKey: "transitionContext")
                fromV.layer.add(animation, forKey: "actionsheetAnimator")
            }else if self.preferredStyle == .popover{
                //动画
                let animation:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
                animation.fromValue = 1
                animation.toValue = 0
                animation.isRemovedOnCompletion = false
                animation.duration = self.transitionDuration(using: transitionContext)
                animation.fillMode = kCAFillModeForwards
                animation.delegate = self
                animation.setValue(transitionContext, forKey: "transitionContext")
                fromV.layer.add(animation, forKey: "opacityAnimator")
            }
        }else{
            transitionContext.completeTransition(false)
        }
        
        if let toV =  toView{
            toV.frame = UIScreen.main.bounds
            containerView.addSubview(toV)
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
