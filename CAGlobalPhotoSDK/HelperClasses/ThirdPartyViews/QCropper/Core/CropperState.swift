//
//  CropperState.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//

import UIKit

public struct CropperState: Codable {
    var viewFrame: CGRect
    var angle: CGFloat
    var rotationAngle: CGFloat
    var straightenAngle: CGFloat
    var flipAngle: CGFloat
    var imageOrientationRawValue: Int
    var scrollViewTransform: CGAffineTransform
    var scrollViewCenter: CGPoint
    var scrollViewBounds: CGRect
    var scrollViewContentOffset: CGPoint
    var scrollViewMinimumZoomScale: CGFloat
    var scrollViewMaximumZoomScale: CGFloat
    var scrollViewZoomScale: CGFloat
    var cropBoxFrame: CGRect
    var photoTranslation: CGPoint
    var imageViewTransform: CGAffineTransform
    var imageViewBoundsSize: CGRect
    var imageCenter: CGPoint
    var isFlip: Bool
    var isMirror: Bool
}
