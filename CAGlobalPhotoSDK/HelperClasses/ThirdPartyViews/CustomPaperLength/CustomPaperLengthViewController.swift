//
//  CustomPaperLengthViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/05/23.
//

struct List {
    var label = ""
    var ratio:CGFloat?
    var maxSizeRatio:CGFloat?
    var tag = 0
}

enum CanvasOrientation {
    case portrait
    case landscape
}

enum CanvasContentMode {
    case fit
    case fill
}

class SuggetedLength {
    let bestFit = List(label: "Best Fit", ratio: nil, maxSizeRatio: nil, tag: 0)
    let tag  = List(label: "Tag", ratio: 4/2, maxSizeRatio: 2/4, tag:1)
    let sticker  = List(label: "Sticker", ratio: 2/2, maxSizeRatio: 2/2, tag:2)
    let label  = List(label: "Label", ratio: 6/2, maxSizeRatio: 2/6, tag:3)
}

var xAxisFloating = UIScreen.main.bounds.size.width - 48
var yAxisFloating = 195.0
var widthFloating = 42.0
var heightFloating = 95.0
var widthButtonFill = 47.0
var heightButtonFill = 47.0
var screenHeight = UIScreen.main.bounds.size.height

import UIKit
import Photos

public class CustomPaperLengthViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var tableViewSize: UITableView!
    @IBOutlet weak var canvasView: CanvasCropView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Variables and Properties
    var buttonOrientation = UIButton(type: .custom)
    var buttonFitFill = UIButton(type: .custom)
    var floatingButtonsView = UIView()
    var source:String?
    var selectedTag = 0
    var bestFitRatioValue: CGFloat?
    var selectedRatioWith: CGFloat?
    @objc var mediaImage = UIImage()
    var isImageSavePopupShowComingFromCamera:Bool?
    var isLandscape = true
    var isFillImage = false
    var isOrienationChnaged = false
    var saveIamgeToGallery: Bool = false
    var goToPreview: Bool = false
    var isImageEditedToSave: Bool = false
    var isImageEditedFromEditor: Bool = false
    
    open var image: UIImage? {
        didSet {
            canvasView?.image = image
        }
    }
    
    open var rotationEnabled = false {
        didSet {
            canvasView?.rotationGestureRecognizer.isEnabled = rotationEnabled
        }
    }
    
    var originalImageSize: CGSize? = CGSize.zero
    var originalFinalImageSize: CGSize? = CGSize.zero
    var originalCanvasOrientation: CanvasOrientation?
    var originalCanvasContentMode: CanvasContentMode?
    var originalImageMoved: Bool = false
    
    // MARK: - Init methods
    @objc static func presentCustomPaperLength(currentViewController:UIViewController, mediaImage:UIImage, animated:Bool ){
        
    }
    
    // MARK: - View Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.isPaperLengthView = true
        canvasView.delegate = self
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        let nib = UINib(nibName: PaperLengthCell.className, bundle: nil)
        tableViewSize.register(nib, forCellReuseIdentifier: PaperLengthCell.className)
        tableViewSize.dataSource = self
        tableViewSize.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.orientationFloatingButton()
            self.initBestFitOptionWithtImage()
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            self.setOriginalImageParameters()
        }
        self.doubleGesture()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        setNeedsStatusBarAppearanceUpdate()
    }
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        orientationFloatingButton()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        floatingButtonsView.removeFromSuperview()
    }
     
    func doubleGesture() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(CustomPaperLengthViewController.actionFitFillChnage(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        canvasView.addGestureRecognizer(doubleTapGesture)
    }
    
    // MARK: - Functions
    
    func setOriginalImageParameters() {
        
        if let image = canvasView.image {
            self.originalImageSize = image.size
        }
        
        if let image = canvasView.finalImage {
            self.originalFinalImageSize = image.size
        }
        
        self.originalCanvasOrientation = self.isLandscape ? .landscape : .portrait
        self.originalCanvasContentMode = self.isFillImage ? .fill : .fit
        self.selectedSizeOfPaperlength(0)
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
        } else if selectedTag == 0 && self.originalCanvasOrientation == currentOrientation {
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
    
    func initBestFitOptionWithtImage() {
        
        canvasView.isPaperLengthView = true
        canvasView.isBlankCanvasRuler = false
        let imageHeigth = self.mediaImage.size.height
        let imageWidth = self.mediaImage.size.width
        
        if imageHeigth > imageWidth {
            //-- Portrait
            isLandscape = false
            bestFitRatioValue = round(((imageHeigth/imageWidth) * 2) * 10) / 10.0
        } else {
            //-- landscape
            isLandscape = true
            bestFitRatioValue = round(((imageWidth/imageHeigth) * 2) * 10) / 10.0
        }
        
        if bestFitRatioValue! > 9.0 {
            bestFitRatioValue = 9.0
        }
        self.selectedSizeOfPaperlength(0)
    }
    
    func calculateMaxSize(aspectRatio:CGFloat) -> CGFloat{
        //As landscape, width is constant, need to calculte heigth for ratio given
        if isLandscape {
            let maxWidth = self.canvasView.frame.size.width - 105
            return maxWidth * aspectRatio
        } else {
            //As portrit, height is constant, need to calculte width for ratio given
            let maxHeight = self.canvasView.frame.size.width - 105
            return maxHeight * aspectRatio
        }
    }
    
    // MARK: - @IBActions
    @IBAction func actionCustomLength(_ sender: Any) {
        if let newImage = canvasView?.image {
            let paperLengthImageMovement = canvasView.paperLengthImageMovementTransform
            let paperLengthImageRotation = canvasView.paperLengthImageRotation
            let scrollViewZoomScale = 1
            let scrollviewPaperLengthFrame = canvasView.frame
            let isImageEdited = self.isImageEdited(newImage, goingToEditor: false)
            
            let rulerViewController = CustomRulerCanvasViewController(nibName: CustomRulerCanvasViewController.className, bundle: nil)
            rulerViewController.image = newImage
            rulerViewController.isLandscape = isLandscape
            rulerViewController.sliderCanvasImageValue = self.selectedRatioWith
            rulerViewController.isBlankCanvasRuler = false
            rulerViewController.previousImageView = canvasView.imageView
            rulerViewController.isFillImage = isFillImage

            rulerViewController.paperLengthImageMovement = paperLengthImageMovement
            rulerViewController.paperLengthImageRotation = paperLengthImageRotation
            rulerViewController.scrollViewZoomScale = CGFloat(scrollViewZoomScale)
            rulerViewController.scrollviewPaperLengthFrame = scrollviewPaperLengthFrame
            rulerViewController.isImageAlreadyEdited = isImageEdited
            self.navigationController?.pushViewController(rulerViewController, animated: true)
        }
    }
    
    @IBAction func actionNextButton(_ sender: Any) {
        GlobalHelper.sharedManager.selectedRatioWith = self.selectedRatioWith ?? 0
//        let viewController = CAEditViewController(nibName: CAEditViewController.className, bundle: nil)
//        if let newImage = canvasView?.finalImage {
//            viewController.imageOrignal = newImage
//            viewController.imageOrignalBackUp = newImage
//            let isImageEdited = self.isImageEdited(newImage, goingToEditor: true)
//            viewController.selectedRatioWith = self.selectedRatioWith ?? 0
//            viewController.selectedRatioWith2 = self.selectedRatioWith ?? 0
//            viewController.isLandscape = self.isLandscape
//            viewController.isLandscape2 = self.isLandscape
//            viewController.isBlankCanvasRuler = false
//            viewController.isImageAlreadyEdited = isImageEdited
//            self.navigationController?.pushViewController(viewController, animated: true)
//        }
    }
    
    @IBAction func actionBackButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc func actionOrientationChnage(_ sender: Any) {
        isLandscape = !isLandscape
        isOrienationChnaged = true
        selectedSizeOfPaperlength(selectedTag)
    }
    
    @objc func actionFitFillChnage(_ sender:Any) {
        if isFillImage {
            isFillImage = false
            //For best fit,sometime shows white line when image is fill hence only for bestfit fit scenraion made it aspect fill
            
            if selectedTag == SuggetedLength().bestFit.tag {
                if (originalCanvasOrientation == .landscape && isLandscape) || (originalCanvasOrientation == .portrait && !isLandscape){
                } else {
                    canvasView.setupImgViewAgainForCanvasSizeChange(contentMode: .scaleAspectFit, orienationaChange:false)
                }
            } else {
                canvasView.setupImgViewAgainForCanvasSizeChange(contentMode: .scaleAspectFit, orienationaChange:false)
            }
            
        } else {
            isFillImage = true
            canvasView.setupImgViewAgainForCanvasSizeChange(contentMode: .scaleAspectFill, orienationaChange:false)
        }
    }
}

// MARK: - CropView Delegate
extension CustomPaperLengthViewController: CropViewDelegate {
    func didDragCanvas(_: CanvasCropView, didDragImage moved: Bool) {
        
    }
    
    func cropView(_: CanvasCropView, didMoveImage moved: Bool) {
        self.originalImageMoved = moved
    }
}


// MARK: - Tableview delegates
extension CustomPaperLengthViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let optionalCell = tableView.dequeueReusableCell(withIdentifier: PaperLengthCell.className, for: indexPath) as? PaperLengthCell
        guard let cell = optionalCell else {
            // 'optionalCell' is nil, will return empty cell
            return UITableViewCell()
        }

        if indexPath.row == 0 {
            if bestFitRatioValue ?? 0.0 > 9 {
                cell.initButtonWithText(text: SuggetedLength().bestFit.label, size: "2\" x 9\"", tag: indexPath.row)
            } else {
                let ratio =  round((bestFitRatioValue ?? 0.0) * 10) / 10.0
                cell.initButtonWithText(text: SuggetedLength().bestFit.label, size: "2\" x \(ratio)\"", tag: indexPath.row)
            }
        } else if indexPath.row == 1 {
            cell.initButtonWithText(text: SuggetedLength().tag.label, size: "2\" x 4\"", tag: indexPath.row)
        } else if indexPath.row == 2 {
            cell.initButtonWithText(text: SuggetedLength().sticker.label, size: "2\" x 2\"", tag: indexPath.row)
        } else if indexPath.row == 3 {
            cell.initButtonWithText(text: SuggetedLength().label.label, size: "2\" x 6\"", tag: indexPath.row)
        }
        
        if indexPath.row == selectedTag {
            cell.actionChangeCanvasSize()
        }
        
        cell.delegate = self
        return cell
    }
    
}

// MARK: - PGPaperLengthDelegate

extension CustomPaperLengthViewController: PaperLengthDelegate {
    
    func selectedSizeOfPaperlength(_ tag: Int){
        //Update UI
        selectedTag = tag
        tableViewSize.reloadData()
        var isOriginalCanvasOrientation = false
        
        if (originalCanvasOrientation == .landscape && isLandscape) || (originalCanvasOrientation == .portrait && !isLandscape){
            isOriginalCanvasOrientation = true
        }
        
        switch tag {
        case SuggetedLength().bestFit.tag :
            selectedRatioWith = bestFitRatioValue
            if isOriginalCanvasOrientation{
                self.isFillImage = true
                let aspectRatio = ((bestFitRatioValue ?? 2)/2)
                let size = calculateMaxSize(aspectRatio: (2/(bestFitRatioValue ?? 2)))
                canvasView.canvasFrame(isLandscape: isLandscape, aspectRatio: aspectRatio, size: size, image: self.mediaImage, contentMode: .scaleAspectFill, orienationaChange: isOrienationChnaged)
            } else {
                self.isFillImage = false
                let aspectRatio = ((bestFitRatioValue ?? 2)/2)
                let size = calculateMaxSize(aspectRatio: (2/(bestFitRatioValue ?? 2)))
                canvasView.canvasFrame(isLandscape: isLandscape, aspectRatio: aspectRatio, size: size, image: self.mediaImage, contentMode: .scaleAspectFit, orienationaChange: isOrienationChnaged)
            }
        case SuggetedLength().tag.tag :
            self.isImageEditedToSave = true
            selectedRatioWith = 4
            if isOriginalCanvasOrientation {
                self.isFillImage = true
                let aspectRatio = SuggetedLength().tag.ratio ?? 2.0
                let size = calculateMaxSize(aspectRatio:SuggetedLength().tag.maxSizeRatio ?? 0.0)
                canvasView.canvasFrame(isLandscape: isLandscape, aspectRatio: aspectRatio, size: size, image: self.mediaImage, contentMode: .scaleAspectFill, orienationaChange: isOrienationChnaged)
            } else {
                self.isFillImage = false
                let aspectRatio = SuggetedLength().tag.ratio ?? 0
                let size = calculateMaxSize(aspectRatio:SuggetedLength().tag.maxSizeRatio ?? 0.0)
                canvasView.canvasFrame(isLandscape: isLandscape, aspectRatio: aspectRatio, size: size, image: self.mediaImage, contentMode: .scaleAspectFit, orienationaChange: isOrienationChnaged)
            }
        case SuggetedLength().sticker.tag :
            self.isImageEditedToSave = true
            selectedRatioWith = 2
            if isOriginalCanvasOrientation{
                self.isFillImage = true
                let aspectRatio = SuggetedLength().sticker.ratio ?? 0.0
                let size = calculateMaxSize(aspectRatio: SuggetedLength().sticker.maxSizeRatio ?? 0.0)
                canvasView.canvasFrame(isLandscape: isLandscape, aspectRatio: aspectRatio, size: size, image: self.mediaImage, contentMode: .scaleAspectFill, orienationaChange: isOrienationChnaged)
            } else {
                self.isFillImage = false
                let aspectRatio = SuggetedLength().sticker.ratio  ?? 0.0
                let size = calculateMaxSize(aspectRatio: SuggetedLength().sticker.maxSizeRatio ?? 0.0)
                canvasView.canvasFrame(isLandscape: isLandscape, aspectRatio: aspectRatio, size: size, image: self.mediaImage, contentMode: .scaleAspectFit, orienationaChange: isOrienationChnaged)
            }
        case SuggetedLength().label.tag :
            self.isImageEditedToSave = true
            selectedRatioWith = 6
            if isOriginalCanvasOrientation {
                self.isFillImage = true
                let aspectRatio = SuggetedLength().label.ratio ?? 0.0
                let size = calculateMaxSize(aspectRatio:SuggetedLength().label.maxSizeRatio ?? 0.0)
                canvasView.canvasFrame(isLandscape: isLandscape, aspectRatio: aspectRatio, size: size, image: self.mediaImage, contentMode: .scaleAspectFill, orienationaChange: isOrienationChnaged)
            } else {
                self.isFillImage = false
                let aspectRatio = SuggetedLength().label.ratio ?? 0.0
                let size = calculateMaxSize(aspectRatio:SuggetedLength().label.maxSizeRatio ?? 0.0)
                canvasView.canvasFrame(isLandscape: isLandscape, aspectRatio: aspectRatio, size: size, image: self.mediaImage, contentMode: .scaleAspectFit, orienationaChange: isOrienationChnaged)
            }
        default:
            break
        }
        canvasView.imgNewRatio = selectedRatioWith ?? 0.0
        if isOrienationChnaged {
            isOrienationChnaged = false
        }
    }
}


// MARK: - Orientation Floating button

extension CustomPaperLengthViewController {
    
    func orientationFloatingButton(){
        let xAxis = xAxisFloating
        let yAxis = screenHeight - tableViewSize.frame.height - yAxisFloating
        floatingButtonsView.frame = CGRect(x: xAxis, y: yAxis , width: widthFloating, height: heightFloating)
        let optionalImage = UIImage(named: "custom_lenght_floating_background")
        guard let image = optionalImage else {
            return
        }
        floatingButtonsView.backgroundColor = UIColor(patternImage: image)
        
        //Orientation button
        buttonOrientation.frame = CGRect(x: -3, y: 1 , width: widthButtonFill, height: heightButtonFill)
        buttonOrientation.setImage(UIImage(named: "custom_length_orientation"), for: .normal)
        buttonOrientation.clipsToBounds = true
        buttonOrientation.addTarget(self,action: #selector(CustomPaperLengthViewController.actionOrientationChnage(_:)), for: .touchUpInside)
        buttonOrientation.isUserInteractionEnabled = true
        
        buttonFitFill.frame = CGRect(x: -3, y: widthFloating - 2 , width: widthButtonFill, height: heightButtonFill)
        buttonFitFill.setImage(UIImage(named: "custom_length_fitfill"), for: .normal)
        buttonFitFill.clipsToBounds = true
        buttonFitFill.addTarget(self,action: #selector(CustomPaperLengthViewController.actionFitFillChnage(_:)), for: .touchUpInside)
        buttonFitFill.isUserInteractionEnabled = true
        
        floatingButtonsView.addSubview(buttonOrientation)
        floatingButtonsView.addSubview(buttonFitFill)
        if let window = UIApplication.shared.delegate?.window {
            window?.addSubview(floatingButtonsView)
        }
    }
}
