
//
//  LoadingView.swift
//  CarServer
//
//  Created by 朱建伟 on 2016/11/13.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

public class JWProgressHUDLoadingView: UIView {
    
    //当前类型
    var loadingType:JWProgressHUDType?{
        willSet{
            if let type = newValue{
                if type == .loading{
                    self.imageView.startAnimating()
                }else if type == .success{
                    self.imageView.stopAnimating()
                    imageView.image = Bundle.image(named:"success")!
                }else if type == .error{
                    self.imageView.stopAnimating()
                    imageView.image = Bundle.image(named:"error")!
                }else{
                    self.imageView.stopAnimating()
                }
            }else{
                
                self.imageView.stopAnimating()
            }
        }
    }
    
    //imageView
    private var imageView:UIImageView = UIImageView()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        
        imageView.animationImages = [Bundle.image(named:"loading1")!,Bundle.image(named:"loading2")!,Bundle.image(named:"loading3")!]
        imageView.animationDuration = 0.3
        imageView.animationRepeatCount =  10000
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let imageWH:CGFloat = self.bounds.width > self.bounds.height ? self.bounds.height : self.bounds.height
        
        let imageX:CGFloat = (self.bounds.width - imageWH)/2
        let imageY:CGFloat = (self.bounds.height - imageWH)/2
        imageView.frame = CGRect(x: imageX, y: imageY, width: imageWH, height: imageWH)
    }
}
