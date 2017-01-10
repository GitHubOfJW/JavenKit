//
//  JWPhotoBrowerItem.swift
//  JWCoreImageBrowser
//
//  Created by 朱建伟 on 2016/11/28.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

class JWPhotoBrowerItem: NSObject {
    
    var index:Int = 0
    
    //缩略图
    var thumbnail:UIImage?
    
    //大图
    var bigImage:UIImage?
    
    
    //完成回掉
    var thumbnailClosure:JWPhotoBrowserViewController.JWPhotoHanlderClosure?
    
    //完成回掉
    var bigImageClosure:JWPhotoBrowserViewController.JWPhotoHanlderClosure?
    
    
    //sourceFrame
    var sourceRect:CGRect?
     

}
