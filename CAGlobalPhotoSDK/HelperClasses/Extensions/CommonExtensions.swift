import UIKit
import Photos
import Accelerate


extension UIImageView {
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.alpha = 0.8
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
}

extension UIView {

    @IBInspectable private var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = newValue > 0
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable var circular: Bool {
        get {
            return false
        }
        set {
            if newValue {
                makeCircular()
            }
        }
    }

    func makeCircular() {
        layer.cornerRadius = min(self.frame.size.height, self.frame.size.width)/2
        layer.masksToBounds = true
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }

    func addShadow(
        shadowColor: CGColor = UIColor.black.cgColor,
        shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
        shadowOpacity: Float = 0.4,
        shadowRadius: CGFloat = 3.0
    ) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
}

extension UIImage {
    var uncompressedPNGData: Data { return self.pngData()! }
    var highestQualityJPEGNSData: Data { return self.jpegData(compressionQuality: 1.0)! }
    var highQualityJPEGNSData: Data { return self.jpegData(compressionQuality: 0.75)! }
    var mediumQualityJPEGNSData: Data { return self.jpegData(compressionQuality: 0.5)! }
    var lowQualityJPEGNSData: Data { return self.jpegData(compressionQuality: 0.25)! }
    var lowestQualityJPEGNSData: Data { return self.jpegData(compressionQuality: 0.0)! }

    func blurred(radius: CGFloat) -> UIImage {
        let ciContext = CIContext(options: nil)
        guard let cgImage = cgImage else { return self }
        let inputImage = CIImage(cgImage: cgImage)
        guard let ciFilter = CIFilter(name: "CIGaussianBlur") else { return self }
        ciFilter.setValue(inputImage, forKey: kCIInputImageKey)
        ciFilter.setValue(radius, forKey: "inputRadius")
        guard let resultImage = ciFilter.value(forKey: kCIOutputImageKey) as? CIImage else { return self }
        guard let cgImage2 = ciContext.createCGImage(resultImage, from: inputImage.extent) else { return self }
        return UIImage(cgImage: cgImage2)
    }

    func imageWithAlpha(alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPointZero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

    // MARK: - Masking
    func maskedImage(with maskImage: UIImage) -> UIImage? {
        guard let mask = maskImage.cgImage else { return nil }

        guard let masked = self.cgImage?.masking(mask) else {
            return nil
        }
        let result = UIImage(cgImage: masked)

        return result
    }

    func resize(_ size: CGSize) -> UIImage? {
        var width = Int(size.width)
        var height = Int(size.height)

        guard let imageRef = self.cgImage else { return nil }
        guard let colorSpaceInfo = imageRef.colorSpace else { return nil }
        let row = 4 * width
        let bitMapInf = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let bitmap: CGContext? = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: row, space: colorSpaceInfo, bitmapInfo: bitMapInf)

        if self.imageOrientation == .left || self.imageOrientation == .right {
            width = Int(size.height)
            height = Int(size.width)
        }

        if self.imageOrientation == .left || self.imageOrientation == .leftMirrored {
            bitmap?.rotate(by: CGFloat.pi / 2)
            bitmap?.translateBy(x: 0, y: -CGFloat(height))
        } else if self.imageOrientation == .right || self.imageOrientation == .rightMirrored {
            bitmap?.rotate(by: -CGFloat.pi / 2)
            bitmap?.translateBy(x: -CGFloat(width), y: 0)
        } else if self.imageOrientation == .up || self.imageOrientation == .upMirrored {
            // Nothing
        } else if self.imageOrientation == .down || self.imageOrientation == .downMirrored {
            bitmap?.translateBy(x: CGFloat(width), y: CGFloat(height))
            bitmap?.rotate(by: -CGFloat.pi)
        }

        bitmap?.draw(imageRef, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let ref = bitmap?.makeImage() else { return nil }
        let newImage = UIImage(cgImage: ref)

        return newImage
    }

    // MARK: - Blur
    func gaussBlur(blurLevel: CGFloat) -> UIImage? {
        let blurLevel = min(1.0, max(0.0, blurLevel))

        var boxSize = Int(blurLevel * 0.1 * min(self.size.width, self.size.height))
        boxSize = boxSize - (boxSize % 2) + 1

        guard let tmpImage = UIImage(data: self.jpegData(compressionQuality: 1)!) else { return nil }

        guard let img = tmpImage.cgImage else { return nil }

        var inBuffer = vImage_Buffer()
        var outBuffer = vImage_Buffer()

        let inProvider = img.dataProvider
        let inBitmapData = inProvider?.data
        inBuffer.width = vImagePixelCount(img.width)
        inBuffer.height = vImagePixelCount(img.height)
        inBuffer.rowBytes = img.bytesPerRow
        inBuffer.data = UnsafeMutableRawPointer(mutating: CFDataGetBytePtr(inBitmapData))

        let pixelBuffer = malloc(img.bytesPerRow * img.height)

        outBuffer.data = pixelBuffer
        outBuffer.width = vImagePixelCount(img.width)
        outBuffer.height = vImagePixelCount(img.height)
        outBuffer.rowBytes = img.bytesPerRow

        let windowR = boxSize / 2
        var sig2 = CGFloat(windowR) / 3.0
        if windowR > 0 {
            sig2 = -1 / (2 * sig2 * sig2)
        }

        var error: vImage_Error = kvImageNoError

        let kernel = UnsafeMutablePointer<Int16>.allocate(capacity: boxSize * MemoryLayout<Int16>.size)
        var sum: Int32 = 0
        for index in 0..<boxSize {
            kernel[index] = Int16(255 * exp(sig2 * CGFloat((index - windowR) * (index - windowR))))
            sum += Int32(kernel[index])
        }

        // convolution
        error = vImageConvolve_ARGB8888(&inBuffer, &outBuffer, nil, 0, 0, kernel, UInt32(boxSize), 1, sum, nil, vImage_Flags(kvImageEdgeExtend))

        vImageConvolve_ARGB8888(&outBuffer, &inBuffer, nil, 0, 0, kernel, 1, UInt32(boxSize), sum, nil, vImage_Flags(kvImageEdgeExtend))
        outBuffer = inBuffer

        free(kernel)

        if error != kvImageNoError {
            NSLog("error from convolution %ld", error.description)
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let ctx = CGContext(data: outBuffer.data,
                            width: Int(outBuffer.width),
                            height: Int(outBuffer.height),
                            bitsPerComponent: 8,
                            bytesPerRow: outBuffer.rowBytes,
                            space: colorSpace,
                            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)


        guard let imageRef = ctx?.makeImage() else { return nil }

        let returnImage = UIImage(cgImage: imageRef)
        free(pixelBuffer)
        return returnImage
    }
}
extension UIViewController {
    func showToast(message: String, duration: Double = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 100,
                                               y: self.view.frame.size.height-100,
                                               width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
}
extension UIColor {


    func hexStringToUIColor(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if cString.count != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }

    class var className: String {
        return String(describing: self)
    }
}

func SYSTEM_VERSION_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: .numeric) == ComparisonResult.orderedSame
}

func SYSTEM_VERSION_GREATER_THAN(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: .numeric) == ComparisonResult.orderedDescending
}

func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: .numeric) != ComparisonResult.orderedAscending
}

func SYSTEM_VERSION_LESS_THAN(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: .numeric) == ComparisonResult.orderedAscending
}

func SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: .numeric) != ComparisonResult.orderedDescending
}

func getCurrentIphone() -> String {
    var str = String()

    if UIDevice.current.userInterfaceIdiom == .phone {
        let screenHeight = UIScreen.main.nativeBounds.height

        switch screenHeight {
        case 1136:
            str = "iPhone 5 or 5S or 5C"
        case 1334:
            str = "iPhone 6, 6S, 7, 8"
        case 1920, 2208:
            str = "iPhone 6+, 6S+, 7+, 8+"
        case 2436:
            str = "iPhone X, XS, 11 Pro"
        case 1792:
            str = "iPhone XR, 11"
        case 2688:
            str = "iPhone XS Max, 11 Pro Max"
        case 2778:
            str = "iPhone 12 Pro Max"
        case 2532:
            str = "iPhone 12, 12 Pro"
        case 2340:
            str = "iPhone 12 mini"
        case 960:
            str = "Older iPad (not recommended to check like this)"
        default:
            str = "Unknown iPhone"
        }
    } else if UIDevice.current.userInterfaceIdiom == .pad {
        str = "iPad"
    }

    return str
}


func isPresentedModally(VC: UIViewController) -> Bool {
    let isPresented = VC.navigationController?.viewControllers.count == 1
    return isPresented
}

func isPhotoLibraryPermissionAllowed() -> Bool {
    return PHPhotoLibrary.authorizationStatus() == .authorized
}

func checkIfImageOrientationPortrait(image: UIImage) -> Bool {
    return image.size.height > image.size.width
}

extension CGSize {
    func sizeThatFitsSize(_ aSize: CGSize) -> CGSize {
        let width = min(self.width * aSize.height / self.height, aSize.width)
        return CGSize(width: width, height: self.height * width / self.width)
    }
}

func showAlertView(title: String, message: String) -> UIAlertController {
    let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    dialog.addAction(okAction)
    return dialog
}

extension UIImage {

    func withSaturationAdjustment(byVal: CGFloat) -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        guard let filter = CIFilter(name: "CIColorControls") else { return self }
        filter.setValue(CIImage(cgImage: cgImage), forKey: kCIInputImageKey)
        filter.setValue(byVal, forKey: kCIInputSaturationKey)
        guard let result = filter.value(forKey: kCIOutputImageKey) as? CIImage else { return self }
        guard let newCgImage = CIContext(options: nil).createCGImage(result, from: result.extent) else { return self }
        return UIImage(cgImage: newCgImage, scale: UIScreen.main.scale, orientation: imageOrientation)
    }

}

extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

extension UIImage {
//    func resizeImage(targetSize: CGSize) -> UIImage {
//        let size = self.size
//        let widthRatio  = targetSize.width  / size.width
//        let heightRatio = targetSize.height / size.height
//        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
//        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
//
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
//        self.draw(in: rect)
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return newImage!
//    }
}

// Define a function to get the pixel color at a specific point in the image
extension UIImage {
    func getPixelColor(xAxis: Int, yAxis: Int) -> UIColor? {
        guard let cgImage = cgImage,
              let pixelData = cgImage.dataProvider?.data,
              let data = CFDataGetBytePtr(pixelData) else {
            return nil
        }

        let width = cgImage.width
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let byteIndex = (bytesPerRow * yAxis) + (bytesPerPixel * xAxis)

        let red = CGFloat(data[byteIndex]) / 255.0
        let green = CGFloat(data[byteIndex + 1]) / 255.0
        let blue = CGFloat(data[byteIndex + 2]) / 255.0
        let alpha = CGFloat(data[byteIndex + 3]) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIView {
    func getPixelColorAt(point:CGPoint) -> UIColor{

        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

        context!.translateBy(x: -point.x, y: -point.y)
        layer.render(in: context!)
        let color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0,
                                    green: CGFloat(pixel[1])/255.0,
                                    blue: CGFloat(pixel[2])/255.0,
                                    alpha: 1)
        return color
    }
}

// Define a function to check if a UIColor is white
extension UIColor {
    func isWhite() -> Bool {
        var white: CGFloat = 0.0
        getWhite(&white, alpha: nil)
        return white >= 0.9 // Adjust the threshold as needed
    }
}


extension UIView {
    func showView() {
        self.isHidden = false
    }

    func hideView() {
        self.isHidden = true
    }
}

extension UIImage {
    func resizeSticker(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        return resizedImage
    }
}

extension NSCoding where Self: NSObject {
    static func unsecureUnarchived(from data: Data) -> Self? {
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            unarchiver.requiresSecureCoding = false
            let obj = unarchiver.decodeObject(of: self, forKey: NSKeyedArchiveRootObjectKey)
            if let error = unarchiver.error {
                print("Error:\(error)")
            }
            return obj
        } catch {
            print("Error:\(error)")
        }
        return nil
    }
}

extension String {

    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }

    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}

extension UIView {
    func loopViewHierarchy(block: (_ view: UIView, _ stop: inout Bool) -> ()) {
        var stop = false
        block(self, &stop)
        if !stop {
            self.subviews.forEach { $0.loopViewHierarchy(block: block) }
        }
    }
}
