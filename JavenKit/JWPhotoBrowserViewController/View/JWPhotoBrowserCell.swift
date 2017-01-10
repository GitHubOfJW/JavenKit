//
//  JWPhotoBrowserCell.swift
//  JWCoreImageBrowser
//
//  Created by 朱建伟 on 2016/11/28.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

class JWPhotoBrowserCell: UICollectionViewCell,UIScrollViewDelegate{
    
    //图片item
    var photoBrowserItem:JWPhotoBrowerItem?{
        
        willSet{
            
            self.photoImageView.backgroundColor = UIColor.orange
            
            self.setNeedsLayout()
        }
    }
    
    
    //bgScrollView
    let bgScrollView:UIScrollView = UIScrollView()
    
    
    //imageView
     let photoImageView:UIImageView = UIImageView()
    
    //加载中
    private let indicatorView:UIActivityIndicatorView = UIActivityIndicatorView()
 
    //双击放大缩小
   private var doubleTapReg:UITapGestureRecognizer!
    
    
   private var tapPoint:CGPoint =  CGPoint.zero
    
   private var isDobleClick:Bool = false
    
    //双击放大
    func handlerDoubleTapReg(reg:UITapGestureRecognizer) {
        
        self.tapPoint = reg.location(in: reg.view)
        
        //如果小于1.5
        if self.currentScale == self.bgScrollView.minimumZoomScale || self.currentScale < (bgScrollView.maximumZoomScale + bgScrollView.minimumZoomScale) / 2{
            isDobleClick = true
            self.bgScrollView.setZoomScale(self.bgScrollView.maximumZoomScale, animated: true)
        }else if  self.currentScale > (bgScrollView.maximumZoomScale + bgScrollView.minimumZoomScale) / 2 || self.currentScale == self.bgScrollView.maximumZoomScale
        {
            isDobleClick = false
            self.bgScrollView.setZoomScale(self.bgScrollView.minimumZoomScale, animated: true)
            
        }
        
    }
    
    
    var currentScale:CGFloat = 1
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
        self.currentScale =  scale
        
        isDobleClick =  false
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.photoImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //当捏或移动时，需要对center重新定义以达到正确显示未知
        let  xCenter:CGFloat = scrollView.contentSize.width > scrollView.bounds.width ? scrollView.contentSize.width/2:scrollView.center.x
        
        let  yCenter:CGFloat = scrollView.contentSize.height > scrollView.bounds.height ? scrollView.contentSize.height/2 : scrollView.center.y;
       
        //如果是双击 判断contentSize
        if isDobleClick{
            
            var offsetX:CGFloat = 0
            var offsetY:CGFloat = 0
            
            //宽度超出scrollView
            if scrollView.contentSize.width > scrollView.bounds.width{
                //根据坐标点计算偏移量
              
                offsetX =  tapPoint.x * bgScrollView.maximumZoomScale - scrollView.bounds.width/2
                
                //判断越界
                if offsetX > scrollView.contentSize.width - scrollView.bounds.width{
                    offsetX = scrollView.contentSize.width - scrollView.bounds.width
                }else if offsetX < 0{
                    offsetX = 0
                }
            }
            
            //高度超出scrollView
            if scrollView.contentSize.height > scrollView.bounds.height{
                //根据坐标点计算偏移量
                offsetY =  tapPoint.y * bgScrollView.maximumZoomScale - scrollView.bounds.height/2
                
                //判断越界
                if offsetY > scrollView.contentSize.height - scrollView.bounds.height{
                    offsetY = scrollView.contentSize.height - scrollView.bounds.height
                }else if offsetY < 0{
                    offsetY = 0
                }
            }
            self.bgScrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: false)
        }
        
        self.photoImageView.center = CGPoint(x:xCenter,y:yCenter)
    }
    
    
    //处理设置图片
    func handler() {
        
        self.indicatorView.stopAnimating()

        if let  item =  photoBrowserItem{
            
            if let closure = item.thumbnailClosure{
                self.indicatorView.startAnimating()
                closure(item.index, photoImageView, { (thumbnail) in
                    
                    item.thumbnail =  thumbnail
                    
                    self.hanlderPhotoImageView(image: thumbnail, isThumbnail: true)
                
                    
                    //设置大图
                    if let bigImageClosure  =  item.bigImageClosure{
                        
                        self.indicatorView.startAnimating()
                        
                        bigImageClosure(item.index, self.photoImageView, { (bigImage) in
                            self.hanlderPhotoImageView(image: bigImage, isThumbnail: false)
                        })
                    }
                    
                    //设置成缩略图
                    if let tb  = thumbnail{
                        self.photoImageView.image = tb
                    }
                })
            }
        }
    }
    
    
    
    //处理图片
    private func hanlderPhotoImageView(image:UIImage?,isThumbnail:Bool) {
        
        if isThumbnail{
            
            var imageW = bgScrollView.bounds.width
            var imageH = imageW
            
            if let thumbnail =  image{
                
                self.indicatorView.stopAnimating()
                
                self.photoImageView.image = thumbnail
                
                let imageSize =  thumbnail.size
                
                imageW = bgScrollView.bounds.width
                imageH = imageW / imageSize.width * imageSize.height
            }
            
            //图片高度比bgScrollView高
            if imageH > bgScrollView.bounds.height{
                
                bgScrollView.contentSize =  CGSize(width: imageW, height: imageH)
                bgScrollView.contentOffset = CGPoint(x: 0, y: (imageH - bgScrollView.bounds.height)/2)
                //设置x
                self.photoImageView.frame = CGRect(x:(bgScrollView.bounds.width -  imageW)/2, y: 0, width: imageW, height: imageH)
            }else{
                bgScrollView.contentSize = bgScrollView.bounds.size
                bgScrollView.contentOffset = CGPoint.zero
                //设置x
                self.photoImageView.frame = CGRect(x: (bgScrollView.bounds.width -  imageW)/2, y: (bgScrollView.bounds.height - imageH)/2, width: imageW, height: imageH)
            }
            
            
        }else{
             
            var imageW = bgScrollView.bounds.width
            var imageH = imageW

            
            if let bigImage =  image{
                
                self.photoImageView.image = bigImage
                
                self.indicatorView.stopAnimating()
                
                let imageSize =  bigImage.size
                
                imageW = bgScrollView.bounds.width
                imageH = imageW / imageSize.width * imageSize.height
            }
                
            //图片高度比bgScrollView高
            if imageH > bgScrollView.bounds.height{
                bgScrollView.contentSize =  CGSize(width: imageW, height: imageH)
                bgScrollView.contentOffset = CGPoint(x: 0, y: (imageH - bgScrollView.bounds.height)/2)
                //设置x
                self.photoImageView.frame = CGRect(x:(bgScrollView.bounds.width -  imageW)/2, y: 0, width: imageW, height: imageH)
            }else{
                bgScrollView.contentSize = bgScrollView.bounds.size
                bgScrollView.contentOffset = CGPoint.zero
                //设置x
                self.photoImageView.frame = CGRect(x: (bgScrollView.bounds.width -  imageW)/2, y: (bgScrollView.bounds.height - imageH)/2, width: imageW, height: imageH)
            }
        }
        self.bgScrollView.setZoomScale(bgScrollView.minimumZoomScale, animated: false)
        self.currentScale = bgScrollView.minimumZoomScale
     }
 
    
    //初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //底部的scrollView
        self.contentView.addSubview(bgScrollView)
        self.bgScrollView.backgroundColor = UIColor.clear
        self.bgScrollView.addSubview(photoImageView)
        self.bgScrollView.maximumZoomScale = 3
        self.bgScrollView.minimumZoomScale = 1
        self.bgScrollView.delegate = self
        
        self.currentScale =  1
        
        
        //加载中
        indicatorView.hidesWhenStopped = true
        indicatorView.tintColor = UIColor.orange
        self.contentView.addSubview(indicatorView)
        
        
        self.photoImageView.isUserInteractionEnabled = true
        self.photoImageView.contentMode = UIViewContentMode.scaleAspectFit
        self.photoImageView.clipsToBounds = true
        self.doubleTapReg = UITapGestureRecognizer(target: self, action: #selector(JWPhotoBrowserCell.handlerDoubleTapReg(reg:)))
        self.doubleTapReg.numberOfTapsRequired = 2
        self.doubleTapReg.numberOfTouchesRequired = 1
        self.photoImageView.addGestureRecognizer(self.doubleTapReg)
        
        
        
        self.contentView.layer.borderWidth = 5
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        
        let singleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(JWPhotoBrowserCell.handlerTap(tapReg:)))
        self.contentView.addGestureRecognizer(singleTap)
        
        singleTap.require(toFail: self.doubleTapReg)
    }

    
    var dismissClosure:((JWPhotoBrowerItem,UIView)->Void)?
    func handlerTap(tapReg:UITapGestureRecognizer) {
        if let closure =  dismissClosure{
            if let item = self.photoBrowserItem{
                closure(item,self.photoImageView)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.bgScrollView.frame = self.bounds
        
        self.indicatorView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        self.indicatorView.center = self.bgScrollView.center
        
        handler()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
