//
//  CanvasRatioManager.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//


import Foundation
import UIKit

@objc class CanvasRatioManager: NSObject {
    
    // MARK: - Properties
    
    @objc static let shared = CanvasRatioManager()
    var printerWidth = 2.0447   // print head width in inches
    var printerDPI = 500
    var paperWidth = 1.9567    // nominal paper width inches ( used for preview windowing )

    override init() {
        super.init()
    }
    
    func getSizeAccordingPrintWidth(ratio:CGFloat) -> CGSize {
        let tempOutputHeight = round(CGFloat(printerDPI) * ratio)
        let tempOutputWidth = round(tempOutputHeight * printerWidth / ratio)
        return CGSize(width: tempOutputWidth, height: tempOutputHeight)
    }
    
    func getAspectRatioAccordingPrintWidth(ratio:CGFloat) -> CGFloat {
        let tempOutputHeight = round(CGFloat(printerDPI) * ratio)
        let tempOutputWidth = round(tempOutputHeight * printerWidth / ratio)

        var ratio = 0.0
        if tempOutputHeight > tempOutputWidth {
            ratio = (((tempOutputHeight/tempOutputWidth) * 2) * 10) / 10.0
        } else {
            ratio = (((tempOutputWidth/tempOutputHeight) * 2) * 10) / 10.0
        }
        return ratio
    }
    
    func newGetImageAccordingPrintRatio(image:UIImage, ratio:CGFloat) -> (UIImage) {
        var image = image
        let tempOutputHeightPreview = round(CGFloat(printerDPI) * ratio)
        let tempOutputWidthPreview = round(tempOutputHeightPreview * printerWidth / ratio)
        var newSize = CGSize()
        var tempIsLandscape = false
        
        if image.size.width > image.size.height {
            tempIsLandscape = true
        } else {
            tempIsLandscape = false
        }
        
        if tempIsLandscape == true {
            image = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .right)
        }

        newSize = CGSize(width: tempOutputHeightPreview, height: tempOutputWidthPreview)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if tempIsLandscape {
            newImage = UIImage(cgImage: newImage!.cgImage!, scale: 1.0, orientation: .left)
        }
        
        return newImage!
    }
    
    @objc func getImageAccordingPrintRatio(image:UIImage, ratio:CGFloat) -> UIImage {
        var image = image
        let tempOutputHeightPreview = round(CGFloat(printerDPI) * ratio)
        let tempOutputWidthPreview = round(tempOutputHeightPreview * printerWidth / ratio)
        var newSize = CGSize()
        var tempIsLandscape = false

        if image.size.width > image.size.height {
            tempIsLandscape = true
        } else {
            tempIsLandscape = false
        }
        
        if tempIsLandscape == true {
            image = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .right)
        }

        newSize = CGSize(width: tempOutputWidthPreview, height: tempOutputHeightPreview)
       UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        

        if tempIsLandscape {
            newImage = UIImage(cgImage: newImage!.cgImage!, scale: 1.0, orientation: .left)
        }
        
        if newImage!.getSizeInMB() > 9.0 {
            newImage = resizeAndCompressImage(image: newImage!, maxSizeKB: 9216)
        }
        return newImage!
    }
    
    func resizeAndCompressImage(image: UIImage, maxSizeKB: Int) -> UIImage? {        
        let maxBytes = maxSizeKB * 1024  // Convert KB to bytes
        var compression: CGFloat = 1.0   // Initial compression quality
        
        guard var compressedData = image.jpegData(compressionQuality: compression),
              compressedData.count > maxBytes else {
            return image  // Return original image if already within size limit
        }
        
        while compressedData.count > maxBytes && compression > 0 {
            compression -= 0.1
            if let newCompressedData = image.jpegData(compressionQuality: compression) {
                compressedData = newCompressedData
            }
        }
        
        return UIImage(data: compressedData)
    }
}
extension UIImage {
    func getSizeInMB() -> Double {
        if let imageData = self.jpegData(compressionQuality: 1.0) {
            let imageSizeInBytes = Double(imageData.count)
            let imageSizeInMB = imageSizeInBytes / (1024 * 1024) // Convert bytes to MB
            return imageSizeInMB
        }
        return 0.0
    }
}
