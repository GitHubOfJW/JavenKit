//
//  JWCalendarViewCell.swift
//  KitDemo
//
//  Created by 朱建伟 on 2017/1/4.
//  Copyright © 2017年 zhujianwei. All rights reserved.
//

import UIKit

//类型
public enum DayItemState:Int {
    case none//不在时间范围内，置灰色
    case placeholder//占位
    case normal//普通
    case selected//选中
    case disabled//禁用
}


class JWCalendarViewCell: UICollectionViewCell {
     
    var dayItemState:DayItemState = .normal{
        willSet{
            
            self.drawView.dayItemState = newValue
            
            switch newValue {
                case .placeholder:
                    
                break
                case .normal:
                    self.titleLabel.textColor = dayNormalTextColor
                    break
                case .selected:
                    self.titleLabel.textColor = daySelectedTextColor
                    break
                case .disabled:
                    self.titleLabel.textColor = dayDisabledTextColor
                    break
                case .none:
                    self.titleLabel.textColor = dayNoneTextColor
                    break
            }
            
             
        }
    }
    
    //标签
    let titleLabel:UILabel = UILabel()
    
    
    let bottomLineView:UIView = UIView()
    let leftLineView:UIView = UIView()
    
    let topLineView:UIView = UIView()
    let rightLineView:UIView = UIView()
    
    
    private let bgView:UIView = UIView()
    
    private let drawView:JWCalendarDrawView = JWCalendarDrawView()
    
    
    //初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor =  UIColor.white
        
        bgView.backgroundColor = UIColor.white
        self.contentView.addSubview(bgView)
        
        self.drawView.backgroundColor = UIColor.white
        self.bgView.addSubview(drawView)
        
        
        
        //控件
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.textColor = dayNormalTextColor
        titleLabel.textAlignment = .center
        self.bgView.addSubview(titleLabel)
        
      
        
        bottomLineView.backgroundColor = UIColor(white: 0.86, alpha: 1)
        bottomLineView.isHidden = true
        self.contentView.addSubview(bottomLineView)
        
        leftLineView.backgroundColor = UIColor(white: 0.86, alpha: 1)
        leftLineView.isHidden = true
        self.contentView.addSubview(leftLineView)
        
        
        topLineView.backgroundColor = UIColor(white: 0.86, alpha: 1)
        topLineView.isHidden = true
        self.contentView.addSubview(topLineView)
        
        rightLineView.backgroundColor = UIColor(white: 0.86, alpha: 1)
        rightLineView.isHidden = true
        self.contentView.addSubview(rightLineView)
        
    }
    
    
    
    //布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgView.frame = CGRect(x: 0, y: 0, width: self.contentView.bounds.width, height: self.contentView.bounds.height)
        
        let x:CGFloat = 5
        let w:CGFloat = (self.bgView.bounds.width - x*2)
        let h:CGFloat = w
        let y:CGFloat = ( self.bgView.bounds.height - h )/2
        titleLabel.frame = CGRect(x: x, y: y, width: w, height: h)
        
        self.drawView.frame = CGRect(x: x, y: y, width: w, height: h)
        
        
        bottomLineView.frame = CGRect(x: 0, y: self.contentView.bounds.height  - 0.5, width: self.bgView.bounds.width, height: 0.5)
        
        
        leftLineView.frame = CGRect(x: 0, y: 0, width: 0.5, height: self.contentView.bounds.height)
        
        
        topLineView.frame = CGRect(x: 0, y: 0, width: self.contentView.bounds.width, height: 0.5)
        
        
        rightLineView.frame = CGRect(x: self.contentView.bounds.width - 0.5, y: 0, width: 0.5, height: self.contentView.bounds.height)
        
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.dayItemState == .selected || self.dayItemState == .normal{
            return super.point(inside: point, with: event)
        }else{
            return false
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//绘制北京
class  JWCalendarDrawView: UIView {
    var dayItemState:DayItemState = DayItemState.normal{
        didSet{
           self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.backgroundColor?.setFill()
        
        let bgPath:UIBezierPath = UIBezierPath(rect: rect)
        bgPath.fill()
        
        
        let path:UIBezierPath = UIBezierPath(ovalIn: rect)
        
        switch self.dayItemState {
            case .placeholder:
                UIColor.clear.setFill()
                break
            case .normal:
                dayNormalColor.setFill()
                break
            case .selected:
                daySelectedColor.setFill()
                break
            case .disabled:
                dayDisabledColor.setFill()
                break
            case .none:
                dayNoneColor.setFill()
                break
        }
        path.fill()

       
    }
    
    
}
