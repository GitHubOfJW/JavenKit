//
//  JWWebViewProgress.swift
//  CarServer
//
//  Created by 朱建伟 on 2016/10/12.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

class JWWebViewProgressView: UIView,CAAnimationDelegate{

    let maskLayer:CALayer = CALayer()
    
    lazy var progressLayer:CAGradientLayer = {
       let progressLayer:CAGradientLayer = CAGradientLayer()
       progressLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
       progressLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
       
       var colors = [CGColor]()
       var locations = [NSNumber]()
       
        for var i in 0...360
        {
            if i%5 == 0 {
                let hue = CGFloat(i)/360.0
                var color:CGColor = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0).cgColor
                
                colors.append(color)
            }
        }
        
       progressLayer.colors =  colors
       return progressLayer
    }()
    
    //进度条
    var progress:CGFloat? = 0
    {
        
        willSet{
            if let value  =  newValue {
                let width =  bounds.width * value
                
                maskLayer.frame = CGRect(x: 0, y: 0, width: width, height: bounds.height)
                progressLayer.mask = self.maskLayer
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
         //maskLayer 设置
         maskLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
         maskLayer.backgroundColor = UIColor.white.cgColor
         progressLayer.mask = maskLayer
         progressLayer.backgroundColor = UIColor.blue.cgColor
         layer.addSublayer(progressLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //更新进度颜色
    func startAnimation() {
       if let colors =  progressLayer.colors
       {
          var newColors:[CGColor] = colors as! [CGColor]
          let lastColor =  newColors.last
          newColors.removeLast()
          newColors.insert(lastColor!, at: 0)
        
            progressLayer.colors = newColors
        
            let animation:CABasicAnimation = CABasicAnimation(keyPath: "colors")
            animation.toValue = newColors
            animation.duration = 1.0
            animation.isRemovedOnCompletion = true
            animation.fillMode = kCAFillModeForwards
            animation.delegate = self
            progressLayer.add(animation, forKey: "animateGradient")
       }
    }
    
     
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        //加载中 and 未隐藏
        if progress! < CGFloat(1.0) && !isHidden
        {
            startAnimation()
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        progressLayer.frame = bounds
        
    }
}


