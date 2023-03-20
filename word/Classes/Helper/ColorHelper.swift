//
//  ColorHelper.swift
//  word
//
//  Created by 小红李 on 2023/3/20.
//

import UIKit

extension UIColor {
    convenience public init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
    convenience public init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1)
    }
    
    convenience public init(hexValue: Int) {
        self.init(hexValue: hexValue, alpha: 1)
    }
    
    convenience public init(hexValue: Int, alpha: CGFloat) {
        self.init(r: (CGFloat)((hexValue & 0xFF0000) >> 16), g: (CGFloat)((hexValue & 0xFF00) >> 8), b: (CGFloat)(hexValue & 0xFF), a: alpha)
    }
}

extension UIColor {
    static func buttonColor() -> UIColor {
        return #colorLiteral(red: 0.1921568627, green: 0.6470588235, blue: 0.5176470588, alpha: 1)
    }
    
    static func bgColor() -> UIColor {
        return #colorLiteral(red: 0.168627451, green: 0.1725490196, blue: 0.2509803922, alpha: 1)
    }
    static func lightenBgColor() -> UIColor {
        return #colorLiteral(red: 0.1921568627, green: 0.2, blue: 0.2823529412, alpha: 1)
    }
}
