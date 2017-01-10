//
//  JWPhotoPresentBrowserTransitioning.swift
//  JWCoreImageBrowser
//
//  Created by 朱建伟 on 2016/11/29.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

class JWPhotoPresentBrowserTransitioning: NSObject,UIViewControllerAnimatedTransitioning {
    
    weak var sourceView:UIView?
    
    weak var sourceImage:UIImage?
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval{
        return 0.3
    }
    
    
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
        
        
        
//        let r = CGFloat(arc4random_uniform(255))/255.0
//        let g = CGFloat(arc4random_uniform(255))/255.0
//        let b = CGFloat(arc4random_uniform(255))/255.0
        let color:UIColor = UIColor.black// UIColor(red: r, green: g, blue: b, alpha: 1)
        
        let coverView:UIView = UIView()
        coverView.backgroundColor = color
        coverView.alpha = 0
        coverView.frame  = toView.bounds
        containerView.addSubview(coverView)
      
        
        
        let tempView:UIImageView = UIImageView()
        
        let tempViewW:CGFloat = toView.bounds.width
        var tempViewH:CGFloat = toView.bounds.width
        let tempViewX:CGFloat = (toView.bounds.width -  tempViewW)/2
        var tempViewY:CGFloat = (toView.bounds.height - tempViewH)/2
        
        
        var flag = true
        
        if let sView = sourceView{
            tempView.frame =  sView.convert(sView.bounds, to: toView)
            containerView.addSubview(tempView)
            
            if let image =  sourceImage{
                tempView.clipsToBounds = true
                tempView.contentMode = UIViewContentMode.scaleAspectFill
                tempView.image = image
                tempViewH = tempViewW / image.size.width * image.size.height
                tempViewY = (toView.bounds.height - tempViewH)/2
                
                flag = false
                //设置动画
                UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                    ()-> Void in
                    coverView.alpha = 1
                    tempView.frame = CGRect(x: tempViewX, y: tempViewY, width: tempViewW, height: tempViewH)
                    
                }, completion: {
                    (isFinished) -> Void in
                    toView.backgroundColor  = color
                    coverView.removeFromSuperview()
                    tempView.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
            }
        }
        
        //什么都没有push动画
        if flag{
            coverView.transform =  CGAffineTransform(translationX: toView.bounds.width, y: 0)
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                coverView.alpha = 1
                coverView.transform = CGAffineTransform.identity
            }, completion: { (finished) in
                toView.backgroundColor  = color
                coverView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
    
    public func animationEnded(_ transitionCompleted: Bool){
        
    }

}
