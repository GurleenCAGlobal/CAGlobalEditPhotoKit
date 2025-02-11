//
//  AMColorPickerSlider.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//

import UIKit

class AMColorPickerSlider: UISlider {

    @IBInspectable var sliderTopSpace: CGFloat = 0
    @IBInspectable var sliderSideSpace: CGFloat = 0
    @IBInspectable var sliderColor: UIColor = .clear
    
    override var bounds: CGRect {
        didSet {
            drawSlider()
        }
    }
    
    private let sliderLayer = CAGradientLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        initView()
    }
    
    private func initView() {
        self.maximumTrackTintColor = .clear
        self.minimumTrackTintColor = .clear
        
        let bundle = Bundle(for: AMColorPickerSlider.self)
        if let imagePath = bundle.path(forResource: "AMCP_slider_thumb@2x", ofType: "png") {
            setThumbImage(UIImage(contentsOfFile: imagePath), for: .normal)
        }
    }
    
    override func draw(_ rect: CGRect) {
        drawSlider()
    }
    
    private func drawSlider() {
        sliderLayer.removeFromSuperlayer()
        
        let height = frame.height - sliderTopSpace*2
        let width = frame.width - sliderSideSpace*2
        
        sliderLayer.frame = CGRect(x: sliderSideSpace, y: sliderTopSpace,
                                   width: width, height: height)
        sliderLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        sliderLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        sliderLayer.cornerRadius = 5.0
        sliderLayer.borderWidth = 2.0
        sliderLayer.borderColor = UIColor.gray.cgColor
        sliderLayer.backgroundColor = sliderColor.cgColor
        layer.insertSublayer(sliderLayer, at: 0)
    }
    
    func setGradient(startColor: UIColor, endColor: UIColor) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue,
                               forKey: kCATransactionDisableActions)
        
        sliderLayer.colors = [startColor.cgColor, endColor.cgColor]
        CATransaction.commit()
    }
}
