//
//  JWPhotoTapDismissTransioning.swift
//  JWCoreImageBrowser
//
//  Created by 朱建伟 on 2016/11/29.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

class JWPhotoTapDismissTransioning: NSObject,UIViewControllerAnimatedTransitioning{
    
    //图片
    weak var sourceView:UIView?
    
    //目标rect
    var destinationFrame:CGRect?
    
    //图片
    var desinationImage:UIImage?
    
    
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
        
        
        var flag = true
        let tempView:UIImageView = UIImageView()
        
        if let destinationFrame = self.destinationFrame{
            if let scView =  sourceView{
                
                    if let image = self.desinationImage{
                    let cover:UIView = UIView()
                    cover.frame = fromView.bounds
                    cover.backgroundColor = UIColor.black
                    containerView.addSubview(cover)
                    
                    
                    let sourceRect = scView.convert(scView.bounds, to: fromView)
                    tempView.image =  image
                    tempView.frame =  sourceRect
                    containerView.addSubview(tempView)
                    tempView.contentMode = UIViewContentMode.scaleAspectFill
                    tempView.clipsToBounds = true
                    
                    flag = false
                    
                    fromView.alpha = 0
                    
                    UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                        tempView.frame = destinationFrame
                        cover.alpha = 0
                    }, completion: { (isFinshed) in
                        tempView.removeFromSuperview()
                        cover.removeFromSuperview()
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                        fromView.alpha = 1
                    })
                }
            }
        }
        
        if flag {
            //设置动画
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                ()-> Void in
                fromView.alpha = 0
            }, completion: {
                (isFinished) -> Void in
                fromView.alpha = 1
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
    
    
    public func animationEnded(_ transitionCompleted: Bool){
        
    }
}
