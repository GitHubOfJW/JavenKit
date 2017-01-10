//
//  JWProgressHUD.swift
//  CarServer
//
//  Created by 朱建伟 on 2016/11/13.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

public enum JWProgressHUDType:Int{
    case loading//加载中
    case message//提示
    case success//成功
    case error//失败
    case dismiss//隐藏
}

public
class JWProgressHUD: UIView,CAAnimationDelegate {
    
    private let duration:TimeInterval = 0.25
    
    private let selfWidth :CGFloat = UIScreen.main.bounds.width
    private let selfHeight:CGFloat = UIScreen.main.bounds.height
    
    
    private var currentProgressType:JWProgressHUDType = .dismiss
    private var nextProgressExcuteType:JWProgressHUDType?
    
    private var isDismissDelay:Bool = false
    
    //背景层View
    private let bgCoverView:UIButton = UIButton()
    
    //弹出模块
    private let containerView:UIView = UIView()
    
    //提示文字
    private let promptLabel:UILabel = UILabel()
    
    //加载中的View
    private let loadingView:JWProgressHUDLoadingView = JWProgressHUDLoadingView()
    
   
   
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        //背景
        let rgb:CGFloat = 60.0/255.0
        bgCoverView.backgroundColor = UIColor(red: rgb, green: rgb, blue: rgb, alpha: 0.5)
        
        bgCoverView.addTarget(self, action: #selector(JWProgressHUD.bgBtnClick(bgBtn:)), for: UIControlEvents.touchUpInside)
        addSubview(bgCoverView)
        
        //弹出模块
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 5.0
        containerView.layer.masksToBounds = true
        //        containerView.layer.borderColor = UIColor.orange.cgColor
        //        containerView.layer.borderWidth = 0.5
        addSubview(containerView)
        
        //提示文字
        promptLabel.font = UIFont.systemFont(ofSize: 16)
        promptLabel.numberOfLines  = 0
        promptLabel.textColor = UIColor.darkGray
        promptLabel.textAlignment = NSTextAlignment.center
        containerView.addSubview(promptLabel)
        
        //加载View
        containerView.addSubview(loadingView)
        
//        self.isHidden = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //dismiss
    internal func bgBtnClick(bgBtn:UIButton) {
        if self.currentProgressType == .dismiss{
            self.showMessage(message: "", type: JWProgressHUDType.dismiss,complectionClosure: { })
        }else {
            if bgBtn.tag == 1 {
                bgBtn.tag = 0
                self.showMessage(message: "", type: JWProgressHUDType.dismiss,complectionClosure: {})
            }else{
                bgBtn.tag = 1
            }
            
        }
    }
    
    
    private var complectionClosure:(()->Void)?
    
    //展示弹出层
   public func  showMessage(message:String?,type:JWProgressHUDType){
        
        //展示弹出层
        self.showMessage(message:message,type:type,complectionClosure: {})
    }
        
    
    //展示弹出层
   public func  showMessage(message:String?,type:JWProgressHUDType,complectionClosure:@escaping (()->Void)){
        
        if self.currentProgressType == type{
            return
        }
        
        if let closure = self.complectionClosure{
            closure()
        }
        
        self.complectionClosure = complectionClosure
        
        let lastWinidow = UIApplication.shared.keyWindow
        lastWinidow?.addSubview(self)
        
        //几个状态
        var tempLoadingViewHidden:Bool = true
        
        var tempPromptFrame:CGRect =  CGRect()
        
        var tempPromptHidden:Bool = false
        
        var tempContainerViewFrame:CGRect =  CGRect()
        //结状状态
        
        
        let loadingViewW:CGFloat = 80
        let loadingViewH:CGFloat = 80
        
        
        let edge:UIEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        
        //loadingView
        loadingView.frame = CGRect(x:edge.left, y: edge.top, width:loadingViewW, height: loadingViewH)
        
        
        //提示文字的最大高度
        var promptLabelMaxW:CGFloat =  0
        var promptLabelY:CGFloat = 0
        
        
        if type == .loading {
            tempLoadingViewHidden = false
            promptLabelMaxW = loadingViewW
            promptLabelY = loadingView.frame.maxY + 10
        }else if(type == .message){
            promptLabelMaxW =  selfWidth * 0.8 - edge.left - edge.right
            promptLabelY = edge.top
        }else{
            tempLoadingViewHidden = false
            promptLabelMaxW = loadingViewW  + edge.left + edge.right
            promptLabelY = loadingView.frame.maxY
        }
        
        
        tempPromptHidden =  true
        
        //有值则布局
        if let msg = message{
            //不为“”则展示
            if msg.compare("") != ComparisonResult.orderedSame{
                //高度
                let promptSize:CGSize =  NSString(string: msg).boundingRect(with: CGSize(width:promptLabelMaxW,height:selfHeight), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:promptLabel.font], context: nil).size
                
                var promptLabelH:CGFloat =  promptSize.height + 2
                
                //当行高度
                if promptLabelH < 20 {
                    promptLabelH = 20
                }
                
                var promptLabelW:CGFloat  = promptSize.width
                
                if promptLabelW < loadingViewW
                {
                    promptLabelW = loadingViewW
                    
                }
                
                //提示文字
                tempPromptFrame = CGRect(x:edge.left, y: promptLabelY, width: promptLabelW, height: promptLabelH)
                
                tempPromptHidden = false
            }
        }
        
        
        //计算container宽度
        let containerW:CGFloat =   tempPromptHidden == false ?  (tempPromptFrame.width + edge.left + edge.right):(loadingView.bounds.width + edge.left + edge.right)
        //计算container高度
        let containerH:CGFloat = ( tempPromptHidden ? loadingView.frame.maxY : tempPromptFrame.maxY )  + edge.bottom
        
        tempContainerViewFrame =  CGRect(x: (selfWidth - containerW)*0.5, y: ((selfHeight) - containerH)*0.5, width: containerW, height: containerH)
        
        
        
        let animation:CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.delegate = self
        animation.duration = self.duration
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        animation.autoreverses =  false
        
        let opacityAnim:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fillMode = kCAFillModeForwards
        opacityAnim.isRemovedOnCompletion = false
        opacityAnim.autoreverses =  false
        
        
        //清空
        self.nextProgressExcuteType = nil
        self.isDismissDelay = false
        
        
        //如果是dismiss
        if type == .dismiss && self.currentProgressType != .dismiss{
            
            if self.currentProgressType == .loading{
                //缓解dimss的问题
                self.isDismissDelay = true
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {//loading 延时消失
                    
                    if self.isDismissDelay{
                        self.containerView.layer.removeAllAnimations()
                        //执行弹出
                        animation.values = [1.0,1.2,1.0,0.5]
                        self.containerView.layer.add(animation, forKey: String(format:"%zd",type.rawValue))
                        
                        //隐藏
                        opacityAnim.toValue  = 0
                        self.bgCoverView.layer.add(opacityAnim, forKey: "opacity")
                        
                        self.currentProgressType = .dismiss
                    }
                })
                return;
            }
            
            self.containerView.layer.removeAllAnimations()
            
            //执行弹出
            animation.values = [1.0,1.2,1.0,0.5]
            self.containerView.layer.add(animation, forKey: String(format:"%zd",type.rawValue))
            
            //隐藏
            opacityAnim.toValue  = 0
            self.bgCoverView.layer.add(opacityAnim, forKey: "opacity")
            
            
            self.currentProgressType = .dismiss
            return
            
        }
         
        //根据当前的类型选择动画
        switch self.currentProgressType {
        case .loading:
            //如果将要弹出状态不是加载状态
            if type != .loading{
                //如果是dismiss则隐藏
                if type == .dismiss{
                    //缓解dimss的问题
                    self.isDismissDelay = true
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3, execute: {//loading延时消失
                        if self.isDismissDelay{
                            self.showMessage(message: "消失", type: JWProgressHUDType.dismiss)
                        }
                    })
                    return
                }else{
                    
                    //延时消失
                    self.isDismissDelay = true
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()  + 0.3, execute: {//loading延时消失
                        //如果当前动画还是dismiss 则执行
                        if self.isDismissDelay {
                            //通知 loadingView 停止loading动画 并切换状态
                            self.loadingView.loadingType =  type
                            
                            self.containerView.layer.removeAllAnimations()
                            self.promptLabel.text =  !tempPromptHidden ? message ?? "" : ""
                            
                            self.isHidden = false
                            UIView.animate(withDuration: self.duration, animations: {
                                self.loadingView.isHidden = tempLoadingViewHidden
                                self.promptLabel.frame =  tempPromptFrame
                                self.promptLabel.isHidden = tempPromptHidden
                                self.containerView.frame =  tempContainerViewFrame
                                }, completion: { (finished) in
                                    
                                    //如果直接结束的时候出现新的动画 则不能开启dimiss
                                    if let nextExcuteType = self.nextProgressExcuteType
                                    {
                                        self.showMessage(message: message, type: nextExcuteType)
                                        return
                                    }else{
                                        var delay:TimeInterval = 1.2;
                                        if let msg = message{
                                            delay =  TimeInterval((msg.characters.count)) * 0.04
                                        }
                                        //延时消失
                                        self.isDismissDelay = true
                                        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + self.duration + delay, execute: {//message延时消失
                                            //如果当前动画还是dismiss 则执行
                                            if self.isDismissDelay {
                                                self.showMessage(message: "消失", type: JWProgressHUDType.dismiss)
                                            }
                                        })
                                    }
                            })
                        }
                    })
                }
                break
            }else{
                self.isDismissDelay = false
                fallthrough
            }
        case .success:
            fallthrough
        case .error:
            fallthrough
        case .message:
            //如果将要弹出状态不是加载状态
            if type == .loading || type == .success || type == .error{
                
                promptLabel.text =  !tempPromptHidden ? message ?? "" : ""
                self.loadingView.loadingType =  type
                
               
                //开启延时隐藏
                if type != .loading{
                    
                    //延时消失
                    self.isDismissDelay = true
                    var delay:TimeInterval = 1.2;
                    if let msg = message{
                        delay =  TimeInterval((msg.characters.count)) * 0.04
                    }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.duration + delay, execute: {//message延时消失
                        
                        //如果当前动画还是dismiss 则执行
                        if self.isDismissDelay {
                            
                            self.isHidden = false
                            self.containerView.layer.removeAllAnimations()
                            
                            UIView.animate(withDuration: self.duration, animations: {
                                self.loadingView.isHidden = tempLoadingViewHidden
                                self.promptLabel.frame =  tempPromptFrame
                                self.promptLabel.isHidden = tempPromptHidden
                                self.containerView.frame =  tempContainerViewFrame
                                }, completion: { (finished) in
                                    //若果直接结束的时候出现新的动画 则不能开启dimiss
                                    if let nextExcuteType = self.nextProgressExcuteType
                                    {
                                        self.showMessage(message: message, type: nextExcuteType)
                                        return
                                    }else{
                                        //通知 loadingView 开启loading动画 并切换状态
                                        self.loadingView.loadingType =  type
                                    }
                            })
                        }
                    })
                    return
                }
                
                self.isDismissDelay = false
                self.containerView.layer.removeAllAnimations()
                
                //弹出错误或者成功
                self.isHidden = false
                UIView.animate(withDuration: duration, animations: {
                    self.loadingView.isHidden = tempLoadingViewHidden
                    self.promptLabel.frame =  tempPromptFrame
                    self.promptLabel.isHidden = tempPromptHidden
                    self.containerView.frame =  tempContainerViewFrame
                    }, completion: { (finished) in
                        //若果直接结束的时候出现新的动画 则不能开启dimiss
                        if let nextExcuteType = self.nextProgressExcuteType
                        {
                            self.showMessage(message: message, type: nextExcuteType)
                            return
                        }else{
                            //通知 loadingView 开启loading动画 并切换状态
                            self.loadingView.loadingType =  type
                        }
                        
                        //开启延时隐藏
                            self.isDismissDelay =  true
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.duration + 1, execute: {//成功失败延时消失
                                //如果当前动画还是dismiss 则执行
                                if self.isDismissDelay {
                                    self.showMessage(message: "消失", type: JWProgressHUDType.dismiss)
                                }
                            })
                })
            }else if type == .dismiss{
                //如果是dismiss 不用操作，自动隐藏
                
                //移除所有的动画
                self.containerView.layer.removeAllAnimations()
                
                
                promptLabel.text =  !tempPromptHidden ? message ?? "" : ""
                self.loadingView.loadingType =  type
                
                //执行弹出
                animation.values = [1.0,1.2,1.0,0.5]
                containerView.layer.add(animation, forKey: String(format:"%zd",type.rawValue))
                
                //隐藏
                //                opacityAnim.fromValue = 1
                opacityAnim.toValue  = 0
                self.bgCoverView.layer.add(opacityAnim, forKey: "opacity")
                
                return
            }else{ //message
                //设置好控件的状态
                self.loadingView.isHidden = tempLoadingViewHidden
                self.promptLabel.frame =  tempPromptFrame
                self.promptLabel.isHidden = tempPromptHidden
                self.containerView.frame =  tempContainerViewFrame
                
                promptLabel.text =  !tempPromptHidden ? message ?? "" : ""
                self.loadingView.loadingType =  type
                
                self.containerView.layer.removeAllAnimations()
                
                //执行弹出
                animation.values = [0.5,1.2,0.8,1.0]
                containerView.layer.add(animation, forKey: String(format:"%zd",type.rawValue))
                
                //隐藏
                //                opacityAnim.fromValue = 0
                opacityAnim.toValue  = 1
                self.bgCoverView.layer.add(opacityAnim, forKey: "opacity")
                
                
                
                self.isDismissDelay =  true
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration + 1, execute: {//成功失败延时消失
                    //如果当前动画还是dismiss 则执行
                    if self.isDismissDelay {
                        self.showMessage(message: "消失", type: JWProgressHUDType.dismiss)
                    }
                })
                
            }
            break
        case .dismiss://dismiss状态下，直接弹出提示
            if type != .dismiss{
                //设置好控件的状态
                self.loadingView.isHidden = tempLoadingViewHidden
                self.promptLabel.frame =  tempPromptFrame
                self.promptLabel.isHidden = tempPromptHidden
                self.containerView.frame =  tempContainerViewFrame
                
                promptLabel.text =  !tempPromptHidden ? message ?? "" : ""
                self.loadingView.loadingType =  type
                
                self.containerView.layer.removeAllAnimations()
                
                //动画切换
                animation.values = [0.5,1.2,0.8,1.0]
                containerView.layer.add(animation, forKey: String(format:"%zd",type.rawValue))
                
                //隐藏
                //                opacityAnim.fromValue = 0
                opacityAnim.toValue  = 1
                self.bgCoverView.layer.add(opacityAnim, forKey: "opacity")
                
                //如果不等于loading 延时消失
                if type != .loading{
                    //延时消失
                    self.isDismissDelay = true
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration + 1, execute: {//成功失败延时消失
                        //如果当前动画还是dismiss 则执行
                        if self.isDismissDelay {
                            self.showMessage(message: "消失", type: JWProgressHUDType.dismiss)
                            return
                        }
                    })
                }else{
                    self.isDismissDelay = false
                }
            }
            break
        }
        
        self.currentProgressType = type
    }
    
    
    public func animationDidStart(_ anim: CAAnimation) {
        self.isHidden = false
    }
    
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if  self.currentProgressType == .dismiss {
            self.isHidden = true
            if let closure = self.complectionClosure{
                closure()
            }
        }else{
            self.isHidden = false
        }
    }
    
    //布局
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let x:CGFloat = 0
        let y:CGFloat = 0
        let w:CGFloat = selfWidth
        let h:CGFloat = selfHeight
        
        let rect:CGRect =  CGRect(x: x, y: y, width: w, height: h)
        self.frame = rect//UIScreen.main.bounds
        
        bgCoverView.frame = rect// self.bounds
        
    }
    
}

public let JavenHUD:JWProgressHUD = JWProgressHUD()
