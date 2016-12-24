//
//  JWAlertMenuViewController.swift
//  CarServer
//
//  Created by 朱建伟 on 2016/12/12.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit


class JWAlertMenuViewController: UIViewController,UIViewControllerTransitioningDelegate{
    
    private var bgButton:UIButton = UIButton()
    
    //数组
    var actions:[JWAlertAction] = [JWAlertAction]()
    
    
    private var bgView:UIView?
    private var bgLayer:CAShapeLayer =  CAShapeLayer()
    private var containerView:UIView = UIView()
    
    override func loadView() {
        super.loadView()
        
        self.bgView =  (UIApplication.shared.keyWindow?.snapshotView(afterScreenUpdates: true))!
        
        bgLayer.fillColor = UIColor.black.cgColor

        
    }
    
    convenience init(showFromRect:CGRect) {
        //初始化
        self.init()
        
        self.fromViewRect =  showFromRect
    }
    
    
    convenience init(showFromView:UIView) {
        //初始化
        self.init()
        
        self.fromViewRect = showFromView.convert(showFromView.bounds, to: self.view.window ?? UIApplication.shared.keyWindow)
    }
    
    //加载
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
        self.transitioningDelegate = self
        
        
        if let bgView = self.bgView{
            view.addSubview(bgView)
        }else{
            bgView =  (UIApplication.shared.keyWindow?.snapshotView(afterScreenUpdates: true))!
            view.addSubview(bgView!)
        }
        
        bgButton.addTarget(self, action: #selector(JWAlertController.actionBtnClick(btn:)), for: UIControlEvents.touchUpInside)
        bgButton.frame = self.view.bounds
        bgButton.tag = 100
        view.addSubview(bgButton)
        
        
        
    }
    
    
    private var isShow:Bool = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        
        //添加layer
        self.bgButton.layer.addSublayer(bgLayer)
        
        self.containerView.layer.cornerRadius = 5.0
        self.containerView.backgroundColor = UIColor.black
        self.containerView.layer.masksToBounds = true
        
        //如果未展示
        if !isShow{
            isShow = true
            let rgb:CGFloat = 80
            let bgColor:UIColor =  UIColor(red: rgb/255.0, green: rgb/255.0, blue: rgb/255.0, alpha: 0.4)
            
            //动画展示
//            UIView.animate(withDuration: 0.25, animations: { 
//                self.bgButton.backgroundColor = bgColor
//            }, completion: { (isFinished) in
                if self.actions.count > 0 {
                    //展示菜单
                    self.showMenuButton(duration:0.08 * Double(self.actions.count))
                }
//            })
        }
    }

    
    private let arrowSize:CGSize = CGSize(width: 10, height: 15)
    
    var fromViewRect:CGRect?
    
    var maxWidth:CGFloat = 40
    private func showMenuButton(duration:TimeInterval) {
        
        
        if let fromViewRect = self.fromViewRect{
            
            var containerX:CGFloat = 0
            var containerY:CGFloat = 0
            
//            let arrowW:CGFloat = 10
            let arrowH:CGFloat = arrowSize.height
            let padding:CGFloat = 8
            
            let height:CGFloat = 26*CGFloat(self.actions.count)
            let containerH:CGFloat = CGFloat(self.actions.count - 1)*0.5+height + 2*padding
            
            
            let maxContainerWidth:CGFloat = self.maxWidth + 2 * padding
            
            var arrowPointX:CGFloat = 0
            var arrowPointY:CGFloat = 0
            
            let margin:CGFloat = 5
            
            //下半部分
            if (fromViewRect.maxY + fromViewRect.minY)/2 > view.bounds.width/2{
                //右边
                if (fromViewRect.minX + fromViewRect.maxX)/2 > view.bounds.width/2{
                    
                    containerX =  (fromViewRect.minX + fromViewRect.maxX)/2 - maxWidth / 2
                    
                    //判断超出
                    if containerX + maxContainerWidth > view.bounds.width - margin{
                       containerX =  view.bounds.width - maxContainerWidth - margin
                    }
                    
                    
                    containerY  = (fromViewRect.minY - arrowH - containerH )
                    
                    arrowPointX = (fromViewRect.minX+fromViewRect.maxX)/2
                    arrowPointY = fromViewRect.minY
                }else{//左边
                    
                    containerX =  (fromViewRect.minX + fromViewRect.maxX)/2 - maxContainerWidth / 2
                    
                    containerY  = (fromViewRect.minY - arrowH - containerH)
                    
                    //判断超出
                    if containerX < margin {
                        containerX = margin
                    }
                    
                    arrowPointX = (fromViewRect.minX+fromViewRect.maxX)/2
                    arrowPointY = fromViewRect.minY
                    
                }
            }else{//上半部分
                //右边
                if (fromViewRect.minX + fromViewRect.maxX)/2 > view.bounds.width/2{
                    
                    containerX =  (fromViewRect.minX + fromViewRect.maxX)/2 - maxContainerWidth / 2
                    
                    containerY  = (fromViewRect.maxY + arrowH)
                    
                    
                    //判断超出
                    if containerX + maxContainerWidth > view.bounds.width - margin{
                        containerX =  view.bounds.width -  maxContainerWidth - margin
                    }
                    
                    
                    arrowPointX = (fromViewRect.minX+fromViewRect.maxX)/2
                    arrowPointY = fromViewRect.maxY
                    
                    
                    
                }else{//左边
                    containerX =  (fromViewRect.minX + fromViewRect.maxX)/2 - maxContainerWidth / 2
                    
                    containerY  = (fromViewRect.maxY + arrowH)
                    
                    //判断超出
                    if containerX < margin {
                        containerX = margin
                    }
                    
                    arrowPointX = (fromViewRect.minX+fromViewRect.maxX)/2
                    arrowPointY = fromViewRect.maxY
                }
            }
            
            
         
            self.containerView.frame =  CGRect(x: containerX, y:containerY, width: maxContainerWidth, height:containerH)
            self.view.addSubview(self.containerView)
            
            
            
            //计算背景
            self.bgLayer.path = self.getPath(arrowPoint: CGPoint(x:arrowPointX,y:arrowPointY), containFrame: self.containerView.frame).cgPath
            
            
            let alertMenuBtn:JWAlertMenuButton = JWAlertMenuButton(frame: CGRect(x: padding, y: padding, width: self.maxWidth, height: height/CGFloat(self.actions.count)))
            alertMenuBtn.tag = 0
            let action:JWAlertAction =  self.actions[0]
            alertMenuBtn.setTitle(action.title, for: UIControlState.normal)
            alertMenuBtn.setTitle(action.title, for: UIControlState.highlighted)
            
            showMenuBtn(alertBtn: alertMenuBtn,duration: duration, maxCount: self.actions.count)
        }
    }
    
    
    private func getPath(arrowPoint:CGPoint,containFrame:CGRect) -> UIBezierPath {
        
//        let path:UIBezierPath = UIBezierPath(roundedRect:containFrame, cornerRadius: 5)
        
        let path:UIBezierPath = UIBezierPath()
        
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
//        path.move(to: arrowPoint)
        
        
        let arrowCenterX:CGFloat = (arrowPoint.x - containFrame.minX) - arrowSize.width/2 + containFrame.minX
        
        let arrowCenterY:CGFloat = arrowPoint.y
        
        
        let centerPoint:CGPoint = CGPoint(x:arrowCenterX, y: arrowCenterY)
        
        
        if arrowPoint.y < containFrame.minY{//尖头在上面
            path.move(to:CGPoint(x: centerPoint.x-arrowSize.width/2, y: containFrame.minY))
            path.addLine(to: arrowPoint)
            path.addLine(to: CGPoint(x: centerPoint.x + arrowSize.width/2, y: containFrame.minY))
        
            path.close()
            
        }else{//在下面
            
            path.move(to:CGPoint(x: centerPoint.x-arrowSize.width/2, y: containFrame.maxY))
            path.addLine(to: arrowPoint)
            path.addLine(to: CGPoint(x: centerPoint.x + arrowSize.width/2, y: containFrame.maxY))
            
            path.close()
        }
        
        
        return path
    }
    
    
    private func showMenuBtn(alertBtn:JWAlertMenuButton?,duration:TimeInterval,maxCount:Int){
        if let btn:JWAlertMenuButton = alertBtn{
            btn.titleLabel?.font = font
            btn.addTarget(self, action: #selector(JWAlertMenuViewController.actionBtnClick(btn:)), for: UIControlEvents.touchUpInside)
            self.containerView.addSubview(btn)
            //执行动画
            btn.startAnimation(duration: duration, complection: { 
                
                if btn.tag >= maxCount - 1 {
                    
                    
                    self.containerView.backgroundColor = UIColor.black
                    return
                }
                
                //继续执行
                let menuBtn:JWAlertMenuButton = JWAlertMenuButton(frame: CGRect(x: btn.frame.minX, y: btn.frame.maxY+0.5, width: btn.frame.width, height: btn.frame.height))
                
                menuBtn.tag = btn.tag + 1
                
                let action:JWAlertAction =  self.actions[btn.tag + 1]
                
                menuBtn.setTitle(action.title, for: UIControlState.normal)
                menuBtn.setTitle(action.title, for: UIControlState.highlighted)
                
                self.showMenuBtn(alertBtn: menuBtn,duration: duration, maxCount: maxCount)
            })
        }
    }
    
    
    //action按钮点击
    func actionBtnClick(btn:UIButton)  {
        //如果是alert 点击了背景按钮
        
        //如果未展示
        if isShow{
            isShow = false
            
            //动画展示
            UIView.animate(withDuration: 0.25, animations: {
//                self.bgButton.backgroundColor = UIColor.clear
                self.containerView.alpha = 0
                self.bgLayer.opacity = 0
            }, completion: { (isFinished) in
//                self.containerView.alpha = 1
                if btn.tag == 100{
                    self.dismiss(animated: true, completion: {
                        
                    })
                    return
                }else{
                    self.dismiss(animated: true, completion: {
                        let action =  self.actions[btn.tag]
                        if let ac =  action.handler{
                            ac(action)
                        }
                    })
                }
            })
        }
        
       
    }
    
    private let font:UIFont = UIFont.systemFont(ofSize: 16)
    
    //添加action
    func addAction(actionTitle:String,actionStyle:JWAlertActionStyle,handler:@escaping JWAlertAction.JWActionClosure) {
        
        let alertAction:JWAlertAction = JWAlertAction(title: actionTitle, style: actionStyle, handler: handler)
        
        addAction(action: alertAction)
    }
    
    
    //添加action
    func  addAction(action:JWAlertAction) {
        
        let width =  boundingSize(str: action.title ?? "", maxWidth: view.bounds.width, font: font).width + 20
        
        if width > maxWidth {
            self.maxWidth = width
        }
        
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
                    return true
                }else
                {
                    return false
                }
            }
            return false
        }
    }
    
    
    //计算高度
    func boundingSize(str:String,maxWidth:CGFloat,font:UIFont) -> CGSize {
        let size:CGSize =  NSString(string: str).boundingRect(with: CGSize(width:maxWidth,height:view.bounds.height), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:font], context: nil).size
        
        return size
    }
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let presentTrasition:JWAlertMenuControllerPresentTrasitioning = JWAlertMenuControllerPresentTrasitioning()
        return presentTrasition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let dismissTrasition:JWAlertMenuControllerDismissTrasitioning = JWAlertMenuControllerDismissTrasitioning()
        return dismissTrasition
    }
    
}


class JWAlertMenuButton: UIButton,CAAnimationDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.setTitleColor(UIColor.white, for: UIControlState.highlighted)
        
        //设置图片
//        self.setBackgroundImage(UIImage(named:"mainWhiteTint"), for: UIControlState.normal)
        
        self.alpha  = 0
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private var closure:(()->Void)?
    func  startAnimation(duration:TimeInterval,complection:@escaping ()->Void) {
        
        self.alpha  = 1
        
//        self.layer.position = CGPoint(x: 0.5, y: 0.5)
        self.layer.anchorPoint = CGPoint(x: 0.5, y:0.5)
        
        let anim:CABasicAnimation =  CABasicAnimation(keyPath: "transform")
        
        anim.fromValue = CATransform3DMakeRotation(CGFloat(M_PI_2), 1, 0, 0)
        
        anim.toValue = CATransform3DIdentity
        
        anim.duration = duration
        
        anim.isRemovedOnCompletion =  false
        
        anim.fillMode = kCAFillModeForwards
        
        anim.delegate = self
        
        closure = complection
        
        self.layer.add(anim, forKey: "ShowMenu")
    }
    
    
    func animationDidStart(_ anim: CAAnimation) {
        
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let c  =  self.closure{
            c()
            self.closure = nil
        }
    }
}


//present
class JWAlertMenuControllerPresentTrasitioning: NSObject,UIViewControllerAnimatedTransitioning {
    
    
//    weak var menuController:JWAlertMenuViewController?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView:UIView =  transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView:UIView =  transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        transitionContext.containerView.addSubview(fromView)
        transitionContext.containerView.addSubview(toView)
        
        
//        if let menuAlertController = menuController{
//            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: { 
//                
//            }, completion: { (finished) in
//                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//            })
//        }else{
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        }
    }
}

//dismiss
class JWAlertMenuControllerDismissTrasitioning: NSObject,UIViewControllerAnimatedTransitioning {
  
    
//    weak var menuController:JWAlertMenuViewController?
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView:UIView =  transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView:UIView =  transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        transitionContext.containerView.addSubview(toView)
        transitionContext.containerView.addSubview(fromView)
        
        
//        if let menuAlertController = menuController{
//            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
//                
//            }, completion: { (finished) in
//                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//            })
//        }else{
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//        }
    }
    
}
