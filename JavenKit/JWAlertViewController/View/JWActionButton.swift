//
//  JWActionButton.swift
//  JWAlertViewController_Demo
//
//  Created by 朱建伟 on 2016/12/17.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

class JWActionButton: UIButton {

    let lineView:UIView = UIView()
    
    var lineMargin:CGFloat = 0
    
    //初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        
         
        
        lineView.backgroundColor = UIColor(white: 0.85, alpha: 1)
         
        
        addSubview(lineView)
        
    
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let lineW:CGFloat = self.bounds.size.width - 2 * self.lineMargin
        let lineX:CGFloat = (self.bounds.size.width - lineW)/2
        let lineY:CGFloat = 0
        let lineH:CGFloat = 0.5
        self.lineView.frame = CGRect(x: lineX, y: lineY, width: lineW, height: lineH)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
