//
//  AMColorPickerProtocol.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//


import UIKit

typealias Rgba = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
typealias Hsba = (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)
public protocol AMColorPicker: NSObject {
}

public protocol AMColorPickerDelegate: AnyObject {
    func colorPicker(_ colorPicker: AMColorPicker, didSelect color: UIColor, opacity: CGFloat)
}

extension UIColor {
    
    var rgba: Rgba {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red: red, green: green, blue: blue, alpha: alpha)
    }
    
    var hsba: Hsba {
        var hue:CGFloat = 0
        var saturation:CGFloat = 0
        var brightness:CGFloat = 0
        var alpha:CGFloat = 0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    var colorCode: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let rgb = (Int)(red*255)<<16 | (Int)(green*255)<<8 | (Int)(blue*255)<<0
        return String(format: "%06x", rgb)
    }
}

extension CGFloat {
    var colorFormatted: String {
        return String(format: "%.0f", self)
    }
}

extension Float {
    var colorFormatted: String {
        return String(format: "%.0f", self)
    }
}

public class XibLioadView: UIView {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }
    
    private func loadNib() {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let view = bundle.loadNibNamed(nibName, owner: self, options: nil)?.first as? UIView
        view?.frame = bounds
        view?.translatesAutoresizingMaskIntoConstraints = true
        view?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view!)
    }
}
