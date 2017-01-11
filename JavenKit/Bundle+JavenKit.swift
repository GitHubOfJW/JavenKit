//
//  Bundle+JavenKit.swift
//  Pods
//
//  Created by 朱建伟 on 2017/1/11.
//
//

import UIKit

extension Bundle {

    class func image(named:String) -> UIImage? {
        let bundle = Bundle(path:Bundle(for: JWAutoScrollView.classForCoder()).path(forResource: "images", ofType: "bundle")!)
        
        let path = bundle?.path(forResource: named, ofType: "png")
        return UIImage(contentsOfFile: path!)
    }
}
