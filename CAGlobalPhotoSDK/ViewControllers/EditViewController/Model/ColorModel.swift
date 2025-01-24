//
//  ColorModel.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/07/23.
//

import UIKit

class ColorModel: NSObject {
    // Index of the selected color in the color options
    var selectedColorIndex = -1
        
    // Flag indicating whether the selection is for color or font
    var isColor = false
    
    // The selected color for the text
    var color = UIColor.white
}
