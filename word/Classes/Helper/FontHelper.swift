//
//  FontHelper.swift
//  nobody
//
//  Created by Lee on 2019/4/12.
//  Copyright © 2019 Lee. All rights reserved.
//

import UIKit

extension UIFont {
    convenience init(size: CGFloat) {
        self.init()
        UIFont.systemFont(ofSize: size)
    }
    
    static func medium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Medium", size: size)!
    }
    
    static func light(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Light", size: size)!
    }
    
    static func regular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Regular", size: size)!
    }
    
    static func thin(_ size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Thin", size: size)!
    }
}
