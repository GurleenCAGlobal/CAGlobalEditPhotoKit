//
//  FrameCategoryModel.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/05/23.
//

import Foundation

class FrameCategoryModel: NSObject {
    var categoryName:String?
    var categoryIcon:String?
    var frameList:[FrameModel]?
}

class FrameModel: NSObject {
    var frame: Any? // Replace Any with the appropriate type for your frames
    var opacity: CGFloat

    init(frame: Any?, opacity: CGFloat) {
        self.frame = frame
        self.opacity = opacity
    }
}

 
