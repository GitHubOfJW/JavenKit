//
//  JWAutoScrollView.swift
//  CarServer
//
//  Created by 朱建伟 on 2016/10/18.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//
import Foundation
import UIKit

public protocol JWAutoScrollViewDelegate:NSObjectProtocol {
    
    //返回总个数
    func autoScrollViewNumberOfPage() -> Int
    //设置图片 直接返回按钮，由自己去操作
    func autoScrollView(autoScrollView:JWAutoScrollView,index:Int,imageButton:JWAutoScrollViewButton)
    //点击了选项
    func autoScrollView(autoScrollView:JWAutoScrollView,didSelectedItemAt itemIndex:Int)
    //停止滚动
    func autoScrollView(autoScrollView:JWAutoScrollView,didEndAnimationAt itemIndex:Int)
}


public class JWAutoScrollView: UIView,UIScrollViewDelegate {
    
    var bottomPrompt:String?{
        willSet{
            if let value = newValue{
                if value.compare("") != ComparisonResult.orderedSame{
                    bottomLabel?.isHidden = false
                    bottomLabel?.text = value
                    pageControl?.isHidden = true
                }else{
                    pageControl?.isHidden =  self.pageCount <= 1
                    bottomLabel?.text = ""
                    bottomLabel?.isHidden = true
                }
            }else{
                pageControl?.isHidden = self.pageCount <= 1
                bottomLabel?.text = ""
                bottomLabel?.isHidden = true
            }
        }
    }
    
    //状态
    var isScrolling:Bool = false
    
    private var timer:Timer?
    
    private var btnArray:[JWAutoScrollViewButton] = [JWAutoScrollViewButton]()
    
    private let expand:Int = 200
    
    private var preIndex = 0
    
    private var currentIndex = 0
    
    private var bottomLabel:UILabel?
    
    public weak var delegate:JWAutoScrollViewDelegate?{
        didSet{
            if self.superview != nil{
                if  self.delegate != nil{
                    self.reloadData()
                }
            }
        }
        
    }
    
    private var pageCount:Int = 0
    
    //scrollView
    private var bgScrollView:UIScrollView?
    
    //pageControl
    private var pageControl:UIPageControl?
    
    //初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        //初始化scrollView
        bgScrollView = UIScrollView()
        bgScrollView?.showsVerticalScrollIndicator =  false
        bgScrollView?.showsHorizontalScrollIndicator = false
        bgScrollView?.isDirectionalLockEnabled = true
        //        bgScrollView?.bounces =  false
        bgScrollView?.delegate = self
        
        bgScrollView?.addSubview(UIView(frame: CGRect()))
        
        for _ in 0...2{
            let imageView = JWAutoScrollViewButton()
            imageView.adjustsImageWhenHighlighted = false
            imageView.contentMode = UIViewContentMode.scaleAspectFill
            //            imageView.backgroundColor = UIColor.red
            imageView.imageView?.contentMode =  UIViewContentMode.scaleAspectFill
            imageView.tag = 0
            imageView.addTarget(self, action: #selector(JWAutoScrollView.itemBtnClick(btn:)), for: UIControlEvents.touchUpInside)
            bgScrollView?.addSubview(imageView)
            btnArray.append(imageView)
        }
        addSubview(bgScrollView!)
        
        //初始化pageConrol
        pageControl = UIPageControl()
        pageControl?.isEnabled = false
        pageControl?.isEnabled = false
        pageControl?.currentPage = 0;
        pageControl?.currentPageIndicatorTintColor = UIColor.orange
        pageControl?.pageIndicatorTintColor = UIColor.white
        addSubview(pageControl!)
        
        bottomLabel = UILabel()
        bottomLabel?.font = UIFont.systemFont(ofSize: 14)
        bottomLabel?.backgroundColor = UIColor.red//UIColor(red: (80/255.0), green: (80/255.0), blue: (80/255.0), alpha: 0.8);
        bottomLabel?.textAlignment = NSTextAlignment.center
        bottomLabel?.textColor = UIColor.white
        bottomLabel?.isHidden = true
        addSubview(bottomLabel!)
    }
    
    //点击了按钮
    internal func itemBtnClick(btn:JWAutoScrollViewButton) {
        
        bgScrollView?.isPagingEnabled =  true
        
        if  let d = delegate {
            d.autoScrollView(autoScrollView: self, didSelectedItemAt: btn.tag)
        }
    }
    
    //MARK:代理
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if pageCount<=1 {
            return
        }
        
        let page =  scrollView.contentOffset.x / scrollView.bounds.width
        
        let  index:Int = lroundf(Float(page))
        
        currentIndex  =  index
        
        pageControl?.currentPage = index%pageCount
        
        refreshData()
        
    }
    
    
    
    //开始拖拽
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        bgScrollView?.isPagingEnabled = true
        timerEnd()
    }
    
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        timerStart()
    }
    
    
    //定时开始
    func timerStart() {
        //低于1张不轮播
        if pageCount <= 1 {
            return
        }
        
        
        if timer == nil {
            timer =  Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(JWAutoScrollView.handler), userInfo:nil, repeats: true)
        }
    }
    
    //处理
    internal func handler(){
        bgScrollView?.isPagingEnabled = false
        currentIndex = currentIndex+1
        
        //判断越界
        if currentIndex >= expand * pageCount {
            
            currentIndex  =  expand*pageCount/2-1
            preIndex = currentIndex
            
            var index = 0
            for view:JWAutoScrollViewButton in btnArray{
                let x:CGFloat = CGFloat(index+currentIndex-1)*(bgScrollView?.bounds.width)!
                let w:CGFloat = (bgScrollView?.bounds.width)!
                let h:CGFloat = (bgScrollView?.bounds.height)!
                view.frame = CGRect(x: x, y: 0, width: w, height: h)
                index += 1
            }
            //归位
            bgScrollView?.setContentOffset(CGPoint(x:CGFloat(currentIndex)*(bgScrollView?.bounds.width)!,y:0), animated: false)
            currentIndex =  currentIndex + 1;
        }
        
        isScrolling = true
        bgScrollView?.setContentOffset(CGPoint(x:CGFloat(currentIndex)*(bgScrollView?.bounds.width)!,y:0), animated: true)
        
    }
    
    //定时结束
    func timerEnd() {
        //低于1张不轮播
        if pageCount <= 1 {
            return
        }
        
        if self.timer != nil{
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    
    //更细UI和数据
    internal func refreshData(){
        if  currentIndex > preIndex {//往后滑动
            if btnArray.count > 0 {
                let view:JWAutoScrollViewButton =  btnArray.first!
                let x:CGFloat =  CGFloat(currentIndex+1)*bgScrollView!.bounds.width
                
                
                btnArray.removeFirst()
                btnArray.append(view)
                
                
                
                if currentIndex <= expand * pageCount - 1 {
                    if let d =  delegate {
                        d.autoScrollView(autoScrollView: self, index: (currentIndex+1)%pageCount, imageButton: view)
                    }
                }
                
                //设置当前索引
                view.tag = (currentIndex+1)%pageCount
                view.frame = CGRect(x: x, y: 0, width: (bgScrollView!.bounds.width), height: (bgScrollView?.bounds.height)!)
                
                
            }
        }
        else if currentIndex < preIndex//往前滑动
        {
            
            if btnArray.count > 0 {
                let view:JWAutoScrollViewButton =  btnArray.last!
                let x:CGFloat =  CGFloat(currentIndex-1)*bgScrollView!.bounds.width
                
                btnArray.removeLast()
                btnArray.insert(view, at: 0)
                
                if currentIndex-1 >= 0 {
                    if let d =  delegate {
                        d.autoScrollView(autoScrollView: self, index: (currentIndex-1)%pageCount, imageButton: view)
                    }
                }
                
                //设置当前索引
                view.tag = (currentIndex-1)%pageCount
                view.frame = CGRect(x: x, y: 0, width: (bgScrollView!.bounds.width), height: (bgScrollView?.bounds.height)!)
                
                
            }
        }
        preIndex = currentIndex
    }
    
    //刷新
    func reloadData() {
        if let d =  delegate{
            self.pageControl?.isHidden = false
            let count:Int = d.autoScrollViewNumberOfPage()
            //0 就处理掉
            if  count <= 0 {
                if self.bottomPrompt != nil && self.bottomPrompt?.compare("") != ComparisonResult.orderedSame{
                    pageControl?.isHidden =  true
                }else{
                    pageControl?.isHidden = false
                }
                return
            }
            
            //低于1张不轮播
            if count > 1 {
                if self.bottomPrompt != nil && self.bottomPrompt?.compare("") != ComparisonResult.orderedSame{
                    pageControl?.isHidden =  true
                }else{
                    pageControl?.isHidden = false
                }
            }else
            {
                pageControl?.isHidden =  true
            }
            
            pageCount = count
            
            //设置页数
            pageControl?.numberOfPages = count
            
            if count <= 1{
                self.bgScrollView?.isScrollEnabled = false
            }else{
                self.bgScrollView?.isScrollEnabled = true
            }
            
            //初始化位置
            var index:Int = 0
            for  view:JWAutoScrollViewButton in btnArray
            {
                let tempIndex =  index+expand*pageCount/2-1
                let x:CGFloat = (bgScrollView?.bounds.width)! * CGFloat(tempIndex)
                let w:CGFloat = (bgScrollView?.bounds.width)!
                let h:CGFloat = (bgScrollView?.bounds.height)!
                
                if (pageCount == 1&&index != 1) {
                    view.frame  = CGRect(x: x, y: 0, width: w, height: h)
                    
                    index += 1
                    continue
                }
                
                
                view.frame  = CGRect(x: x, y: 0, width: w, height: h)
                 
                
                if let d =  delegate {
                    if (tempIndex % pageCount) < pageCount {
                        d.autoScrollView(autoScrollView: self, index: tempIndex%pageCount, imageButton: view)
                        //设置当前索引
                        view.tag = tempIndex%pageCount
                    }
                }
                
                
                index += 1
            }
            
            preIndex = expand * pageCount/2
            bgScrollView?.contentOffset = CGPoint(x: CGFloat(expand * pageCount/2) * (bgScrollView?.bounds.width)!, y: 0)
            
            bgScrollView?.contentSize = CGSize(width:CGFloat(expand * pageCount)*(bgScrollView?.bounds.width)!, height: (bgScrollView?.bounds.height)!)
            
            
            //开启定时
            timerStart()
        }
    }
    
    //停止滚动
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        isScrolling = false
        
        
        if pageCount<=1 {
            return
        }
        
        let page =  scrollView.contentOffset.x / scrollView.bounds.width
        
        let  index:Int = lroundf(Float(page))
        
        if  let d =  self.delegate{
            d.autoScrollView(autoScrollView: self, didEndAnimationAt:  index%pageCount)
        }
    }
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let bgScX:CGFloat = 0
        let bgScY:CGFloat = 0
        let bgScW:CGFloat = bounds.width
        let bgScH:CGFloat = bounds.height
        
        let flag:Bool =  (self.bgScrollView?.frame.equalTo(CGRect()))!
        
        self.bgScrollView?.frame = CGRect(x: bgScX, y: bgScY, width: bgScW, height: bgScH)
        
        
        let pageControlW:CGFloat = bounds.width
        let pageControlH:CGFloat = 30
        let pageControlX:CGFloat = (bounds.width - pageControlW)/2
        let pageControlY:CGFloat = (bounds.height - pageControlH)
        self.pageControl?.frame =  CGRect(x: pageControlX, y: pageControlY, width: pageControlW, height: pageControlH)
        
        
        let bottomW:CGFloat = bounds.width
        let bottomH:CGFloat = 25
        let bottomX:CGFloat = (bounds.width - bottomW)/2
        let bottomY:CGFloat = (bounds.height - bottomH)
        self.bottomLabel?.frame = CGRect(x: bottomX, y: bottomY, width: bottomW, height: bottomH)
        
        
        if flag {
            reloadData()
        }
    }
    
    
    override public func removeFromSuperview() {
        super.removeFromSuperview()
        timerEnd()
    }
    
    
}

public class JWAutoScrollViewButton: UIButton {
    override public func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return contentRect
    }
    
    override public func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return contentRect
    }
}

