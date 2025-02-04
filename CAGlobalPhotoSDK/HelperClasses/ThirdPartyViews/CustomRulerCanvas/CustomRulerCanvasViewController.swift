//
//  CustomRulerCanvasViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/05/23.
//

import Foundation
import UIKit
import Photos
protocol RulerCanvasDelegate {
    func dismissWithUpdatedRatio(paperLengthImageMovementTransform: CGAffineTransform,
                                 paperLengthImageRotation: CGAffineTransform,
                                 previousImageViewTransform: CGAffineTransform,
                                 scrollViewZoomScale: Int,
                                 scrollviewPaperLengthFrame: CGRect ,
                                 isImageAlreadyEdited: Bool,
                                 isFillImage: Bool,
                                 isLandscape: Bool,
                                 selectedRatioWith: CGFloat,
                                 image:UIImage)
    func backButtonClicked(isLandscape: Bool)
}




@objc public class CustomRulerCanvasViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var sliderCustomRange: ThumbTextSlider!
    @IBOutlet weak var viewCustomCanvas: CanvasCropView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nextButton: UIButton!

    let option = EditOptions()
    var stickerManager = StickerManager()

    // MARK: - Variables and Properties
    var viewDottedVertical: UIView!
    var viewDottedHorizontal: UIView!
    var buttonOrientation = UIButton(type: .custom)
    var buttonFitFill = UIButton(type: .custom)
    var floatingButtonsView = UIView()
    var isBlankCanvasRuler: Bool = true
    var isFromPaperLength: Bool = true
    var isLandscape = true
    var dottedLinePortraitWidth = 0.0
    var dottedLineLandscapeWidth = 0.0
    var dottedLinePortraitHeight = 0.0
    var dottedLineLandscapeHeight = 0.0
    var sliderCanvasImageValue:CGFloat?
    var paperLengthImageRotation:CGAffineTransform?
    var paperLengthImageMovement:CGAffineTransform?
    
    var transformScrollView:CGAffineTransform?
    var zoomScrollView:CGFloat?

    var scrollViewZoomScale:CGFloat?
    var isFillImage = false
    var scrollviewPaperLengthFrame:CGRect?
    var saveIamgeToGallery: Bool = false
    var goToPreview: Bool = false
    var isDragEventFromRuler: Bool = false
    var isImageAlreadyEdited: Bool = false
    var isImageEditedFromEditor: Bool = false
    var previousImageView: UIImageView?
    var rulerCanvasDelegate: RulerCanvasDelegate?
    var selectedColor = UIColor()
    var previousImageViewTransform: CGAffineTransform?
    var navigateFromEditScreen = false
    var paintImageView = UIImageView()
    
    open var image: UIImage? {
        didSet {
            viewCustomCanvas?.image = image
        }
    }
    
    open var rotationEnabled = false {
        didSet {
            viewCustomCanvas?.rotationGestureRecognizer.isEnabled = rotationEnabled
        }
    }
    
    var originalFinalImageSize: CGSize? = CGSize.zero
    var originalCanvasOrientation: CanvasOrientation?
    var originalCanvasContentMode: CanvasContentMode?
    var originalImageMoved: Bool = false
    var originalImageLengthRatio: CGFloat? = CGFloat.zero
    
    // Cropper View Controller properties
    var viewFrame: CGRect?
    var angle: CGFloat?
    var rotationAngle: CGFloat?
    var straightenAngle: CGFloat?
    var flipAngle: CGFloat?
    var imageOrientationRawValue: Int?
    
    var scrollViewBounds: CGRect?
    
    var cropBoxFrame: CGRect?
    var photoTranslation: CGPoint?
    var imageViewTransform: CGAffineTransform?
    var imageViewBoundsSize: CGSize?
    var bestFitRatioValue: CGFloat?
    var selectedRatioWith: CGFloat?
    var originalImageSize: CGSize? = CGSize.zero
    
    var drawingImage:UIImage?
    var editSelectedFrame: Any?
    var drawingStickerImage:UIImage?
    lazy var stickerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]
        view.tag = 1001
      //  view.backgroundColor = .red
        return view
    }()
    
    lazy var viewPaint: DrawingView = {
        let view = DrawingView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .clear
        view.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]
     //   view.backgroundColor = .yellow
        return view
    }()
    
    // MARK: - View Life Cycle
    public override func viewDidLoad() {
        GlobalHelper.sharedManager.isRulerSliderChange = false

        super.viewDidLoad()
        self.selectedColor = .white
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        extendedLayoutIncludesOpaqueBars = true
        self.viewCustomCanvas.isBlankCanvasRuler = self.isBlankCanvasRuler
        self.viewCustomCanvas.isPaperLengthView = false
        self.viewCustomCanvas?.image = image
        self.viewCustomCanvas.delegate = self

        if let value = self.sliderCanvasImageValue {
            self.viewCustomCanvas?.imgDefaultRatio = CGFloat(value)
            self.sliderCustomRange.value = Float(value)
            self.viewCustomCanvas.imgNewRatio = value
        } else {
            self.viewCustomCanvas.imgNewRatio = 3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.initPortraitDottedLineWidthAsPerDeviceSize()
            self.initLandscapeDottedLineHeightAsPerDeviceSize()
            if self.isBlankCanvasRuler {
                self.initCanvasWithoutImage()
                self.changeCanvasSize(orienationaChange: false)
            } else {
                self.initCanvasWithImage()
                let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(CustomPaperLengthViewController.actionFitFillChnage(_:)))
                doubleTapGesture.numberOfTapsRequired = 2
                self.viewCustomCanvas.addGestureRecognizer(doubleTapGesture)
                if self.previousImageView != nil {
                    self.viewCustomCanvas.imageView.transform = self.previousImageView!.transform
                }
                if !self.isFromPaperLength {
                    self.viewCustomCanvas.imageView.transform = self.previousImageViewTransform ?? self.viewCustomCanvas.imageView.transform
                }
                self.changeCanvasSize(orienationaChange: false)
            }
            self.viewDottedVertical.backgroundColor = .clear
            self.viewDottedHorizontal.backgroundColor = .clear
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            self.setOriginalImageParameters()
        }
        
        viewCustomCanvas.viewWhiteCanvas.backgroundColor = self.selectedColor

        viewCustomCanvas.setupImgViewAgainForCanvasSizeChange(contentMode: .scaleAspectFill, orienationaChange:false)

    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isFromPaperLength {
            self.nextButton.setTitle("Done", for: .normal)
            self.nextButton.titleLabel?.text = "Done"
        }
        
        setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.navigateFromEditScreen == false {
            if self.isBlankCanvasRuler {
                self.orientationFloatingButtonForBlankCanvas()
            } else {
                self.orientationFloatingButtonForImage()
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        self.buttonOrientation.removeFromSuperview()
        self.buttonFitFill.removeFromSuperview()
        self.floatingButtonsView.removeFromSuperview()
    }
    
    // MARK: - Functions
    func setOriginalImageParameters() {
        var originalImage: UIImage?
        repeat {
            if let image = viewCustomCanvas.finalImage {
                originalImage = image
            } else {
                originalImage = nil
            }
        } while (originalImage == nil)
        
        self.originalFinalImageSize = originalImage?.size
        self.originalCanvasOrientation = self.isLandscape ? .landscape : .portrait
        self.originalCanvasContentMode = self.isFillImage ? .fill : .fit
        self.originalImageLengthRatio = self.viewCustomCanvas.imgNewRatio
    }
    
    func isImageEdited(_ image: UIImage?) -> Bool {
        guard let image = image else {
            return false
        }
        var returnEdited = false
        
        let currentImageSize = image.size
        let currentOrientation:CanvasOrientation = self.isLandscape ? .landscape : .portrait
        let currentContentMode: CanvasContentMode = self.isFillImage ? .fill : .fit
        
        if self.isImageAlreadyEdited {
            returnEdited = true
        }
        
        if originalImageLengthRatio == viewCustomCanvas.imgNewRatio && self.originalCanvasOrientation == currentOrientation {
            // For this case,
            // Image was originally and finally in the best fit with same orientation.
            // This should neglect the change in contentMode of the canvas.
        } else if self.originalCanvasContentMode != currentContentMode  {
            returnEdited = true
        }
        
        if self.originalCanvasOrientation != currentOrientation  {
            returnEdited = true
        }
        
        if self.originalFinalImageSize != currentImageSize {
            returnEdited = true
        }
        
        if self.originalImageMoved  {
            returnEdited = true
        }
        
        return returnEdited
    }
    
    func changeCanvasSize(orienationaChange:Bool){
        GlobalHelper.sharedManager.isRulerSliderChange = true

        let valueOfSlider = (Double(sliderCustomRange.value).rounded(toPlaces: 1))
        viewCustomCanvas.imgNewRatio = valueOfSlider
        if isLandscape {
            if sliderCustomRange.value == 9 {
                self.viewDottedHorizontal.isHidden = true
            } else {
                self.viewDottedHorizontal.isHidden = false
            }
            viewCustomCanvas.calculteCanvasSize(aspectRatio: CGFloat(sliderCustomRange.value)/2.0, width: nil, height: dottedLineLandscapeHeight, orienationaChange: orienationaChange)
        } else {
            if sliderCustomRange.value == 9 {
                self.viewDottedVertical.isHidden = true
            } else {
                self.viewDottedVertical.isHidden = false
            }
            viewCustomCanvas.calculteCanvasSize(aspectRatio: CGFloat(sliderCustomRange.value)/2.0, width: dottedLinePortraitWidth, height: nil, orienationaChange: orienationaChange)
        }
        if let image = viewCustomCanvas.image {
            if isDragEventFromRuler {
                self.eventImageDraggingByRuler(withImage: image)
            } else {
                self.eventImageDraggingByRuler(withImage: image)
            }
        }        
    }
    
    func initPortraitDottedLineWidthAsPerDeviceSize(){
        //As portrit, height is constant, need to calculte width for ratio 2:9
        //Added dotted view insted of ImaheView
        self.viewDottedVertical = UIView()
        self.viewDottedVertical.frame.size.height = viewCustomCanvas.frame.size.height - 40
        
        dottedLinePortraitHeight = self.viewDottedVertical.frame.size.height
        dottedLinePortraitWidth = dottedLinePortraitHeight * (2/9)
        
        self.viewDottedVertical.frame.size.width = dottedLinePortraitWidth - 2
        viewCustomCanvas.addSubview(self.viewDottedVertical)
        let width = viewCustomCanvas.frame.size.width
        self.viewDottedVertical.frame.origin.y = 20
        self.viewDottedVertical.frame.origin.x = (width / 2) - (dottedLinePortraitWidth/2) + 1
        
    }
    
    func initLandscapeDottedLineHeightAsPerDeviceSize() {
        //As landscape, width is constant, need to calculte heigth for ratio 9:2
        //Added dotted view insted of ImaheView
        self.viewDottedHorizontal = UIView()
        self.viewDottedHorizontal.frame.size.width = viewCustomCanvas.frame.size.width - 10
        
        dottedLineLandscapeWidth = self.viewDottedHorizontal.frame.size.width
        dottedLineLandscapeHeight = dottedLineLandscapeWidth * (2/9)
        self.viewDottedHorizontal.frame.size.height = dottedLineLandscapeHeight - 2
        viewCustomCanvas.addSubview(self.viewDottedHorizontal)
        let height = viewCustomCanvas.frame.size.height
        self.viewDottedHorizontal.frame.origin.y = (height / 2) - (dottedLineLandscapeHeight/2) + 1
        self.viewDottedHorizontal.frame.origin.x = 5
    }
    
    // MARK: - - Button Action
    @IBAction func actionBackButton(_ sender: Any) {
        if isBlankCanvasRuler == true {
            zoomScale = nil
            if self.presentingViewController != nil {
                self.dismiss(animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            zoomScale = nil
            self.navigationController?.popViewController(animated: true)
        }
        
        self.rulerCanvasDelegate?.backButtonClicked(isLandscape: isLandscape)
    }
    
    @IBAction func actionNextButton(_ sender: Any) {
        if !isFromPaperLength {
            viewCustomCanvas?.frameImageView.isHidden = true
            self.stickerView.removeFromSuperview()
            self.paintImageView.removeFromSuperview()
            if let newImage = viewCustomCanvas?.finalImage {
                let paperLengthImageMovement = viewCustomCanvas?.paperLengthImageMovementTransform ?? viewCustomCanvas.transform
                let paperLengthImageRotation = viewCustomCanvas?.paperLengthImageRotation ?? viewCustomCanvas.transform
                _ = 1
                let scrollviewPaperLengthFrame = (viewCustomCanvas?.frame)!
                let isImageEdited = self.isImageEdited(newImage, goingToEditor: false)
                let isFillImage = isFillImage
                let isLandscape = isLandscape
                let sliderCanvasImageValue = CGFloat(sliderCustomRange.value)
                let previousImageViewTransform = self.viewCustomCanvas.imageView.transform
                self.rulerCanvasDelegate?.dismissWithUpdatedRatio(paperLengthImageMovementTransform: paperLengthImageMovement, 
                                                                  paperLengthImageRotation: paperLengthImageRotation,
                                                                  previousImageViewTransform: previousImageViewTransform,
                                                                  scrollViewZoomScale: 1,
                                                                  scrollviewPaperLengthFrame: scrollviewPaperLengthFrame,
                                                                  isImageAlreadyEdited: isImageEdited,
                                                                  isFillImage: isFillImage,
                                                                  isLandscape: isLandscape,
                                                                  selectedRatioWith: sliderCanvasImageValue,
                                                                  image: newImage)
            }
        } else {

            let viewController = CAEditViewController(nibName: CAEditViewController.className, bundle: nil)
            if let newImage = viewCustomCanvas?.finalImage {
                viewController.imageOrignal = newImage
                viewController.imageOrignalBackUp = newImage
                viewController.isImageAlreadyEdited = self.isImageEdited(newImage)
            }
            viewController.selectedRatioWith = CGFloat(sliderCustomRange.value)
            viewController.isLandscape = self.isLandscape
            viewController.selectedRatioWith2 = self.selectedRatioWith ?? 0
            viewController.isLandscape2 = self.isLandscape
            viewController.isBlankCanvasRuler = self.isBlankCanvasRuler
            viewController.selectedCanvasColor = self.selectedColor
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func actionOrientationChnage(_ sender: Any) {
        self.isDragEventFromRuler = true
        
        if isLandscape {
            self.viewDottedHorizontal.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.isLandscape = false
                self.viewDottedVertical.isHidden = false
                self.changeCanvasSize(orienationaChange: true)
                
                let subViews = self.stickerView.subviews
                for subview in subViews {
                    if subview is UIImageView {
                        subview.removeFromSuperview()
                    }
                }
                let image = UIImageView()
                image.frame = self.viewCustomCanvas.imageView.frame
                image.contentMode = self.viewCustomCanvas.imageView.contentMode
                image.center = self.viewCustomCanvas.imageView.center
                image.image = self.drawingStickerImage
                self.stickerView.addSubview(image)
                self.viewCustomCanvas.viewImageGesture.addSubview(self.paintImageView)
                self.viewCustomCanvas.viewImageGesture.addSubview(self.stickerView)

            }
        } else {
            self.viewDottedVertical.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.isLandscape = true
                self.viewDottedHorizontal.isHidden = false
                self.changeCanvasSize(orienationaChange: true)
                self.viewCustomCanvas.viewImageGesture.addSubview(self.paintImageView)
                self.viewCustomCanvas.viewImageGesture.addSubview(self.stickerView)
//                self.paintImageView.frame = self.viewCustomCanvas.viewImageGesture.bounds

            }
        }
        
        //stickerView.removeFromSuperview()

       // stickerView.bringSubviewToFront(self.viewCustomCanvas.imageView)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            
//            //Sticker
//            let widthRatio = self.stickerView.frame.width / self.viewCustomCanvas.viewImageGesture.frame.size.width
//            let heightRatio = self.stickerView.frame.height / self.viewCustomCanvas.viewImageGesture.frame.size.height
//            
//            self.stickerView.frame = CGRectMake(0, 0, self.viewCustomCanvas.viewImageGesture.frame.size.width, self.viewCustomCanvas.viewImageGesture.frame.size.height)
//            
//            if self.transformScrollView != nil {
//                self.stickerView.transform = self.transformScrollView!
//            }
//            
//            let subViews = self.stickerView.subviews
//            for subview in subViews {
//                if subview is AddSticker {
//                    if let addSticker = subview as? AddSticker {
//                        let origin = addSticker.frame.origin
//                        let size = addSticker.frame.size
//                        if self.isLandscape {
//                            
//                        } else {
//                            
//                        }
//                        let frame = CGRect(x: origin.x/heightRatio , y: origin.y/widthRatio , width: size.width/widthRatio, height: size.height/heightRatio)
//                        addSticker.frame = frame
//                    }
//                }
//                
//                if subview is AddTextView {
//                    if let addSticker = subview as? AddTextView {
//                        addSticker.font = UIFont.systemFont(ofSize: addSticker.font.pointSize/heightRatio)
//                        let origin = addSticker.frame.origin
//                        let size = addSticker.frame.size
//                        
//                        let frame = CGRect()
//                        if self.isLandscape {
//                            
//                        } else {
//                            
//                        }
//                        let frame = CGRect(x: origin.x/heightRatio , y: origin.y/widthRatio , width: size.width/widthRatio, height: size.height/heightRatio)
//                        addSticker.frame = frame
//                    }
//                }
//            }
//            
//            self.viewCustomCanvas.viewImageGesture.addSubview(self.stickerView)
//
//        }
    }
    
    @objc func actionFitFillChnage(_ sender:Any){
        if self.navigateFromEditScreen == false {
            viewCustomCanvas.isRulerImgFitForLessThanDefault = false
            if let _ = self.image {
                if isFillImage {
                    isFillImage = false
                    GlobalHelper.sharedManager.isRulerSliderChange = true

                    viewCustomCanvas.setupImgViewAgainForCanvasSizeChange(contentMode: .scaleAspectFit, orienationaChange:false)
                    viewCustomCanvas.isRulerImgFitForLessThanDefault = false
                    if viewCustomCanvas.imgNewRatio < viewCustomCanvas.imgDefaultRatio {
                        viewCustomCanvas.isRulerImgFitForLessThanDefault = true
                    }
                } else {
                    isFillImage = true
                    GlobalHelper.sharedManager.isRulerSliderChange = false
                    viewCustomCanvas.setupImgViewAgainForCanvasSizeChange(contentMode: .scaleAspectFill, orienationaChange:false)
                }
                self.viewCustomCanvas.imageView.addSubview(paintImageView)
                self.viewCustomCanvas.imageView.addSubview(stickerView)

            }
        }
    }
    
    @IBAction func actionSliderValueChange(_ sender: Any) {
        self.changeCanvasSize(orienationaChange: false)
    }
    
    // MARK: - - Copilot Event Functions
    
    func eventTapNext(withImage image: UIImage) {
        
    }
    
    func eventImageDraggingByTouch(withImage image: UIImage) {
        
    }
    
    func eventImageDraggingByRuler(withImage image: UIImage) {
        
    }
    
    func isImageEdited(_ image: UIImage?, goingToEditor: Bool) -> Bool {
        guard let image = image else {
            return false
        }
        var returnEdited = false
        
        let currentImageSize = image.size
        let currentOrientation:CanvasOrientation = self.isLandscape ? .landscape : .portrait
        let currentContentMode: CanvasContentMode = self.isFillImage ? .fill : .fit
        
        if self.bestFitRatioValue == 2.0 && self.selectedRatioWith == 2.0 {
            // For this case,
            // Image was originally and finally square.
            // This should neglect the change in contentMode or orientation of canvas.
        } else if self.originalCanvasOrientation == currentOrientation {
            // For this case,
            // Image was originally and finally in the best fit with same orientation.
            // This should neglect the change in contentMode of the canvas.
        } else {
            
            if self.originalCanvasOrientation != currentOrientation  {
                returnEdited = true
            }
            
            if self.originalCanvasContentMode != currentContentMode  {
                returnEdited = true
            }
        }
        
        if goingToEditor {
            if self.originalFinalImageSize != currentImageSize {
                returnEdited = true
            }
        } else {
            if self.originalImageSize != currentImageSize {
                returnEdited = true
            }
        }
        
        if self.originalImageMoved  {
            returnEdited = true
        }
        
        return returnEdited
    }
    
    func moveToPnPreviewController(finalImage: UIImage) {
        let image = finalImage
        var canvasResult: UIImage

        if GlobalHelper.sharedManager.selectedRatioWith < 2.0 {
            canvasResult = CanvasRatioManager.shared.newGetImageAccordingPrintRatio(image: image, ratio: GlobalHelper.sharedManager.selectedRatioWith)
        } else {
            canvasResult = CanvasRatioManager.shared.getImageAccordingPrintRatio(image: image, ratio: GlobalHelper.sharedManager.selectedRatioWith)
        }

        GlobalHelper.sharedManager.isLandcape = false
        if image.size.width > image.size.height {
            GlobalHelper.sharedManager.isLandcape = true
        }

//        let cMedia = HPPRCameraRollMedia()
//        cMedia.placeholderImage = canvasResult
//        cMedia.createdTime = Date()
//        cMedia.mediaType = .image
//        cMedia.videoPlaybackUri = nil
//        PGPhotoSelection.sharedInstance().select(cMedia)
//        GlobalHelper.sharedManager.fromPhotobooth = true

//        let storyboard = UIStoryboard(name: "PG_Preview", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "PNPreviewViewController") as! PNPreviewViewController
//
//        let isLessThanTwoInches = GlobalHelper.sharedManager.selectedRatioWith < 2.0
//        controller.isLessThanTwoInches = isLessThanTwoInches
//        controller.isFromBlankScreen = true
//        if image.size.height > image.size.width && isLessThanTwoInches {
//            controller.makePintImageLandscape = true
//        } else if isLessThanTwoInches && image.size.width > image.size.height {
//            controller.makePintImageLandscape = true
//        } else {
//            controller.makePintImageLandscape = false
//        }
//
//        controller.imageWithActualRatio = image
//        controller.source = "Gallery"
//        controller.navigateFromController = self
//        controller.isImageAlreadyEdited = true
//        GlobalHelper.sharedManager.navigationController.pushViewController(controller, animated: true)
    }

}

// MARK: - CropView Delegate
extension CustomRulerCanvasViewController: CropViewDelegate {
    @objc func dragCanvasReceivedNotification(moved: Bool) {
        self.isDragEventFromRuler = false
        if moved == true {
            self.sliderCustomRange.value += 0.1
        } else {
            self.sliderCustomRange.value -= 0.1
        }
        self.changeCanvasSize(orienationaChange: false)
    }
    
    func didDragCanvas(_ cropView: CanvasCropView, didDragImage moved: Bool) {
        self.dragCanvasReceivedNotification(moved: moved)
    }
    
    func cropView(_ cropView: CanvasCropView, didMoveImage moved: Bool) {
        self.originalImageMoved = moved
    }
}

// MARK: - Customised slider class
class ThumbTextSlider: UISlider {
    var thumbTextLabel: UILabel = UILabel()
    
    private var thumbFrame: CGRect {
        return thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: CGRect(x: bounds.origin.x, y: bounds.origin.y,  width: bounds.width, height: bounds.height - 60)), value: value)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        thumbTextLabel.frame = thumbFrame
        thumbTextLabel.frame.size.width = 100
        
        let valueOfSlider = (Double(value).rounded(toPlaces: 1))
        let decimalValue = Decimal(valueOfSlider)
        if decimalValue.isWholeNumber{
            thumbTextLabel.text = "\(Int(valueOfSlider))\""
        } else {
            thumbTextLabel.text = "\(valueOfSlider)\""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(thumbTextLabel)
        if let thumbImage = UIImage(named: "slider_thumb_ruler") {
            self.setThumbImage(thumbImage, for: .normal)
        }
        thumbTextLabel.textAlignment = .left
        thumbTextLabel.font = FontManager.largeBold
        thumbTextLabel.textColor = .white
        self.minimumTrackTintColor = .clear
        self.maximumTrackTintColor = .clear
    }
}

extension Decimal {
    var isWholeNumber: Bool {
        return self.isZero || (self.isNormal && self.exponent >= 0)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension CustomRulerCanvasViewController {
    // MARK: - Orientation Floating button
    func orientationFloatingButtonForBlankCanvas(){
        let xAxis = UIScreen.main.bounds.size.width - 70
        let yAxis = UIScreen.main.bounds.size.height - (UIScreen.main.bounds.size.height - viewCustomCanvas.frame.size.height - 10)
        self.buttonOrientation.frame = CGRect(x: xAxis, y: yAxis , width: 55, height: 55)
        self.buttonOrientation.setBackgroundImage(UIImage(named: "orientation_change"), for: .normal)
        self.buttonOrientation.clipsToBounds = true
        self.buttonOrientation.addTarget(self,action: #selector(CustomRulerCanvasViewController.actionOrientationChnage(_:)), for: .touchUpInside)
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            window.addSubview(self.buttonOrientation)
        }
    }
    
    // MARK: - Orientation Floating button
    func orientationFloatingButtonForImage(){
        let xAxis = UIScreen.main.bounds.size.width - 55
        let yAxis = UIScreen.main.bounds.size.height - (UIScreen.main.bounds.size.height - viewCustomCanvas.frame.size.height + 50)
        self.floatingButtonsView.frame = CGRect(x: xAxis, y: yAxis , width: 42, height: 95)
        self.floatingButtonsView.backgroundColor = UIColor(patternImage: UIImage(named: "custom_lenght_floating_background")!)
        
        //Orientation button
        self.buttonOrientation.frame = CGRect(x: -3, y: 1 , width: 47, height: 47)
        self.buttonOrientation.setImage(UIImage(named: "custom_length_orientation"), for: .normal)
        self.buttonOrientation.clipsToBounds = true
        self.buttonOrientation.addTarget(self,action: #selector(CustomRulerCanvasViewController.actionOrientationChnage(_:)), for: .touchUpInside)
        self.buttonOrientation.isUserInteractionEnabled = true
        
        self.buttonFitFill.frame = CGRect(x: -3, y: 44, width: 47, height: 47)
        self.buttonFitFill.setImage(UIImage(named: "custom_length_fitfill"), for: .normal)
        self.buttonFitFill.clipsToBounds = true
        self.buttonFitFill.addTarget(self,action:#selector(CustomRulerCanvasViewController.actionFitFillChnage(_:)), for: .touchUpInside)
        self.buttonFitFill.isUserInteractionEnabled = true
        
        self.floatingButtonsView.addSubview(self.buttonOrientation)
        self.floatingButtonsView.addSubview(self.buttonFitFill)
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            window.addSubview(self.floatingButtonsView)
        }
    }
}


extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

extension UIView {
    func addDashedBorders() {
        let color = UIColor(red: 167 / 255.0, green: 167 / 255.0, blue: 167 / 255.0, alpha: 1).cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1.5
        shapeLayer.lineJoin = CAShapeLayerLineJoin.bevel
        shapeLayer.lineDashPattern = [8,5]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 0).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
}

extension CustomRulerCanvasViewController {
    
    func initCanvasWithImage() {
        self.viewCustomCanvas.navigateFromEditScreen = navigateFromEditScreen
        self.viewCustomCanvas.edit_selectedFrame = editSelectedFrame

        self.viewCustomCanvas.addSubview(self.viewDottedHorizontal)
        self.viewCustomCanvas.addSubview(self.viewDottedVertical)
        
        self.viewDottedHorizontal.isUserInteractionEnabled = false
        self.viewDottedVertical.isUserInteractionEnabled = false
        
        let aspectRatio = (sliderCustomRange.value)/2.0
        if isLandscape {
            self.viewDottedVertical.isHidden = true
            self.viewDottedHorizontal.isHidden = false
            viewCustomCanvas?.calculteCanvasSize(aspectRatio: CGFloat(aspectRatio), width: nil, height: dottedLineLandscapeHeight, orienationaChange: false)
        } else {
            self.viewDottedVertical.isHidden = false
            self.viewDottedHorizontal.isHidden = true
            viewCustomCanvas?.calculteCanvasSize(aspectRatio: CGFloat(aspectRatio), width: dottedLinePortraitWidth, height: nil, orienationaChange: false)
        }
        
        if (paperLengthImageMovement != nil) || (paperLengthImageRotation != nil) {
            viewCustomCanvas.isPositionChange = true
        } else {
            viewCustomCanvas.isPositionChange = false
        }
        
        viewCustomCanvas.paperLengthImageRotation = paperLengthImageRotation
        viewCustomCanvas.paperLengthImageMovementTransform = imageViewTransform
        viewCustomCanvas.transformScrollView = transformScrollView

        if isFillImage {
            viewCustomCanvas.setupImageView(contentMode: .scaleAspectFill)
        } else {
            viewCustomCanvas.setupImageView(contentMode: .scaleAspectFit)
        }
        
        //Sticker
        let widthDevide = (self.scrollViewBounds?.size.width ?? 0)/self.viewCustomCanvas.viewImageGesture.frame.size.width
        let heightDevide = (self.scrollViewBounds?.size.height ?? 0)/self.viewCustomCanvas.viewImageGesture.frame.size.height
        print(widthDevide,heightDevide)
        
        let widthRatio = stickerView.frame.width / self.viewCustomCanvas.viewImageGesture.frame.size.width
        let heightRatio = stickerView.frame.height / self.viewCustomCanvas.viewImageGesture.frame.size.height
        print(widthRatio,heightRatio)
        stickerView.frame = CGRectMake(0, 0, self.viewCustomCanvas.viewImageGesture.frame.size.width, self.viewCustomCanvas.viewImageGesture.frame.size.height)
        
        stickerView.isUserInteractionEnabled = false
        let subViews = stickerView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let addSticker = subview as? AddSticker {
                    addSticker.removeFromSuperview()
                }
            }
            
            if subview is AddTextView {
                if let addSticker = subview as? AddTextView {
                    addSticker.removeFromSuperview()
                }
            }
        }
        

        let image = UIImageView()
        image.frame = CGRectMake(0, 0, self.viewCustomCanvas.viewImageGesture.frame.size.width, self.viewCustomCanvas.viewImageGesture.frame.size.height)
        image.image = self.drawingStickerImage
        self.stickerView.addSubview(image)
        self.viewCustomCanvas.imageView.addSubview(stickerView)
        
        paintImageView = UIImageView(image: drawingImage)
        paintImageView.frame = self.viewCustomCanvas.viewImageGesture.bounds
        self.viewCustomCanvas.imageView.addSubview(paintImageView)
    }
    
    func updateFramesSticker(heightRatio: CGFloat, widthRatio: CGFloat) {
        for (_,textView) in self.option.stickerDetail.enumerated() {
            let textViewDetail = textView.sticker
            let transform = textViewDetail!.transform
            let origin = textViewDetail?.frame.origin
            let size = textViewDetail?.frame.size
            let frame = CGRect(x: (origin?.x ?? 0)/widthRatio , y: (origin?.y ?? 0)/heightRatio , width: (size?.width ?? 0)/widthRatio, height: (size?.height ?? 0)/heightRatio)

            var color = UIColor.white
            if customStickerArray.count > 0 {
                
            } else {
                
            }
            var colorManager = ColorManager()
            let colorData = colorManager.getColorsData()
            
            if textView.stickerName == "shapes" {
                color = (UIColor(named: .stickerColor, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!)
            } else {
                color = (UIColor(named: .white, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!)
            }
            let view = self.stickerManager.addSticker(delegate:self, frame: frame, image: textView.image! ,isTransform: true , transform: transform, tag: stickerSavedTags, sticker: textView.stickerName ?? "", isSticker: textView.isSticker ?? false, color: textView.color ?? color)
            view.isSelected = false
            view.alpha = textView.alpha ?? 1.0
            self.stickerView.addSubview(view)
        }
    }
}

extension CustomRulerCanvasViewController {
    
    func initCanvasWithoutImage() {
        self.sliderCustomRange.value = 3
        self.viewDottedVertical.isHidden = true
        self.viewDottedHorizontal.isHidden = false
        self.viewCustomCanvas.hideSideViewArea = 0.0
        self.isLandscape = true
        self.viewCustomCanvas.bringSubviewToFront(self.viewDottedHorizontal)
        self.viewCustomCanvas.bringSubviewToFront(self.viewDottedVertical)
        self.viewCustomCanvas?.calculteCanvasSize(aspectRatio: 3.0/2.0, width: nil, height: self.dottedLineLandscapeHeight, orienationaChange: false)
    }
}
