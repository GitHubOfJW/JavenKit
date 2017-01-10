//
//  JWCalendarView.swift
//  KitDemo
//
//  Created by 朱建伟 on 2017/1/3.
//  Copyright © 2017年 zhujianwei. All rights reserved.
//


import UIKit


//协议
public protocol JWCalendarViewDelegate: NSObjectProtocol {
    
    //天数
    func numberOfDay(in calendarView:JWCalendarView) -> Int
    
    //缩进
    func placeholders(in calendarView:JWCalendarView) -> Int;
    
    //单天的状态
    func dayState(in calendarView:JWCalendarView,dayIndex:Int) -> JWCalendarView.DayItemType;
    
    //间隙
    func rowPadding(in calendarView:JWCalendarView)-> CGFloat;
    
    //间隙
    func columnPadding(in calendarView:JWCalendarView)-> CGFloat;
     
}


//展示日期的View
public class JWCalendarView: UIView {

    //类型
    public enum DayItemType:Int {
        case normal//普通
        case selected//选中
        case disabled//禁用
    }
    
    
    
    
    weak var delegate:JWCalendarViewDelegate?
    
    
    
    //刷新
    func reloadData() {
        self.setNeedsDisplay()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //绘制
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let delegate = self.delegate{
            //天数
            let numberOfDays:Int = delegate.numberOfDay(in: self)
            
            if numberOfDays <= 0{
                return
            }
            
            //缩进
            let placeholders:Int = delegate.placeholders(in: self)
            
            //总行数
            let totlaRows:Int = (numberOfDays+placeholders + 7 - 1)/7
            
            //行间距
            let rowPadding:CGFloat = delegate.rowPadding(in: self)
            
            //列间距
            let columnPadding:CGFloat = delegate.columnPadding(in: self)
            
            //按钮宽度
            let itemW:CGFloat = (self.bounds.width-(8*columnPadding))/7
            
            //高度
            let itemH:CGFloat = (self.bounds.height-(CGFloat(totlaRows+1)*rowPadding))/CGFloat(totlaRows)
            
            //遍历刷新
            for index in 0...numberOfDays{
                
                //计算位置
                let x:CGFloat = CGFloat((index + placeholders) % 7)*(itemW+columnPadding)+columnPadding
                let y:CGFloat = CGFloat((index + placeholders) / 7)*(itemH+rowPadding)+rowPadding
                
                let rect:CGRect = CGRect(x: x, y: y, width: itemW, height: itemH)
                
                let state:DayItemType = delegate.dayState(in: self, dayIndex: index)
                
                
                //上下文
                let context:CGContext = UIGraphicsGetCurrentContext()!
                
                let fontSize:CGFloat = itemH * 0.5
                
                
                
                let titleStr:NSString  = NSString(string:String(format:"%zd",index+1))
                
                let titleSize:CGSize = titleStr.boundingRect(with: CGSize(width:itemW,height:itemH), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: fontSize)], context: nil).size
                
                let offSetX:CGFloat = (itemW -  titleSize.width)/2
                let offSetY:CGFloat = (itemH -  titleSize.height)/2
                
                
                //绘制背景
                switch state {
                case .normal:
                    //普通
                    context.setFillColor(dayNormalColor.cgColor)
                    context.addEllipse(in: rect)
                    context.fillPath()
                    
                    //文字
                    titleStr.draw(at: CGPoint(x:rect.minX+offSetX,y: rect.minY + offSetY) , withAttributes: [NSFontAttributeName:UIFont.systemFont(ofSize: fontSize),NSForegroundColorAttributeName:dayNormalTextColor])
                    
                     break
                case .selected:
                    //选中
                    context.setFillColor(daySelectedColor.cgColor)
                    context.addEllipse(in: rect)
                    context.fillPath()
                    
                    //文字
                   titleStr.draw(at: CGPoint(x:rect.minX+offSetX,y: rect.minY + offSetY) , withAttributes: [NSFontAttributeName:UIFont.systemFont(ofSize: fontSize),NSForegroundColorAttributeName:daySelectedTextColor])
                    break
                case .disabled:
                    //禁用
                    context.setFillColor(dayDisabledColor.cgColor)
                    context.addEllipse(in: rect)
                    context.fillPath()
                    
                    //文字
                    titleStr.draw(at: CGPoint(x:rect.minX+offSetX,y: rect.minY + offSetY) , withAttributes: [NSFontAttributeName:UIFont.systemFont(ofSize: fontSize),NSForegroundColorAttributeName:dayDisabledTextColor])
                    break
                }
                
            }
        }
        
    }
    
    

}
