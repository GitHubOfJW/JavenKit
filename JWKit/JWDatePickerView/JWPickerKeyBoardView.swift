//
//  JWDatePickerKeyBoardView.swift
//  CarServer
//
//  Created by 朱建伟 on 2016/10/17.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

class JWPickerKeyBoardView: UIView ,UIPickerViewDelegate,UIPickerViewDataSource{
    
    typealias ConfirmDateClosure = (Int) -> ()
    
    var didConfirmClosure:ConfirmDateClosure?
    
    var numberClosure:(()->Int)?
    
    var titleClosure:((Int)->String)?
     
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
    let pickerView:UIPickerView = UIPickerView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        cover.addTarget(self, action: #selector(JWDatePickerKeyBoardView.exitKeyBoard), for: UIControlEvents.touchUpInside)
        
//        FontPrompt_120_218_317_416_515_614_712_810_908
        font = Font4
        
        //标题View
        titleView = UIView()
        let rgb:CGFloat = 220/255.0
        titleView?.backgroundColor = UIColor(red: rgb, green: rgb, blue: rgb, alpha: 1)
        addSubview(titleView!)
        
        //取消按钮
        cancelBtn = UIButton()
        cancelBtn?.addTarget(self, action:#selector(JWDatePickerKeyBoardView.btnClick(btn:)), for: UIControlEvents.touchUpInside)
        cancelBtn?.titleLabel?.font = font
        cancelBtn?.setTitle("取消", for: UIControlState.normal)
        cancelBtn?.setTitle("取消", for: UIControlState.selected)
        cancelBtn?.setTitleColor(UIColor.orange, for: UIControlState.normal)
        cancelBtn?.tag = 0
        titleView?.addSubview(cancelBtn!)
        
        //确定按钮
        confirmBtn = UIButton()
        confirmBtn?.addTarget(self, action:#selector(JWDatePickerKeyBoardView.btnClick(btn:)), for: UIControlEvents.touchUpInside)
        confirmBtn?.titleLabel?.font = font
        confirmBtn?.setTitle("确定", for: UIControlState.normal)
        confirmBtn?.setTitle("确定", for: UIControlState.selected)
        confirmBtn?.setTitleColor(UIColor.orange, for: UIControlState.normal)
        confirmBtn?.tag = 1
        titleView?.addSubview(confirmBtn!)
        
        //标题
        titleLabel = UILabel()
        titleLabel?.textAlignment = NSTextAlignment.center
        titleLabel?.font = font
        titleLabel?.text = title
        titleLabel?.textColor = FontGrayColor
        titleView?.addSubview(titleLabel!)
        
        //pickerView
        addSubview(pickerView)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let closure =  self.numberClosure{
            if self.titleClosure != nil{
             return closure()
            }
        }
        
        return 0
        
    }
    
    //返回选项高度
    internal func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerView.bounds.height/5
    }
    
    
    //返回label
    internal func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let title:String =  titleClosure!(row)
        
        var label:UILabel? = nil
        
        if view != nil {
            label = view as! UILabel?
        }else{
            label = UILabel()
            label?.textAlignment = NSTextAlignment.center
            label?.textColor = FontGrayColor
            //            Font_120_218_317_416_515_614_712_810_908
            label?.font = Font4
            label?.text = title
        }
        return label!
    }
    
    private var currentIndex:Int = 0
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentIndex = row
    }

    
    internal func btnClick(btn:UIButton) {
        if btn.tag == 1 {
             if let closure = didConfirmClosure{
                closure(self.currentIndex)
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

    func  reloadData() {
        self.currentIndex = 0
        pickerView.reloadAllComponents()
    }
}
