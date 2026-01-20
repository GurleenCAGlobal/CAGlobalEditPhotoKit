//
//  BaseViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 23/06/23.
//

import UIKit
import Photos

public class BaseViewController: UIViewController {
    // MARK: - AdjustView Option Functionality -
    
    // Apply an effect to the image based on the selected option
    func setEffectOn(image: UIImage, effect: ImageOrientation2) -> UIImage {
        let orientation = image.imageOrientation
        let image = image.cgImage!
        if effect == .flip {
            // Flip effect
            switch orientation {
            case .up:
                return UIImage(cgImage: image, scale: 1.0, orientation: .downMirrored)
            case .downMirrored:
                return UIImage(cgImage: image, scale: 1.0, orientation: .up)
            case .upMirrored:
                return UIImage(cgImage: image, scale: 1.0, orientation: .down)
            case .down:
                return UIImage(cgImage: image, scale: 1.0, orientation: .upMirrored)
            default:
                return UIImage(cgImage: image, scale: 1.0, orientation: .up)
            }
        } else if effect == .rotate {
            // Rotate effect
            switch orientation {
            case .up:
                return UIImage(cgImage: image, scale: 1.0, orientation: .right)
            case .right:
                return UIImage(cgImage: image, scale: 1.0, orientation: .down)
            case .down:
                return UIImage(cgImage: image, scale: 1.0, orientation: .left)
            case .left:
                return UIImage(cgImage: image, scale: 1.0, orientation: .up)
            default:
                return UIImage(cgImage: image, scale: 1.0, orientation: .up)
            }
        } else {
            // Mirror effect
            switch orientation {
            case .up:
                return UIImage(cgImage: image, scale: 1.0, orientation: .upMirrored)
            case .upMirrored:
                return UIImage(cgImage: image, scale: 1.0, orientation: .up)
            case .down:
                return UIImage(cgImage: image, scale: 1.0, orientation: .downMirrored)
            case .downMirrored:
                return UIImage(cgImage: image, scale: 1.0, orientation: .down)
            case .right:
                return UIImage(cgImage: image, scale: 1.0, orientation: .up)
            default:
                return UIImage(cgImage: image, scale: 1.0, orientation: .upMirrored)
            }
        }
    }
    
    // Apply auto enhancement to the image

    func applyAutoEnhancement(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }

        // Parameters (similar to Kotlin)
        let brightness: Float = 0.1       // 10% boost (range -1 to 1)
        let contrast: Float = 1.15        // 15% boost
        let saturation: Float = 1.2       // 20% boost
        let temperature: Float = 30       // Range: -100 to +100

        // Apply brightness, contrast, saturation
        let colorControlsFilter = CIFilter(name: "CIColorControls")
        colorControlsFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        colorControlsFilter?.setValue(saturation, forKey: kCIInputSaturationKey)
        colorControlsFilter?.setValue(contrast, forKey: kCIInputContrastKey)
        colorControlsFilter?.setValue(brightness, forKey: kCIInputBrightnessKey)


        guard let colorAdjustedImage = colorControlsFilter?.outputImage else { return nil }

        // Apply temperature (white balance)
        let tempFilter = CIFilter(name: "CITemperatureAndTint")
        tempFilter?.setValue(colorAdjustedImage, forKey: kCIInputImageKey)

        guard let outputImage = tempFilter?.outputImage else { return nil }

        // Render final image
        let context = CIContext()
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }

        return nil
    }

    func autoEnhance(image: UIImage, all: Bool = false, isRedEye: Bool) -> UIImage? {
        if var ciImage = CIImage(image: image) {
            let dictionary = [CIImageAutoAdjustmentOption.redEye: isRedEye]
            var adjustments = ciImage.autoAdjustmentFilters(options: dictionary)
            if all {
                adjustments = ciImage.autoAdjustmentFilters()
            }
            for filter in adjustments {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                if let outputImage = filter.outputImage {
                    ciImage = outputImage
                }
            }
            let context = CIContext(options: nil)
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                let finalImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
                return finalImage
            }
        }
        return nil
    }
    
    // Captures the image from a given view
    func captureImageInView(inView: UIView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: inView.bounds.size)
        let image = renderer.image { _ in
            inView.drawHierarchy(in: inView.bounds, afterScreenUpdates: true)
        }
        
        let data = image.highestQualityJPEGNSData
        let iageHigh = UIImage(data: data)
        return iageHigh
    }
    
    func captureImageToSave(inView: UIView, rect: CGRect) -> UIImage? {
        let cgsize = CGSizeMake(rect.width, rect.height)
        let renderer = UIGraphicsImageRenderer(size: cgsize)
        let image = renderer.image { _ in
            inView.drawHierarchy(in: rect, afterScreenUpdates: true)
        }
        
        let data = image.highestQualityJPEGNSData
        let iageHigh = UIImage(data: data)
        return iageHigh
    }
    
    
    
    // Apply red-eye correction to the image
    func redEye(image: UIImage, isEnhance: Bool) -> UIImage? {
        if var ciImage = CIImage(image: image) {
            let dictionary = [CIImageAutoAdjustmentOption.enhance: isEnhance]
            let adjustments = ciImage.autoAdjustmentFilters(options: dictionary)
            
            for filter in adjustments {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                if let outputImage = filter.outputImage {
                    ciImage = outputImage
                }
            }
            let context = CIContext(options: nil)
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                let finalImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
                return finalImage
            }
        }
        return nil
    }
    
    // Calculate the height required for a given text with a specific font and width
    func heightForText(text: String, font: UIFont, maxWidth: CGFloat) -> CGSize {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()

        // Return the actual size it fits in
        return label.bounds.size
    }

    
    // Get the rotation value from a given transform
    func rotation(from transform: CGAffineTransform) -> Double {
        return atan2(Double(transform.b), Double(transform.a))
    }
    
    func overlayImageWithAspectFill(image: UIImage?, in areaSize: CGSize) -> UIImage? {
        guard let image = image else {
            return nil
        }
        
        let imageSize = image.size
        let targetSize = CGSize(width: areaSize.width, height: areaSize.height)
        let scaleFactor = max(targetSize.width / imageSize.width, targetSize.height / imageSize.height)
        let scaledSize = CGSize(width: imageSize.width * scaleFactor, height: imageSize.height * scaleFactor)
        let origin = CGPoint(x: (targetSize.width - scaledSize.width) / 2, y: (targetSize.height - scaledSize.height) / 2)
        let targetRect = CGRect(origin: origin, size: scaledSize)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        image.draw(in: targetRect)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return resultImage
    }
    
    func temperature(_ image: UIImage, byVal: CGFloat) -> UIImage {
        let filter = CIFilter(name: "CITemperatureAndTint")
        let sourceImage = CIImage(image: image)
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)
        filter?.setValue(CIVector(x: byVal + 6500, y: 0), forKey: "inputNeutral")
        filter?.setValue(CIVector(x: 6500, y: 0), forKey: "inputTargetNeutral") // Default value: [6500, 0] Identity: [6500, 0]
        let output = filter?.outputImage
        let outputCGImage = CIContext().createCGImage(output!, from: output!.extent)!
        let filteredImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        return filteredImage
    }
    func increaseSaturation(_ image: UIImage, byVal: CGFloat) -> UIImage {
        let filter: CIFilter? = CIFilter(name: "CIColorControls")
        let sourceImage = CIImage(image: image)
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)
        filter?.setValue(byVal, forKey: kCIInputSaturationKey)
        let output = filter?.outputImage
        let outputCGImage = CIContext().createCGImage(output!, from: output!.extent)!
        let filteredImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        return filteredImage
    }
    func increaseContrast(_ image: UIImage, byVal: CGFloat) -> UIImage {
        let filter: CIFilter? = CIFilter(name: "CIColorControls")
        let sourceImage = CIImage(image: image)
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)
        filter?.setValue(byVal, forKey: kCIInputContrastKey)
        let output = filter?.outputImage
        let outputCGImage = CIContext().createCGImage(output!, from: output!.extent)!
        let filteredImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        return filteredImage
    }
    func increaseBrightness(for image: UIImage, byVal: CGFloat) -> UIImage {
        let filter: CIFilter? = CIFilter(name: "CIColorControls")
        let sourceImage = CIImage(image: image)
        filter?.setValue(sourceImage, forKey: kCIInputImageKey)
        filter?.setValue(byVal, forKey: kCIInputBrightnessKey)
        let output = filter?.outputImage
        let outputCGImage = CIContext().createCGImage(output!, from: output!.extent)!
        let filteredImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        return filteredImage
    }
    func increaseExposure(for image: UIImage, byVal: CGFloat) -> UIImage {
        let ciContext = CIContext(options: nil)
        var coreImage = CIImage()
        coreImage = image.ciImage!
        
        let filter = CIFilter(name: "CIExposureAdjust")
        filter?.setValue(byVal, forKey: kCIInputEVKey)
        filter?.setValue(coreImage, forKey: kCIInputImageKey)
        
        var filteredImage = UIImage()
        if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            let cgimgresult = ciContext.createCGImage(output, from: output.extent)
            filteredImage = UIImage(cgImage: cgimgresult!)
        } else {
            print("image filtering failed")
        }
        return filteredImage
    }
    
    // CreateCollageViewController methods
    func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    func getImagesFromAssets(selectedAssetsIDArray:[String]) -> [UIImage] {
        var imageArray = [UIImage]()
        let imageManager = PHImageManager()
        // Get images in for loop as the images we are gettings from selAssetsIdentifiersArray's URLs, are automatically sorted by date
        for url in selectedAssetsIDArray {
            let assetsFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [url], options: nil)
            assetsFetchResult.enumerateObjects{(object: AnyObject!,
                                                _: Int,
                                                _: UnsafeMutablePointer<ObjCBool>) in
                if object is PHAsset{
                    let asset = object as? PHAsset
                    let imageSize = CGSize(width: asset?.pixelWidth ?? 0,
                                           height: asset?.pixelHeight ?? 0)
                    let options = PHImageRequestOptions()
                    options.deliveryMode = .opportunistic
                    options.isSynchronous = true
                    options.isNetworkAccessAllowed = true
                    imageManager.requestImage(for: asset!,
                                              targetSize: imageSize,
                                              contentMode: .aspectFill,
                                              options: options,
                                              resultHandler:
                                                {
                        (image, _) -> Void in
                        if let recievedImage = image {
                            /* The image is now available to us */
                            imageArray.append(recievedImage)
                        } else {
                            var imageSize = 1000.0
                            var loopCount = 5
                            for _ in 0..<loopCount {
                                imageManager.requestImage(for: asset!,
                                                          targetSize: CGSize(width: imageSize, height: imageSize),
                                                          contentMode: PHImageContentMode.aspectFit,
                                                          options: options,
                                                          resultHandler:
                                                            { image, _ in
                                    if let recievedImage = image {
                                        /* The image is now available to us */
                                        imageArray.append(recievedImage)
                                        loopCount = 0
                                    }
                                })
                                imageSize -= 200
                            }
                        }
                    })
                }
            }
        }
        return imageArray
    }
    
    //TextViewController methods
    func addBlurBackgroundEffect(view: UIView) {
        // Add a blur effect to the background
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.alpha = 0.4
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.insertSubview(blurEffectView, at: 0)
    }

    func sizeForView(text: String, font: UIFont, maxSize: CGSize? = nil, forTransform: Bool = false, padding: CGFloat = 20.0) -> (CGSize, Bool) {
        // Create an instance of the custom PaddedLabel
        let label = PaddedLabel()
        label.padding = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding) // Set padding values for left and right
        label.numberOfLines = 0
        label.textAlignment = .left // Adjust alignment as needed
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text

        // Check for maximum size constraints
        if let maxSize = maxSize {
            // Constrain to maxSize if provided
            label.frame = CGRect(x: 0, y: 0, width: maxSize.width, height: maxSize.height)
            label.sizeToFit()

            // Adjust width and height based on padding and maxSize
            let width = min(label.frame.width, maxSize.width) + label.padding.left + label.padding.right
            let height = min(label.frame.height, maxSize.height) + label.padding.top + label.padding.bottom

            // Ensure that the label fits within the max size
            if height > (maxSize.height - padding) {
                return (CGSize(width: width, height: height), false)
            }

            // Return the size with padding applied
            return (CGSize(width: width, height: height), true)
        } else {
            // No max size, dynamically calculate size
            label.sizeToFit()
            let width = label.frame.width + label.padding.left + label.padding.right
            let height = label.frame.height + label.padding.top + label.padding.bottom

            // Apply padding for transform scenario
            if forTransform {
                return (CGSize(width: width, height: height), false)
            }

            // Return the size with padding applied normally
            return (CGSize(width: width, height: height), true)
        }
    }


    
//    func sizeForView(text: String, font: UIFont, maxSize: CGSize) -> (CGSize,Bool) {
//        
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: maxSize.width, height: maxSize.height))
//        label.numberOfLines = 0
//        label.lineBreakMode = .byWordWrapping
//        label.font = font
//        label.text = text
//        label.sizeToFit()
//        let width = min(label.frame.width, maxSize.width)
//        let height = min(label.frame.height, maxSize.height)
//        
//        if label.frame.size.height > (maxSize.height - 20) {
//            return (CGSize(width:  width, height: height),false)
//        }
//        return (CGSize(width:  width, height: height),true)
//    }
//    func sizeForViewText(text: String, font: UIFont) -> (CGSize, Bool) {
//        let label = UILabel()
//        label.numberOfLines = 0
//        label.lineBreakMode = .byWordWrapping
//        label.font = font
//        label.text = text
//        label.sizeToFit()
//
//        let width = label.frame.width
//        let height = label.frame.height
//
//        if label.frame.size.height > 20 {
//            return (CGSize(width: width, height: height), false)
//        }
//        return (CGSize(width: width, height: height), true)
//    }


    
}

class PaddedLabel: UILabel {
    var padding = UIEdgeInsets.zero

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: padding)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let width = size.width + padding.left + padding.right
        let height = size.height + padding.top + padding.bottom
        return CGSize(width: width, height: height)
    }
}
