//
//  CanvasCropView.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/05/23.
//

import UIKit
import AVFoundation

struct ImageContentMode {
    var notSet = 0
    var fit = 1
    var fill = 2
}

protocol CropViewDelegate: AnyObject {
    func cropView(_: CanvasCropView, didMoveImage moved: Bool)
    func didDragCanvas(_: CanvasCropView, didDragImage moved: Bool)
}

var zoomScale:CGFloat?
var imageViewDidZoom: () -> Void = {}
var paperLengthImageZoom = CGAffineTransform()
open class CanvasCropView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    open var image: UIImage?
    open var imageView = UIImageView()
    
    open var frameImageView = UIImageView()
    var edit_selectedFrame: Any?


    open var paperLengthImageRotation:CGAffineTransform?
    open var paperLengthImageMovementTransform:CGAffineTransform?
    var transformScrollView:CGAffineTransform?
    var zoomScrollView:CGFloat?

    var scrollViewTransform: CGAffineTransform?
    var scrollViewCenter: CGPoint?
    var scrollViewBounds: CGRect?
    var scrollViewContentOffset: CGPoint?
    var scrollViewMinimumZoomScale: CGFloat?
    var scrollViewMaximumZoomScale: CGFloat?
    var scrollViewZoomScaleCropper: CGFloat?
    
    var straightenAngle: CGFloat = 0.0
    var rotationAngle: CGFloat = 0.0
    var flipAngle: CGFloat = 0.0
    
    var isAspectFill = false
    var isPositionChange = false
    open var imgDefaultRatio:CGFloat = 0.0
    open var imgNewRatio:CGFloat = 0.0
    var isLandscape = false
    var isRulerImgFitForLessThanDefault = false
    weak var delegate: CropViewDelegate?
    var lastScale = CGFloat()
    var originalImageViewSize = CGSize()
    var navigateFromEditScreen = false

    open var finalImage:UIImage?{

        let scale = 3.0
        let viewWhiteCanvasTemp = UIView(frame: CGRect(x: (viewWhiteCanvas.frame.origin.x - 1.0) * scale, y: viewWhiteCanvas.frame.origin.y * scale, width: (viewWhiteCanvas.frame.size.width - 1.0) * scale, height: (viewWhiteCanvas.frame.size.height - 1.0) * scale))
        viewWhiteCanvasTemp.backgroundColor = .white
        
        let gestureImage = self.viewImageGesture.takeScreenshotHD()

        let imageViewTemp = UIImageView(frame: CGRect(x: 0, y: 0, width: viewWhiteCanvas.frame.size.width * scale, height: viewWhiteCanvas.frame.size.height * scale))
        imageViewTemp.image = gestureImage
        imageViewTemp.contentMode = imageView.contentMode
        imageViewTemp.backgroundColor = .clear
        
        viewWhiteCanvasTemp.addSubview(imageViewTemp)
        let image = viewWhiteCanvasTemp.takeScreenshotHD()
        return image
    }
    
    // open  var scrollView: UIScrollView!
    var viewWhiteCanvas = UIView()
     var viewImageGesture = UIView()
    // var mainScrollView = UIScrollView()
    fileprivate var viewMain = UIView()
    
    var blueLineForviewToComposite = UIView()
    var buttonImgBluePortraitBottom = UIButton()
    var buttonImgBlueLandscapeRight = UIButton()
    var buttonImgBluePortraitTop = UIButton()
    var buttonImgBlueLandscapeLeft = UIButton()
    
    open  var rotationGestureRecognizer: UIRotationGestureRecognizer!
    var pangestureToMoveImage:UIPanGestureRecognizer!
    var pinchGestureToMoveImage:UIPinchGestureRecognizer!
    
    var pangestureToDragLandscapeCanvasRitgh :UIPanGestureRecognizer!
    var pangestureToDragPortraitCanvasBottom :UIPanGestureRecognizer!
    var pangestureToDragLandscapeCanvasLeft :UIPanGestureRecognizer!
    var pangestureToDragPortraitCanvasTop :UIPanGestureRecognizer!
    
    fileprivate let topOverlayView = UIView()
    fileprivate let leftOverlayView = UIView()
    fileprivate let rightOverlayView = UIView()
    fileprivate let bottomOverlayView = UIView()
    
    fileprivate let leftShadowview = UIView()
    fileprivate let rigthShadowview = UIView()
    fileprivate let topShadowview = UIView()
    fileprivate let bottomShadowview = UIView()
    fileprivate let gradientShadowview = UIView()
    
    var startPosition: CGPoint?
    var endPosition: CGPoint?
    var isBlankCanvasRuler: Bool = true
    var isPaperLengthView: Bool = true
    private var initialCenter: CGPoint = .zero
    var hideSideViewArea = 0.0
    var infoViewHeight = 20.0
    
    var totalAngle: CGFloat = 0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        clipsToBounds = true
        viewMain = UIView()
        viewMain.frame = self.bounds
        viewMain.center = self.center
        viewMain.backgroundColor = .clear
        addSubview(viewMain)
        
        //SetBlankCanvas
        viewWhiteCanvas = UIView()
        viewWhiteCanvas.center = self.viewMain.center
        viewMain.addSubview(viewWhiteCanvas)
        self.viewWhiteCanvas.backgroundColor = .white
        viewWhiteCanvas.isUserInteractionEnabled = false
        
        viewImageGesture = UIView()
        viewImageGesture.center = self.viewMain.center
        viewMain.insertSubview(viewImageGesture, aboveSubview: viewWhiteCanvas)
        self.viewImageGesture.backgroundColor = .clear
        
        viewImageGesture.isUserInteractionEnabled = true
        topOverlayView.isUserInteractionEnabled = false
        leftOverlayView.isUserInteractionEnabled = false
        rightOverlayView.isUserInteractionEnabled = false
        bottomOverlayView.isUserInteractionEnabled = false
        
        viewMain.insertSubview(topOverlayView, aboveSubview: viewImageGesture)
        viewMain.insertSubview(leftOverlayView, aboveSubview: viewImageGesture)
        viewMain.insertSubview(rightOverlayView, aboveSubview: viewImageGesture)
        viewMain.insertSubview(bottomOverlayView, aboveSubview: viewImageGesture)
        
        initBlueLines()
        if isPaperLengthView {
            hideSideViewArea = 0.0
            shadowEffectOnSetPaperlength()
        } else {
            hideSideViewArea = 0.0
        }
        
        imageViewDidZoom = {
            self.delegate?.cropView(self, didMoveImage: true)
        }
    }
    
    func getNewSizeWithDimensionLimit(limit:CGFloat,ratio:CGFloat) -> CGSize {
        
        let printSize = CanvasRatioManager.shared.getSizeAccordingPrintWidth(ratio: ratio)
        
        var divideValue = 5.5
        var size = CGSize()
        for _ in 1...200 {
            if isLandscape {
                size =  CGSize(width: printSize.height/divideValue, height: printSize.width/divideValue)
            } else {
                size = CGSize(width: printSize.width/divideValue, height: printSize.height/divideValue)
            }
            
            if size.width < limit && size.height < limit {
                break
            }
            divideValue += 0.10
        }
        return size
    }
    
    func rotation(from transform: CGAffineTransform) -> Double {
        return atan2(Double(transform.b), Double(transform.a))
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if image == nil {
            return
        }
        
        if isBlankCanvasRuler {
            imageView.isHidden = true
        }
        
        self.viewMain.frame = bounds
        viewWhiteCanvas.center = self.viewMain.center
        viewImageGesture.center = self.viewMain.center
        layoutOverlayViewsWithCropRect(viewWhiteCanvas.frame)
    }
    
    @objc func handleRotation(_ gestureRecognizer: UIRotationGestureRecognizer) {
        
        if gestureRecognizer.state == .began ||  gestureRecognizer.state == .changed {
            if let view = gestureRecognizer.view {
                
                view.transform = view.transform.rotated(by: gestureRecognizer.rotation)
                paperLengthImageRotation = gestureRecognizer.view?.transform
                isPositionChange = true
                gestureRecognizer.rotation = 0
                
                if isPaperLengthView {
                    showOverlayView(color:  UIColor(red: 153 / 255.0, green: 145 / 255.0, blue: 145 / 255.0, alpha: 1), opacity:1)
                } else {
                    showOverlayView(color:  UIColor(red: 77 / 255.0, green: 77 / 255.0, blue: 77 / 255.0, alpha: 1), opacity: 0.75)
                }
            }
        } else if gestureRecognizer.state == .ended {
            if isPaperLengthView {
                showOverlayView(color:  UIColor(red: 153 / 255.0, green: 145 / 255.0, blue: 145 / 255.0, alpha: 1), opacity: 1 )
            } else {
                showOverlayView(color:  UIColor(red: 77 / 255.0, green: 77 / 255.0, blue: 77 / 255.0, alpha: 1), opacity:1)
            }
            self.delegate?.cropView(self, didMoveImage: self.isPositionChange)
        }
    }
    
    
    @objc func handleImageMovment(_ sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: imageView)
        imageView.transform = imageView.transform.translatedBy(x: translation.x, y: translation.y)
        sender.setTranslation(.zero, in: imageView)
        self.paperLengthImageMovementTransform = imageView.transform
        isPositionChange = true
        
        if sender.state == .began || sender.state == .changed {
            if isPaperLengthView{
                showOverlayView(color:  UIColor(red: 153 / 255.0, green: 145 / 255.0, blue: 145 / 255.0, alpha: 1), opacity: 1 )
            } else{
                showOverlayView(color:  UIColor(red: 77 / 255.0, green: 77 / 255.0, blue: 77 / 255.0, alpha: 1), opacity: 0.75)
            }
        } else if sender.state == .ended {
            if isPaperLengthView{
                showOverlayView(color:  UIColor(red: 153 / 255.0, green: 145 / 255.0, blue: 145 / 255.0, alpha: 1), opacity: 1 )
            } else{
                showOverlayView(color:  UIColor(red: 77 / 255.0, green: 77 / 255.0, blue: 77 / 255.0, alpha: 1), opacity: 1)
            }
            self.delegate?.cropView(self, didMoveImage: self.isPositionChange)
        }
    }
    
    
    @objc func startZooming(_ sender: UIPinchGestureRecognizer) {
        if let view = sender.view {
            switch sender.state {
            case .changed:
                view.transform = view.transform.scaledBy(x: sender.scale, y: sender.scale)
                zoomScale = sender.scale
                paperLengthImageZoom = view.transform
                sender.scale = 1
            case .ended:
                imageViewDidZoom()
            default:
                return
            }
        }
    }
    
    // MARK: - Private methods
    fileprivate func showOverlayView(color:UIColor, opacity:Float) {
        topOverlayView.backgroundColor =  color
        leftOverlayView.backgroundColor = color
        rightOverlayView.backgroundColor =  color
        bottomOverlayView.backgroundColor =  color
        topOverlayView.layer.opacity = opacity
        leftOverlayView.layer.opacity = opacity
        rightOverlayView.layer.opacity = opacity
        bottomOverlayView.layer.opacity = opacity
    }
    
    func shadowEffectOnSetPaperlength() {
        gradientShadowview.backgroundColor = UIColor(red: 119 / 255.0, green: 119 / 255.0, blue: 119 / 255.0, alpha: 1)//leftOverlayView.backgroundColor
        gradientShadowview.isUserInteractionEnabled = false
        self.insertSubview(gradientShadowview, aboveSubview: viewMain)
        gradientShadowview.layer.shadowOpacity = 0.8
        gradientShadowview.layer.shadowOffset = CGSize(width: 5, height: 0)
        gradientShadowview.layer.shadowRadius = 6.0
        let gradienShadowRect: CGRect = gradientShadowview.bounds.insetBy(dx:1, dy:-1)
        gradientShadowview.layer.shadowPath = UIBezierPath(rect: gradienShadowRect).cgPath
        
        leftShadowview.backgroundColor = UIColor(red: 119 / 255.0, green: 119 / 255.0, blue: 119 / 255.0, alpha: 1)
        leftShadowview.isUserInteractionEnabled = false
        viewMain.insertSubview(leftShadowview, aboveSubview: leftOverlayView)
        leftShadowview.layer.shadowOpacity = 1.5
        leftShadowview.layer.shadowOffset = CGSize(width: -5, height: 0)
        leftShadowview.layer.shadowRadius = 6.0
        let leftShadowRect: CGRect = leftShadowview.bounds.insetBy(dx: 1, dy: -1)
        leftShadowview.layer.shadowPath = UIBezierPath(rect: leftShadowRect).cgPath
        
        rigthShadowview.backgroundColor = UIColor(red: 119 / 255.0, green: 119 / 255.0, blue: 119 / 255.0, alpha: 1)//leftOverlayView.backgroundColor
        rigthShadowview.isUserInteractionEnabled = false
        viewMain.insertSubview(rigthShadowview, aboveSubview: rightOverlayView)
        rigthShadowview.layer.shadowOpacity = 1.5
        rigthShadowview.layer.shadowOffset = CGSize(width: 5, height: 0)
        rigthShadowview.layer.shadowRadius = 5.0
        rigthShadowview.layer.shadowPath = UIBezierPath(rect: leftShadowRect).cgPath
        
        
        topShadowview.backgroundColor = UIColor(red: 119 / 255.0, green: 119 / 255.0, blue: 119 / 255.0, alpha: 1)//leftOverlayView.backgroundColor
        topShadowview.isUserInteractionEnabled = false
        viewMain.insertSubview(topShadowview, aboveSubview: topOverlayView)
        topShadowview.layer.shadowOpacity = 1.5
        topShadowview.layer.shadowOffset = CGSize(width: 0, height:-5)
        topShadowview.layer.shadowRadius = 8.0
        topShadowview.layer.shadowPath = UIBezierPath(rect: leftShadowRect).cgPath
        
        bottomShadowview.backgroundColor = UIColor(red: 119 / 255.0, green: 119 / 255.0, blue: 119 / 255.0, alpha: 1)//leftOverlayView.backgroundColor
        bottomShadowview.isUserInteractionEnabled = false
        viewMain.insertSubview(bottomShadowview, aboveSubview: bottomOverlayView)
        bottomShadowview.layer.shadowOpacity = 1.5
        bottomShadowview.layer.shadowOffset = CGSize(width:0, height: 5)
        bottomShadowview.layer.shadowRadius = 5.0
        bottomShadowview.layer.shadowPath = UIBezierPath(rect: leftShadowRect).cgPath
    }
    
    func shadowFrameChanged() {
        gradientShadowview.frame = CGRect(x: 0, y: 0, width: 2, height: self.frame.size.height)
        
        if isLandscape {
            let width = viewWhiteCanvas.frame.size.width + 1
            
            var yAxis = ((viewMain.frame.size.height - viewWhiteCanvas.frame.size.height)/2) - 1
            yAxis = viewMain.frame.size.height - yAxis
            yAxis -= hideSideViewArea
            
            leftShadowview.frame = CGRect(x: viewWhiteCanvas.frame.origin.x , y: viewWhiteCanvas.frame.origin.y , width: 1, height: viewWhiteCanvas.frame.size.height - hideSideViewArea)
            let viewMainxAxis = (viewMain.frame.size.width  - ((viewMain.frame.size.width - viewWhiteCanvas.frame.size.width)/2))
            let viewWhiteCanvasyAxis = viewWhiteCanvas.frame.origin.y
            let height = viewWhiteCanvas.frame.size.height - hideSideViewArea
            rigthShadowview.frame = CGRect(x: viewMainxAxis, y: viewWhiteCanvasyAxis, width: 1, height: height)
            topShadowview.frame = CGRect(x: leftShadowview.frame.origin.x, y: viewWhiteCanvas.frame.origin.y + hideSideViewArea, width:width , height: 1)
            bottomShadowview.frame = CGRect(x: leftShadowview.frame.origin.x , y: yAxis, width: viewWhiteCanvas.frame.size.width + 1, height: 2)
            
        } else {
            leftShadowview.frame = CGRect(x: viewWhiteCanvas.frame.origin.x + hideSideViewArea, y: viewWhiteCanvas.frame.origin.y , width: 1, height: viewWhiteCanvas.frame.size.height)
            let xAxis = (viewMain.frame.size.width  - ((viewMain.frame.size.width - viewWhiteCanvas.frame.size.width)/2))
            rigthShadowview.frame = CGRect(x: xAxis - hideSideViewArea, y: viewWhiteCanvas.frame.origin.y, width: 1, height: viewWhiteCanvas.frame.size.height )
            var width = viewWhiteCanvas.frame.size.width + 1
            width -= (hideSideViewArea * 2)
            topShadowview.frame = CGRect(x: leftShadowview.frame.origin.x, y: viewWhiteCanvas.frame.origin.y, width: width, height: 1)
            let yAxis = viewMain.frame.size.height  - ((viewMain.frame.size.height - viewWhiteCanvas.frame.size.height)/2) - 1
            bottomShadowview.frame = CGRect(x: leftShadowview.frame.origin.x , y: yAxis, width: width, height: 2)
        }
    }
    
    func setupImageView(contentMode:ContentMode) {
        viewImageGesture.frame = viewWhiteCanvas.frame
        
        
        if (self.image != nil) && contentMode == .scaleAspectFill || contentMode == .scaleToFill {
            _ = CGFloat()
            var imageWidth = CGFloat()
            var imageHeight = CGFloat()
            var imageRatio = CGFloat()
            imageRatio = image!.size.height/image!.size.width
            imageWidth = viewImageGesture.frame.size.width
            imageHeight = viewImageGesture.frame.size.width * imageRatio
            let tempImageHeight = Int(imageHeight)
            let tempGestureViewHeight = Int(viewImageGesture.frame.size.height)
            if tempImageHeight < tempGestureViewHeight {
                imageRatio = image!.size.width/image!.size.height
                imageWidth = viewImageGesture.frame.size.height * imageRatio
                imageHeight = viewImageGesture.frame.size.height
            }
            self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        } else {
            self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: viewImageGesture.frame.size.width, height: viewImageGesture.frame.size.height))
        }
        
        self.imageView.backgroundColor = .clear
        self.imageView.image = self.image
        self.imageView.contentMode = contentMode
        
        // mainScrollView =  UIScrollView(frame: CGRect(x: 0, y: 0, width: viewImageGesture.frame.size.width, height: viewImageGesture.frame.size.height))
        if contentMode == .scaleAspectFill {
            self.isAspectFill = true
        } else {
            self.isAspectFill = false
        }
        
        self.imageView.center =  CGPoint(x: viewImageGesture.frame.width / 2, y: viewImageGesture.frame.height / 2)
        viewImageGesture.addSubview(self.imageView)
        imageView.isUserInteractionEnabled = true
        originalImageViewSize = self.imageView.frame.size
        
        pinchGestureToMoveImage = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
        pinchGestureToMoveImage.delegate = self
        imageView.addGestureRecognizer(pinchGestureToMoveImage)
        
        rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(CanvasCropView.handleRotation(_:)))
        rotationGestureRecognizer.delegate = self
        self.imageView.addGestureRecognizer(rotationGestureRecognizer)
        
        pangestureToMoveImage = UIPanGestureRecognizer(target: self, action: #selector(self.handleImageMovment(_:)))
        pangestureToMoveImage.delegate = self
        self.imageView.addGestureRecognizer(pangestureToMoveImage)
        
        self.configureFrameView()

        if navigateFromEditScreen == true {
            frameImageView.isHidden = false
        } else {
            frameImageView.isHidden = true
        }
    
        viewImageGesture.addSubview(self.frameImageView)
    }
    
    fileprivate func layoutOverlayViewsWithCropRect(_ cropRect: CGRect) {
        
        if isLandscape {
            leftOverlayView.frame = CGRect(x: 0, y: cropRect.minY, width: cropRect.minX, height: cropRect.height )
            rightOverlayView.frame = CGRect(x: cropRect.maxX , y: cropRect.minY, width: viewMain.bounds.width - cropRect.maxX , height: cropRect.height )
            
            topOverlayView.frame = CGRect(x: 0, y: 0, width: viewMain.bounds.width, height: cropRect.minY + hideSideViewArea)
            bottomOverlayView.frame = CGRect(x: 0, y: cropRect.maxY - hideSideViewArea, width: viewMain.bounds.width, height: viewMain.bounds.height - cropRect.maxY + hideSideViewArea)
        } else {
            topOverlayView.frame = CGRect(x: 0, y: 0, width: viewMain.bounds.width, height: cropRect.minY)
            bottomOverlayView.frame = CGRect(x: 0, y: cropRect.maxY , width: viewMain.bounds.width, height: viewMain.bounds.height - cropRect.maxY)
            
            leftOverlayView.frame = CGRect(x: 0, y: cropRect.minY, width: cropRect.minX + hideSideViewArea, height: cropRect.height )
            rightOverlayView.frame = CGRect(x: cropRect.maxX - hideSideViewArea, y: cropRect.minY, width: viewMain.bounds.width - cropRect.maxX + hideSideViewArea, height: cropRect.height )
        }
        
        
        if isPaperLengthView{
            shadowFrameChanged()
        }
    }
    
    // MARK: - Gesture Recognizer delegate methods
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension CanvasCropView {
    func urlOfImg(image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return nil
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return nil
        }
        do {
            try data.write(to: directory.appendingPathComponent("fileName.png")!)
            if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                return  URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("fileName.png")
            }
            return nil
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

// MARK: - Blank Canvas Mamangement methods
extension CanvasCropView {
    
    func initBlueLines() {
        //SET BORDER LINE
        blueLineForviewToComposite = UIView()
        insertSubview(blueLineForviewToComposite, aboveSubview: viewWhiteCanvas)
        self.blueLineForviewToComposite.backgroundColor = UIColor.clear
        blueLineForviewToComposite.isUserInteractionEnabled = false
        blueLineForviewToComposite.layer.borderWidth = 1.8
        blueLineForviewToComposite.layer.borderColor = UIColor(red: 0 / 255.0, green: 150 / 255.0, blue: 214 / 255.0, alpha: 1).cgColor
        
        //Set Portrait blue line edge
        buttonImgBluePortraitBottom = UIButton()
        buttonImgBluePortraitBottom.setBackgroundImage(UIImage(named: "ruler_blueline_portrait_bottom"), for: .normal)
        insertSubview(buttonImgBluePortraitBottom, aboveSubview: bottomOverlayView)
        
        buttonImgBluePortraitTop = UIButton()
        buttonImgBluePortraitTop.setBackgroundImage(UIImage(named: "ruler_blueline_portrait_top"), for: .normal)
        insertSubview(buttonImgBluePortraitTop, aboveSubview: topOverlayView)
        
        //Set Landscape blue line edge
        buttonImgBlueLandscapeRight = UIButton()
        buttonImgBlueLandscapeRight.setBackgroundImage(UIImage(named: "ruler_blueline_landscape_right"), for: .normal)
        insertSubview(buttonImgBlueLandscapeRight, aboveSubview: leftOverlayView)
        
        buttonImgBlueLandscapeLeft = UIButton()
        buttonImgBlueLandscapeLeft.setBackgroundImage(UIImage(named: "ruler_blueline_landscape_left"), for: .normal)
        insertSubview(buttonImgBlueLandscapeLeft, aboveSubview: rightOverlayView)
        
        //Add Gesture For Drag canvas
        //Landscape
        pangestureToDragLandscapeCanvasRitgh = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureActionForLandscapeRight(_:)))
        buttonImgBlueLandscapeRight.addGestureRecognizer(pangestureToDragLandscapeCanvasRitgh)
        
        pangestureToDragLandscapeCanvasLeft = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureActionForLandscapeLeft(_:)))
        buttonImgBlueLandscapeLeft.addGestureRecognizer(pangestureToDragLandscapeCanvasLeft)
        
        //Portrait
        pangestureToDragPortraitCanvasBottom = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureActionForPortraitBottom(_:)))
        buttonImgBluePortraitBottom.addGestureRecognizer(pangestureToDragPortraitCanvasBottom)
        
        pangestureToDragPortraitCanvasTop = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureActionForPortraitTop(_:)))
        buttonImgBluePortraitTop.addGestureRecognizer(pangestureToDragPortraitCanvasTop)
        
    }
    
    //** Size calculation using ratio with respect to device size
    func calculteCanvasSize(aspectRatio: CGFloat, width: CGFloat?, height:CGFloat?, orienationaChange:Bool){
        isRulerImgFitForLessThanDefault = false
        if let width = width {
            //Portrait
            self.isLandscape = false
            let calculatedSize = aspectRatio * width
            viewWhiteCanvas.bounds = CGRect(x:0, y: 0, width: width, height: calculatedSize)
            orientationForBlueLine(isLandscape: false,calculatedSize:calculatedSize, givenSize: width)
        }
        if let height = height {
            //Landscape
            self.isLandscape = true
            let calculatedSize = aspectRatio * height
            viewWhiteCanvas.bounds = CGRect(x: 0, y: 0, width: calculatedSize, height: height)
            orientationForBlueLine(isLandscape: true,calculatedSize:calculatedSize, givenSize: height)
        }
        
        layoutOverlayViewsWithCropRect(viewWhiteCanvas.frame)
        if orienationaChange && (!isPositionChange && zoomScale == nil) {
            setupImgViewAgainForCanvasSizeChange(contentMode: .scaleAspectFit, orienationaChange:orienationaChange)
            print("dsdsd")
        } else {
            print("dddd")
            if orienationaChange == true {
                setupImgViewAgainForCanvasSizeChange(contentMode: .scaleAspectFit, orienationaChange:orienationaChange)
                print("vvv")

            } else {
                print("ffff")

                viewWhiteCanvas.center = self.viewMain.center
                viewImageGesture.frame = viewWhiteCanvas.frame
                viewImageGesture.center = self.viewMain.center
                viewImageGesture.transform = viewWhiteCanvas.transform
                self.imageView.center =  CGPoint(x: viewImageGesture.frame.width / 2, y: viewImageGesture.frame.height / 2)
            }
        }
        
        if isPaperLengthView {
            showOverlayView(color:  UIColor(red: 153 / 255.0, green: 145 / 255.0, blue: 145 / 255.0, alpha: 1), opacity: 1)
        } else {
            showOverlayView(color:  UIColor(red: 77 / 255.0, green: 77 / 255.0, blue: 77 / 255.0, alpha: 1), opacity: 1)
        }
        
        self.configureFrameView()

    }
    
    func orientationForBlueLine(isLandscape:Bool,calculatedSize:CGFloat,givenSize:CGFloat) {
        buttonImgBluePortraitBottom.isHidden = isLandscape
        buttonImgBluePortraitTop.isHidden = isLandscape
        buttonImgBlueLandscapeRight.isHidden = !isLandscape
        buttonImgBlueLandscapeLeft.isHidden = !isLandscape
        
        if isLandscape {
            blueLineForviewToComposite.frame = viewWhiteCanvas.frame
            buttonImgBlueLandscapeLeft.frame = CGRect(x: viewWhiteCanvas.frame.origin.x - 3 , y: viewWhiteCanvas.frame.origin.y - 3, width: 20, height: givenSize + 6)
            let xAxis = (self.frame.size.width - (self.frame.size.width - calculatedSize)/2) - 16
            let yAxis = viewWhiteCanvas.frame.origin.y - 4
            buttonImgBlueLandscapeRight.frame = CGRect(x: xAxis, y: yAxis, width: 20, height: givenSize + 6)
        } else {
            blueLineForviewToComposite.frame = viewWhiteCanvas.frame
            let xAxis = viewWhiteCanvas.frame.origin.x - 2
            let yAxis = (self.frame.size.height - (self.frame.size.height - calculatedSize)/2) - 16.5
            buttonImgBluePortraitBottom.frame = CGRect(x: xAxis, y: yAxis, width: givenSize + 5, height: 20)
            buttonImgBluePortraitTop.frame = CGRect(x: viewWhiteCanvas.frame.origin.x - 2, y: viewWhiteCanvas.frame.origin.y - 4.5, width: givenSize + 5, height: 20)
        }
        
        self.bringSubviewToFront(blueLineForviewToComposite)
        self.bringSubviewToFront(buttonImgBluePortraitBottom)
        self.bringSubviewToFront(buttonImgBluePortraitTop)
        self.bringSubviewToFront(buttonImgBlueLandscapeRight)
        self.bringSubviewToFront(buttonImgBlueLandscapeLeft)
    }
    
    @objc func panGestureActionForLandscapeRight(_ pan: UIPanGestureRecognizer){
        
        if pan.state == .began {
            startPosition = pangestureToDragLandscapeCanvasRitgh.location(in: buttonImgBluePortraitBottom)
            
        } else if  pan.state == .changed {
            endPosition = pan.location(in: buttonImgBluePortraitBottom)
            if let sPosition = startPosition, let ePosition = endPosition {
                
                if sPosition.x < ePosition.x {
                    //Increase Value
                    self.delegate?.didDragCanvas(self, didDragImage: true)
                } else if sPosition.x > ePosition.x{
                    //Decrease value
                    self.delegate?.didDragCanvas(self, didDragImage: false)
                }
                startPosition = endPosition
            }
            
        } else if pan.state == .ended {
            // You can handle this how you want.
        }
    }
    
    @objc func panGestureActionForPortraitBottom(_ pan: UIPanGestureRecognizer){
        if pan.state == .began {
            startPosition = pangestureToDragPortraitCanvasBottom.location(in: buttonImgBlueLandscapeRight)
        } else if  pan.state == .changed {
            endPosition = pan.location(in: buttonImgBlueLandscapeRight)
            if let sPosition = startPosition, let ePosition = endPosition {
                // Portrait
                if sPosition.y < ePosition.y {
                    //Increase Value
                    self.delegate?.didDragCanvas(self, didDragImage: true)
                } else if sPosition.y > ePosition.y{
                    //Decrease value
                    self.delegate?.didDragCanvas(self, didDragImage: false)
                }
                startPosition = endPosition
            }
        } else if pan.state == .ended {
            // You can handle this how you want.
        }
    }
    
    @objc func panGestureActionForLandscapeLeft(_ pan: UIPanGestureRecognizer){
        if pan.state == .began {
            startPosition = pangestureToDragLandscapeCanvasLeft.location(in: buttonImgBluePortraitTop)
        } else if  pan.state == .changed {
            endPosition = pan.location(in: buttonImgBluePortraitTop)
            if let sPosition = startPosition, let ePosition = endPosition {
                
                if sPosition.x > ePosition.x {
                    //Increase Value
                    self.delegate?.didDragCanvas(self, didDragImage: true)
                } else if sPosition.x < ePosition.x{
                    //Decrease value
                    self.delegate?.didDragCanvas(self, didDragImage: false)
                }
                startPosition = endPosition
            }
            
        } else if pan.state == .ended {
            // You can handle this how you want.
        }
    }
    
    @objc func panGestureActionForPortraitTop(_ pan: UIPanGestureRecognizer){
        if pan.state == .began {
            startPosition = pangestureToDragPortraitCanvasBottom.location(in: buttonImgBlueLandscapeRight)
            
        } else if  pan.state == .changed {
            endPosition = pan.location(in: buttonImgBlueLandscapeRight)
            if let sPosition = startPosition, let ePosition = endPosition {
                // Portrait
                if sPosition.y > ePosition.y {
                    //Increase Value
                    self.delegate?.didDragCanvas(self, didDragImage: true)
                } else if sPosition.y < ePosition.y{
                    //Decrease value
                    self.delegate?.didDragCanvas(self, didDragImage: false)
                }
                startPosition = endPosition
            }
            
        } else if pan.state == .ended {
            // You can handle this how you want.
        }
    }
    
    func configureFrameView() {
        frameImageView.frame = viewImageGesture.frame
        frameImageView.center = self.imageView.center
        self.toResetFrames(frame: (edit_selectedFrame as? String) ?? "")
        
        if transformScrollView != nil {
            /*
             let rect = self.viewWhiteCanvas.frame
             let rotatedRect = rect.applying(transformScrollView!)
             let width = rotatedRect.size.width
             let height = rotatedRect.size.height
             let center = viewImageGesture.center

             let contentOffset = viewImageGesture.contentOffset
             let contentOffsetCenter = CGPoint(x: contentOffset.x + viewImageGesture.bounds.size.width / 2, y: contentOffset.y + viewImageGesture.bounds.size.height / 2)
             viewImageGesture.frame.size.width = width
             viewImageGesture.frame.size.height = height
             let newContentOffset = CGPoint(x: contentOffsetCenter.x - viewImageGesture.bounds.size.width / 2, y: contentOffsetCenter.y - viewImageGesture.bounds.size.height / 2)
             viewImageGesture.contentOffset = newContentOffset
             viewImageGesture.center = center
             viewImageGesture.minimumZoomScale = scrollViewZoomScaleToBounds()
             viewImageGesture.setZoomScale(scrollViewZoomScaleToBounds(), animated: false)
             self.viewImageGesture.transform = transformScrollView!
             self.imageView.frame = self.viewImageGesture.bounds
             **/
//            self.imageView.transform = CGAffineTransform(scaleX: scrollViewZoomScaleToBounds(), y: scrollViewZoomScaleToBounds())
//            self.imageView.transform = transformScrollView!
        }
    }
        
    func scrollViewZoomScaleToBounds() -> CGFloat {
        /*
         let scaleW = viewImageGesture.bounds.size.width / self.viewWhiteCanvas.bounds.size.width
         let scaleH = viewImageGesture.bounds.size.height / self.viewWhiteCanvas.bounds.size.height
         **/
        let scaleW = viewImageGesture.bounds.size.width / self.imageView.bounds.size.width
        let scaleH = viewImageGesture.bounds.size.height / self.imageView.bounds.size.height
        return max(scaleW, scaleH)
    }
    
    func standardizeAngleSticker(_ angle: CGFloat) -> CGFloat {
        var angle = angle
        if angle >= 0, angle <= 2 * CGFloat.pi {
            return angle
        } else if angle < 0 {
            angle += 2 * CGFloat.pi

            return standardizeAngleSticker(angle)
        } else {
            angle -= 2 * CGFloat.pi

            return standardizeAngleSticker(angle)
        }
    }
    
    func autoHorizontalOrVerticalAngleSticker(_ angle: CGFloat) -> CGFloat {
        var angle = angle
        angle = standardizeAngleSticker(angle)

        let deviation: CGFloat = 0.017444444 // 1 * 3.14 / 180, sync with AngleRuler
        if abs(angle - 0) < deviation {
            angle = 0
        } else if abs(angle - CGFloat.pi / 2.0) < deviation {
            angle = CGFloat.pi / 2.0
        } else if abs(angle - CGFloat.pi) < deviation {
            angle = CGFloat.pi - 0.001 // Handling a iOS bug that causes problems with rotation animations
        } else if abs(angle - CGFloat.pi / 2.0 * 3) < deviation {
            angle = CGFloat.pi / 2.0 * 3
        } else if abs(angle - CGFloat.pi * 2) < deviation {
            angle = CGFloat.pi * 2
        }
        
        return angle
    }
    
    func toResetFrames(frame: String) {
        
        var frameNameArray = frame.components(separatedBy: "_")
        let photoLength: CGFloat = self.imgNewRatio
        var sizeType = ""
        if photoLength <= 2 {
            sizeType = "1"
        } else if photoLength <= 5 {
            sizeType = "4"
        } else if photoLength <= 7 {
            sizeType = "7"
        } else if photoLength <= 9 {
            sizeType = "9"
        } else {
            sizeType = "9"
        }
        
        if frame.contains("L") {
            frameNameArray.removeLast()
            frameNameArray.removeLast()
        } else {
            frameNameArray.removeLast()
        }
        
        
        let prefixName =  frameNameArray.joined(separator: "_")
        var imageName = "\(prefixName)_\(sizeType)"
        if self.isLandscape == true {
            imageName = "\(prefixName)_\(sizeType)_L"
        }
        self.frameImageView.image = UIImage(named: imageName)
    }
}

//MARK: Canvas Mamangement methods for Paper Length
extension CanvasCropView {
    
    func canvasFrame(isLandscape:Bool,aspectRatio: CGFloat,size: CGFloat, image:UIImage, contentMode:ContentMode,orienationaChange:Bool) {
        self.isLandscape = isLandscape
        let calculatedSize = aspectRatio * size
        if isLandscape {
            //Landscape
            viewWhiteCanvas.bounds = CGRect(x: 0, y: 0, width: calculatedSize, height: size)
        } else {
            //Portrait
            viewWhiteCanvas.bounds = CGRect(x: 0, y: 0, width: size, height: calculatedSize)
        }
        layoutOverlayViewsWithCropRect(viewWhiteCanvas.frame)
        
        if !orienationaChange || (!isPositionChange && zoomScale == nil) {
            self.image = image
            setupImgViewAgainForCanvasSizeChange(contentMode: contentMode, orienationaChange:orienationaChange)
        } else {
            self.image = image
            setupImgViewAgainForCanvasSizeChange(contentMode: contentMode, orienationaChange:orienationaChange)
        }
        
        if isPaperLengthView {
            showOverlayView(color: UIColor(red: 153 / 255.0, green: 145 / 255.0, blue: 145 / 255.0, alpha: 1), opacity: 1)
        } else {
            showOverlayView(color:  UIColor(red: 77 / 255.0, green: 77 / 255.0, blue: 77 / 255.0, alpha: 1), opacity: 1)
        }
    }
    
    func setupImgViewAgainForCanvasSizeChange(contentMode: ContentMode,orienationaChange:Bool,isClearTransform:Bool?=true) {
        self.viewMain.frame = bounds
        viewWhiteCanvas.center = self.viewMain.center
        viewImageGesture.center = self.viewMain.center
        viewImageGesture.transform = viewWhiteCanvas.transform
        
        imageView.removeFromSuperview()
        if contentMode == .scaleAspectFill {
            self.isAspectFill = true
        } else {
            self.isAspectFill = false
        }
        
        self.paperLengthImageMovementTransform = nil
        zoomScale = nil
        isPositionChange = false
        paperLengthImageRotation = nil
        
        setupImageView(contentMode: contentMode)
        self.delegate?.cropView(self, didMoveImage: self.isPositionChange)
    }
}

extension UIColor {
    convenience init(hexaString: String, alpha: CGFloat = 1) {
        let chars = Array(hexaString.dropFirst())
        self.init(red:   .init(strtoul(String(chars[0...1]),nil,16))/255,
                  green: .init(strtoul(String(chars[2...3]),nil,16))/255,
                  blue:  .init(strtoul(String(chars[4...5]),nil,16))/255,
                  alpha: alpha)}
}

@objc extension UIView {
    
    func scale(by scale: CGFloat) {
        self.contentScaleFactor = scale
        for subview in self.subviews {
            subview.scale(by: scale)
        }
    }
    
    @objc func takeScreenshot() -> UIImage {
        let newScale = UIScreen.main.scale
        self.scale(by: newScale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = newScale
        
        let renderer = UIGraphicsImageRenderer(size:self.bounds.size, format: format)
        let image = renderer.image { rendererContext in
            self.layer.render(in: rendererContext.cgContext)
        }
        return image
    }
    
    func getAspectRatioSize(isLandscape:Bool,oneAspectRatio:CGFloat,size:CGFloat) -> CGSize{
        var size:Double = size
        var newSize:Double = size
        
        repeat {
            if oneAspectRatio < 2 {
                newSize = size * oneAspectRatio/2
                size -= 1
            } else {
                newSize = size * 2/oneAspectRatio
                size += 1
            }
        } while newSize.rounded(.up) != newSize.rounded(.down)
        
        if oneAspectRatio < 2 {
            //AS per aspect ratio <2, changes the orientation. This condition occours from ruler Screen
            if isLandscape {
                //portrait
                return CGSize(width: newSize, height: (size + 1 ))
            } else {
                //landscape
                return CGSize(width: (size + 1 ), height: newSize)
            }
        } else {
            
            if isLandscape {
                //landscape
                return CGSize(width: (size + 1 ), height: newSize)
            } else {
                //portrait
                return CGSize(width: newSize, height: (size + 1 ))
            }
        }
    }
}

extension UIImage {
    struct RotationOptions: OptionSet {
        let rawValue: Int
        
        static let flipOnVerticalAxis = RotationOptions(rawValue: 1)
        static let flipOnHorizontalAxis = RotationOptions(rawValue: 2)
    }
    
    func rotated(by rotationAngle: Measurement<UnitAngle>, options: RotationOptions = []) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let rotationInRadians = CGFloat(rotationAngle.converted(to: .radians).value)
        let transform = CGAffineTransform(rotationAngle: rotationInRadians)
        var rect = CGRect(origin: .zero, size: self.size).applying(transform)
        rect.origin = .zero
        
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { renderContext in
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: rotationInRadians)
            
            let xAxis = options.contains(.flipOnVerticalAxis) ? -1.0 : 1.0
            let yAxis = options.contains(.flipOnHorizontalAxis) ? 1.0 : -1.0
            renderContext.cgContext.scaleBy(x: CGFloat(xAxis), y: CGFloat(yAxis))
            let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
    }
}
