//
//  JWCalendarViewLayout.swift
//  KitDemo
//
//  Created by 朱建伟 on 2017/1/4.
//  Copyright © 2017年 zhujianwei. All rights reserved.
//

import UIKit

class JWCalendarViewLayout: UICollectionViewFlowLayout {
//
//    override func prepare() {
//        super.prepare()
//    }
//    
//    
//    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        return true
//    }
//    
//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        
//        let attr:UICollectionViewLayoutAttributes? =  super.layoutAttributesForItem(at: indexPath)
//        
//        if let attribute =  attr{
//            var frame = attribute.frame
//            
//            frame.origin.x = 150
//            
//            attribute.frame  = frame
//        }
//        
//        return attr
//    }
//    
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        
//        return super.layoutAttributesForElements(in: rect)
//        
//        if let m_attr =  super.layoutAttributesForElements(in: rect) {
//            for attr  in m_attr{
//                //遍历
//                if attr.representedElementCategory == .cell{
//                    attr.frame =  (self.layoutAttributesForItem(at:IndexPath(item:attr.indexPath.item + (attr.indexPath.section % 2 == 0 ? 4 : 6), section:attr.indexPath.section))?.frame)!
//                }
//                else if attr.representedElementCategory == .supplementaryView{
//                    attr.frame =  (self.layoutAttributesForSupplementaryView(ofKind: attr.representedElementKind!, at: attr.indexPath)?.frame)!
//                }
//            }
//            
//            return m_attr
//        }else{
//            return super.layoutAttributesForElements(in: rect)
//        }
//        
//    }
}
