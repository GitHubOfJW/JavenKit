//
//  JWPhotoBrowserViewController.swift
//  JWCoreImageBrowser
//
//  Created by 朱建伟 on 2016/11/28.
//  Copyright © 2016年 zhujianwei. All rights reserved.
//

import UIKit
 

public class JWPhotoBrowserViewController: UICollectionViewController,UIViewControllerTransitioningDelegate{

    let PBReuseIdentifier:String = "reuseIdentifier"
    
    
    //如果是图片直接调用  不是则下载完成后调用
   public typealias JWPhotoCompletionClosure = (UIImage?)->Void
    
    //图片获取
   public typealias JWPhotoHanlderClosure = ((Int,UIImageView,@escaping JWPhotoCompletionClosure) -> Void)
    
    //返回对应的View
   public  typealias JWPhotoSourceViewClosure = (Int)->((UIView?,UIImage?))?
    
    
    
    //数组
    var photoSource:[JWPhotoBrowerItem] = [JWPhotoBrowerItem]()
    
    //初始化
    convenience public init(photoCount:Int,showIndex:Int,thumbnailClosure:  @escaping JWPhotoHanlderClosure,bigImageClosure: @escaping JWPhotoHanlderClosure,sourceViewClosure:JWPhotoSourceViewClosure){
        
        
        //1.初始化布局
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = UIScreen.main.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        self.init(collectionViewLayout:layout)

        
        //2.创建
        self.photoSource.removeAll()
        for i:Int in 0..<photoCount
        {
            let  item = JWPhotoBrowerItem()
            
            item.index = i
            
            item.thumbnailClosure =  thumbnailClosure
            
            item.bigImageClosure = bigImageClosure
            
            if  let source =  sourceViewClosure(i){
                if let sourceView = source.0{
                    
                    let rect  = sourceView.convert(sourceView.bounds, to: UIApplication.shared.keyWindow)
                    
                    if rect.intersects(UIScreen.main.bounds){
                        item.sourceRect = rect
                    }
                    
                    //展示页相同
                    if i == showIndex{
                        self.presentTransitioning.sourceView = sourceView
                    }
                }
                
                if let sourceImage = source.1{
                    //展示页相同
                    if i == showIndex{
                        self.presentTransitioning.sourceImage = sourceImage
                    }
                }
           }
            
            self.photoSource.append(item)
        }
        
        self.collectionView?.isPagingEnabled = true
        self.collectionView?.backgroundColor = UIColor.clear
        collectionView?.reloadData()
        
        
        IndexPromptLabel.frame =  CGRect(x: 10, y: view.bounds.height - 50 , width:100, height: 40)
        IndexPromptLabel.textAlignment = NSTextAlignment.center
        IndexPromptLabel.layer.cornerRadius =  20
        IndexPromptLabel.backgroundColor = UIColor.black
        IndexPromptLabel.layer.masksToBounds = true
        
        let m_attr:NSMutableAttributedString = NSMutableAttributedString(string:String(format:"%zd",showIndex < photoCount ? showIndex + 1 : 1), attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 30),NSForegroundColorAttributeName:UIColor.white])
        
        self.lastAttributeString =  NSAttributedString(string: String(format:" / %zd",photoCount), attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 15),NSForegroundColorAttributeName:UIColor.white])
        
        m_attr.append(self.lastAttributeString!)
        
        IndexPromptLabel.attributedText = m_attr
        
        view.addSubview(IndexPromptLabel)
        
        
        if showIndex < photoCount{
            //滚动到指定的
            self.collectionView?.scrollToItem(at:IndexPath(item: showIndex, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
        
        }
        
       
    }
    
    private var  lastAttributeString:NSAttributedString?
    
    var IndexPromptLabel:UILabel = UILabel()
    
    
    
    var operationView:UIImageView = UIImageView()
    override public func viewDidLoad() {
        super.viewDidLoad()
        
 
        
        self.collectionView!.register(JWPhotoBrowserCell.self, forCellWithReuseIdentifier: PBReuseIdentifier)
        
        self.transitioningDelegate = self
        
        IndexPromptLabel.isHidden = true
        
    }
    

    
    

    
    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoSource.count
    }

    
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //1.获取cell
        let cell:JWPhotoBrowserCell = collectionView.dequeueReusableCell(withReuseIdentifier: PBReuseIdentifier, for: indexPath) as! JWPhotoBrowserCell
        
        //2.设置cell
        cell.photoBrowserItem =  photoSource[indexPath.item]
        
        weak var weakSelf =  self
        cell.dismissClosure = {
            (item,photoView)->Void in
            
            weakSelf?.dismissTapTransitioning.sourceView = photoView
            weakSelf?.dismissTapTransitioning.destinationFrame = item.sourceRect
            weakSelf?.dismissTapTransitioning.desinationImage = item.bigImage ?? item.thumbnail
            
            weakSelf?.dismiss(animated: true, completion: { 
                
            })
        }
        
        //3.返回
        return cell
    }
    
    
    
    override public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //1.获取cell
        let cell:JWPhotoBrowserCell = cell as! JWPhotoBrowserCell
        
        //2.
        cell.handler()
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("选中了：\(indexPath)")
    }
    
    override public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let page =  scrollView.contentOffset.x / scrollView.bounds.width
        
        let  showIndex:Int = lroundf(Float(page))+1
        
        let m_attr:NSMutableAttributedString = NSMutableAttributedString(string:String(format:"%zd",showIndex), attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 30),NSForegroundColorAttributeName:UIColor.white])
        
        m_attr.append(self.lastAttributeString!)
        
        IndexPromptLabel.attributedText = m_attr
    }
    
    override public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        IndexPromptLabel.isHidden =  false
         self.IndexPromptLabel.tag = 0
    }
    
    override public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if IndexPromptLabel.tag == 0{
            IndexPromptLabel.tag = 1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute:
                {
                    if self.IndexPromptLabel.tag == 1{
                    UIView.animate(withDuration: 0.25, animations: {
                        self.IndexPromptLabel.isHidden = true
                    }, completion: {(finished)->Void in
                         self.IndexPromptLabel.tag = 1
                    })
                    }else{
                        self.IndexPromptLabel.layer.removeAllAnimations()
                    }
            })
        }
    }
     
    private override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    //上下滑动退出
    var dismissTransitioning:JWPhotoDismissBrowserTransitioning =  JWPhotoDismissBrowserTransitioning()
    
    //点击后退出
    var dismissTapTransitioning:JWPhotoTapDismissTransioning =  JWPhotoTapDismissTransioning()
    
    //弹出
    var presentTransitioning:JWPhotoPresentBrowserTransitioning = JWPhotoPresentBrowserTransitioning()
    
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if self.interactionTransitioning.isStart{
            return dismissTransitioning
        }else{
            return dismissTapTransitioning
        }
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            return presentTransitioning
    }
    
    var interactionTransitioning:JWPhotoInteractiveTransitioning = JWPhotoInteractiveTransitioning()
    
     public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?{
          return self.interactionTransitioning.isStart ? self.interactionTransitioning : nil
    }
    
 
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        interactionTransitioning.addPopInteractiveTransition(browserViewController: self)
     
    }
     
    
}
