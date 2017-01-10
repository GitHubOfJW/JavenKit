//
//  JWAlertAction.swift
//  CarServer
//
//  Created by 朱建伟 on 2016/11/6.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

public enum JWAlertActionStyle:Int{
    case `default`
    case cancel
    case destructive
}

public class JWAlertAction: NSObject {
    
 
    
   public typealias JWActionClosure = (JWAlertAction)->Void
    

    //初始化
    public convenience init(title:String,style:JWAlertActionStyle,handler:@escaping JWActionClosure) {
        self.init()
        
        //设置标题
        self.title = title
        
        
        //回掉
        self.handler =  handler
        
        //样式
        self.actionStyle = style
    }
    
    
    //类型
    var actionStyle:JWAlertActionStyle =  JWAlertActionStyle.default
    
    
    //回调
    var handler:JWActionClosure?
    
    
    //title
    var title:String?
    
    
    
    private override init() {
        super.init()
    }
    
}
