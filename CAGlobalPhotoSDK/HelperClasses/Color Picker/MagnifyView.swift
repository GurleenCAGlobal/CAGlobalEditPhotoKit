//
//  MagnifyView.swift
//  MagnifyingGlass
//
//  Created by Damidu Dasanayake on 6/29/18.
//  Copyright © 2018 Damidu Dasanayake. All rights reserved.
//

import UIKit

var magnifyBorderWidth = 3
var magnifyCornerRadius = 50
var magnifyImage = "magnifierFocus"
var magnifyTranslate = 0.5
var magnifyScale = 1.5

class MagnifyView: UIView {

    var viewToMagnify: UIView!
    var plusImageView: UIImageView!
    var touchPoint: CGPoint!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        // Set border color, border width and corner radius of the magnify view
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = CGFloat(magnifyBorderWidth)
        self.layer.cornerRadius = CGFloat(magnifyCornerRadius)
        self.layer.masksToBounds = true
        self.plusImageView = UIImageView(frame: CGRectMake(45, 45, 10, 10))
        self.plusImageView.image = UIImage.init(named: magnifyImage)
        self.addSubview(self.plusImageView)
    }
    
    func setTouchPoint(pt: CGPoint) {
        touchPoint = pt
        self.center = CGPoint(x: touchPoint.x, y: touchPoint.y)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 1 * (self.frame.size.width * magnifyTranslate), y: 1 * (self.frame.size.height * magnifyTranslate))
        context!.scaleBy(x: magnifyScale, y: magnifyScale)
        context!.translateBy(x: -1 * (self.center.x), y: -1 * (self.center.y))
        self.viewToMagnify.layer.render(in: context!)
    }

}
