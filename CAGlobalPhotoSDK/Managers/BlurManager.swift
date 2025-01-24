//
//  BlurManager.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 23/06/23.
//

import UIKit

class BlurManager: NSObject {
    
    let circleImage = "circle.png"
    var mainImageView = CGRect()
    var circleView = CGRect()
    var optionalmage = UIImage()
    
    func buildResultImage(_ image: UIImage, withBlurImage blurImage: UIImage) -> UIImage {
        var result = blurImage
        result = circleBlurImage(image, withBlurImage: blurImage)
        return result
    }
    
    func circleBlurImage(_ image: UIImage, withBlurImage blurImage: UIImage) -> UIImage {
        let ratioWidth = image.size.width / mainImageView.size.width
        let ratioHeight = image.size.height / mainImageView.size.height
        var frame = circleView
        frame.size.width *= ratioWidth
        frame.size.height *= ratioWidth
        frame.origin.x *= ratioWidth
        frame.origin.y *= (ratioHeight)
        let mask = UIImage(named: circleImage)!
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        mask.draw(in: frame)
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return self.blurImage(image, withBlurImage: blurImage, andMask: maskedImage)
    }
    
    func blurImage(_ image: UIImage, withBlurImage blurImage: UIImage, andMask maskImage: UIImage) -> UIImage {
        var tmp = self.maskImage(image: image, withMask: maskImage)
        UIGraphicsBeginImageContext(blurImage.size)
        blurImage.draw(at: .zero)
        tmp.draw(in: CGRect(x: 0, y: 0, width: blurImage.size.width, height: blurImage.size.height))
        tmp = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return tmp
    }
    
    func maskImage(image: UIImage, withMask maskImage: UIImage) -> UIImage {
        let maskRef = maskImage.cgImage
        let mask = CGImage(
            maskWidth: maskRef!.width,
            height: maskRef!.height,
            bitsPerComponent: maskRef!.bitsPerComponent,
            bitsPerPixel: maskRef!.bitsPerPixel,
            bytesPerRow: maskRef!.bytesPerRow,
            provider: maskRef!.dataProvider!,
            decode: nil,
            shouldInterpolate: false)!
        let masked = image.cgImage!.masking(mask)!
        let maskedImage = UIImage(cgImage: masked)
        // No need to release. Core Foundation objects are automatically memory managed.
        return maskedImage

    }
}
