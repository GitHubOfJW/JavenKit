//
//  JWDatePickerKeyBoardView.swift
//  CarServer
//
//  Created by 朱建伟 on 2016/10/17.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

class JWDatePickerKeyBoardView: UIView {
    
    typealias ConfirmDateClosure = (Date) -> ()
    
    var didConfirmDateClosure:ConfirmDateClosure?
    
    
    var isRemove:Bool =  false
    
    var font:UIFont?{
        willSet{
            if let f = font {
                titleLabel?.font = f
                titleLabel?.text = "日期选择"
                cancelBtn?.titleLabel?.font = f
                confirmBtn?.titleLabel?.font = f
            }
        }
    }
    
    
    var title:String?{
        willSet{
            if let t  = newValue{
                titleLabel?.text = t
            }
        }
    }
    
    //蒙版
    private var cover:UIControl = {
        let view:UIControl =  UIControl(frame: ScreenBounds)
        view.backgroundColor = UIColor.black
        view.alpha =  0.4
        
        return view
    }()

    //取消按钮
     private var cancelBtn:UIButton?

    //确定按钮
     private var confirmBtn:UIButton?
    
    //头部标题
    private var titleLabel:UILabel?
    
    //头部View
    private var titleView:UIView?
    
    //pickerView
    let pickerView:JWDatePickerView = JWDatePickerView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        cover.addTarget(self, action: #selector(JWDatePickerKeyBoardView.exitKeyBoard), for: UIControlEvents.touchUpInside)
        
//        FontPrompt_120_218_317_416_515_614_712_810_908
        font = Font4
        
        //标题View
        titleView = UIView()
        titleView?.backgroundColor = UIColor.orange
        addSubview(titleView!)
        
        //取消按钮
        cancelBtn = UIButton()
        cancelBtn?.addTarget(self, action:#selector(JWDatePickerKeyBoardView.btnClick(btn:)), for: UIControlEvents.touchUpInside)
        cancelBtn?.titleLabel?.font = font
        cancelBtn?.setTitle("取消", for: UIControlState.normal)
        cancelBtn?.setTitle("取消", for: UIControlState.selected)
        cancelBtn?.setTitleColor(UIColor.white, for: UIControlState.normal)
        cancelBtn?.tag = 0
        titleView?.addSubview(cancelBtn!)
        
        //确定按钮
        confirmBtn = UIButton()
        confirmBtn?.addTarget(self, action:#selector(JWDatePickerKeyBoardView.btnClick(btn:)), for: UIControlEvents.touchUpInside)
        confirmBtn?.titleLabel?.font = font
        confirmBtn?.setTitle("确定", for: UIControlState.normal)
        confirmBtn?.setTitle("确定", for: UIControlState.selected)
        confirmBtn?.setTitleColor(UIColor.white, for: UIControlState.normal)
        confirmBtn?.tag = 1
        titleView?.addSubview(confirmBtn!)
        
        //标题
        titleLabel = UILabel()
        titleLabel?.textAlignment = NSTextAlignment.center
        titleLabel?.font = font
        titleLabel?.text = title
        titleLabel?.textColor = UIColor.white
        titleView?.addSubview(titleLabel!)
        
        //pickerView
        addSubview(pickerView)
    }
    
    
    internal func btnClick(btn:UIButton) {
        if btn.tag == 1 {
             if let closure = didConfirmDateClosure{
                if let date =  pickerView.date{
                   closure(date)
                }
             }
        }
        
        cover.alpha = 0.021;
        UIApplication.shared.keyWindow?.endEditing(true)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
         
        //titleView
        setH(256)
        
        let titleViewX:CGFloat = 0
        let titleViewY:CGFloat = 0
        let titleViewW:CGFloat = bounds.width
        let titleViewH:CGFloat = 50
        titleView?.frame = CGRect(x: titleViewX, y: titleViewY, width: titleViewW, height: titleViewH)
        
        let cancelX:CGFloat = 0
        let cancelY:CGFloat = 0
        let cancelW:CGFloat = 80
        let cancelH:CGFloat = titleViewH
        cancelBtn?.frame  = CGRect(x: cancelX, y: cancelY, width: cancelW, height: cancelH)
        
        let confirmW:CGFloat = cancelW
        let confirmH:CGFloat = titleViewH
        let confirmX:CGFloat = bounds.width - confirmW
        let confirmY:CGFloat = 0
        confirmBtn?.frame =  CGRect(x: confirmX, y: confirmY, width: confirmW, height: confirmH)
        
        let titleW:CGFloat = bounds.width - cancelW*2
        let titleH:CGFloat = titleViewH
        let titleX:CGFloat = (cancelBtn?.frame.maxX)!
        let titleY:CGFloat = 0
        titleLabel?.frame = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
        
        
        let pickerX:CGFloat = 0
        let pickerY:CGFloat = titleViewH
        let pickerW:CGFloat = titleViewW
        let pickerH:CGFloat = bounds.size.height - titleViewH
        pickerView.frame = CGRect(x: pickerX, y: pickerY, width: pickerW, height: pickerH)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /**
     *  此方法当 自定键盘移动到窗口上调用
     */
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isRemove == false {
            let window:UIWindow = UIApplication.shared.keyWindow!
            cover.frame =  ScreenBounds
            cover.alpha = 0.4
            window.addSubview(cover)
        }else
        {
            isRemove =  false
        }
    }
    
    
    /**
     *  移除时 将蒙板一并移除
     */
    override func removeFromSuperview() {
        isRemove = true
        cover.removeFromSuperview()
        
        super.removeFromSuperview()
    }
    
    
    func exitKeyBoard()  {
        cover.alpha  = 0.021
        UIApplication.shared.keyWindow?.endEditing(true)
    }

}
