//
//  JWAlertViewController.swift
//  CarServer
//
//  Created by 朱建伟 on 2016/11/6.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

public enum JWAlertControllerStyle:Int{
    case actionSheet//ActionSheet
    case alert//alertView
    case popover//带箭头的悬浮小菜单
}


public class JWAlertController: UIViewController ,UIViewControllerTransitioningDelegate{
    
    private var preferredStyle:JWAlertControllerStyle = JWAlertControllerStyle.actionSheet
    
    private let containerViewPadding:CGFloat = 20
    
    
    //蒙版
    private let coverView:UIButton = UIButton()
    
    //展示的View
    private let containerView:UIView = UIView()
    
    //边框阴影的view
    private let shadowView:UIButton = UIButton()
    
    //标题
    private let titleLabel:UILabel = UILabel()
    
    //内容
    private let messageLabel:UILabel = UILabel()
    
    //lineView
    private let lineView:UIView = UIView()
    
    //按钮的view
    private let operationView:UIView = UIView()
    
    //箭头图层
    private let arrowLayer:CAShapeLayer = CAShapeLayer()
    
    
    //按钮数组
    private var actiontBtnArray:[JWActionButton] = [JWActionButton]()
    
    //数组
    private var actions:[JWAlertAction] = [JWAlertAction]()
    
    
    //popver
    private var sourceViewRect:CGRect = CGRect()
    
    //箭头
    private let arrowSize:CGSize = CGSize(width: 12, height: 8)
    
    //具体内容
    var message:String?
    
    
    //初始化
    public convenience init(preferredStyle: JWAlertControllerStyle,sourceViewRect:CGRect?){
        self.init()
        
        self.modalPresentationStyle  =  .custom
        
        if preferredStyle == .popover{
            if let sourceViewRect =  sourceViewRect{
                self.sourceViewRect = sourceViewRect
                self.preferredStyle   = preferredStyle
            }
        }
        
        self.transitioningDelegate = self
        
    }
    
    //初始化
    public convenience init(preferredStyle: JWAlertControllerStyle,sourceView:UIView?){
        self.init()
        
        self.modalPresentationStyle  =  .custom
        
        if preferredStyle == .popover{
            if let sourceView =  sourceView{
                self.sourceViewRect = sourceView.convert(sourceView.bounds, to:  UIApplication.shared.keyWindow)
                self.preferredStyle   = preferredStyle
            }
        }
        
        self.transitioningDelegate = self
        
    }
    
    //初始化
    public convenience init(preferredStyle: JWAlertControllerStyle){
        self.init()
        
        self.modalPresentationStyle  =  .custom
        
        self.preferredStyle   = preferredStyle
        
        
        self.transitioningDelegate = self
        
    }
    
    //初始化
    public convenience init(title: String?, message: String?, preferredStyle: JWAlertControllerStyle){
        self.init()
        
        
        self.modalPresentationStyle  =  .custom
        
        
        //标题
        if let t =  title {
            self.title = t
        }
        
        //内容
        if let msg  = message{
            self.message =  msg
        }
        
        
        //样式
        self.preferredStyle = preferredStyle
        
        
        self.transitioningDelegate = self
        
    }
    
    
    
    //加载
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
        //蒙版
        coverView.backgroundColor = UIColor.clear
        coverView.tag = -1
        coverView.addTarget(self, action: #selector(JWAlertController.actionBtnClick(btn:)), for: UIControlEvents.touchUpInside)
        view.addSubview(coverView)
        
        //边框阴影的view
        shadowView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.45).cgColor
        shadowView.layer.shadowRadius  = 20
        shadowView.layer.shadowOffset = CGSize(width: 0, height:10)
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.masksToBounds = false
        view.addSubview(shadowView)
        
        
        
        //展示的View
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 13.0
        containerView.layer.masksToBounds = true
        shadowView.addSubview(containerView)
        
        
        if preferredStyle == .popover{
            shadowView.layer.shadowRadius  = 10
            shadowView.layer.shadowOffset = CGSize(width: 0, height:5)
            containerView.layer.cornerRadius = 5.0
        }
        
        
        //标题
        titleLabel.numberOfLines = 0
        titleLabel.isUserInteractionEnabled = true
        titleLabel.isHidden = true
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.textColor = UIColor(red: 94/255.0, green: 96/255.0, blue: 102/255.0, alpha: 1)
        containerView.addSubview(titleLabel)
        
        //内容
        messageLabel.numberOfLines = 0
        messageLabel.isUserInteractionEnabled = true
        messageLabel.isHidden = true
        messageLabel.font = UIFont.systemFont(ofSize:16)
        messageLabel.textAlignment = NSTextAlignment.center
        messageLabel.textColor = UIColor(red: 94/255.0, green: 96/255.0, blue: 102/255.0, alpha: 1)
        containerView.addSubview(messageLabel)
        
        //线
        lineView.backgroundColor = UIColor(white: 0.85, alpha: 1)
        containerView.addSubview(lineView)
        
        
        //按钮的view
        operationView.backgroundColor = UIColor(white: 0.85, alpha: 1)
        containerView.addSubview(operationView)
        
        
        
        
        //如果按钮大于2个 隐藏线
        self.lineView.isHidden = self.actions.count > 2
        //移除按钮
        for btn in self.actiontBtnArray{
            btn.removeFromSuperview()
        }
        
        self.actiontBtnArray.removeAll()
        
        let normalColor:UIColor =  UIColor(red: 94/255.0, green: 96/255.0, blue: 102/255.0, alpha: 1)
        
        let highlightedColor = UIColor(red: 104/255.0, green: 106/255.0, blue: 112/255.0, alpha: 1)
        //添加
        for action in self.actions{
            let actionBtn:JWActionButton = JWActionButton()
            actionBtn.tag  = self.actiontBtnArray.count
            actionBtn.lineView.isHidden = self.actions.count <= 2
            
            
            actionBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            actionBtn.addTarget(self, action: #selector(JWAlertController.actionBtnClick(btn:)), for: UIControlEvents.touchUpInside)
            
            operationView.addSubview(actionBtn)
            
            //设置标题
            actionBtn.setTitle(action.title, for: UIControlState.normal)
            actionBtn.setTitle(action.title, for: UIControlState.selected)
            
            
            if preferredStyle == .popover{
                actionBtn.lineMargin = 10
                actionBtn.lineView.isHidden = self.actiontBtnArray.count < 1
                actionBtn.setBackgroundImage(Bundle.image(named:"normalBlackBg"), for: UIControlState.normal)
                actionBtn.setBackgroundImage(Bundle.image(named:"normalBlackBg"), for: UIControlState.highlighted)
                actionBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
                actionBtn.setTitleColor(UIColor.white, for: UIControlState.highlighted)
            }else{
                
                actionBtn.setBackgroundImage(Bundle.image(named:"normalBg"), for: UIControlState.normal)
                actionBtn.setBackgroundImage(Bundle.image(named:"highlightBg"), for: UIControlState.highlighted)
                
                switch action.actionStyle {
                case .cancel:
                    actionBtn.setTitleColor(highlightedColor, for: UIControlState.normal)
                    
                    break
                case .default:
                    actionBtn.setTitleColor(normalColor, for: UIControlState.normal)
                    break
                case .destructive:
                    actionBtn.setTitleColor(UIColor.red, for: UIControlState.normal)
                    break
                }
            }
            
            self.actiontBtnArray.append(actionBtn)
        }
        
        
        //添加箭头
        self.arrowLayer.fillColor = UIColor.black.cgColor
        self.view.layer.addSublayer(self.arrowLayer)
        
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        
        self.coverView.frame = view.bounds
        
        //布局控件
        var shadowViewW:CGFloat = preferredStyle == .alert ? view.bounds.width * 0.75 : view.bounds.width * 0.9
        
        var btnH:CGFloat = 45
        
        
        //如果是popover模式
        if preferredStyle == .popover{
            shadowViewW = 85
            btnH = 40
        }
        
        let containViewW:CGFloat = shadowViewW
        
        //标题
        let titleW:CGFloat = containViewW - 2*containerViewPadding
        let titleX:CGFloat = containerViewPadding
        var titleH:CGFloat =  0
        var titleY:CGFloat = 0
        
        //计算高度
        if let title = self.title{
            if title != ""{
                titleY = 20
                titleH = boundingRect(size: CGSize(width:titleW,height:UIScreen.main.bounds.height), font:titleLabel.font, str: title).height + 5
                titleLabel.isHidden = false
                titleLabel.text = title
            }
        }
        titleLabel.frame = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
        
        
        //内容
        let messageX:CGFloat = titleX
        let messageW:CGFloat = titleW
        var messageH:CGFloat = 0
        var messageY:CGFloat = titleLabel.frame.maxY
        
        //计算高度
        if let message = self.message{
            if message != ""{
                messageY = titleLabel.frame.maxY + 15
                messageH = boundingRect(size: CGSize(width:messageW,height:UIScreen.main.bounds.height), font:messageLabel.font, str: message).height + 5
                
                messageLabel.isHidden = false
                messageLabel.text = message
            }
        }
        messageLabel.frame = CGRect(x: messageX, y: messageY, width: messageW, height: messageH)
        
        
        //线
        let lineW:CGFloat = containViewW - containerViewPadding*2
        let lineH:CGFloat = ((messageLabel.isHidden && titleLabel.isHidden) ? 0 : 0.5)
        let lineX:CGFloat = (containViewW - lineW)/2
        let lineY:CGFloat = messageLabel.frame.maxY  + ((messageLabel.isHidden && titleLabel.isHidden) ? 0 : 20)
        lineView.frame = CGRect(x: lineX, y: lineY, width: lineW, height: lineH)
        
        //按钮的view
        let operationY:CGFloat = lineView.frame.maxY
        let operationW:CGFloat = containViewW
        let operationX:CGFloat = (containViewW - operationW)/2
        
        
        let operationH:CGFloat = (self.actions.count > 2 || preferredStyle == .popover) ? btnH * CGFloat(self.actions.count) : btnH
        operationView.frame = CGRect(x: operationX, y: operationY, width: operationW, height: operationH)
        
        
        let btnW:CGFloat = (self.actions.count > 2 || self.actions.count == 1 || preferredStyle == .popover) ? containViewW : (containViewW/2 - 0.25)
        
        
        //布局按钮
        var i:Int = 0
        for btn in self.actiontBtnArray{
            let btnX:CGFloat = (self.actions.count > 2 || preferredStyle == .popover) ? 0 : (btnW+0.5) * CGFloat(i)
            let btnY:CGFloat = (self.actions.count > 2 || preferredStyle == .popover) ? (btnH * CGFloat(i)) : 0
            
            if (messageLabel.isHidden && titleLabel.isHidden) && i == 0 && self.preferredStyle ==  .actionSheet {
                btn.lineView.isHidden = true
            }
            
            btn.frame = CGRect(x: btnX, y: btnY, width: btnW, height: btnH)
            //累计
            i = i+1
        }
        
        
        
        
        //展示的View
        let containViewH:CGFloat = operationView.frame.maxY
        let containViewX:CGFloat = (shadowViewW - containViewW)/2
        let containViewY:CGFloat = 0
        containerView.frame = CGRect(x: containViewX, y: containViewY, width: containViewW, height: containViewH)
        
        //边框阴影的view
        let shadowViewH:CGFloat = containViewH
        var shadowViewX:CGFloat = (view.bounds.width - shadowViewW) / 2
        var shadowViewY:CGFloat = self.preferredStyle == .actionSheet ?  (view.bounds.height - shadowViewH - 30)  : (view.bounds.height - shadowViewH)/2
        
        
        if preferredStyle == .popover{
            self.arrowLayer.isHidden = false
            let margin:CGFloat = 5
            var arrowPointX:CGFloat = 0
            var arrowPointY:CGFloat = 0
            
            //下半部分
            if (sourceViewRect.maxY + sourceViewRect.minY)/2 > view.bounds.width/2{
                //右边
                if (sourceViewRect.minX + sourceViewRect.maxX)/2 > view.bounds.width/2{
                    
                    shadowViewX =  (sourceViewRect.minX + sourceViewRect.maxX)/2 - shadowViewW / 2
                    
                    //判断超出
                    if shadowViewX + shadowViewW > view.bounds.width {
                        shadowViewX =  view.bounds.width - shadowViewW - margin
                    }
                    
                    
                    shadowViewY  = (sourceViewRect.minY - self.arrowSize.height - shadowViewH )
                    
                    arrowPointX = (sourceViewRect.minX+sourceViewRect.maxX)/2
                    arrowPointY = sourceViewRect.minY
                }else{//左边
                    
                    shadowViewX =  (sourceViewRect.minX + sourceViewRect.maxX)/2 - shadowViewW / 2
                    
                    shadowViewY  = (sourceViewRect.minY - self.arrowSize.height - shadowViewH)
                    
                    //判断超出
                    if shadowViewX < margin {
                        shadowViewX = margin
                    }
                    
                    arrowPointX = (sourceViewRect.minX+sourceViewRect.maxX)/2
                    arrowPointY = sourceViewRect.minY
                    
                }
            }else{//上半部分
                //右边
                if (sourceViewRect.minX + sourceViewRect.maxX)/2 > view.bounds.width/2{
                    
                    shadowViewX =  (sourceViewRect.minX + sourceViewRect.maxX)/2 - shadowViewW / 2
                    
                    shadowViewY  = (sourceViewRect.maxY + self.arrowSize.height)
                    
                    
                    //判断超出
                    if shadowViewX + shadowViewW > view.bounds.width - margin{
                        shadowViewX =  view.bounds.width -  shadowViewW - margin
                    }
                    
                    
                    arrowPointX = (sourceViewRect.minX+sourceViewRect.maxX)/2
                    arrowPointY = sourceViewRect.maxY
                    
                    
                    
                }else{//左边
                    shadowViewX =  (sourceViewRect.minX + sourceViewRect.maxX)/2 - shadowViewW / 2
                    
                    shadowViewY  = (sourceViewRect.maxY + self.arrowSize.height)
                    
                    //判断超出
                    if shadowViewX < margin {
                        shadowViewX = margin
                    }
                    
                    arrowPointX = (sourceViewRect.minX+sourceViewRect.maxX)/2
                    arrowPointY = sourceViewRect.maxY
                }
            }
            
            shadowView.frame = CGRect(x: shadowViewX, y: shadowViewY, width: shadowViewW, height: shadowViewH)
            
            //计算背景
            self.arrowLayer.path = self.getPath(arrowPoint: CGPoint(x:arrowPointX,y:arrowPointY), containFrame: self.shadowView.frame).cgPath
            
        }else{
            self.arrowLayer.isHidden = true
            shadowView.frame = CGRect(x: shadowViewX, y: shadowViewY, width: shadowViewW, height: shadowViewH)
        }
        
    }
    
    
    //action按钮点击
    func actionBtnClick(btn:UIButton)  {
        
        //如果是alert 点击了背景按钮
        if self.preferredStyle == JWAlertControllerStyle.alert && btn.tag == -1
        {
            return
        }else if btn.tag == -1{
            dismiss(animated: true, completion: {
                
            })
            return
        }else{
            dismiss(animated: true, completion: {
                let action =  self.actions[btn.tag]
                if let ac =  action.handler{
                    ac(action)
                }
            })
        }
    }
    
    
    //添加action
    public func addAction(actionTitle:String,actionStyle:JWAlertActionStyle,handler:@escaping JWAlertAction.JWActionClosure) {
        let alertAction:JWAlertAction = JWAlertAction(title: actionTitle, style: actionStyle, handler: handler)
        addAction(action: alertAction)
    }
    
    
    
    //添加action
    public func  addAction(action:JWAlertAction) {
        //如果是默认
        actions.append(action)
        
        //排序
        actions.sort { (action1, action2) -> Bool in
            
            if action1.actionStyle == JWAlertActionStyle.destructive{
                if action2.actionStyle == JWAlertActionStyle.destructive{
                    return false
                }else{
                    return true
                }
            }else if action1.actionStyle == JWAlertActionStyle.cancel{
                //如果是取消
                if action2.actionStyle == JWAlertActionStyle.cancel{
                    if preferredStyle == JWAlertControllerStyle.alert{
                        return false
                    }
                    return true
                }else
                {
                    if preferredStyle == JWAlertControllerStyle.alert{
                        return true
                    }
                    return false
                }
            }
            return false
        }
    }
    
    
    
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.modalPresentationStyle  =  .custom
        let presentTrasition:JWAlertPresentTransitioning = JWAlertPresentTransitioning()
        presentTrasition.preferredStyle = self.preferredStyle
        return presentTrasition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.modalPresentationStyle  =  .custom
        let dismissTrasition:JWAlertDismissTransitioning = JWAlertDismissTransitioning()
        dismissTrasition.preferredStyle = self.preferredStyle
        return dismissTrasition
    }
    
    
    
    //计算高度
    func boundingRect(size:CGSize,font:UIFont,str:String)  ->  CGSize {
        let size:CGSize =  NSString(string: str).boundingRect(with:size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil).size
        if size.height < 20{
            return CGSize(width: size.width+5, height: 20)
        }
        return CGSize(width: size.width+5, height:size.height+2)
    }
    
    
    private func getPath(arrowPoint:CGPoint,containFrame:CGRect) -> UIBezierPath {
        
        //        let path:UIBezierPath = UIBezierPath(roundedRect:containFrame, cornerRadius: 5)
        
        let path:UIBezierPath = UIBezierPath()
        
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        
        let arrowCenterX:CGFloat = (arrowPoint.x - containFrame.minX) + containFrame.minX
        
        let arrowCenterY:CGFloat = arrowPoint.y
        
        
        let centerPoint:CGPoint = CGPoint(x:arrowCenterX, y: arrowCenterY)
        
        
        if arrowPoint.y < containFrame.minY{//尖头在上面
            path.move(to:CGPoint(x: centerPoint.x-arrowSize.width/2, y: containFrame.minY))
            path.addLine(to: CGPoint(x: arrowPoint.x, y: arrowPoint.y+1))
            path.addLine(to: CGPoint(x: centerPoint.x + arrowSize.width/2, y: containFrame.minY))
            
            path.close()
            
        }else{//在下面
            
            path.move(to:CGPoint(x: centerPoint.x-arrowSize.width/2, y: containFrame.maxY))
            path.addLine(to: CGPoint(x: arrowPoint.x, y: arrowPoint.y-1))
            path.addLine(to: CGPoint(x: centerPoint.x + arrowSize.width/2, y: containFrame.maxY))
            
            path.close()
        }
        
        
        return path
    }
    
}


