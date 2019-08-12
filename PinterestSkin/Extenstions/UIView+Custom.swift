//
//  UIView+Custom.swift
//  PinterestSkin
//
//  Created by Aman Thakur on 8/6/19.
//  Copyright © 2019 Aman Thakur. All rights reserved.
//

import UIKit

/// Extenion to set corner radius, can add other stuffs as well
extension UIView{
    func setCornerRadiusFor(cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
    }
    
    func setCornerRadius() {
        self.layer.cornerRadius = frame.size.width/2
        self.layer.masksToBounds = true
    }
}
