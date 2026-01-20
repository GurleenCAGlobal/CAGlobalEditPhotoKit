//
//  EditOptions.swift
//  CAPhotoEditor
//
//  Created by Gurleen Singh on 22/03/23.
//

import UIKit

class EditOptions: NSObject {
    
    // Boolean flags
    var isBlank = false
    var isAuto = false
    var isAutoInAdjust = false
    var isRedEye = false
    var isTransform = false
    var isTransformActual = false
    var isText = false
    var isOverlay = false
    var isBlur = false
    var isBlurActual = false
    var isSticker = false
    var isFilter = false
    var isFrames = false
    var isFramesSelected = false
    var isAdjust = false
    var isBrush = false
    
    var imageDetail = [(imageView:UIImageView, frame: CGRect?, color: UIColor?, transform: CGAffineTransform?, opacity: CGFloat?)]()

    // Store text label details: textView, text, frame, font, fontIndex, color, colorIndex, transform
    var textDetail = [(
        txtVw: AddTextView,
        text: String?,
        frame: CGRect?,
        center: CGPoint?,
        trnf: CGAffineTransform?,
        font: UIFont?,
        index: Int?,
        color: UIColor?,
        colorIn: Int?,
        previousColor: UIColor?,
        previousColorIndex: Int?,
        bcolor: UIColor?,
        bcolorIn: Int?,
        previousbColor: UIColor?,
        previousbColorIndex: Int?,
        slider: CGFloat?,
        opacity: CGFloat?,
        textAlignment: NSTextAlignment?,
        fontCustom: String?,
        previousfont: String?,
        textString: String?,
        previousTextString: String?,
        selectedFontIndex: Int?,
        selectedPreviousFontIndex: Int?)]()

    // Store sticker label details: sticker, stickerName, frame, color, colorIndex, transform
    var stickerDetail = [(sticker: AddSticker?,
                          trns: CGAffineTransform,
                          frame: CGRect?,
                          cnter: CGPoint?,
                          orntn: String?,
                          isSticker: Bool?,
                          color: UIColor?,
                          image: UIImage?,
                          stickerName: String?,
                          straightenAngle: CGFloat?,
                          rotationAngle: CGFloat?,
                          alpha: CGFloat?,
                          flipAngle: CGFloat?)]()
    
    // Store overlay name and opacity for overlay
    var appliedOverlayDetails = [(overlayName: String, opacityValue: CGFloat)]()

    // Store overlay name and opacity for overlay
    var appliedFramesDetails = [(framesName: Any, opacityValue: CGFloat, imageOrientation: UIImage.Orientation?, isRotate_new: Bool, isAspect: Bool)]()

    // Store filter name and opacity for filter
    var appliedFilterDetails = [(filterName: String, opacityValue: CGFloat)]()

    var appliedBlurDetails = [CGRect]()
    
    var appliedBrushDetails = [TouchPointsAndColor]()
    var removedBrushDetails = [TouchPointsAndColor]()
    var selectedBrushColorIndex = 0
    var savedBrushColorIndex = 0

    
    
}
