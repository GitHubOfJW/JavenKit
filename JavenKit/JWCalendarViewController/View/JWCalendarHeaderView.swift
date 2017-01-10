//
//  JWCalendarHeaderView.swift
//  KitDemo
//
//  Created by 朱建伟 on 2017/1/5.
//  Copyright © 2017年 zhujianwei. All rights reserved.
//

import UIKit

class JWCalendarHeaderView: UIView {
    
    //容器
    let containView:UIView = UIView()
    
    //头部提示部分
    let topPromptView:UIView = UIView()
    
    private let lineView:UIView = UIView()
    
    
    
    //背景
    private let normalLayer:CAShapeLayer = CAShapeLayer()
    private let selectedLayer:CAShapeLayer = CAShapeLayer()
    private let disabledLayer:CAShapeLayer = CAShapeLayer()
    
    
    private let normalLabel:UILabel = UILabel()
    private let selectedLabel:UILabel = UILabel()
    private let disabledLabel:UILabel = UILabel()
    
    
    //边距
    var sectionInset:UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10){
        didSet{
            self.setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 0.94, alpha: 1)
     
        
        //layer
        normalLayer.fillColor = dayNormalColor.cgColor
        topPromptView.layer.addSublayer(normalLayer)
        
        selectedLayer.fillColor = daySelectedColor.cgColor
        topPromptView.layer.addSublayer(selectedLayer)
        
        disabledLayer.fillColor = dayDisabledColor.cgColor
        topPromptView.layer.addSublayer(disabledLayer)
        
        normalLabel.font = UIFont.systemFont(ofSize: 14)
        normalLabel.text = "普通"
        normalLabel.textColor = UIColor(white: 0.3, alpha: 1)
        topPromptView.addSubview(normalLabel)
        
        selectedLabel.font = UIFont.systemFont(ofSize: 14)
        selectedLabel.text = "选中"
        selectedLabel.textColor = UIColor(white: 0.3, alpha: 1)
        topPromptView.addSubview(selectedLabel)
        
        disabledLabel.font = UIFont.systemFont(ofSize: 14)
        disabledLabel.text = "禁用"
        disabledLabel.textColor = UIColor(white: 0.3, alpha: 1)
        topPromptView.addSubview(disabledLabel)
        
        
    
        addSubview(topPromptView)
        addSubview(containView)
        
        let weekTitleArray:[String] = ["日","一","二","三","四","五","六"]
        
        for index in 0..<7{
            let weekLabel:UILabel = UILabel()
            weekLabel.font = UIFont.systemFont(ofSize: 17)
            weekLabel.textColor = dayNormalTextColor
            weekLabel.textAlignment = .center
            weekLabel.text = weekTitleArray[index]
            containView.addSubview(weekLabel)
        }
        
        lineView.backgroundColor = UIColor(white: 0.86, alpha: 1)
//        lineView.isHidden  = true
        self.addSubview(lineView)
    }
    
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let topPromptH:CGFloat = (self.bounds.height - self.sectionInset.top - self.sectionInset.bottom)*0.45
        
        let layerWH:CGFloat = topPromptH * 0.5
        
        let layerX:CGFloat = 0
        let layerY:CGFloat = (topPromptH -  layerWH) / 2
        
        let textW:CGFloat = 60
        
        let normalLayerFrame = CGRect(x: layerX, y: layerY, width: layerWH, height: layerWH)
        normalLayer.path = UIBezierPath(rect:normalLayerFrame).cgPath
        normalLabel.frame = CGRect(x: normalLayerFrame.maxX+5, y: 0, width: textW, height: topPromptH)
        
        
        
        let selectedLayerFrame = CGRect(x: normalLabel.frame.maxX+5, y: layerY, width: layerWH, height: layerWH)
        selectedLayer.path = UIBezierPath(rect:selectedLayerFrame).cgPath
        
        selectedLabel.frame = CGRect(x: selectedLayerFrame.maxX+5, y: 0, width: textW, height: topPromptH)
        
        
        
        let disabledLayerFrame = CGRect(x: selectedLabel.frame.maxX+5, y: layerY, width: layerWH, height: layerWH)
        disabledLayer.path = UIBezierPath(rect:disabledLayerFrame).cgPath
        disabledLabel.frame = CGRect(x: disabledLayerFrame.maxX+5, y: 0, width: textW, height: topPromptH)
        
        
        let topPromptY:CGFloat = self.sectionInset.top
        let topPromptW:CGFloat = disabledLabel.frame.maxX
        let topPromptX:CGFloat = (self.bounds.width - topPromptW) / 2
        self.topPromptView.frame =  CGRect(x: topPromptX, y: topPromptY, width: topPromptW, height: topPromptH)
        
        
        let containerX:CGFloat = self.sectionInset.left
        let containerY:CGFloat = self.topPromptView.frame.maxY
        let containerW:CGFloat = self.bounds.width -  self.sectionInset.left - self.sectionInset.right
        let containerH:CGFloat = (self.bounds.height - self.sectionInset.top - self.sectionInset.bottom)*0.55
        
        containView.frame = CGRect(x: containerX, y: containerY, width: containerW, height: containerH)
        
        var index:Int = 0
        
        let weekWidth:CGFloat = containerW / 7
        for weekLabel in containView.subviews{
            
            let x:CGFloat = weekWidth * CGFloat(index)
            let y:CGFloat = 0
            let w:CGFloat = weekWidth
            let h:CGFloat = containerH
            
            weekLabel.frame = CGRect(x: x, y: y, width: w, height: h)
            
            index = index + 1
        }
        
        lineView.frame = CGRect(x: 0, y: self.bounds.height  - 0.5, width: self.bounds.width, height: 0.5)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
