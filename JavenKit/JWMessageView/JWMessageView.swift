//
//  JWMessageView.swift
//  JWMessageView
//
//  Created by 朱建伟 on 2016/12/1.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

public class JWMessageView: UIView,UIDynamicAnimatorDelegate {
    
    var messageCount:Int = 0 {
        
        willSet{
            
            if newValue <= 0{
                self.isHidden = true
            }else{
                self.isHidden = false
            }
            
            self.messageButton.isHidden = false
            
            let tempCenter:CGPoint = self.center
            
            let fontStr:String = String(format: "%@", newValue > 99 ? "99+":String(format:"%zd",newValue))
            
            
            
            let size:CGSize = NSString(string: fontStr).boundingRect(with: CGSize(width:UIScreen.main.bounds.width,height:UIScreen.main.bounds.height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:messageFont], context: nil).size
            
            self.frame = CGRect(x: 0, y: 0, width: size.width + size.height, height: size.height + 5)
            
            self.center = tempCenter
            
            //消息
            messageButton.setTitle(fontStr, for: UIControlState.normal)
            messageButton.setTitle(fontStr, for: UIControlState.highlighted)
            
        }
    }
    
    
    let RangeSizeWH:CGFloat = 100
    
    var messageFont:UIFont = UIFont.systemFont(ofSize: 10)
    
    //消息label
    private var messageButton:UIButton = UIButton()
    
    //消息layer
    private var messageLayer:CAShapeLayer = CAShapeLayer()
    
    //消失的后显示的图片
    private var disappearedImageView:UIImageView = UIImageView()
    
    
    //拖拽消息的手势
    private var messageDragPan:UIPanGestureRecognizer?
    
    
    //初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //消息的layer
        messageLayer.fillColor = UIColor.red.cgColor
        layer.addSublayer(messageLayer)
        
        
        //消息
        messageButton.titleLabel?.font = messageFont
        
        messageButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        messageButton.setTitleColor(UIColor.white, for: UIControlState.highlighted)
        
        messageButton.setBackgroundImage(UIImage(named:"images.bundle/JWMessage"), for: UIControlState.normal)
        messageButton.setBackgroundImage(UIImage(named:"images.bundle/JWMessage"), for: UIControlState.highlighted)
        
        //点击按钮
//        messageButton.addTarget(self, action: #selector(JWMessageView.messageTouchDown(btn:)), for: UIControlEvents.touchDown)
        
        messageButton.addTarget(self, action: #selector(JWMessageView.messageTouchUpInside(btn:)), for: UIControlEvents.touchUpInside)
        
        
        
        
        addSubview(messageButton)
        
        
        //消失后显示的图片
        disappearedImageView.image = UIImage(named:"images.bundle/Bom")
        disappearedImageView.isHidden = true
        addSubview(disappearedImageView)
    
        
        //拖拽消息的手势
        messageDragPan = UIPanGestureRecognizer(target: self, action: #selector(JWMessageView.messageDragHandler(panReg:)))
        
        addGestureRecognizer(messageDragPan!)
        
    
    }
    
    
    private let scale:CGFloat = 0.8
    
    
    //根据两个点返回两个
    private func getMessagePath(sourcePoint:CGPoint,destinationPoint:CGPoint) -> UIBezierPath {
        //路径
        let messagePath:UIBezierPath = UIBezierPath()
        messagePath.lineJoinStyle = .round
        messagePath.lineCapStyle = .round
        
        let lineLength:CGFloat =  CGFloat(sqrtf(powf(Float(destinationPoint.y -  sourcePoint.y), 2) + powf(Float(destinationPoint.x -  sourcePoint.x), 2)))
        
        
        let radius:CGFloat = (bounds.height/2*scale - (bounds.height/24)/RangeSizeWH/2*lineLength*scale)
        
        let minRadius:CGFloat = (bounds.height/12)*scale - (bounds.height/12)/RangeSizeWH/2*lineLength*scale
        
        
        if lineLength >= RangeSizeWH*0.9
        {
            return messagePath
        }
        
        
        let reduceAngle:CGFloat = CGFloat(M_PI_4/2)
        
        
        //获取偏移角度
        let offSetAngle:CGFloat =  atan2(destinationPoint.y -  sourcePoint.y,destinationPoint.x -  sourcePoint.x)  + reduceAngle - CGFloat(M_PI_2)
         
        
        let center:CGPoint =  CGPoint(x:self.bounds.width/2,y:self.bounds.height/2)
        
        let firstSourcePoint:CGPoint =  self.getCirclePoint(radius: radius, center:center, angle:offSetAngle)
        
        //移动到对应点
        messagePath.move(to:firstSourcePoint )
        
        
        //添加半圆
        messagePath.addArc(withCenter:center, radius:radius, startAngle: offSetAngle, endAngle: offSetAngle - CGFloat(M_PI) - reduceAngle * 2, clockwise: false)
        
        
        //弧线中点
        let messageLayerCenter = CGPoint(x:(destinationPoint.x  + sourcePoint.x)/2, y: (destinationPoint.y + sourcePoint.y)/2)
        
        
        //添加弧线
        let firstControlPoint:CGPoint =  getCirclePoint(radius: minRadius, center:messageLayerCenter, angle: offSetAngle - CGFloat(M_PI) - reduceAngle * 2)
        
        //目标点
        let firstCurvePoint:CGPoint = getCirclePoint(radius: radius, center: destinationPoint, angle: offSetAngle - CGFloat(M_PI) - reduceAngle * 2)
        
        messagePath.addQuadCurve(to: firstCurvePoint, controlPoint: firstControlPoint)
        
        
        //第二个半弧
        messagePath.addArc(withCenter: destinationPoint, radius: radius, startAngle: offSetAngle - CGFloat(M_PI) - reduceAngle * 2, endAngle: offSetAngle, clockwise: true)
        
        
        
        //添加第二个弧线
        
        let secondControlPoint:CGPoint =  getCirclePoint(radius: minRadius, center:messageLayerCenter, angle: offSetAngle)
        
        
         messagePath.addQuadCurve(to: firstSourcePoint, controlPoint: secondControlPoint)
        
        
        
        return messagePath
    }
    
    
    //圆上的点
    private func getCirclePoint(radius:CGFloat,center:CGPoint,angle:CGFloat) -> CGPoint {
        
        let pointX:CGFloat = CGFloat(cosf(Float(angle))) * radius
        let pointY:CGFloat = CGFloat(sinf(Float(angle))) * radius
        
        return CGPoint(x: pointX+center.x, y: pointY+center.y)
    }
    
    
    
    var  messageMoveFlag:Bool = false
    //处理手势
    func messageDragHandler(panReg:UIPanGestureRecognizer) {
        //获取偏移量
        let translationPoint:CGPoint = panReg.translation(in: panReg.view)
        
        switch panReg.state {
        case .changed://改变
            messageButton.transform = CGAffineTransform(translationX: translationPoint.x, y: translationPoint.y)
            disappearedImageView.transform = CGAffineTransform(translationX: translationPoint.x, y: translationPoint.y)
            
            //路径
           self.messageLayer.path =  getMessagePath(sourcePoint: CGPoint(x:self.bounds.width/2,y:self.bounds.height/2), destinationPoint: CGPoint(x:self.bounds.width/2+translationPoint.x,y:self.bounds.height/2+translationPoint.y)).cgPath
            
            break
        case .failed:
            fallthrough
        case .cancelled:
            fallthrough
        case .ended://结束
            
            //路径恢复掉
            self.messageLayer.path = UIBezierPath().cgPath
            
            let lineLength:CGFloat =  CGFloat(sqrtf(powf(Float(translationPoint.y), 2) + powf(Float(translationPoint.x), 2)))
            
            //处理消息
            messageHanlder(alwaysShow: lineLength < RangeSizeWH*0.9)
            
            break
        case .began://开始
            
            //1.停止抖动的动画
//            messageTouchEnd(btn: messageButton)
            
            //2.隐藏图片
            self.disappearedImageView.isHidden = true
            self.messageButton.isHidden = false
            
            //3.开启移动模式
            self.messageMoveFlag = true
            
            
            break
        default:
            break
        }
    }
    
    
    //消息处理
    private func messageHanlder(alwaysShow:Bool) {
        //判断是否显示
        if alwaysShow{
            self.messageButton.isHidden = false
            self.disappearedImageView.isHidden = true
            self.messageDragPan?.isEnabled = true

            
            self.messageMoveFlag = false
            self.messageButton.transform = CGAffineTransform.identity
            disappearedImageView.transform = CGAffineTransform.identity
            self.setNeedsLayout()
        }else{
            
            self.messageButton.isHidden = true
            self.disappearedImageView.isHidden = false
            self.messageDragPan?.isEnabled = false
            self.messageButton.transform = CGAffineTransform.identity
            
            
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: {
                UIView.animate(withDuration: 0.25, animations: {
                    self.disappearedImageView.alpha = 0
                }, completion: { (finished) in
                    self.disappearedImageView.alpha = 1
                    self.disappearedImageView.isHidden = true
                    
                    self.messageDragPan?.isEnabled = true
                    self.messageMoveFlag = false
                    self.setNeedsLayout()
                    self.disappearedImageView.transform = CGAffineTransform.identity
                })
            })
        }
    }
    
    
    
//    private var delayFalg:Bool = false
    //消息点击
//    func messageTouchDown(btn:UIButton){
//        delayFalg = true
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute:{
//            let keyFrameAnim :CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
//            if self.delayFalg{
//                keyFrameAnim.values = [0,-3,0,3,0]
//                keyFrameAnim.fillMode = kCAFillModeForwards
//                keyFrameAnim.isRemovedOnCompletion = false
//                keyFrameAnim.duration = 0.2
//                keyFrameAnim.repeatCount = 1000
//                btn.layer.add(keyFrameAnim, forKey: "ShakeKey")
//            }
//        })
        
//    }
    
    func messageTouchUpInside(btn:UIButton){
//        delayFalg = false
//        btn.layer.removeAllAnimations()
        messageHanlder(alwaysShow: false)
    }
    
    
    
    
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        
        if !messageMoveFlag{
            //消息
            messageButton.frame = self.bounds
            messageButton.layer.cornerRadius = self.bounds.height/2
            messageButton.layer.masksToBounds = true
            
            
            //图片
            let imageH:CGFloat = self.bounds.height + 10
            let imageW:CGFloat = imageH
            let imageX:CGFloat = (self.bounds.width - imageW)/2
            let imageY:CGFloat = (self.bounds.height - imageW)/2
            disappearedImageView.frame = CGRect(x: imageX, y: imageY, width: imageW, height: imageH)
        }
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
