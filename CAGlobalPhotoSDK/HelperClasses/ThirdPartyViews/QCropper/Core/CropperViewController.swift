//
//  CropperViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//

import UIKit

enum CropBoxEdge: Int {
    case none
    case left
    case topLeft
    case top
    case topRight
    case right
    case bottomRight
    case bottom
    case bottomLeft
}

protocol CropperViewControllerDelegate: AnyObject {
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?, selectedRatioWith: CGFloat)
    func cropperDidCancel(_ cropper: CropperViewController)
}

extension CropperViewControllerDelegate {
    func cropperDidCancel(_ cropper: CropperViewController) {
        cropper.navigationController?.popViewController(animated: true)
    }
}

class CropperViewController: BaseViewController, Rotatable, StateRestorable, Flipable, RulerCanvasDelegate {
    func backButtonClicked(isLandscape: Bool) {
        
    }
    
    func dismissWithUpdatedRatio(paperLengthImageMovementTransform: CGAffineTransform, paperLengthImageRotation: CGAffineTransform, previousImageViewTransform: CGAffineTransform, scrollViewZoomScale: Int, scrollviewPaperLengthFrame: CGRect, isImageAlreadyEdited: Bool, isFillImage: Bool, isLandscape: Bool, selectedRatioWith: CGFloat, image: UIImage) {
        
    }
    
    public var originalImage: UIImage
    var originalImageForSetPaperLength: UIImage!
    var initialState: CropperState?
    var isCircular: Bool
    @IBOutlet weak var viewCustomCanvas: UIView!
    @IBOutlet weak var sliderCustomRange: ThumbTextSlider!
    
    public init(originalImage: UIImage, initialState: CropperState? = nil, isCircular: Bool = false) {
        self.originalImage = originalImage
        self.initialState = initialState
        self.isCircular = isCircular
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public weak var delegate: CropperViewControllerDelegate?
    
    // if self not init with a state, return false
    open var isCurrentlyInInitialState: Bool {
        isCurrentlyInState(initialState)
    }
    
    public var aspectRatioLocked: Bool = false {
        didSet {
            overlay.free = !aspectRatioLocked
        }
    }
    
    // This outlet represents the bottom view where we are using sub view of edit options
    @IBOutlet weak var bottomTransformView: UIView!
    
    // This outlet represents the bottom view where we are using sub view of edit options
    @IBOutlet weak var angleView: UIView!
    
    // This outlet represents the tickView
    @IBOutlet weak var tickView: UIView!
    
    // This outlet represents the tickAboveView
    @IBOutlet weak var tickAboveView: UIView!
    
    // This outlet represents the main view
    @IBOutlet weak var mainView: UIView!

    // This outlet represents the main view
    @IBOutlet weak var backgroundView: UIView!

    // This outlet represents the main view
    @IBOutlet weak var scrollViewContainer: ScrollViewContainer!

    // This outlet represents the main view
    @IBOutlet weak var resetView: UIView!
    
    // This outlet represents the main view
    @IBOutlet weak var setPaperView: UIView!
    
    // This outlet represents the main view
    @IBOutlet weak var verticalView: UIView!
    
    // This outlet represents the main view
    @IBOutlet weak var horizontalView: UIView!
    
    // This outlet represents the main view
    @IBOutlet weak var innerPortraitView: UIView!
    
    // This outlet represents the main view
    @IBOutlet weak var innerSquarePortraitView: UIView!
    
    // This outlet represents the main view
    @IBOutlet weak var innerLandscapeView: UIView!
    
    @IBOutlet weak var resetButton: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneImageView: UIImageView!
    @IBOutlet weak var cancelImageView: UIImageView!
    @IBOutlet weak var labelLandscape: UILabel!
    @IBOutlet weak var labelPotrait: UILabel!
    
    public var currentAspectRatioValue: CGFloat = 1.0
    public var isCropBoxPanEnabled: Bool = true
    public var cropContentInset: UIEdgeInsets = UIEdgeInsets(top: 60, left: 20, bottom: 100, right: 20)
    
    let cropBoxHotArea: CGFloat = 50
    let cropBoxMinSize: CGFloat = 20
    let barHeight: CGFloat = 44
    
    var cropRegionInsets: UIEdgeInsets = .zero
    var maxCropRegion: CGRect = .zero
    var defaultCropBoxCenter: CGPoint = .zero
    var defaultCropBoxSize: CGSize = .zero
    
    var straightenAngle: CGFloat = 0.0
    var rotationAngle: CGFloat = 0.0
    var flipAngle: CGFloat = 0.0
    
    var panBeginningPoint: CGPoint = .zero
    var panBeginningCropBoxEdge: CropBoxEdge = .none
    var panBeginningCropBoxFrame: CGRect = .zero
    
    var manualZoomed: Bool = false
    
    var needReload: Bool = false
    var defaultCropperState: CropperState?
    var uniqueActivityTimer: Timer?
    var uniqueActivityThings: (() -> Void)?
    
    var selectedRatioWith: CGFloat?
    var orignalSelectedRatioWith: CGFloat?
    var isLandscape: Bool?
    
    open var isCurrentlyInDefalutState: Bool {
        isCurrentlyInState(defaultCropperState)
    }
    
    var totalAngle: CGFloat {
        return autoHorizontalOrVerticalAngle(straightenAngle + rotationAngle + flipAngle)
    }
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.defaultCropBoxSize.width, height: self.defaultCropBoxSize.height))
        sv.delegate = self
        sv.center = self.mainView.convert(defaultCropBoxCenter, to: scrollViewContainer)
        sv.bounces = true
        sv.bouncesZoom = true
        sv.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        sv.alwaysBounceVertical = true
        sv.alwaysBounceHorizontal = true
        sv.minimumZoomScale = 1
        sv.maximumZoomScale = 20
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.clipsToBounds = false
        sv.contentSize = self.defaultCropBoxSize
        return sv
    }()
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView(image: self.originalImage)
        iv.backgroundColor = .clear
        return iv
    }()
    
    lazy var cropBoxPanGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(cropBoxPan(_:)))
        pan.delegate = self
        return pan
    }()
    
    // MARK: Custom UI
        
    open lazy var bottomView: UIView = {
        let view = UIView(frame: CGRect(x: 110, y: 0, width: view.width - 110 - 60, height: 52))
        view.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]
        return view
    }()
    
    var verticalAspectRatios: [AspectRatio] = []
    
    open lazy var overlay: Overlay = Overlay(frame: self.backgroundView.bounds)
    
    public lazy var angleRuler: AngleRuler = {
        let ar = AngleRuler(frame: CGRect(x: 0, y: 0, width: view.width - 110 - 60, height: 52))
        ar.addTarget(self, action: #selector(angleRulerValueChanged(_:)), for: .valueChanged)
        ar.addTarget(self, action: #selector(angleRulerTouchEnded(_:)), for: [.editingDidEnd])
        return ar
    }()
    
    public lazy var aspectRatioPicker: AspectRatioPicker = {
        let picker = AspectRatioPicker(frame: CGRect(x: 0, y: 0, width: view.width, height: 80))
        picker.isHidden = true
        picker.delegate = self
        return picker
    }()
    
    @objc
    func angleRulerValueChanged(_: AnyObject) {
        scrollViewContainer.isUserInteractionEnabled = false
        setStraightenAngle(CGFloat(angleRuler.value * CGFloat.pi / 180.0))
    }
    
    @objc
    func angleRulerTouchEnded(_: AnyObject) {
        UIView.animate(withDuration: 0.25, animations: {
            self.overlay.gridLinesAlpha = 0
            self.overlay.blur = true
        }, completion: { _ in
            self.scrollViewContainer.isUserInteractionEnabled = true
            self.overlay.gridLinesCount = 2
        })
    }
    
    // MARK: - Override
    
    deinit {
        self.cancelUniqueActivity()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        view.clipsToBounds = true
        if self.originalImage.size.width < 1 || self.originalImage.size.height < 1 {
            return
        }
        
        view.backgroundColor = .clear
        self.scrollView.addSubview(self.imageView)
        
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        self.scrollViewContainer.scrollView = self.scrollView
        self.scrollViewContainer.addGestureRecognizer(self.cropBoxPanGesture)
        self.scrollView.panGestureRecognizer.require(toFail: self.cropBoxPanGesture)
        self.scrollViewContainer.frame = CGRectMake(0, 0, self.mainView.frame.size.width, self.mainView.frame.size.height)
        self.backgroundView.frame = CGRectMake(0, 0, self.mainView.frame.size.width, self.mainView.frame.size.height)
        self.bottomView.addSubview(self.angleRuler)
        self.view.bringSubviewToFront(self.bottomTransformView)
        self.view.bringSubviewToFront(self.tickView)
        self.view.bringSubviewToFront(self.tickAboveView)
        self.view.bringSubviewToFront(self.resetButton)
        self.angleView.addSubview(self.bottomView)
        self.view.bringSubviewToFront(self.angleView)
        self.view.bringSubviewToFront(self.viewCustomCanvas)

    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Layout when self.view finish layout and never layout before, or self.view need reload
        self.scrollViewContainer.frame = CGRectMake(0, 0, self.mainView.frame.size.width, self.mainView.frame.size.height)
        self.backgroundView.frame = CGRectMake(0, 0, self.mainView.frame.size.width, self.mainView.frame.size.height)
        self.scrollViewContainer.addSubview(self.scrollView)
        if let viewFrame = self.defaultCropperState?.viewFrame,
           viewFrame.equalTo(self.mainView.frame) {
            if self.needReload {
                self.needReload = false
                self.resetToDefaultLayout()
            }
        } else {
            self.resetToDefaultLayout()
            if let initialState = self.initialState {
                self.restoreState(initialState)
                self.updateButtons()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    open override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .top
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if !view.size.isEqual(to: size, accuracy: 0.0001) {
            needReload = true
        }
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    @IBAction func actionMirror(_ sender: UIButton) {
        self.mirrorButtonPressed(sender)
    }
    
    @IBAction func actionFlip(_ sender: UIButton) {
        self.flipButtonPressed(sender)
    }
    
    @IBAction func actionAspectRatioLandscape(_ sender: UIButton) {
        self.verticalView.layer.borderWidth = 0
        self.horizontalView.layer.borderWidth = 2
        self.resetView.layer.borderWidth = 0
        self.setPaperView.layer.borderWidth = 0
        self.aspectRatioPickerDidSelectedAspectRatio(verticalAspectRatios[1])
    }
    
    @IBAction func actionAspectRatioPotrait(_ sender: UIButton) {
        self.verticalView.layer.borderWidth = 2
        self.horizontalView.layer.borderWidth = 0
        self.resetView.layer.borderWidth = 0
        self.setPaperView.layer.borderWidth = 0
        self.aspectRatioPickerDidSelectedAspectRatio(verticalAspectRatios[0])
    }
    
    @IBAction func actionBlankCanvas(_ sender: UIButton) {
        self.verticalView.layer.borderWidth = 0
        self.horizontalView.layer.borderWidth = 0
        self.resetView.layer.borderWidth = 0
        self.setPaperView.layer.borderWidth = 2
        self.rationButtonPressed(sender)
    }
    
    @IBAction func actionRotate(_ sender: UIButton) {
        self.rotateButtonPressed(sender)
    }
    
    @IBAction func actionCancel(_ sender: UIButton) {
        self.cancelButtonPressed(sender)
    }
    
    @IBAction func actionReset(_ sender: UIButton) {
        self.selectedRatioWith = self.orignalSelectedRatioWith
        self.verticalView.layer.borderWidth = 0
        self.horizontalView.layer.borderWidth = 0
        self.resetView.layer.borderWidth = 2
        self.setPaperView.layer.borderWidth = 0
        self.resetButtonPressed(sender)
    }
    
    @IBAction func actionDone(_ sender: UIButton) {
        self.confirmButtonPressed(sender)
    }
    
    @IBAction func actionAngle(_ sender: UIButton) {
        self.cancelButton.isHidden = true
        self.cancelImageView.isHidden = true
        self.resetButton.isHidden = true
        self.view.bringSubviewToFront(self.angleView)
        self.angleView.isHidden = !self.angleView.isHidden
    }
    
    // MARK: - User Interaction
    
    @objc
    func cropBoxPan(_ pan: UIPanGestureRecognizer) {
        guard isCropBoxPanEnabled else {
            return
        }
        let point = pan.location(in: self.mainView)
        
        if pan.state == .began {
            cancelUniqueActivity()
            panBeginningPoint = point
            panBeginningCropBoxFrame = overlay.cropBoxFrame
            panBeginningCropBoxEdge = nearestCropBoxEdgeForPoint(point: panBeginningPoint)
            overlay.blur = false
            overlay.gridLinesAlpha = 1
            bottomView.isUserInteractionEnabled = false
        }
        
        if pan.state == .ended || pan.state == .cancelled {
            uniqueActivityAndThenRun {
                self.matchScrollViewAndCropView(animated: true, targetCropBoxFrame: self.overlay.cropBoxFrame, extraZoomScale: 1, blurLayerAnimated: true, animations: {
                    self.overlay.gridLinesAlpha = 0
                    self.overlay.blur = true
                }, completion: {
                    self.bottomView.isUserInteractionEnabled = true
                    self.updateButtons()
                })
            }
        } else {
            updateCropBoxFrameWithPanGesturePoint(point)
        }
    }
    
    @objc
    func cancelButtonPressed(_: UIButton) {
        delegate?.cropperDidCancel(self)
    }
    
    @objc
    func confirmButtonPressed(_: UIButton) {
        self.navigationController?.popViewController(animated: true)
        delegate?.cropperDidConfirm(self, state: saveState(), selectedRatioWith: self.selectedRatioWith ?? 3)
    }
    
    @objc
    func resetButtonPressed(_: UIButton) {
        overlay.blur = false
        overlay.gridLinesAlpha = 0
        overlay.cropBoxAlpha = 0
        bottomView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.25, animations: {
            self.resetToDefaultLayout()
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, animations: {
                self.overlay.cropBoxAlpha = 1
                self.overlay.blur = true
            }, completion: { _ in
                self.bottomView.isUserInteractionEnabled = true
            })
        })
    }
    
    @objc
    func flipButtonPressed(_: UIButton) {
        flip(directionHorizontal: false)
    }
    
    @objc
    func rotateButtonPressed(_: UIButton) {
        rotate90degrees()
    }
    
    @objc
    func mirrorButtonPressed(_ sender: UIButton) {
        flip()
    }
    
    @objc
    func aspectRationButtonPressed(_ sender: UIButton) {
        self.aspectRatioPickerDidSelectedAspectRatio(verticalAspectRatios[0])
        sender.isSelected = !sender.isSelected
        
        angleRuler.isHidden = sender.isSelected
        aspectRatioPicker.isHidden = !sender.isSelected
    }
    
    @objc
    func rationButtonPressed(_ sender: UIButton) {
        let rulerViewController = CustomRulerCanvasViewController(nibName: CustomRulerCanvasViewController.className, bundle: nil)
        rulerViewController.image = self.originalImageForSetPaperLength
        rulerViewController.isLandscape = isLandscape!
        rulerViewController.sliderCanvasImageValue = self.selectedRatioWith
        rulerViewController.isBlankCanvasRuler = false
        rulerViewController.isFromPaperLength = false
        rulerViewController.rulerCanvasDelegate = self
        rulerViewController.rulerCanvasDelegate = self
        rulerViewController.angle = self.angleRuler.value
        rulerViewController.rotationAngle = self.rotationAngle
        rulerViewController.straightenAngle = self.straightenAngle
        rulerViewController.flipAngle = self.flipAngle
        rulerViewController.scrollViewBounds = self.scrollView.bounds
        rulerViewController.imageViewTransform = self.imageView.transform
        rulerViewController.imageViewBoundsSize = self.imageView.bounds.size
        self.navigationController?.pushViewController(rulerViewController, animated: true)
    }
    
    func dismissWithUpdatedRatio(selectedRatioWith: CGFloat, image: UIImage) {
        originalImageForSetPaperLength = image
        updateButtons()
        self.selectedRatioWith = selectedRatioWith
        self.resetToDefaultLayout(isSetPaperLength: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private Methods
    
    open var cropBoxFrame: CGRect {
        get {
            return overlay.cropBoxFrame
        }
        set {
            overlay.cropBoxFrame = safeCropBoxFrame(newValue)
        }
    }
    
    open func resetToDefaultLayout(isSetPaperLength : Bool = false) {
        
        let _: CGFloat = 20
        aspectRatioPicker.frame = angleRuler.frame
        
        cropRegionInsets = UIEdgeInsets(top: cropContentInset.top,
                                        left: cropContentInset.left,
                                        bottom: cropContentInset.bottom,
                                        right: cropContentInset.right)
        
        maxCropRegion = CGRect(x: cropRegionInsets.left,
                               y: cropRegionInsets.top,
                               width: self.backgroundView.width - cropRegionInsets.left - cropRegionInsets.right,
                               height: self.backgroundView.height - cropRegionInsets.top - cropRegionInsets.bottom)
        defaultCropBoxCenter = CGPoint(x: self.backgroundView.width / 2.0, y: cropRegionInsets.top + maxCropRegion.size.height / 2.0)
        defaultCropBoxSize = {
            var size: CGSize
            let scaleW = self.originalImage.size.width / self.maxCropRegion.size.width
            let scaleH = self.originalImage.size.height / self.maxCropRegion.size.height
            let scale = max(scaleW, scaleH)
            size = CGSize(width: self.originalImage.size.width / scale, height: self.originalImage.size.height / scale)
            return size
        }()
        
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 20
        scrollView.zoomScale = 1
        scrollView.transform = .identity
        scrollView.bounds = CGRect(x: 0, y: 0, width: defaultCropBoxSize.width, height: defaultCropBoxSize.height)
        scrollView.contentSize = defaultCropBoxSize
        scrollView.contentOffset = .zero
        scrollView.center = self.mainView.convert(defaultCropBoxCenter, to: scrollViewContainer)
        imageView.transform = .identity
        imageView.frame = scrollView.bounds
        imageView.image = (isSetPaperLength) ? originalImageForSetPaperLength : originalImage
        overlay.frame = backgroundView.bounds
        overlay.cropBoxFrame = CGRect(center: defaultCropBoxCenter, size: defaultCropBoxSize)
        
        straightenAngle = 0
        rotationAngle = 0
        flipAngle = 0
        aspectRatioLocked = false
        currentAspectRatioValue = 1
        
        if isCircular {
            isCropBoxPanEnabled = false
            overlay.isCircular = true
            aspectRatioPicker.isHidden = true
            angleRuler.isHidden = true
            cropBoxFrame = CGRect(center: defaultCropBoxCenter, size: CGSize(width: maxCropRegion.size.width, height: maxCropRegion.size.width))
            matchScrollViewAndCropView()
        } else {
            if originalImage.size.width / originalImage.size.height < cropBoxMinSize / maxCropRegion.size.height { // very long
                cropBoxFrame = CGRect(x: (mainView.width - cropBoxMinSize) / 2, y: cropRegionInsets.top, width: cropBoxMinSize, height: maxCropRegion.size.height)
                matchScrollViewAndCropView()
            } else if originalImage.size.height / originalImage.size.width < cropBoxMinSize / maxCropRegion.size.width { // very wide
                cropBoxFrame = CGRect(x: cropRegionInsets.left, y: cropRegionInsets.top + (maxCropRegion.size.height - cropBoxMinSize) / 2, width: maxCropRegion.size.width, height: cropBoxMinSize)
                matchScrollViewAndCropView()
            }
        }
        
        defaultCropperState = saveState()
        
        angleRuler.value = 0.0
        updateAspectRatio()
        updateButtons()
        
    }
    
    func updateAspectRatio() {
        verticalAspectRatios.removeAll()
        if Double(self.selectedRatioWith ?? 0.0).rounded(toPlaces: 1) != 2.0 {
            self.innerSquarePortraitView.isHidden = true
            self.innerPortraitView.isHidden = false
            self.horizontalView.showView()
        } else {
            self.innerSquarePortraitView.isHidden = false
            self.innerPortraitView.isHidden = true
            self.horizontalView.hideView()
        }
        
        // for portrait
        self.labelPotrait?.text = "2:\(Double(self.selectedRatioWith ?? 0.0).rounded(toPlaces: 1))"
        verticalAspectRatios.append(.ratio(width: 2, height: self.selectedRatioWith ?? 0.0))
        
        // for landscape
        self.labelLandscape?.text = "\(Double(self.selectedRatioWith ?? 0.0).rounded(toPlaces: 1)):2"
        verticalAspectRatios.append(.ratio(width: self.selectedRatioWith ?? 0.0, height: 2))
        
        if self.isLandscape == true {
            self.actionAspectRatioLandscape(self.doneButton)
        } else {
            self.actionAspectRatioPotrait(self.doneButton)
        }
    }
    
    func updateButtons() {
        if isCurrentlyInDefalutState {
            self.resetView.hideView()
        } else {
            if self.resetView.isHidden == true ||  self.doneButton.isHidden == true {
                self.resetView.showView()
            }
        }
    }
    
    func scrollViewZoomScaleToBounds() -> CGFloat {
        let scaleW = scrollView.bounds.size.width / imageView.bounds.size.width
        let scaleH = scrollView.bounds.size.height / imageView.bounds.size.height
        return max(scaleW, scaleH)
    }
    
    func willSetScrollViewZoomScale(_ zoomScale: CGFloat) {
        if zoomScale > scrollView.maximumZoomScale {
            scrollView.maximumZoomScale = zoomScale
        }
        if zoomScale < scrollView.minimumZoomScale {
            scrollView.minimumZoomScale = zoomScale
        }
    }
    
    func photoTranslation() -> CGPoint {
        let rect = imageView.convert(imageView.bounds, to: self.mainView)
        let point = CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y + rect.size.height / 2)
        let zeroPoint = CGPoint(x: mainView.frame.width / 2, y: defaultCropBoxCenter.y)
        
        return CGPoint(x: point.x - zeroPoint.x, y: point.y - zeroPoint.y)
    }
    
    public static let overlayCropBoxFramePlaceholder: CGRect = .zero
    
    public func matchScrollViewAndCropView(animated: Bool = false,
                                           targetCropBoxFrame: CGRect = overlayCropBoxFramePlaceholder,
                                           extraZoomScale: CGFloat = 1.0,
                                           blurLayerAnimated: Bool = false,
                                           animations: (() -> Void)? = nil,
                                           completion: (() -> Void)? = nil) {
        var targetCropBoxFrame = targetCropBoxFrame
        if targetCropBoxFrame.equalTo(CropperViewController.overlayCropBoxFramePlaceholder) {
            targetCropBoxFrame = overlay.cropBoxFrame
        }
        
        let scaleX = maxCropRegion.size.width / targetCropBoxFrame.size.width
        let scaleY = maxCropRegion.size.height / targetCropBoxFrame.size.height
        
        let scale = min(scaleX, scaleY)
        
        // calculate the new bounds of crop view
        let newCropBounds = CGRect(x: 0, y: 0, width: scale * targetCropBoxFrame.size.width, height: scale * targetCropBoxFrame.size.height)
        
        // calculate the new bounds of scroll view
        let rotatedRect = newCropBounds.applying(CGAffineTransform(rotationAngle: totalAngle))
        let width = rotatedRect.size.width
        let height = rotatedRect.size.height
        
        let cropBoxFrameBeforeZoom = targetCropBoxFrame
        
        let zoomRect = mainView.convert(cropBoxFrameBeforeZoom, to: imageView) // zoomRect is base on imageView when scrollView.zoomScale = 1
        let center = CGPoint(x: zoomRect.origin.x + zoomRect.size.width / 2, y: zoomRect.origin.y + zoomRect.size.height / 2)
        let normalizedCenter = CGPoint(x: center.x / (imageView.width / scrollView.zoomScale), y: center.y / (imageView.height / scrollView.zoomScale))
        
        UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
            self.overlay.setCropBoxFrame(CGRect(center: self.defaultCropBoxCenter, size: newCropBounds.size), blurLayerAnimated: blurLayerAnimated)
            animations?()
            self.scrollView.bounds = CGRect(x: 0, y: 0, width: width, height: height)
            
            var zoomScale = scale * self.scrollView.zoomScale * extraZoomScale
            let scrollViewZoomScaleToBounds = self.scrollViewZoomScaleToBounds()
            if zoomScale < scrollViewZoomScaleToBounds { // Some area not fill image in the cropbox area
                zoomScale = scrollViewZoomScaleToBounds
            }
            if zoomScale > self.scrollView.maximumZoomScale { // Only rotate can make maximumZoomScale to get bigger
                zoomScale = self.scrollView.maximumZoomScale
            }
            self.willSetScrollViewZoomScale(zoomScale)
            
            self.scrollView.zoomScale = zoomScale
            
            let contentOffset = CGPoint(x: normalizedCenter.x * self.imageView.width - self.scrollView.bounds.size.width * 0.5,
                                        y: normalizedCenter.y * self.imageView.height - self.scrollView.bounds.size.height * 0.5)
            self.scrollView.contentOffset = self.safeContentOffsetForScrollView(contentOffset)
        }, completion: { _ in
            completion?()
        })
        
        manualZoomed = true
    }
    
    func safeContentOffsetForScrollView(_ contentOffset: CGPoint) -> CGPoint {
        var contentOffset = contentOffset
        contentOffset.x = max(contentOffset.x, 0)
        contentOffset.y = max(contentOffset.y, 0)
        
        if scrollView.contentSize.height - contentOffset.y <= scrollView.bounds.size.height {
            contentOffset.y = scrollView.contentSize.height - scrollView.bounds.size.height
        }
        
        if scrollView.contentSize.width - contentOffset.x <= scrollView.bounds.size.width {
            contentOffset.x = scrollView.contentSize.width - scrollView.bounds.size.width
        }
        
        return contentOffset
    }
    
    func safeCropBoxFrame(_ cropBoxFrame: CGRect) -> CGRect {
        var cropBoxFrame = cropBoxFrame
        // Upon init, sometimes the box size is still 0, which can result in CALayer issues
        if cropBoxFrame.size.width < .ulpOfOne || cropBoxFrame.size.height < .ulpOfOne {
            return CGRect(center: defaultCropBoxCenter, size: defaultCropBoxSize)
        }
        
        // clamp the cropping region to the inset boundaries of the screen
        let contentFrame = maxCropRegion
        let xOrigin = contentFrame.origin.x
        let xDelta = cropBoxFrame.origin.x - xOrigin
        cropBoxFrame.origin.x = max(cropBoxFrame.origin.x, xOrigin)
        if xDelta < -.ulpOfOne { // If we clamp the x value, ensure we compensate for the subsequent delta generated in the width (Or else, the box will keep growing)
            cropBoxFrame.size.width += xDelta
        }
        
        let yOrigin = contentFrame.origin.y
        let yDelta = cropBoxFrame.origin.y - yOrigin
        cropBoxFrame.origin.y = max(cropBoxFrame.origin.y, yOrigin)
        if yDelta < -.ulpOfOne {
            cropBoxFrame.size.height += yDelta
        }
        
        // given the clamped X/Y values, make sure we can't extend the crop box beyond the edge of the screen in the current state
        let maxWidth = (contentFrame.size.width + contentFrame.origin.x) - cropBoxFrame.origin.x
        cropBoxFrame.size.width = min(cropBoxFrame.size.width, maxWidth)
        
        let maxHeight = (contentFrame.size.height + contentFrame.origin.y) - cropBoxFrame.origin.y
        cropBoxFrame.size.height = min(cropBoxFrame.size.height, maxHeight)
        
        // Make sure we can't make the crop box too small
        cropBoxFrame.size.width = max(cropBoxFrame.size.width, cropBoxMinSize)
        cropBoxFrame.size.height = max(cropBoxFrame.size.height, cropBoxMinSize)
        
        return cropBoxFrame
    }
}

// MARK: UIScrollViewDelegate

extension CropperViewController: UIScrollViewDelegate {
    
    public func viewForZooming(in _: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewWillBeginZooming(_: UIScrollView, with _: UIView?) {
        cancelUniqueActivity()
        overlay.blur = false
        overlay.gridLinesAlpha = 1
        bottomView.isUserInteractionEnabled = false
    }
    
    public func scrollViewDidEndZooming(_: UIScrollView, with _: UIView?, atScale _: CGFloat) {
        matchScrollViewAndCropView(animated: true, completion: {
            self.uniqueActivityAndThenRun {
                UIView.animate(withDuration: 0.25, animations: {
                    self.overlay.gridLinesAlpha = 0
                    self.overlay.blur = true
                }, completion: { _ in
                    self.bottomView.isUserInteractionEnabled = true
                    self.updateButtons()
                })
                
                self.manualZoomed = true
            }
        })
    }
    
    public func scrollViewWillBeginDragging(_: UIScrollView) {
        cancelUniqueActivity()
        overlay.blur = false
        overlay.gridLinesAlpha = 1
        bottomView.isUserInteractionEnabled = false
    }
    
    public func scrollViewDidEndDragging(_: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            matchScrollViewAndCropView(animated: true, completion: {
                self.uniqueActivityAndThenRun {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.overlay.gridLinesAlpha = 0
                        self.overlay.blur = true
                    }, completion: { _ in
                        self.bottomView.isUserInteractionEnabled = true
                        self.updateButtons()
                    })
                }
            })
        }
    }
    
    public func scrollViewDidEndDecelerating(_: UIScrollView) {
        matchScrollViewAndCropView(animated: true, completion: {
            self.uniqueActivityAndThenRun {
                UIView.animate(withDuration: 0.25, animations: {
                    self.overlay.gridLinesAlpha = 0
                    self.overlay.blur = true
                }, completion: { _ in
                    self.bottomView.isUserInteractionEnabled = true
                    self.updateButtons()
                })
            }
        })
    }
}

// MARK: UIGestureRecognizerDelegate

extension CropperViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == cropBoxPanGesture {
            guard isCropBoxPanEnabled else {
                return false
            }
            let tapPoint = gestureRecognizer.location(in: self.mainView)
            
            let frame = overlay.cropBoxFrame
            
            let direction = cropBoxHotArea / 2.0
            let innerFrame = frame.insetBy(dx: direction, dy: direction)
            let outerFrame = frame.insetBy(dx: -direction, dy: -direction)
            
            if innerFrame.contains(tapPoint) || !outerFrame.contains(tapPoint) {
                return false
            }
        }
        
        return true
    }
}

// MARK: AspectRatioPickerDelegate

extension CropperViewController: AspectRatioPickerDelegate {
    
    func aspectRatioPickerDidSelectedAspectRatio(_ aspectRatio: AspectRatio) {
        setAspectRatio(aspectRatio)
    }
}

// MARK: Add capability from protocols

extension CropperViewController: UniqueActivity, AngleAssist, CropBoxEdgeDraggable, AspectRatioSettable {}
