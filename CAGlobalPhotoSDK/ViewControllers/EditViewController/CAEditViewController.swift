//
//  CAEditViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 17/03/23.
//

import UIKit
import Photos
import Accelerate
import AudioToolbox


var currentZoomScale: CGFloat = 1.0 // Stores the current zoom scale of the editing canvas
var isImageSaved = false // Tracks whether the edited image has been saved
var isImageAltered = false // Tracks if the image has been modified after loading
var finalImage: UIImage? // Stores the final image that will be saved or printed
var autoOrAdjust: Bool? // true = auto filter applied, false = manual adjustment
let kCLImageToolAnimationDuration: CGFloat = 0.3 // Standard animation duration for edit tools
var printerDPI = 500 // Printer dots per inch setting
var printerWidth = 2.0447 // Print head width in inches
var isShowingSocialPhotos = false // Used for photo source handling (social media)
var isSortByOldestFirst = Bool() // Determines sort order of displayed photos

let kPGCSMLastStickerNumberKey = "com.caglobal.CAGlobalPhotoSDK" // UserDefaults key for last sticker used
let kPGCustomStickerManagerDirectory = "stickers" // Folder for custom sticker files
let kCustomStickerManagerPrefixLength = 8 // Prefix used for unique file naming
let kCustomStickerManagerThumbnailSuffix = "_TN" // Suffix for sticker thumbnail files
let kCustomStickerManagerUniqueHashLength = 4 // Unique hash length for identifying sticker files

var customStickerArray = [UIImage]()

var currentFilterState: FilterState = FilterState(filterName: "", opacity: 1.0)
var filterOpacityValue:CGFloat = 1.0  // Keep track of the current opacity
var selectedFilter = String()
var global_shouldCancelStickerResizing = false
var global_shouldCancelFrameResizing = false
struct EditStaticStrings {
    static let color = "color"
    static let previousColor = "previousColor"
    static let selectedColorIndex = "selectedColorIndex"
    static let selectedPreviousColorIndex = "selectedPreviousColorIndex"
    static let font = "font"
    static let text = "text"
    static let newText = "newText"
    static let previousText = "previousText"
    static let previousFont = "previousFont"
    static let selectedFontIndex = "selectedFontIndex"
    static let selectedPreviousFontIndex = "selectedPreviousFontIndex"
    static let selectedOpacity = "selectedOpacity"
    static let selectedAlignment = "selectedAlignment"
    
    static let backgroundColor = "backgroundColor"
    static let previousBackgroundColor = "previousBackgroundColor"
    static let selectedBackgroundColorIndex = "selectedBackgroundColorIndex"
    static let selectedBackgroundPreviousColorIndex = "selectedBackgroundPreviousColorIndex"

}

enum FilterSelection: Int {
    case auto = 0
    case adjust = 1
    case filter = 2
    case frame = 3
    case sticker = 4
    case text = 5
    case brush = 6
    case gallery = 7
    case transform = 8
    case none = -1

}


enum BrushSelection: Int {
    case color = 0
    case transperancy = 1
    case size = 2
    case sharpness = 3
    case none = -1
}

enum AdjustSelection: Int {
    case brightness = 0
    case contrast = 1
    case saturation = 2
    case temperature = 3
    case exposure = 4
    case none = -1
}

enum TextStickersOption {
    case showDeleteButton
    case hideDeleteButton
    case hideSelection
    case showDeleteButtonOnTap
    case edit
    case replace
    case resetMove
    case resetEdit
    case removeAll
    case withoutTick
    case saved
    case setColor
    case setBackgroundColor
    case setFont
    case setLeft
    case setRight
    case setCenter
    case setOpacity
    case setOpacityEnd
    case mirror
    case onTop
    case align
}

enum ImageOrientation2 {
    case flip
    case mirror
    case rotate
}

enum CLBlurType: Int {
    case blurTypeNormal = 0
    case blurTypeCircle = 1
}

class CLBlurCircle: UIView {
    var color: UIColor?
}

struct StickerFlipState {
    let image: UIImage
    let transform: CGAffineTransform
    let center: CGPoint
}

struct StickerEditState {
    let image: UIImage
    let tintColor: UIColor
    let stickerSelection: String
    let isBackgroundRemoved: Bool
    let transform: CGAffineTransform
    let stickerRef: AddSticker
}

let textSavedTags = 20
let textTempTags = 200
let textEditTags = 21
let textTempEditTags = 201
let textMoveSavedTags = 202
let textMoveTempTags = 203

let stickerSavedTags = 10
let stickerTempTags = 100
let stickerEditTags = 11
let stickerTempEditTags = 101
let stickerMoveSavedTags = 102
let stickerMoveTempTags = 103
let stickerReplaceTags = 104

@objc protocol EditImageDelegate: AnyObject {

    /*
     Called when the user to apply colors and font name
     */
    func printImage(image: UIImage, hasframe:Bool)
    func backcallback(isSave:Bool)
}

class CAEditViewController: BaseViewController, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // This outlet represents the collection view for all options for edit
    @IBOutlet weak var mainCollectionView: UICollectionView!
    //    // This outlet represents the main view where we are showing image and textView
    //    @IBOutlet weak var constraintsBottomTransform: NSLayoutConstraint!
    // This outlet represents the main view where we are showing image and textView
    //    @IBOutlet weak var stickerTextView: UIView!
    // This outlet represents the cross save button when edit begins
    @IBOutlet weak var saveCrossView: UIView!
    // This outlet represents the cross save button when edit begins
    @IBOutlet weak var saveCrossSubOptionsView: UIView!
    // This outlet represents the bottom view where we are using sub view of edit options
    @IBOutlet weak var bottomView: UIView!
    // This outlet represents the main image view
    //    @IBOutlet weak var framesImageView: UIImageView!
    //    // This outlet represents the main image view
    //    @IBOutlet weak var mainImageView: UIImageView!
    // This outlet represents the height of text view
    @IBOutlet weak var constraintsMainImageViewHeight: NSLayoutConstraint!
    // This outlet represents the width of text view
    @IBOutlet weak var constraintsMainImageViewWidth: NSLayoutConstraint!
    // This outlet represents the bottom view where we are using sub view of sticker option
    @IBOutlet weak var stickerBaseView: UIView!

    @IBOutlet weak var stickerVisualEffectView: UIView!
    // This outlet represents the width of text view
    @IBOutlet weak var constraintsBottomViewHeight: NSLayoutConstraint!
    // This outlet represents the done button on top
    @IBOutlet weak var doneButton: UIButton!
    // This outlet represents the delete and add text and sticker
    @IBOutlet weak var deleteAndAddButtons: UIStackView!
    // This outlet represents the button to plus
    @IBOutlet weak var plusButton: UIButton!
    // This outlet represents the flip and on top text and sticker
    @IBOutlet weak var flipAndOntopButtons: UIStackView!
    // This outlet represents the button to undo
    @IBOutlet weak var undoButton: UIButton!
    // This outlet represents the button to redo
    @IBOutlet weak var redoButton: UIButton!
    // This outlet represents the top of main view
    @IBOutlet weak var constraintsTopView: NSLayoutConstraint!
    // This outlet represents the bottom of main view
    @IBOutlet weak var constraintsBottomView: NSLayoutConstraint!
    // This outlet represents the button to redo
    @IBOutlet weak var topAlignMargin: UILabel!
    // This outlet represents the button to redo
    @IBOutlet weak var bottomAlignMargin: UILabel!
    // This outlet represents the button to redo
    @IBOutlet weak var rightAlignMargin: UILabel!
    // This outlet represents the button to redo
    @IBOutlet weak var leftAlignMargin: UILabel!
    // This outlet represents the button to redo
    @IBOutlet weak var centerHorizontalMargin: UILabel!
    // This outlet represents the button to redo
    @IBOutlet weak var centerVerticalMargin: UILabel!
    // This outlet represents the button to redo
    @IBOutlet weak var centerDashLineMargin: UILabel!

    // This outlet represents the main view
    @IBOutlet weak var transformMainView: UIView!
    // This outlet represents the main view
    @IBOutlet weak var backgroundView: UIView!
    // This outlet represents the main view
    @IBOutlet weak var scrollViewContainer: ScrollViewContainer!
    // This outlet represents the main view
    @IBOutlet weak var blackCrossTickTransform: UIView!
    // This outlet represents the main view
    @IBOutlet weak var crossTickTransform: UIView!
    // This outlet represents the main view
    @IBOutlet weak var transformOptions: UIView!
    // This outlet represents the main view
    @IBOutlet weak var resetView: UIView!
    // This outlet represents the main view
    @IBOutlet weak var verticalView: UIView!
    // This outlet represents the main view
    @IBOutlet weak var horizontalView: UIView!
    // This outlet represents the bottom view where we are using sub view of edit options
    @IBOutlet weak var angleView: UIView!
    // This outlet represents the main view
    @IBOutlet weak var innerPortraitView: UIView!
    // This outlet represents the main view
    @IBOutlet weak var innerSquarePortraitView: UIView!
    // This outlet represents the main view
    @IBOutlet weak var innerLandscapeView: UIView!
    // This outlet represents the bottom of main view
    @IBOutlet weak var constraintsWidthOfBottom: NSLayoutConstraint!
    // This outlet represents the Brush Sharpness view
    @IBOutlet weak var brushSharpenessView: UIView!
    // This outlet represents the Brush Sharpness Imageview
    @IBOutlet weak var brushSharpenessImageView: UIImageView!
    //    // This outlet represents the top title
    //    @IBOutlet weak var frameTitleLabel: UILabel!
    //    // This outlet represents the top title
    //    @IBOutlet weak var frameTitleLabel2: UILabel!
    @IBOutlet weak var constraintsBottomtransform: NSLayoutConstraint!

    @IBOutlet weak var setPaperView: UIView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneImageView: UIImageView!
    @IBOutlet weak var cancelImageView: UIImageView!
    @IBOutlet weak var labelLandscape: UILabel!
    @IBOutlet weak var labelPotrait: UILabel!
    @IBOutlet weak var printImageView: UIImageView!
    @IBOutlet weak var angularViewBase: UIView!


    // -- Main
     var alignmentHideTimer: Timer?

    var previousTextDetail: [(txtVw: AddTextView, text: String?, frame: CGRect?, font: UIFont?, index: Int?, color: UIColor?, colorIn: Int?, previousColor: UIColor?, previousColorIndex: Int?, trnf: CGAffineTransform?, slider: CGFloat?, opacity: CGFloat?, textAlignment: NSTextAlignment?, fontCustom: String?, previousfont: String?, textString: String?, previousTextString: String?, selectedFontIndex: Int?, selectedPreviousFontIndex: Int?)]? = nil
    var previousFrame: CGRect? = nil
    var previousBrushStrokes: [TouchPointsAndColor] = []
    // var filterView: FilterView?

    private lazy var filterView: FilterView = {
        let view = FilterView()
        return view
    }()

    // Define the snapping threshold and duration
    let snappingThreshold: CGFloat = 8.0
    let snappingDuration: TimeInterval = 2.0

    var areAlignmentLinesVisible = false

    var isHandlesVisible = true
   // open lazy var overlayForStickerText: Overlay = Overlay(frame: .zero)

    var angle: CGFloat = 0.0
    var textModel = TextModel()
    @objc var imageOrignalBackUp: UIImage!
    @objc var imageBlankCanvas: UIImage!
    @objc var imageOrignal: UIImage!
    var imageTransform: UIImage!
    var imageBlur: UIImage!
    var finalImage: UIImage!
    var mainPreviousImage: UIImage!
    var framePreviousImage: UIImage!
    var lastScale = CGFloat()
    @objc var selectedRatioWith: CGFloat = 0
    @objc var selectedRatioWith2: CGFloat = 0
    var orignalSelectedRatioWith: CGFloat?
    var mainImageScaledSize = CGSize()
    //    var selectedFrame: Any?
    var selectedFrameOpacity = CGFloat()
    var selectedFilter = String()
    var selectedFilterOpacity = CGFloat()
    var thumbnailImage =  UIImage()
    var blurImage = UIImage()
    var blurSlider: UISlider?
    var menuScroll: UIScrollView?
    var handlerView =  UIView()
    var initialFrame = CGRect()
    var imgViewBlur = UIImageView()
    var lastRotation: CGFloat = 0
    var filter: CIFilter!
    var ciImage: CIImage!
    var context: CIContext!
    var imagePicker = UIImagePickerController()
    var textSliderValue: CGFloat = 1
    var overlaySliderValue: CGFloat!
    var stickersSliderValue: CGFloat!
    private var contextObserver = 0
    var framesImageViewBackup = UIImageView()
    var stickerForegroundCache: [UIImage: Bool] = [:]


    let option = EditOptions()
    var filterSelection = FilterSelection(rawValue: -1)
    var brushSelection = BrushSelection(rawValue: -1)

    var editViewModel = CAEditViewModel()
    var blurType = CLBlurType(rawValue: 1)
    var filterManager = FiltersManager()
    var blurManager = BlurManager()
    var textManager = TextManager()
    var adjustSelection: AdjustSelection!
    var cropperState: CropperState?
    var stickerManager = StickerManager()

    var circleView = CircularBlurView()
    let stickerView = StickersView()
    var textView = TextView()
    let stickerOption = StickerOptions()
    var selectedAddSticker : AddSticker?
    var selectedAddTextView : AddTextView?
    var selectedTextModel = TextModel()
    let brushView = BrushView()
    var selectedStickerColor = UIColor(named: .white, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!
    var selectedSickerColorModel = ColorModel()
    var previousSickerColorModel = ColorModel()
    var filterData = [String]()
    var filterImages = [UIImage]()
    var aCIImage = CIImage()
    var brightnessFilter: CIFilter!
    var temperatureFilter: CIFilter!
    var brightnessContext = CIContext()
    var newUIImage = UIImage()
    var floatTemperatureValue = CGFloat()
    var arrayTemperatureSliderValues = [CGFloat]()
    var arraySaturationSliderValues = [CGFloat]()
    var arrayContrastSliderValues = [CGFloat]()
    var arrayBrightnesSliderValues = [CGFloat]()
    var arrayTemperatureSliderSavedValues = [CGFloat]()
    var arraySaturationSliderSavedValues = [CGFloat]()
    var arrayContrastSliderSavedValues = [CGFloat]()
    var arrayBrightnesSliderSavedValues = [CGFloat]()
    var arrayExposureSliderValues = [CGFloat]()
    var arrayExposureSliderSavedValues = [CGFloat]()
    var arrayPaintValues = [String]()
    var arrayTransformRotationValues = [CGFloat]()
    var mainImageScaledSizeForText = CGSize()
    var filterTimer : Timer?
    var stickerTimer : Timer?
    var printIconTimer = Timer()

    var tmpScale: CGFloat = 1.0
    var scaleUpdated = false
    var mirrorAngle = ""
    var flipAngleString = ""
    var flipAngleSticker = ""
    var mainImageViewSize: CGSize!
    var maskView: UIView!
    var selectedCanvasColor = UIColor()
    var stickerSelection = Int()
    var stickerColorSelection = Int()
    var pointSize: CGFloat = 0

    var isEditAddPhoto: Bool?
    var isRotationImage: Bool?
    var isPlusAddPhoto: Bool? = false
    var isStickersFetch: Bool?
    var isFramesFetch: Bool?
    var isCropRatio: Bool?
    var isFilterFetched: Bool = false
    @objc var isBlankCanvasRuler: Bool = true
    var isImageAlreadyEdited: Bool = false
    @objc var isLandscape: Bool = false
    @objc var isLandscape2: Bool = false
    var isReplacingSticker: Bool?
    var isResetWithAuto: Bool = true
    let isOldFrame = true
    var isCircular: Bool?
    var isFinalImage: Bool = false
    var isPanEnableWhileHandlers: Bool = true
    var player: AVPlayer!
    var isSubOptions = false
    var isCategoryFrame = false
    var panBeginningPoint: CGPoint = .zero
    var panBeginningCropBoxEdge: CropBoxEdge = .none
    var panBeginningCropBoxFrame: CGRect = .zero

    var isHoldingMovement = false
    var holdAnimator: UIViewPropertyAnimator?
    var lastSnappedPosition: CGPoint?
//    var holdTimer: Timer?
//    var isNearEdge = false
//    var isSnapped = false

    public var currentAspectRatioValue: CGFloat = 1.0
    public var isCropBoxPanEnabled: Bool = true
    public var cropContentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    public var cropContentInsetStickerText: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var cropRegionInsetsStickerText: UIEdgeInsets = .zero
    var maxCropRegionStickerText: CGRect = .zero
    var defaultCropBoxCenterStickerText: CGPoint = .zero
    var defaultCropBoxSizeStickerText: CGSize = .zero
    

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
    var fliped: Bool = false
    @objc var isFromPhotoBooth: Bool = false
    var manualZoomed: Bool = false
    var initialState: CropperState?
    var indexcount = Int()
    var needReload: Bool = false
    var defaultCropperState: CropperState?
    var uniqueActivityTimer: Timer?
    var uniqueActivityThings: (() -> Void)?
    let doNotShowGoToPrintDialogCount = "doNotShowGoToPrintDialogCount"
    let doNotShowGoToPrintDialog = "doNotShowGoToPrintDialog"
    var currentFrameView:FrameView?
    let magnifyingGlass = MagnifyingGlassView(offset: CGPoint(x: 0, y: 0), radius: 30, scale: 2.5)
    //var selectedFrame2: UIImage?
    var selectedFrame = "none"
    var stickerScale: CGFloat = 1.0
    var textScale: CGFloat = 1.0
    var mainImageScale: CGFloat = 1.0
    let maxScale: CGFloat = 100
    let minScale: CGFloat = 0.5

    var currentTransform: CGAffineTransform? = nil
    var pinchStartImageCenter: CGPoint = CGPoint(x: 0, y: 0)
    let maxScaleImage: CGFloat = 6.0
    var minScaleImage: CGFloat = 1.0
    var pichCenter: CGPoint = CGPoint(x: 0, y: 0)
    var framePanGesture = UIPanGestureRecognizer()
    var isImageEdited: Bool {
        get {
            return (isBlankCanvasRuler || !isBlankCanvasRuler)
        }
    }

    var stickerTagCounter = 1000 // Start from 1000 to avoid potential conflicts

    var lastAdjustedImage: UIImage?
    var lastAutoAppliedImage: UIImage? // To store Auto-applied image
    
    var isFlipped = false
    var isMirrored = false
    var isFlippedSelected = false
    var isMirroredSelected = false
    var isRotateWithCorrectFrame = false
    @objc var customDelegate: EditImageDelegate?
    var selectedRation = 0.0
    var delegate: StickersCellDelegate?
    open lazy var transformBottomView: UIView = {
        let view = UIView(frame: CGRect(x: 110, y: 0, width: view.width - 110 - 60, height: 52))
        view.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]
        return view
    }()

    public var aspectRatioLocked: Bool = false {
        didSet {
            overlay.free = !aspectRatioLocked
        }
    }

    let boundaryRect: CGRect = CGRect(x: 0, y: 0, width: 300, height: 300) // Adjust the boundary rect as needed


    // MARK: - Private Methods

    open var cropBoxFrame: CGRect {
        get {
            return overlay.cropBoxFrame
        }
        set {
            overlay.cropBoxFrame = safeCropBoxFrame(newValue)
        }
    }

    var totalAngle: CGFloat {
        return autoHorizontalOrVerticalAngle(straightenAngle + rotationAngle + flipAngle)
    }

    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.defaultCropBoxSize.width, height: self.defaultCropBoxSize.height))
        sv.delegate = self
        sv.center = self.transformMainView.convert(defaultCropBoxCenter, to: scrollViewContainer)
        sv.bounces = false
        sv.bouncesZoom = false
        sv.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        sv.alwaysBounceVertical = false
        sv.alwaysBounceHorizontal = false
        sv.minimumZoomScale = 1
        sv.maximumZoomScale = 3
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.contentSize = self.defaultCropBoxSize
        return sv
    }()

    lazy var mainImageView: UIImageView = {
        let iv = UIImageView(image: self.imageOrignal)
        iv.backgroundColor = .clear
        iv.clipsToBounds = true
        return iv
    }()

    var cropBoxPanGesture = UIPanGestureRecognizer()
    open lazy var overlay: Overlay = Overlay(frame: self.backgroundView.bounds)
    lazy var framesImageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: -20, width: 100, height: 100))
        return view
    }()

    lazy var framesImageViewAngleRatio: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: -20, width: 100, height: 100))
        return view
    }()

    lazy var stickerTextView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]
        return view
    }()

    lazy var viewPaintDrawing: DrawingView = {
        let view = DrawingView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .clear
        view.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth]
        return view
    }()

    open var isCurrentlyInDefalutState: Bool {
        isCurrentlyInState(defaultCropperState)
    }

    public lazy var angleRuler: AngleRuler = {
        let ar = AngleRuler(frame: CGRect(x: 0, y: 0, width: 147, height: 52))

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
        self.framesImageView.isHidden = true
        self.framesImageViewAngleRatio.isHidden = false
        self.scrollViewContainer.isUserInteractionEnabled = false
        self.setStraightenAngle(CGFloat(angleRuler.value * CGFloat.pi / 180.0))
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

    var paperLengthImageRotation:CGAffineTransform?
    var paperLengthImageMovement:CGAffineTransform?
    var scrollViewZoomScale:CGFloat?
    var scrollviewPaperLengthFrame:CGRect?
    var isFillImage: Bool = false
    var previousImageViewTransform: CGAffineTransform?
    var transformZoomScale: CGFloat?
    var stickerPanGesture: UIPanGestureRecognizer?
    // Instantiate StickerEditor
    var undoRedoManager = UndoManager()
    var previousOpacity = CGFloat()
    var stickerPinchScale: CGFloat = 1.0
    var stickerPreviousPinchScale: CGFloat = 1.0
    var stickerTextPinchGesture = UIPinchGestureRecognizer()
    var isProcessingImage = false // Flag to track image processing state
    var tapMainGesture = UITapGestureRecognizer()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.initialLoad()
        self.calculatingMainImageViewSize()
        NotificationCenter.default.addObserver(self, selector: #selector(handleDisablePanGesture(_:)), name: NSNotification.Name("disabelPanGesture"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdatedFrames(_:)), name: NSNotification.Name("updatedFrames"), object: nil)
        previousSelectedFrame = ""

    }

    override func viewWillAppear(_ animated: Bool) {
        self.isFilterFetched = false
        printIconTimer.invalidate() // just in case this button is tapped multiple times

        // start the timer
        printIconTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }

    @objc func timerAction() {
        self.updateRightBarButtonItem()
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.isFilterFetched = false
        printIconTimer.invalidate()
        global_shouldCancelStickerResizing = true
        global_shouldCancelFrameResizing = true
    }
}

// MARK: - Initial Load -
extension CAEditViewController {
    func initialLoad() {
        self.isEditAddPhoto = false
        drawDottedLine(start: CGPoint(x: self.centerDashLineMargin.bounds.minX, y: self.centerDashLineMargin.bounds.minY), end: CGPoint(x: self.centerDashLineMargin.bounds.maxX, y: self.centerDashLineMargin.bounds.minY), view: self.centerDashLineMargin)

        filterSelection = FilterSelection(rawValue: -1)
        
        self.isShowingRedoUndo()
        self.isEnableRedoUndo()
        
        zoomScale = nil
        mainImageScale = 1.0
        stickerScale = 1.0
        textScale = 1.0
        self.mainImageViewSize = self.mainImageView.bounds.size // Saving initial frames
        switch UIDevice.current.type {
        case .iPhoneSE, .iPhone5, .iPhone5S:
            self.constraintsTopView.constant = 20
            self.mainImageViewSize = CGSize(width: 320, height: 328)
        case .iPhone6, .iPhone7, .iPhone8, .iPhone6S, .iPhoneX:
            break
        default:
            break
        }
        
        self.scrollView.isScrollEnabled = false
        self.addGesturesStickerTextView()
        self.addPanGestureMainEdit()
        self.registerCollectionCell()
        self.setOrignalImage()
        self.calculatingMainImageViewSize()
        self.initialState = saveState()
        self.updatingTransform()
        self.viewPaintDrawing.isUserInteractionEnabled = false
        self.addGesturesMainImageViewForSticker()
        self.selectedFrameOpacity = 1
        self.posGesturesToStickerTextView()
        NotificationCenter.default.addObserver(self, selector: #selector(saveCurrentStateForUndo), name: NSNotification.Name("saveCurrentStateForUndo"), object: nil)
    }
    
    private func updateRightBarButtonItem() {
        let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)

        self.printImageView.image = UIImage(named: "select", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    }

    // MARK: - Notification Functions -
    @objc func handleContextChangedNotification(_ notification: Notification) {
        self.updateRightBarButtonItem()
    }

    @objc func handleDeviceChangedNotification(_ notification: Notification) {
        self.updateRightBarButtonItem()
    }

    @objc func handleDeviceAddedNotification(_ notification: Notification) {
        self.updateRightBarButtonItem()
    }
}

// MARK: - CollectionView -
// MARK: - Register Collection View -

extension CAEditViewController {
    func registerCollectionCell() {
        //Register Collection view cell
        let nib = UINib(nibName: EditOptionsCell.className, bundle: nil)
        self.mainCollectionView.register(nib, forCellWithReuseIdentifier: EditOptionsCell.className)
        self.mainCollectionView.delegate = self
        self.mainCollectionView.dataSource = self
    }

    func setOrignalImage() {
        self.orignalSelectedRatioWith = self.selectedRatioWith
        self.transformMainView.translatesAutoresizingMaskIntoConstraints = false
        //Adding orignal image to main image view
        self.mainImageView.image = self.imageOrignal
        self.imageTransform = self.imageOrignal
        self.imageOrignalBackUp = self.imageOrignal

        isLandscape = (self.imageOrignal.size.height > self.imageOrignal.size.width) ? false : true
        self.updateAspectRatioSelection(isLandscape: self.isLandscape)
    }
}

// MARK: - UIButton Actions -

extension CAEditViewController {
    //MARK: - Main Cross
    @IBAction func actionBackButton(_ sender: Any) {
        self.customDelegate?.backcallback(isSave: false)
        self.dismiss(animated: true)
        if self.hasChanges() {
            print(isFrame())
            //showSaveToGalleryDialog()
        } else {
            if self.isFromPhotoBooth {
                self.dismiss(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }
         
    }

    @IBAction func actionRemoveText(_ sender: Any) {
         
        self.isEnableRedoUndo()
        
        if self.viewPaintDrawing.isUserInteractionEnabled == true || self.magnifyingGlass.magnifiedView != nil {
            if magnifyingGlass.magnifiedView != nil {
                self.saveCrossView.showView()
                self.saveCrossSubOptionsView.hideView()
            }
            let array = self.viewPaintDrawing.lines
            if array.count > 0 {
                self.drawingViewWillBeginDraw()
                self.option.removedBrushDetails.append(self.viewPaintDrawing.lines.last!)
                self.viewPaintDrawing.undoDraw()
                //self.saveDeleteStateForUndo()
            }
        } else {
            let subViews = self.stickerTextView.subviews
            for subview in subViews {
                self.isShowingRedoUndo()
                if subview is AddSticker {
                    if let addSticker = subview as? AddSticker {
                        if addSticker.isSelected {
                            addSticker.removeFromSuperview()
                            self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
                            if subViews.count == 1 {
                                isShowingRedoUndo()
                                isEnableRedoUndo()
                            }

                        }
                    }
                }
                if subview is AddTextView {
                    if let addText = subview as? AddTextView {
                        if addText.isSelected {
                            addText.removeFromSuperview()
                            self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
                            if subViews.count == 1 {
                                isShowingRedoUndo()
                                isEnableRedoUndo()
                            }
                        }
                    }
                }
            }
            self.resetImageView()
            self.saveEdit()
        }
    }

    // MARK: Mid options Tick functionality
    @IBAction func btnSaveEditsClicked(_ sender: Any) {
//        if let handles = self.selectedAddTextView?.handles {
//            let shouldHide = !handles.allSatisfy { $0.isHidden }
//            handles.forEach { $0.isHidden = shouldHide }
//            if shouldHide {
//            }
//        }
        self.selectedAddTextView?.outlineLayer?.isHidden = true
        selectedAddTextView = nil

        self.selectedAddSticker?.handles.forEach { $0.isHidden = true }
        selectedAddSticker = nil
        self.isEnableRedoUndo()
        
        // Restore the initial state if available
        if let defaultCropperState = self.initialState {
            self.restoreState(defaultCropperState)
        }
        self.backgroundView.transform = .identity
        // Apply edits based on the selected filter
        self.saveEdit()

    }
    
    // MARK: Cross functionality
    @IBAction func btnCrossEditsClicked(_ sender: Any) {
         
        self.isShowingRedoUndo()
        
        self.selectedAddTextView?.handles.forEach { $0.isHidden = true }
        self.selectedAddSticker?.handles.forEach { $0.isHidden = true }
        selectedAddTextView = nil
       // selectedAddSticker = nil
        if let defaultCropperState = self.initialState {
            self.restoreState(defaultCropperState)
        }
        self.backgroundView.transform = .identity
        self.hideCrossTick()
    }

    // MARK: Sub options Tick functionality
    @IBAction func actionSubOptionsTick(_ sender: Any) {

        self.selectedAddSticker?.handles.forEach { $0.isHidden = true }

        switch self.filterSelection {
        case .text:
            self.isShownRedoUndo()
            self.deleteAndAddButtons.isHidden = false
            self.isSubOptions = false
            self.magnifyingGlass.magnifiedView = nil
            self.removeGesturesMainImageViewForMagnify()
            self.scrollViewContainer.addGestureRecognizer(self.framePanGesture)

            // Apply the text sub-options (such as font, color, size)
            // self.applySubOptionsForText()

            self.textView.actionCrossForText()

            // Register undo for text changes
//            undoMng?.registerUndo(withTarget: self, handler: { target in
//                target.undoTextChanges()
//              //  self.enableDisableUIControl()
//            })

            self.saveCrossView.showView()
            self.saveCrossSubOptionsView.hideView()
            
//          self.stickersText(text: .showDeleteButton, isText: true)
//            self.deleteAndAddButtons.isHidden = false
//            self.isSubOptions = false
//            self.magnifyingGlass.magnifiedView = nil
//            self.removeGesturesMainImageViewForMagnify()
//            self.mainImageView.addGestureRecognizer(self.framePanGesture)
//            self.applySubOptionsForText()
//            self.saveCrossView.showView()
//            self.saveCrossSubOptionsView.hideView()
//            self.stickersText(text: .showDeleteButton, isText: true)



        case .frame:
            // If a default cropper state exists, restore it
            if let defaultCropperState = self.initialState {
                self.restoreState(defaultCropperState)

                //                // Register undo for frame changes
                //                undoMng?.registerUndo(withTarget: self, handler: { target in
                //                    target.undoFrameChanges()
                //                   // self.enableDisableUIControl()
                //                })
            }

            self.backgroundView.transform = .identity
            self.bottomView.loopViewHierarchy { (view, stop) in
                if view is FrameView {
                    if self.framesImageViewAngleRatio.image == nil {
                        self.saveEdit()
                        self.saveCrossView.hideView()
                        self.saveCrossSubOptionsView.hideView()
                        stop = true
                    } else {
                        //                        let data: [String: Any] = [
                        //                            "view": framesImageViewAngleRatio,
                        //                            "image": framesImageViewAngleRatio.image,
                        //                            "previousImage": framePreviousImage!
                        //                        ]
                        //                        Editor.performAction(type: .add, data: data)
                        self.setUpStickerOptionsAfterSelection(isReset: false)
                        stop = true
                    }
                }
                if view is FrameOptions {
                    self.isRotationImage = false
                    self.saveEdit()
                    self.saveCrossView.hideView()
                    self.saveCrossSubOptionsView.hideView()
                    stop = true

                }
            }
            //            let currentFrameState = FrameModel(frame: selectedFrame2, opacity: selectedFrameOpacity)
            //            print("Applying frames...")
            //            undoStackFrames.append(currentFrameState)
        case .brush:
            self.isShownRedoUndo()
            // Add new brush stroke
            //self.viewPaintDrawing.lines.append(TouchPointsAndColor(color: self.viewPaintDrawing.strokeColor, points: [CGPoint]()))

            // Perform brush-related actions
            self.brushView.actionOnSubOptionTick()

            // Register undo for brush strokes
            self.saveCrossView.showView()
            self.saveCrossSubOptionsView.hideView()
        default:
            break
        }

        // End grouping of undoable actions
        //undoMng?.endUndoGrouping()
    }



    // MARK: Cross functionality
    @IBAction func actionSubOptionsCross(_ sender: Any) {
        self.btnCrossEditsClicked(sender)
        return;

        self.selectedAddTextView?.handles.forEach { $0.isHidden = true }
        selectedAddTextView = nil
        self.selectedAddSticker?.handles.forEach { $0.isHidden = true }
        selectedAddSticker = nil
        self.saveCrossView.showView()
        self.saveCrossSubOptionsView.hideView()
        switch self.filterSelection {
        case .text:
            self.deleteAndAddButtons.isHidden = false
            self.isSubOptions = false
            self.getColorFontProperty()
            self.selectedTextModel.fontCustom = self.selectedTextModel.previousFont
            self.selectedTextModel.selectedFontIndex = self.selectedTextModel.previousSelectedFontIndex

            self.selectedTextModel.color = self.selectedTextModel.previousColor
            self.selectedTextModel.selectedColorIndex = self.selectedTextModel.previousSelectedColorIndex
            self.denyColorAndText(textModel: self.selectedTextModel)
            self.textView.actionCrossForText()

            self.stickersText(text: .showDeleteButtonOnTap, isText: true)

            // Unhide the delete and add buttons
            self.deleteAndAddButtons.isHidden = false

            self.selectedAddTextView?.isSelected = true
            self.selectedAddTextView?.borderView.isHidden = false
//            self.selectedAddTextView?.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
//            self.selectedAddTextView?.layer.borderWidth = 1
            self.setupAddDeleteFlipAndOnTopButtons(isHidden: false) // Show buttons for the selected text

        case .frame:
            if let defaultCropperState = self.initialState {
                self.restoreState(defaultCropperState)
            }
            if isFrameOptionView() {
                self.setUpFrameView(isEdit: true)
            } else {
                if isCategoryFrame == false {
                    isCategoryFrame = true
                    selectedCategoryDetail = nil
                    self.filterSelection = .frame
                    currentFrameView?.frameCollectionView.reloadData()
                } else {
                    self.removeEditSteps()
                    self.hideCrossTick()
                    self.saveCrossView.hideView()
                    self.saveCrossSubOptionsView.hideView()
                }
            }
            break
        case .brush:
            let value = self.option.appliedBrushDetails.last
            
            if self.option.appliedBrushDetails.count == 0 {
                self.option.selectedBrushColorIndex = 0
            }
            
            // Update the brush based on selection
            switch self.brushSelection {
            case .color:
                self.viewPaintDrawing.strokeColor = value?.color ?? UIColor(named: .blackColorName, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!
            case .sharpness:
                self.viewPaintDrawing.brushSharpness = value?.sharpness ?? 1
            case .size:
                self.viewPaintDrawing.strokeWidth = value?.width ?? 10
            case .transperancy:
                self.viewPaintDrawing.strokeOpacity = value?.opacity ?? 1
            default:
                break
            }

            // Update UI elements with the new brush details
            self.brushView.colorModel.selectedColorIndex = self.option.selectedBrushColorIndex
            self.brushView.colorButton.backgroundColor = self.viewPaintDrawing.strokeColor
            self.brushView.widthSlider.value = Float(self.viewPaintDrawing.strokeWidth)
            self.brushView.opacitySlider.value = Float(self.viewPaintDrawing.strokeOpacity)
            
            if self.brushView.sharpnessSlider.value == 10.0 {
                self.brushView.sharpnessSlider.value = 1.0
            } else {
                self.brushView.sharpnessSlider.value = Float(self.viewPaintDrawing.brushSharpness)
            }
            
            // Reset the brush selection
            self.brushSelection = BrushSelection(rawValue: -1)
            self.brushView.actionOnSubOptionTick()
            
            // Show and hide necessary views
            self.saveCrossView.showView()
            self.saveCrossSubOptionsView.hideView()
            
            // Reset color to match the updated stroke color
           // self.resetColor()

            break

//        case .brush:
//
//            let value = self.option.appliedBrushDetails.last
//
//            if self.option.appliedBrushDetails.count == 0 {
//                self.option.selectedBrushColorIndex = 0
//            }
//
//            switch self.brushSelection {
//            case .color:
//                self.viewPaintDrawing.strokeColor = value?.color ?? UIColor(named: .blackColorName)!
//            case .sharpness:
//                self.viewPaintDrawing.brushSharpness = value?.sharpness ?? 1
//            case .size:
//                self.viewPaintDrawing.strokeWidth = value?.width ?? 10
//            case .transperancy:
//                self.viewPaintDrawing.strokeOpacity = value?.opacity ?? 1
//            default:
//                break
//            }
//
//            self.brushView.colorModel.selectedColorIndex = self.option.selectedBrushColorIndex
//            self.brushView.colorButton.backgroundColor = self.viewPaintDrawing.strokeColor
//            self.brushView.widthSlider.value = Float(self.viewPaintDrawing.strokeWidth )
//            self.brushView.opacitySlider.value = Float(self.viewPaintDrawing.strokeOpacity )
//            if self.brushView.sharpnessSlider.value == 10.0 {
//                self.brushView.sharpnessSlider.value = 1.0
//            }   else {
//                self.brushView.sharpnessSlider.value = Float(self.viewPaintDrawing.brushSharpness )
//
//            }
//
//
//            self.brushSelection = BrushSelection(rawValue: -1)
//            self.brushView.actionOnSubOptionTick()
//            self.saveCrossView.showView()
//            self.saveCrossSubOptionsView.hideView()
//            self.resetColor()
//            //self.resetBrush()
//            break
        case .gallery:
            break
        case .adjust:
            self.resetAdjust()
        default:
            break
        }

    }

    func isFrameOptionView() -> Bool {
        let subViews = self.bottomView.subviews
        for subview in subViews {
            if subview is FrameOptions {
                return true
            }
        }
        return false
    }


    // MARK: Tick functionality
    @IBAction func actionTransformTick(_ sender: Any) {
        self.scrollView.isScrollEnabled = false
        self.stickerTextView.isUserInteractionEnabled = true
        self.option.isTransformActual = false
        self.isFlippedSelected = self.isFlipped
        self.isMirroredSelected = self.isMirrored
        // Store current state before changes for undo
        let previousState = self.initialState
        self.saveTransformStateForUndo()
        self.cropperState = saveState()
        self.initialState = saveState()
        self.mainCollectionView.isHidden = false
        
        self.crossTickTransform.isHidden = true
        self.blackCrossTickTransform.isHidden = true
        self.transformOptions.isHidden = true
        self.overlay.gridLinesAlpha = 1
        self.isCropBoxPanEnabled = true
        overlay.blur = false
        overlay.cropBoxAlpha = 1
        if isCurrentlyInState(self.cropperState) {
            self.option.isTransform = false
        } else {
            self.option.isTransform = true
        }
        
        UIView.animate(withDuration: 0.25, animations: {
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, animations: {
                self.overlay.gridLinesAlpha = 0
                self.overlay.cropBoxAlpha = 0
                self.overlay.blur = true
            }, completion: { _ in
                self.overlay.gridLinesAlpha = 0
                self.overlay.cropBoxAlpha = 0
                self.overlay.blur = true
            })
        })
        self.minScaleImage = sqrt(abs(self.scrollView.transform.a * self.scrollView.transform.d - self.scrollView.transform.b * self.scrollView.transform.c))
        self.filterSelection = FilterSelection(rawValue: -1)
        self.applyFrames(isUndoRedo: false)
        
        
//        // Register Undo Operation
//        undoRedoManager.registerUndo(withTarget: self) { target in
//            target.initialState = previousState
//            if let cropperState = target.initialState {
//                self.option.isTransform = true
//                self.restoreState(cropperState)
//                self.updateButtons()
//                
//                self.globalUndoRedo(currentFilterSelection: .transform)
//                self.removeBottomSubViews()
//                self.setUpTransformView()
//                target.restoreTransformStateForUndoRedo(cropperState: self.initialState!)
//            }
//        }
    }
    
    @objc func saveTransformStateForUndo() {
        let currentCropperState = self.initialState!
        undoRedoManager.registerUndo(withTarget: self) { target in
            target.restoreTransformStateForUndoRedo(cropperState: currentCropperState)
        }
        undoRedoManager.setActionName("Transform")
        self.isEnableRedoUndo()
    }
    
    func restoreTransformStateForUndoRedo(cropperState: CropperState) {
        let previousState = self.initialState!
        self.initialState = cropperState

        // Apply the restored state
        self.option.isTransform = true
        self.restoreState(cropperState)

        self.updateButtons()
        
        self.globalUndoRedo(currentFilterSelection: .transform)
        self.removeBottomSubViews()
        self.setUpTransformView()

        undoRedoManager.registerUndo(withTarget: self) { target in
            target.restoreTransformStateForUndoRedo(cropperState: previousState)
        }
        self.isEnableRedoUndo()
    }

    // MARK: Cross functionality
    @IBAction func actionTransformCross(_ sender: Any) {
        self.selectedAddTextView?.handles.forEach { $0.isHidden = true }
        selectedAddTextView = nil
        self.selectedAddSticker?.handles.forEach { $0.isHidden = true }
        selectedAddSticker = nil
        self.scrollView.isScrollEnabled = false
        self.stickerTextView.isUserInteractionEnabled = true
        self.option.isTransformActual = false
        if let cropperState = self.initialState {
            self.option.isTransform = true
            self.restoreState(cropperState)
            self.updateButtons()
        } else {
            self.option.isTransform = false
            self.resetToDefaultLayout(isResetClick: true)
            if let defaultCropperState = self.defaultCropperState {
                self.restoreState(defaultCropperState)
                self.updateButtons()
            }
            self.backgroundView.transform = .identity
        }

        let imageHeigth = self.overlay.cropBox.size.height
        let imageWidth = self.overlay.cropBox.size.width

        if imageHeigth > imageWidth {
            //-- Portrait
            isLandscape = false
            //self.selectedRatioWith = round(((imageHeigth/imageWidth) * 2) * 10) / 10.0
        } else {
            //-- landscape
            isLandscape = true
            //self.selectedRatioWith = round(((imageWidth/imageHeigth) * 2) * 10) / 10.0
        }

        self.resetFramesOnCross()
//        if self.framesImageViewAngleRatio.image != nil {
//            if let frame = selectedFrame as? String {
//                self.toResetFrames(frame: frame)
//            }
//        }

        self.mainCollectionView.isHidden = false
        self.crossTickTransform.isHidden = true
        self.blackCrossTickTransform.isHidden = true
        self.transformOptions.isHidden = true
        self.filterSelection = FilterSelection(rawValue: -1)
        self.backgroundView.transform = .identity
        self.handleOnTap()
    }

    func handleOnTap() {
        self.isShowingRedoUndo()
        self.isEnableRedoUndo()
        
        if let handles = self.selectedAddTextView?.handles {
            let shouldHide = !handles.allSatisfy { $0.isHidden }
            handles.forEach { $0.isHidden = shouldHide }
        }
        
        
        if self.magnifyingGlass.magnifiedView == nil {
            self.selectedAddSticker?.handles.forEach { $0.isHidden = true }
            selectedAddSticker = nil

            if let defaultCropperState = self.initialState {
                self.restoreState(defaultCropperState)
            }
            self.backgroundView.transform = .identity
            
//            switch self.filterSelection {
//            case .sticker:
//                self.applySticker()
//                self.applyImageView()
//                self.hideCrossTickOnly()
//                self.removeBottomSubViews()
//                self.filterSelection = FilterSelection(rawValue: -1)
//                self.mainCollectionView.isHidden = false
//                self.isShowingRedoUndo()
//                self.mainCollectionView.reloadData()
//                
//            case .gallery:
//                self.applySticker()
//                self.applyImageView()
//                self.hideCrossTickOnly()
//                self.removeBottomSubViews()
//                self.filterSelection = FilterSelection(rawValue: -1)
//                self.mainCollectionView.isHidden = false
//                self.isShowingRedoUndo()
//                self.mainCollectionView.reloadData()
//            case .text:
//                self.isShowingRedoUndo()
//                self.applySubOptionsForText()
//                self.applyText()
//                self.applyImageView()
//                self.hideCrossTickOnly()
//                self.removeBottomSubViews()
//                self.filterSelection = FilterSelection(rawValue: -1)
//                self.mainCollectionView.isHidden = false
//                self.mainCollectionView.reloadData()
//            default:
//                break
//            }
            
            isEnableRedoUndo()
            isShowingRedoUndo()
        }
    }
    //MARK: - Main tick
    @IBAction func actionDoneButton(_ sender: Any) {
         

        self.isFinalImage = true
        self.captureEditImage()
        //self.printPreviewButtonAction()
    }

    func capture(view: UIView) -> UIImage?  {
        let snapview = UIView.init(frame: view.frame)

        let renderer = UIGraphicsImageRenderer(size: snapview.bounds.size)
        let image = renderer.image { _ in
            view.addSubview(snapview)
            view.drawHierarchy(in: snapview.bounds, afterScreenUpdates: true)
            snapview.removeFromSuperview()
        }

        if let data = image.jpegData(compressionQuality: 0.8) {
            let iageHigh = UIImage(data: data)
            return iageHigh
        }
        return image
    }

    func capture(image: UIImage, cropBoxFrame:CGRect) -> UIImage?  {
        let mainView = UIView(frame: CGRectMake(0, 0, cropBoxFrame.size.width, cropBoxFrame.size.height))
        let imageView = UIImageView(frame: CGRectMake(0, 0, cropBoxFrame.size.width, cropBoxFrame.size.height))
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        mainView.addSubview(imageView)
        let screenshot = mainView.takeScreenshot()
        return screenshot
    }



    private func currentState() -> CropperState? {
        return CropperState(
            viewFrame: self.view.frame,
            angle: self.angle, // Ensure angle is defined
            rotationAngle: self.rotationAngle,
            straightenAngle: self.straightenAngle,
            flipAngle: self.flipAngle,
            imageOrientationRawValue: self.mainImageView.image?.imageOrientation.rawValue ?? UIImage.Orientation.up.rawValue,
            scrollViewTransform: self.scrollView.transform,
            scrollViewCenter: self.scrollView.center,
            scrollViewBounds: self.scrollView.bounds,
            scrollViewContentOffset: self.scrollView.contentOffset,
            scrollViewMinimumZoomScale: self.scrollView.minimumZoomScale,
            scrollViewMaximumZoomScale: self.scrollView.maximumZoomScale,
            scrollViewZoomScale: self.scrollView.zoomScale,
            cropBoxFrame: self.overlay.cropBoxFrame,
            photoTranslation: self.photoTranslation(), // Ensure this property is defined
            imageViewTransform: self.mainImageView.transform,
            imageViewBoundsSize: self.mainImageView.frame,
            imageCenter: self.mainImageView.center, // Capture image center if needed
            isFlip: isFlippedSelected,
            isMirror: isMirroredSelected
        )
    }

    func draw(with color: UIColor, size: CGFloat, path: UIBezierPath) {

    }


    @IBAction func btnUndoAction(_ sender:UIButton) {
        if undoRedoManager.canUndo {
            undoRedoManager.undo()
        }
        isEnableRedoUndo()
    }

    @IBAction func btnRedoAction(_ sender:UIButton) {
        if undoRedoManager.canRedo {
            undoRedoManager.redo()
        }
        isEnableRedoUndo()
    }

    // Button options's action
    // CALL WHEN CROSS ON ANY MENU OPTIONS--> EXAMPLE STICKERS DATA
    @IBAction func actionBackStickers(_ sender: Any) {
        if self.isReplacingSticker == false {
            self.mainCollectionView.isHidden = false

            self.isShowingRedoUndo()
            self.stickersText(text: .hideDeleteButton, isText: false)
            for view in self.stickerBaseView.subviews {
                view.removeFromSuperview()
            }
            self.bottomView.isHidden = true
            self.stickerVisualEffectView.isHidden = true
            self.saveCrossSubOptionsView.hideView()
            self.saveCrossView.hideView()
        } else {
            self.bottomView.isHidden = false
            self.stickerVisualEffectView.isHidden = true
            let subViews = self.stickerTextView.subviews
            for subview in subViews {
                if subview is AddSticker {
                    if let addSticker = subview as? AddSticker {
                        if addSticker.isSelected {
                            self.setUpStickerOptionView(stickerSelection: addSticker.stickerSelection)
                        }
                    }
                }
            }
        }
    }

    @IBAction func actionAdd(_ sender: Any) {
         
        self.isEnableRedoUndo()
        self.selectedAddTextView?.handles.forEach { $0.isHidden = true }
        selectedAddTextView = nil
        self.selectedAddSticker?.handles.forEach { $0.isHidden = true }

        switch self.filterSelection {
        case .sticker:
            self.applySticker()
            self.setUpStickerView()
            self.isShownRedoUndo()
        case .gallery:
            self.applySticker(isGalleryAddButton: true)
            self.isPlusAddPhoto = true
            self.openPhotoLibrary(isEdit: false)
            self.isShownRedoUndo()
        case .text:
            self.applyText()
            self.setUpTextView(isSaveCross: self.saveCrossView.isHidden)
        default:

            break
        }
    }

    @IBAction func actionMirror(_ sender: Any) {
        switch self.filterSelection {
        case .sticker:
            self.stickersText(text: .mirror, isText: false)
        case .gallery:
            self.stickersText(text: .mirror, isText: false)
        case .text:
            self.stickersText(text: .mirror, isText: true)
        default:
            break
        }
    }

    @IBAction func actionOnTop(_ sender: Any) {
        switch self.filterSelection {
        case .sticker:
            self.stickersText(text: .onTop, isText: false)
        case .gallery:
            self.stickersText(text: .onTop, isText: false)
        case .text:
            self.stickersText(text: .onTop, isText: true)
        default:
            break
        }
    }
}
