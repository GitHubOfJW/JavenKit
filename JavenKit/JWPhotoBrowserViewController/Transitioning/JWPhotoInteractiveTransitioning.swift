//
//  JWPhotoInteractiveTransitioning.swift
//  JWCoreImageBrowser
//
//  Created by 朱建伟 on 2016/11/29.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit

class JWPhotoInteractiveTransitioning:UIPercentDrivenInteractiveTransition {

    private weak var browserVc:JWPhotoBrowserViewController?
    
    func addPopInteractiveTransition(browserViewController:JWPhotoBrowserViewController) {
        let pan:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(JWPhotoInteractiveTransitioning.handlerPanReg(pan:)))
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        //将传入的控制器保存，因为要利用它触发转场操作
        self.browserVc = browserViewController
        browserViewController.view.addGestureRecognizer(pan)
    }
    
    
    var  isStart:Bool = false
    //处理
    func handlerPanReg(pan:UIPanGestureRecognizer) {
        let translationY:CGFloat = pan.translation(in: pan.view).y
        
        let percent:CGFloat =  abs(translationY) / (((browserVc?.view.bounds.height)!))
        
//        print("translationY:\(translationY)")
        switch pan.state {
        case .changed://改变
            self.update(percent)
            //设置位置
            self.browserVc?.operationView.transform = CGAffineTransform(translationX: 0, y: translationY)
            break
        case .began://开始
            self.isStart = true
            
             
            //获取到oprationView
            if (self.browserVc?.collectionView?.visibleCells.count)! > 0{
                let cell:JWPhotoBrowserCell = self.browserVc!.collectionView?.visibleCells.first as! JWPhotoBrowserCell
                
                let rect:CGRect = cell.photoImageView.convert(cell.photoImageView.bounds, to: browserVc!.view)
                
                self.browserVc?.operationView.image = cell.photoImageView.image //cell.photoImageView.snapshotView(afterScreenUpdates:false)!
                
                self.browserVc?.operationView.frame =  rect
                
                self.browserVc?.view.addSubview((self.browserVc?.operationView)!)
            }
            
             self.browserVc?.collectionView?.isHidden = true
            
             self.browserVc?.dismiss(animated: true, completion: { 
                
             })
            
            break
        case .failed://结束 取消
            fallthrough
        case .cancelled:
            fallthrough
        case .ended:
            self.isStart = false
            if abs(translationY) >  ((browserVc?.view.bounds.height)!)/8
            {
                if let oprationView = self.browserVc?.operationView{
                    //默认向上滑动
                    var transform = CGAffineTransform(translationX: 0, y:-(browserVc?.view.bounds.height)!)// oprationView.frame.maxY
                
                    //下滑
                    if translationY > 0 {
                        transform =  CGAffineTransform(translationX: 0, y: (browserVc?.view.bounds.height)!)//(self.browserVc?.view.bounds.height)! - oprationView.frame.minY
                    }
                    
                    UIView.animate(withDuration: Double(self.duration * (1.0 - percent)), animations: {
                        oprationView.transform =  transform
                    }, completion: { (finished) in
                          oprationView.removeFromSuperview()
//                        self.browserVc?.collectionView?.isHidden = true
                    })
                }
                self.finish()
            }else{
                
                if let oprationView =  browserVc?.operationView {
                    UIView.animate(withDuration: Double(self.duration * (1.0 - percent)), animations: {
                        oprationView.transform = CGAffineTransform.identity
                    }, completion: { (finished) in
                        oprationView.removeFromSuperview()
                        self.browserVc?.collectionView?.isHidden = false
                    })
                }
                self.cancel()
            }
            break
        default:
            break
        }
    }
    
    
}
