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

extension String
{
    func localisedString() -> String
    {
        return NSLocalizedString(self, comment: "")
    }
}


//new extension hp500

// MARK: - NSLayoutConstraint

fileprivate extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }

    func withIdentifier(_ identifier: String) -> NSLayoutConstraint {
        self.identifier = identifier
        return self
    }
}



extension UIColor {
    @objc static let destructiveDarkButtonColor = UIColor(red: 79/255, green: 78/255, blue: 78/255, alpha: 1)
    @objc static let destructiveDarkBorderedButtonColor = UIColor(red: 144/255, green: 143/255, blue: 143/255, alpha: 1)
    @objc static let lineSeparatorColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1)
    @objc static let titleColor = UIColor(red: 42/255, green: 42/255, blue: 42/255, alpha: 1)
    @objc static let messageColor = UIColor(red: 77/255, green: 77/255, blue: 77/255, alpha: 1)
    @objc static let alertbuttonColor = UIColor(red: 0/255, green: 150/255, blue: 214/255, alpha: 1)
    @objc static let destructiveButtonColor = UIColor(red: 255/255, green: 88/255, blue: 88/255, alpha: 1)
    @objc static let lastOptionButtonColor = UIColor(red: 243/255, green: 244/255, blue: 245/255, alpha: 1)
    @objc static let grayedButtonColor = UIColor(red: 139/255, green: 139/255, blue: 139/255, alpha: 1)
}


extension UIImageView {

    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

    @available(iOS 9.0, *)
    public func loadGif(asset: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(asset: asset)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

}
extension UIImage {

    public class func gif(data: Data) -> UIImage? {
        // Create source from data
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            //print("SwiftGif: Source for the image does not exist")
            return nil
        }

        return UIImage.animatedImageWithSource(source)
    }

    public class func gif(url: String) -> UIImage? {
        // Validate URL
        guard let bundleURL = URL(string: url) else {
            //print("SwiftGif: This image named \"\(url)\" does not exist")
            return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            //print("SwiftGif: Cannot turn image named \"\(url)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    public class func gif(name: String) -> UIImage? {
        // Check for existance of gif
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                //print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }

        // Validate data
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            //print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }

        return gif(data: imageData)
    }

    @available(iOS 9.0, *)
    public class func gif(asset: String) -> UIImage? {
        // Create source from assets catalog
        guard let dataAsset = NSDataAsset(name: asset) else {
            //print("SwiftGif: Cannot turn image named \"\(asset)\" into NSDataAsset")
            return nil
        }

        return gif(data: dataAsset.data)
    }

    internal class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1

        // Get dictionaries
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
            return delay
        }

        let gifProperties: CFDictionary = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)

        // Get delay time
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }

        if let delayObject = delayObject as? Double, delayObject > 0 {
            delay = delayObject
        } else {
            delay = 0.1 // Make sure they're not too fast
        }

        return delay
    }

    internal class func gcdForPair(_ lhs: Int?, _ rhs: Int?) -> Int {
        var lhs = lhs
        var rhs = rhs
        // Check if one of them is nil
        if rhs == nil || lhs == nil {
            if rhs != nil {
                return rhs!
            } else if lhs != nil {
                return lhs!
            } else {
                return 0
            }
        }

        // Swap for modulo
        if lhs! < rhs! {
            let ctp = lhs
            lhs = rhs
            rhs = ctp
        }

        // Get greatest common divisor
        var rest: Int
        while true {
            rest = lhs! % rhs!

            if rest == 0 {
                return rhs! // Found it
            } else {
                lhs = rhs
                rhs = rest
            }
        }
    }

    internal class func gcdForArray(_ array: [Int]) -> Int {
        if array.isEmpty {
            return 1
        }

        var gcd = array[0]

        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }

        return gcd
    }

    internal class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()

        // Fill arrays
        for index in 0..<count {
            // Add image
            if let image = CGImageSourceCreateImageAtIndex(source, index, nil) {
                images.append(image)
            }

            // At it's delay in cs
            let delaySeconds = UIImage.delayForImageAtIndex(Int(index), source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }

        // Calculate full duration
        let duration: Int = {
            var sum = 0

            for val: Int in delays {
                sum += val
            }

            return sum
        }()

        // Get frames
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()

        var frame: UIImage
        var frameCount: Int
        for index in 0..<count {
            frame = UIImage(cgImage: images[Int(index)])
            frameCount = Int(delays[Int(index)] / gcd)

            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }

        // Heyhey
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)

        return animation
    }

}



fileprivate extension UIDevice {
    static let isIpad: Bool = UIDevice.current.userInterfaceIdiom == .pad ? true : false


}
// MARK: - AlertActionType

@objc enum PNAlertActionType: Int {
    case plain = 0
    case borderd = 1
    case bold = 2
    case boldGrayed = 3
    case destructiveBordered = 4
    case destructiveBold = 5
    case checkmark = 6
    case lastOption = 7
    case borderedRed = 8
    case seperator = 9
}

// MARK: - AlertActionType

@objc enum PNAlertActionFillMode: Int {
    case quater = 0
    case half = 1
    case threeQuaters = 2
    case fourByFive = 4
    case full = 3
}

// MARK: - Type Alias

typealias PNAlertActionHandler = ((PNAlertAction, Bool) -> Void)


// MARK: - AlertAction

@objc class PNAlertAction: NSObject {

    // MARK: - Variables

    var title: String?
    var type: PNAlertActionType = .plain
    @objc var buttonFillMode: PNAlertActionFillMode = .full
    @objc var shouldDismissAlertWithAction: Bool = true


    // MARK: - Initializers

    @objc init(title: String, type: PNAlertActionType, handler: PNAlertActionHandler? = nil) {
        self.title = title
        self.type = type
        self.actionHandler = handler
    }


    // MARK: - Closures

    @objc private var actionHandler: PNAlertActionHandler?


    // MARK: - Custom Functions

    @objc fileprivate func alertAction(checkmark isSelected: Bool) {
        self.actionHandler?(self, isSelected)
    }

    @objc class func actionWith(title: String, handler: PNAlertActionHandler? = nil) -> PNAlertAction {
        let action = PNAlertAction(title: title, type: .plain, handler: handler)
        return action
    }

}

@objc class PNAlertController: UIViewController {


    // MARK: - UI Elements

    private let popupView: UIView = {
        let o = UIView()
        o.translatesAutoresizingMaskIntoConstraints = false
        o.backgroundColor = .white
        o.layer.cornerRadius = 3
        return o
    }()

    private let crossButtonContainerView: UIView = {
        let o = UIView()
        o.translatesAutoresizingMaskIntoConstraints = false
        o.backgroundColor = .clear
        return o
    }()

    private let crossButton: UIButton = {
        let o = UIButton()
        o.translatesAutoresizingMaskIntoConstraints = false
        o.setImage(UIImage(named:"closeBlack"), for: .normal)
        return o
    }()

    private let titleLabelContainerView: UIView = {
        let o = UIView()
        o.translatesAutoresizingMaskIntoConstraints = false
        o.backgroundColor = .clear
        return o
    }()

    private let titleLabel: UILabel = {
        let o = UILabel()
        o.translatesAutoresizingMaskIntoConstraints = false
        o.numberOfLines = 0
        o.text = nil
        o.textAlignment = .center
        o.textColor = .darkGray
        //o.backgroundColor = .orange
        return o
    }()

    private let messageLabelContainerView: UIView = {
        let o = UIView()
        o.translatesAutoresizingMaskIntoConstraints = false
        o.backgroundColor = .clear
        return o
    }()

    private let messageLabel: UILabel = {
        let o = UILabel()
        o.translatesAutoresizingMaskIntoConstraints = false
        o.numberOfLines = 0
        o.text = nil
        o.textAlignment = .center
        o.textColor = .gray
        //o.backgroundColor = .orange
        return o
    }()

    private let labelStackView: UIStackView = {
        let o = UIStackView()
        o.translatesAutoresizingMaskIntoConstraints = false
        o.axis = .vertical
        o.distribution = .fill
        o.spacing = 20
        return o
    }()

    private lazy var buttonStackView: UIStackView = {
        let o = UIStackView()
        o.translatesAutoresizingMaskIntoConstraints = false
        o.axis = .vertical
        o.distribution = .fillEqually
        o.spacing = interSpacing
        return o
    }()

    private lazy var checkmarkButtonStackView: UIStackView = {
        let o = UIStackView()
        o.translatesAutoresizingMaskIntoConstraints = false
        o.axis = .vertical
        o.distribution = .fillEqually
        o.spacing = interSpacing/2
        return o
    }()

    private let lineView: UIView = {
        let o = UIView()
        o.translatesAutoresizingMaskIntoConstraints = false
        o.backgroundColor = .lineSeparatorColor
        //o.layer.cornerRadius = 8
        return o
    }()

    private let gifContainerView: UIView = {
        let o = UIView()
        o.translatesAutoresizingMaskIntoConstraints = false
        o.backgroundColor = .clear
        //o.layer.cornerRadius = 8
        return o
    }()

    private let gifImageView: UIImageView = {
        let o = UIImageView()
        o.translatesAutoresizingMaskIntoConstraints = false
        o.backgroundColor = .lineSeparatorColor
        //o.layer.cornerRadius = 8
        return o
    }()

    private let gifLabel: UILabel = {
        let o = UILabel()
        o.translatesAutoresizingMaskIntoConstraints = false
        o.numberOfLines = 0
        o.text = ""
        o.textAlignment = .center
        o.font = UIFont.boldSystemFont(ofSize: 18)
        o.textColor = .gray
        //o.backgroundColor = .orange
        return o
    }()



    // MARK: - Constraint Identifier

    private enum ConstraintIdentifier {
        static let buttonStackViewHeightConstraintIdentifier = "buttonStackViewHeightConstraintIdentifier"
        static let buttonStackViewLeadingConstraintIdentifier = "buttonStackViewLeadingConstraintIdentifier"
        static let checkmarkButtonStackViewHeightConstraintIdentifier = "checkmarkButtonStackViewHeightConstraintIdentifier"
    }




    func isiPhoneSE() -> Bool {
        let deviceModel = UIDevice.current.model
        return deviceModel.contains("iPhone SE")
    }

    // MARK: - Variables and Constants

    private var logoImageHeight: CGFloat = UIDevice.isIpad ? 56 : 44
    private let buttonHeight: CGFloat = UIDevice.isIpad ? 48 : 38
    private let sideSpacing: CGFloat = UIDevice.isIpad ? 44 : 36
    private var interSpacing: CGFloat = UIDevice.isIpad ? 28 : 10
    private let titleFontSize: CGFloat = UIDevice.isIpad ? 23 : 18
    private let messageFontSize: CGFloat = UIDevice.isIpad ? 18 : 13
    private let seperatorFontSize: CGFloat = UIDevice.isIpad ? 18 : 15
    private let buttonFontSize: CGFloat = UIDevice.isIpad ? 21 : 16
    private let checkmarkButtonFontSize: CGFloat = UIDevice.isIpad ? 20 : 15
    private var gifContainerWidthHeight: CGFloat = 250//164.0




    private let titleFontName: String = "HPSimplified-Regular"
    private let messageFontName: String = "HPSimplified-Light"
    private let buttonFontName: String = "HPSimplified-Regular"

    static let messageFont = UIFont(name: "HPSimplified-Regular", size: 13)
    static let messageFonLightt = UIFont(name: "HPSimplified-Light", size: 13)

    private var actions: [PNAlertAction] = []

    private var actionButtonsAxis: NSLayoutConstraint.Axis {
        get {
            return self.buttonStackView.axis
        }
        set {
            self.buttonStackView.axis = newValue
            self.changeButtonStackViewConstraints(for: newValue)
        }
    }

    private var gifImageName: String?

    @objc var crossButtonEnabled: Bool {
        get {
            return crossButton.isHidden
        }
        set {
            self.crossButton.isHidden = !newValue
        }
    }


    // MARK: - Initializers
    init(title: String? = nil, message: String? = nil, gifImageName: String? = nil, actionButtonsAxis: NSLayoutConstraint.Axis = .vertical) {

        super.init(nibName: nil, bundle: nil)


        gifContainerWidthHeight = isiPhoneSE() ? 200:250
        crossButton.addTarget(self, action: #selector(crossbuttonAction), for: .touchUpInside)
        crossButtonEnabled = false

        let tFont = UIFont(name: titleFontName, size: titleFontSize)
        self.titleLabel.text = title
        self.titleLabel.font = tFont
        self.titleLabel.textColor = .titleColor

        let mFont = UIFont(name: messageFontName, size: messageFontSize)
        self.messageLabel.text = message
        self.messageLabel.font = mFont
        self.messageLabel.textColor = .messageColor

        self.buttonStackView.axis = actionButtonsAxis

        self.modalPresentationStyle = .overFullScreen

        self.gifImageName = gifImageName

        if title == "Printer Connections Full" {
            interSpacing =  interSpacing + 4
        }
        setupViews()

        changeButtonStackViewConstraints(for: actionButtonsAxis)
    }

    init(title: String? = nil, attributedMessage: NSAttributedString? = nil, gifImageName: String? = nil, actionButtonsAxis: NSLayoutConstraint.Axis = .vertical) {

        super.init(nibName: nil, bundle: nil)

        crossButton.addTarget(self, action: #selector(crossbuttonAction), for: .touchUpInside)
        crossButtonEnabled = false

        let tFont = UIFont(name: titleFontName, size: titleFontSize)
        self.titleLabel.text = title
        self.titleLabel.font = tFont
        self.titleLabel.textColor = .titleColor

        self.messageLabel.attributedText = attributedMessage

        self.buttonStackView.axis = actionButtonsAxis

        self.modalPresentationStyle = .overFullScreen

        self.gifImageName = gifImageName

        setupViews()

        changeButtonStackViewConstraints(for: actionButtonsAxis)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc class func alertControllerWithVerticalActionButtonAxis(title: String? = nil, message: String? = nil) -> PNAlertController {
        let alertController = PNAlertController(title: title, message: message, gifImageName: nil, actionButtonsAxis: .vertical)
        return alertController
    }

    @objc class func alertControllerWithHorizontalActionButtonAxis(title: String? = nil, message: String? = nil) -> PNAlertController {
        let alertController = PNAlertController(title: title, message: message, gifImageName: nil, actionButtonsAxis: .horizontal)
        return alertController
    }

    @objc class func alertControllerWith(title: String? = nil, message: String? = nil) -> PNAlertController {
        let alertController = PNAlertController(title: title, message: message, gifImageName: nil, actionButtonsAxis: .vertical)
        return alertController
    }

    @objc class func alertControllerWith(title: String? = nil, message: String? = nil, gifImageName: String? = nil) -> PNAlertController {
        let alertController = PNAlertController(title: title, message: message, gifImageName: gifImageName, actionButtonsAxis: .vertical)
        return alertController
    }


    @objc class func alertControllerWith(title: String? = nil, message: String? = nil, actionButtonsAxis: NSLayoutConstraint.Axis = .vertical) -> PNAlertController {
        let alertController = PNAlertController(title: title, message: message, actionButtonsAxis: actionButtonsAxis)
        return alertController
    }

    @objc class func alertControllerWith(title: String? = nil, attributedMessage: NSAttributedString? = nil, actionButtonsAxis: NSLayoutConstraint.Axis = .vertical) -> PNAlertController {
        let alertController = PNAlertController(title: title, attributedMessage: attributedMessage, actionButtonsAxis: actionButtonsAxis)
        return alertController
    }



    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAlert)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .clear
        self.popupView.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.popupView.alpha = 1
        } completion: { _ in
            // Write code here to execute upon anumation completion.
        }
    }

    // MARK: - Private Fucntions

    private func setupViews() {
        popupView.clipsToBounds = true
        let popupMaxWidth = UIDevice.isIpad ? 500 : min(view.bounds.width, view.bounds.height) - (2 * interSpacing)
        let popupMaxHeight = min(view.bounds.width, view.bounds.height) //+ (2 * padding) //popupMaxWidth + (2 * padding)
        print(popupMaxWidth,popupMaxHeight)
        view.addSubview(popupView)
        view.addConstraints([
            NSLayoutConstraint(item: popupView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: popupView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: popupView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: popupMaxWidth),
            NSLayoutConstraint(item: popupView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: sideSpacing).withPriority(.defaultHigh),
            NSLayoutConstraint(item: popupView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -sideSpacing).withPriority(.defaultHigh),

            NSLayoutConstraint(item: popupView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .top, multiplier: 1, constant: interSpacing),
            NSLayoutConstraint(item: popupView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: view, attribute: .bottom, multiplier: 1, constant: -interSpacing)
        ])

        if UIDevice.isIpad {
            view.addConstraints([
                NSLayoutConstraint(item: popupView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: popupMaxHeight),
            ])
        }

        popupView.addSubview(labelStackView)
        popupView.addConstraints([
            NSLayoutConstraint(item: labelStackView, attribute: .top, relatedBy: .equal, toItem: popupView, attribute: .top, multiplier: 1, constant: (1.5 * interSpacing)),
            NSLayoutConstraint(item: labelStackView, attribute: .leading, relatedBy: .equal, toItem: popupView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: labelStackView, attribute: .trailing, relatedBy: .equal, toItem: popupView, attribute: .trailing, multiplier: 1, constant: 0),
        ])

        // 1. title
        labelStackView.addArrangedSubview(titleLabelContainerView)
        titleLabelContainerView.addSubview(titleLabel)
        titleLabelContainerView.addConstraints([
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: titleLabelContainerView, attribute: .top, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: titleLabelContainerView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: titleLabelContainerView, attribute: .leading, multiplier: 1, constant: (4 * interSpacing)),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: titleLabelContainerView, attribute: .trailing, multiplier: 1, constant: -(4 * interSpacing)),
        ])

        // cross button
        titleLabelContainerView.addSubview(crossButtonContainerView)
        titleLabelContainerView.addConstraints([
            NSLayoutConstraint(item: crossButtonContainerView, attribute: .top, relatedBy: .equal, toItem: titleLabelContainerView, attribute: .top, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: crossButtonContainerView, attribute: .bottom, relatedBy: .equal, toItem: titleLabelContainerView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: crossButtonContainerView, attribute: .leading, relatedBy: .equal, toItem: titleLabel, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: crossButtonContainerView, attribute: .trailing, relatedBy: .equal, toItem: titleLabelContainerView, attribute: .trailing, multiplier: 1, constant: 0),
        ])

        crossButtonContainerView.addSubview(crossButton)
        crossButtonContainerView.addConstraints([
            NSLayoutConstraint(item: crossButton, attribute: .centerX, relatedBy: .equal, toItem: crossButtonContainerView, attribute: .centerX, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: crossButton, attribute: .centerY, relatedBy: .equal, toItem: crossButtonContainerView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: crossButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: titleFontSize),
            NSLayoutConstraint(item: crossButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: titleFontSize),
        ])

        labelStackView.addArrangedSubview(lineView)
        self.labelStackView.addConstraints([
            NSLayoutConstraint(item: lineView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1),
        ])

        // 2. message
        labelStackView.addArrangedSubview(messageLabelContainerView)
//        labelStackView.addConstraint(NSLayoutConstraint(item: messageLabelContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))

        messageLabelContainerView.addSubview(messageLabel)
        messageLabelContainerView.addConstraints([
            NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: messageLabelContainerView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: messageLabel, attribute: .bottom, relatedBy: .equal, toItem: messageLabelContainerView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: messageLabel, attribute: .leading, relatedBy: .equal, toItem: messageLabelContainerView, attribute: .leading, multiplier: 1, constant: (4 * interSpacing)),
            NSLayoutConstraint(item: messageLabel, attribute: .trailing, relatedBy: .equal, toItem: messageLabelContainerView, attribute: .trailing, multiplier: 1, constant: -(4 * interSpacing)),
        ])


        // 3. gif
        if let gifName = gifImageName {

            if gifName == "paperMargin" {
                gifImageView.image = UIImage(named: gifName)
                gifImageView.contentMode = .scaleAspectFit
                gifImageView.backgroundColor = UIColor.clear
            } else if gifName == "PaperCutGif"{
                gifImageView.contentMode = .scaleAspectFill
                gifImageView.loadGif(name: gifName)
            } else {
                gifImageView.loadGif(name: gifName)
            }


            labelStackView.addArrangedSubview(gifContainerView)
            labelStackView.addConstraint(NSLayoutConstraint(item: gifContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: gifContainerWidthHeight))

            self.gifContainerView.addSubview(gifImageView)
            self.gifContainerView.addConstraints([
                NSLayoutConstraint(item: gifImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: gifContainerWidthHeight),
                NSLayoutConstraint(item: gifImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: gifContainerWidthHeight),
                NSLayoutConstraint(item: gifImageView, attribute: .centerX, relatedBy: .equal, toItem: gifContainerView, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: gifImageView, attribute: .centerY, relatedBy: .equal, toItem: gifContainerView, attribute: .centerY, multiplier: 1, constant: 0),
            ])
            gifImageView.layer.cornerRadius = 12



            self.gifContainerView.addSubview(gifLabel)
            self.gifContainerView.addConstraints([
                NSLayoutConstraint(item: gifLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100),
                NSLayoutConstraint(item: gifLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100),
                NSLayoutConstraint(item: gifLabel, attribute: .centerX, relatedBy: .equal, toItem: gifContainerView, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: gifLabel, attribute: .centerY, relatedBy: .equal, toItem: gifContainerView, attribute: .centerY, multiplier: 1, constant: 0),
            ])
        }

        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        messageLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        if (titleLabel.text ?? "").isEmpty || (messageLabel.text ?? "").isEmpty {
            labelStackView.spacing = interSpacing
        }

        // 4. buttons
        popupView.addSubview(buttonStackView)
        popupView.addConstraints([
            NSLayoutConstraint(item: buttonStackView, attribute: .top, relatedBy: .equal, toItem: labelStackView, attribute: .bottom, multiplier: 1, constant: (1.5 * interSpacing)),
          //previous developer commented  //NSLayoutConstraint(item: buttonStackView, attribute: .bottom, relatedBy: .equal, toItem: popupView, attribute: .bottom, multiplier: 1, constant: -interSpacing),


//            NSLayoutConstraint(item: buttonStackView, attribute: .leading, relatedBy: .equal, toItem: popupView, attribute: .leading, multiplier: 1, constant: interSpacing).withIdentifier(ConstraintIdentifier.buttonStackViewLeadingConstraintIdentifier),
//            NSLayoutConstraint(item: buttonStackView, attribute: .trailing, relatedBy: .equal, toItem: popupView, attribute: .trailing, multiplier: 1, constant: -interSpacing),

            NSLayoutConstraint(item: buttonStackView, attribute: .leading, relatedBy: .equal, toItem: popupView, attribute: .leading, multiplier: 1, constant: (3 * interSpacing)),
            NSLayoutConstraint(item: buttonStackView, attribute: .trailing, relatedBy: .equal, toItem: popupView, attribute: .trailing, multiplier: 1, constant: -(3 * interSpacing)),
        ])
        if buttonStackView.axis == .horizontal {
            popupView.addConstraints([
                NSLayoutConstraint(item: buttonStackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonHeight).withIdentifier(ConstraintIdentifier.buttonStackViewHeightConstraintIdentifier),
            ])
        }

        // 4. checkmarks
        popupView.addSubview(checkmarkButtonStackView)
        popupView.addConstraints([
            NSLayoutConstraint(item: checkmarkButtonStackView, attribute: .top, relatedBy: .equal, toItem: buttonStackView, attribute: .bottom, multiplier: 1, constant: (1.5 * interSpacing)),
            NSLayoutConstraint(item: checkmarkButtonStackView, attribute: .bottom, relatedBy: .equal, toItem: popupView, attribute: .bottom, multiplier: 1, constant: -(1.5 * interSpacing)),
            NSLayoutConstraint(item: checkmarkButtonStackView, attribute: .leading, relatedBy: .equal, toItem: popupView, attribute: .leading, multiplier: 1, constant: interSpacing),
            NSLayoutConstraint(item: checkmarkButtonStackView, attribute: .trailing, relatedBy: .equal, toItem: popupView, attribute: .trailing, multiplier: 1, constant: -interSpacing),
        ])
        if buttonStackView.axis == .horizontal {
            popupView.addConstraints([
                NSLayoutConstraint(item: checkmarkButtonStackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonHeight).withIdentifier(ConstraintIdentifier.checkmarkButtonStackViewHeightConstraintIdentifier),
            ])
        }
    }

    private func setupColors() {
        for stackedView in buttonStackView.arrangedSubviews {
            if let button = stackedView as? UIButton {
                let titleColor = UIColor.white
                button.setTitleColor(titleColor, for: .normal)
                let backgroundColor = UIColor.systemBlue
                button.backgroundColor = backgroundColor
            }
        }
    }

    private func setMessage(_ message: String, withInLineSpacing inLineSpacing: CGFloat, font: UIFont, onLabel label: UILabel) {

        let attributedString = NSMutableAttributedString(string: message)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = inLineSpacing
        paragraphStyle.alignment = .center
        let range = NSMakeRange(0, attributedString.length)

        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        if label == self.messageLabel {
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: range)
        }

        label.attributedText = attributedString
    }


    @objc private func crossbuttonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25) {
            self.view.backgroundColor = .clear
            self.popupView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }

    @objc private func dismissAlert(_ sender: Any) {
        if let button = sender as? UIButton {
            self.actions.forEach { (action) in
                if button.titleLabel?.text?.trimmingCharacters(in: .whitespaces) == action.title {
                    if action.shouldDismissAlertWithAction {
                        UIView.animate(withDuration: 0.25) {
                            self.view.backgroundColor = .clear
                            self.popupView.alpha = 0
                        } completion: { _ in
                            self.dismiss(animated: false, completion: {
                                action.alertAction(checkmark: button.isSelected)
                            })
                        }
                    } else {
                        if action.type == .checkmark {
                            button.isSelected = !button.isSelected
                        }
                        action.alertAction(checkmark: button.isSelected)
                    }
                }
            }
        }
    }

    private func changeButtonStackViewConstraints(for axis: NSLayoutConstraint.Axis) {
        if axis == .vertical {
            if let constraint = popupView.constraints.first(where: { $0.identifier == ConstraintIdentifier.buttonStackViewLeadingConstraintIdentifier }) {
                self.popupView.removeConstraint(constraint)
                popupView.addConstraints([
                    NSLayoutConstraint(item: buttonStackView, attribute: .leading, relatedBy: .equal, toItem: popupView, attribute: .leading, multiplier: 1, constant: interSpacing).withIdentifier(ConstraintIdentifier.buttonStackViewLeadingConstraintIdentifier)
                ])
            }

            if let constraint = popupView.constraints.first(where: { $0.identifier == ConstraintIdentifier.buttonStackViewHeightConstraintIdentifier }) {
                self.popupView.removeConstraint(constraint)
                self.buttonStackView.axis = .vertical
                buttonStackView.arrangedSubviews.forEach { (stackedView) in
                    buttonStackView.addConstraints([
                        NSLayoutConstraint(item: stackedView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonHeight)
                    ])
                }
            }
        }
        else if axis == .horizontal {
            /*
            if let constraint = popupView.constraints.first(where: { $0.identifier == ConstraintIdentifier.buttonStackViewLeadingConstraintIdentifier }) {
                self.popupView.removeConstraint(constraint)
                popupView.addConstraints([
                    NSLayoutConstraint(item: buttonStackView, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: popupView, attribute: .leading, multiplier: 1, constant: interSpacing).withIdentifier(ConstraintIdentifier.buttonStackViewLeadingConstraintIdentifier)
                ])
            }
            */
            buttonStackView.arrangedSubviews.forEach { (stackedView) in
                stackedView.removeConstraints(stackedView.constraints)
            }

            popupView.addConstraints([
                NSLayoutConstraint(item: buttonStackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonHeight).withIdentifier(ConstraintIdentifier.buttonStackViewHeightConstraintIdentifier),
            ])
        }
    }



    // MARK: - Accessible Methods

    @objc func addAction(_ action: PNAlertAction) {

        let button = UIButton(type: .custom)

        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle(action.title, for: .normal)

        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: interSpacing/2, bottom: 0, right: interSpacing/2)

        let bFont = UIFont(name: buttonFontName, size: buttonFontSize)
        let mFont = UIFont(name: messageFontName, size: messageFontSize)
        let sFont = UIFont(name: messageFontName, size: seperatorFontSize)

        button.titleLabel?.font =  bFont

        button.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)

        switch action.type {
        case .plain:
            button.backgroundColor = .clear
            button.setTitleColor(UIColor.alertbuttonColor, for: .normal)
            button.layer.borderColor = UIColor.alertbuttonColor.cgColor
            button.layer.cornerRadius = 3
        case .borderd:
            button.backgroundColor = .clear
            button.setTitleColor(UIColor.alertbuttonColor, for: .normal)
            button.layer.borderColor = UIColor.alertbuttonColor.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 3
        case .bold:
            button.backgroundColor = .alertbuttonColor
            button.setTitleColor(UIColor.white, for: .normal)
            button.layer.cornerRadius = 3
        case .checkmark:
            button.backgroundColor = .clear
            button.setTitleColor(UIColor.alertbuttonColor, for: .normal)
            button.layer.borderColor = UIColor.alertbuttonColor.cgColor
            button.layer.cornerRadius = 3
            button.setImage(UIImage(named: "unchecked500"), for: .normal)
            button.setImage(UIImage(named: "checked500"), for: .selected)
            button.setTitle("  \(action.title ?? "")", for: .normal)
            button.setTitle("  \(action.title ?? "")", for: .selected)
            let bFont = UIFont(name: messageFontName, size: checkmarkButtonFontSize)
            button.titleLabel?.font =  bFont
            action.buttonFillMode = .full
        case .destructiveBold:
            button.backgroundColor = .destructiveButtonColor
            button.setTitleColor(UIColor.white, for: .normal)
            button.layer.cornerRadius = 3
        case .destructiveBordered:
            button.backgroundColor = .clear
            button.setTitleColor(UIColor.destructiveButtonColor, for: .normal)
            button.layer.borderColor = UIColor.destructiveButtonColor.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 3
        case .lastOption:
            button.backgroundColor = .lastOptionButtonColor
            button.setTitleColor(.messageColor, for: .normal)
            button.titleLabel?.font =  mFont
        case .boldGrayed:
            button.backgroundColor = .grayedButtonColor
            button.setTitleColor(UIColor.white, for: .normal)
            button.layer.cornerRadius = 3
        case .borderedRed:
            button.backgroundColor = .clear
            button.setTitleColor(UIColor.red, for: .normal)
            button.layer.borderColor = UIColor.red.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 3
        case .seperator:
            button.backgroundColor = .white
            button.setTitleColor(UIColor.messageColor, for: .normal)
            button.titleLabel?.font =  sFont
            button.titleLabel?.text = "----- \(button.titleLabel?.text ?? "" ) -----"
        }

        var multiplierForButtonFillMode: CGFloat = 1
        switch action.buttonFillMode {
        case .quater:
            multiplierForButtonFillMode = 0.25
        case .half:
            multiplierForButtonFillMode = 0.50
        case .threeQuaters:
            multiplierForButtonFillMode = 0.75
        case .fourByFive:
            multiplierForButtonFillMode = 0.90
        case .full:
            multiplierForButtonFillMode = 1
        }

        if action.type == .checkmark {
            if action.type == .checkmark {
                checkmarkButtonStackView.addArrangedSubview(button)
                checkmarkButtonStackView.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonHeight))
            }
        } else if action.type == .seperator {
            let buttonContainerView: UIView = UIView(frame: CGRect.zero)
            buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
            buttonStackView.spacing = interSpacing * 1.5
            buttonStackView.addArrangedSubview(buttonContainerView)
            buttonStackView.addConstraint(NSLayoutConstraint(item: buttonContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonHeight))

            let lineView1 = UIView(frame: CGRect(x: 0, y: buttonHeight/2, width: 25, height: 1))
            lineView1.translatesAutoresizingMaskIntoConstraints = false
            lineView1.backgroundColor = .messageColor
            buttonContainerView.addSubview(lineView1)
            buttonContainerView.addConstraints([
                NSLayoutConstraint(item: lineView1, attribute: .top, relatedBy: .equal, toItem: buttonContainerView, attribute: .top, multiplier: 1, constant: (buttonHeight/2) - 0.5 + 5),
                NSLayoutConstraint(item: lineView1, attribute: .bottom, relatedBy: .equal, toItem: buttonContainerView, attribute: .bottom, multiplier: 1, constant: -((buttonHeight/2) - 0.5 - 5)),
                NSLayoutConstraint(item: lineView1, attribute: .width, relatedBy: .equal, toItem: buttonContainerView, attribute: .width, multiplier: 1 , constant: 0),
                NSLayoutConstraint(item: lineView1, attribute: .centerX, relatedBy: .equal, toItem: buttonContainerView, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: lineView1, attribute: .centerY, relatedBy: .equal, toItem: buttonContainerView, attribute: .centerY, multiplier: 1, constant: 0)
            ])

            buttonContainerView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            buttonContainerView.addConstraints([
                NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: buttonContainerView, attribute: .top, multiplier: 1, constant: 10),
                NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: buttonContainerView, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: buttonContainerView, attribute: .width, multiplier: 0.385 , constant: 0),//0.35
                NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: buttonContainerView, attribute: .centerX, multiplier: 1, constant: 0)
            ])


        } else {
            if action.buttonFillMode == .full || actionButtonsAxis == .horizontal {
                buttonStackView.addArrangedSubview(button)
                buttonStackView.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonHeight))
            } else {
                let buttonContainerView: UIView = UIView(frame: CGRect.zero)
                buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
                buttonStackView.addArrangedSubview(buttonContainerView)
                buttonStackView.addConstraint(NSLayoutConstraint(item: buttonContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonHeight))
                buttonContainerView.addSubview(button)
                button.translatesAutoresizingMaskIntoConstraints = false
                buttonContainerView.addConstraints([
                    NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: buttonContainerView, attribute: .top, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: buttonContainerView, attribute: .bottom, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: buttonContainerView, attribute: .width, multiplier: multiplierForButtonFillMode, constant: 0),
                    NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: buttonContainerView, attribute: .centerX, multiplier: 1, constant: 0)
                ])
            }

            if buttonStackView.axis == .vertical {
                buttonStackView.addConstraints([
                    NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: buttonHeight)
                ])
            }
        }
        actions.append(action)
    }

    @objc func presentFrom(_ controller: UIViewController, completion: (() -> Void)?) {
        controller.present(self, animated: false, completion: completion)
    }

    @objc func presentAlert() {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            if !topController.isKind(of: PNAlertController.self) {
                self.presentFrom(topController, completion: nil)
            }
        }
    }

    @objc func hideAlert() {
        self.crossbuttonAction(crossButton)
    }

}
