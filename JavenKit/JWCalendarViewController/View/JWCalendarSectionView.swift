//
//  JWCalendarSectionView.swift
//  KitDemo
//
//  Created by 朱建伟 on 2017/1/4.
//  Copyright © 2017年 zhujianwei. All rights reserved.
//

import UIKit

class JWCalendarSectionView: UICollectionReusableView {
    
    //边距
    var sectionInset:UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10){
        didSet{
            self.setNeedsLayout()
        }
    }
    
    let dateLabel:UILabel = UILabel()
     
    let lineView:UIView = UIView()
    
    private let bgView = UIView()
    
    //初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        
        self.bgView.backgroundColor = UIColor.white
        
        dateLabel.font = UIFont.systemFont(ofSize: 17)
        dateLabel.textAlignment = .center
        dateLabel.textColor = dayNormalTextColor
        
        self.addSubview(bgView)
        bgView.addSubview(dateLabel)
        
        
        lineView.backgroundColor = UIColor(white: 0.86, alpha: 1)
        lineView.isHidden  = true
        self.addSubview(lineView)
    }
    
    

    //布局
    override public func layoutSubviews() {
        super.layoutSubviews()

        bgView.frame = CGRect(x: self.sectionInset.left, y: self.sectionInset.top, width: self.bounds.width - self.sectionInset.left - self.sectionInset.right, height: self.bounds.height - self.sectionInset.top - self.sectionInset.bottom)
        
        lineView.frame = CGRect(x: 0, y: self.bounds.height  - 1, width: self.bounds.width, height: 0.5)
        
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
