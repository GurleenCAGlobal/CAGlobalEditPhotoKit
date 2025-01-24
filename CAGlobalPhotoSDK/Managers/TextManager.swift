//
//  TextManager.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 26/06/23.
//

import UIKit

class TextManager: NSObject {
    func addText(delegate: UIViewController, textViewDetail: [Any], isTransform: Bool, transform: CGAffineTransform, tag: Int, alpha: CGFloat, textAlignment: NSTextAlignment) -> AddTextView {
        let frame = textViewDetail[0]
        let text = textViewDetail[1] as? String
        let font = textViewDetail[2]
        let color = textViewDetail[3]
        let customView = AddTextView(frame: frame as? CGRect ?? CGRectMake(0, 0, 0, 0)) 
        customView.delegate = delegate as? any AddTextViewDelegate
        customView.text = text ?? ""
        customView.font = font as? UIFont ?? UIFont.systemFont(ofSize: 10)
        customView.textColor = color as? UIColor
        customView.alpha = alpha
        customView.textAlignment = textAlignment
        customView.numberOfLines = 0
        if isTransform {
            customView.transform = CGAffineTransformIdentity
            customView.transform = transform
        }
        customView.tag = tag
        return customView
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }

}
