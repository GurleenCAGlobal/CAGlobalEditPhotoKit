//
//  CAEditTransformViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 6/12/23.
//

import UIKit
// MARK: - Transform Option -

extension CAEditViewController: CropperViewControllerDelegate, RulerCanvasDelegate {

    func setUpTransformView() {
        self.scrollView.isScrollEnabled = true
        self.mainImageView.transform = CGAffineTransformIdentity;
        self.stickerTextView.isUserInteractionEnabled = false
        self.option.isTransform = false
        self.option.isTransformActual = true
        self.crossTickTransform.isHidden = false
        self.blackCrossTickTransform.isHidden = false
        self.transformOptions.isHidden = false
        self.overlay.gridLinesAlpha = 1
        overlay.blur = false
        overlay.gridLinesAlpha = 0
        overlay.cropBoxAlpha = 0
        bottomView.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.25, animations: {
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, animations: {
                self.overlay.gridLinesAlpha = 132
                self.overlay.cropBoxAlpha = 1
                self.overlay.blur = true
            }, completion: { _ in
                self.bottomView.isUserInteractionEnabled = true
            })
        })

        let imageHeigth = self.overlay.cropBox.size.height
        let imageWidth = self.overlay.cropBox.size.width

        if imageHeigth > imageWidth {
            //-- Portrait
            isLandscape = false
            self.verticalView.layer.borderWidth = 2
            self.horizontalView.layer.borderWidth = 0
            self.resetView.layer.borderWidth = 0
            self.setPaperView.layer.borderWidth = 0
            selectedRation = round(((imageHeigth/imageWidth) * 2) * 10) / 10.0
        } else {
            //-- landscape
            isLandscape = true
            self.verticalView.layer.borderWidth     = 0
            self.horizontalView.layer.borderWidth   = 2
            self.resetView.layer.borderWidth        = 0
            self.setPaperView.layer.borderWidth     = 0
            selectedRation = round(((imageWidth/imageHeigth) * 2) * 10) / 10.0
        }

        if let defaultCropperState = self.cropperState {
            self.restoreState(defaultCropperState)
        }
        self.backgroundView.transform = .identity
        if imageHeigth > imageWidth {
            self.aspectRatioPickerDidSelectedAspectRatio(.ratio(width: 2, height: selectedRation))
        } else {
            self.aspectRatioPickerDidSelectedAspectRatio(.ratio(width: selectedRation, height: 2))
        }
    }

    func setUpTransformViewBlank(image: UIImage) {
        self.option.isTransform = false
        self.option.isTransformActual = true
        self.crossTickTransform.isHidden = false
        self.blackCrossTickTransform.isHidden = false
        self.transformOptions.isHidden = false
        self.overlay.blur = true
        self.overlay.gridLinesAlpha = 1
        self.overlay.cropBoxAlpha = 1
    }

    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?, selectedRatioWith: CGFloat) {
        self.selectedRatioWith = selectedRatioWith
        let imageCrop: UIImage!
        if let state = state {
            imageCrop = cropper.originalImage.cropped(withCropperState: state)
            cropperState = state
            self.imageTransform = imageCrop
            self.fetchAspectRatioFromImage(image: imageCrop)
            self.mainImageView.image = self.applyingAllFilters(false,false,false)
            self.saveEdit()
            if isBlankCanvasRuler == false {
                self.calculatingMainImageViewSize()
            }
        }
    }


    func fetchAspectRatioFromImage(image: UIImage) {
        let imageHeigth = image.size.height
        let imageWidth = image.size.width
        var isLandscape = false
        var bestFitRatioValue: CGFloat?
        if imageHeigth > imageWidth {
            //-- Portrait
            isLandscape = false
            bestFitRatioValue = round(((imageHeigth/imageWidth) * 2) * 10) / 10.0
        } else {
            //-- landscape
            isLandscape = true
            bestFitRatioValue = round(((imageWidth/imageHeigth) * 2) * 10) / 10.0
        }
        self.isLandscape = isLandscape
        self.selectedRatioWith = bestFitRatioValue ?? 0
    }

    func didSelectClockwiseRotate() {
        let img = mainImageView.image
        let flippedImage = self.setEffectOn(image:img!, effect:.rotate)
        self.mainImageView.image = flippedImage
        let orientation = flippedImage.imageOrientation
        switch orientation {
        case .up:
            flipAngleString = "up"
        case .upMirrored:
            flipAngleString = "upMirrored"
        case .down, .left, .right, .downMirrored, .leftMirrored, .rightMirrored:
            break;
        @unknown default:
            break
        }
    }

    func didSelectVerticallyFlip() {
        let img = mainImageView.image
        let flippedImage = self.setEffectOn(image:img!, effect:.flip)
        self.mainImageView.image = flippedImage

        let orientation = flippedImage.imageOrientation
        switch orientation {
        case .up:
            flipAngleString = "up"
        case .upMirrored:
            flipAngleString = "upMirrored"
        case .down, .left, .right, .downMirrored, .leftMirrored, .rightMirrored:
            break;
        @unknown default:
            break
        }
    }

    func didSelectHorizontallyFlip() {
        let img = mainImageView.image
        let flippedImage = self.setEffectOn(image:img!, effect:.mirror)
        self.mainImageView.image = flippedImage

        let orientation = flippedImage.imageOrientation
        switch orientation {
        case .up:
            mirrorAngle = "up"
        case .upMirrored:
            mirrorAngle = "upMirrored"
        case .down, .left, .right, .downMirrored, .leftMirrored, .rightMirrored:
            break;
        @unknown default:
            break
        }
    }

    func dismissWithUpdatedRatio(paperLengthImageMovementTransform: CGAffineTransform,
                                 paperLengthImageRotation: CGAffineTransform,
                                 previousImageViewTransform: CGAffineTransform,
                                 scrollViewZoomScale: Int,
                                 scrollviewPaperLengthFrame: CGRect ,
                                 isImageAlreadyEdited: Bool,
                                 isFillImage: Bool,
                                 isLandscape: Bool,
                                 selectedRatioWith: CGFloat,
                                 image:UIImage) {
        self.navigationController?.popViewController(animated: true)
        let gettingImage : UIImage
        gettingImage = self.imageOrignal
        let oldImageSize = gettingImage.size

        self.mainImageScale = 1.0
        self.stickerScale = 1.0
        self.textScale = 1.0
        self.paperLengthImageMovement = paperLengthImageMovementTransform
        self.paperLengthImageRotation = paperLengthImageRotation
        self.scrollViewZoomScale = CGFloat(scrollViewZoomScale)
        self.scrollviewPaperLengthFrame = scrollviewPaperLengthFrame
        self.isImageAlreadyEdited = isImageAlreadyEdited
        self.isFillImage = isFillImage
        self.selectedRatioWith = selectedRatioWith
        self.selectedRatioWith2 = selectedRatioWith
        self.isLandscape2 = isLandscape
        self.imageTransform = image
        self.imageOrignal = image
        self.previousImageViewTransform = previousImageViewTransform
        self.isLandscape = isLandscape
        self.mainImageView.image = self.applyingAllFilters(false,false,true)
        cropContentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        cropRegionInsets = .zero
        maxCropRegion = .zero
        defaultCropBoxCenter = .zero
        defaultCropBoxSize = .zero
        self.resetToDefaultLayout(isResetClick: false, isSetPaperLength: true)
        let newGettingImage : UIImage
        newGettingImage = self.imageOrignal
        let newImageSize = newGettingImage.size

        let differencWidth = oldImageSize.width - newImageSize.width
        let differencHeight = oldImageSize.height - newImageSize.height
        print(differencWidth,differencHeight)

        self.saveEdit()
        if self.framesImageViewAngleRatio.image != nil {
            if let frame = selectedFrame as? String {
                self.toResetFrames(frame: frame)
            }
        }
    }


    func updateFramesSticker(xAxis: CGFloat, yAxis: CGFloat) {
        for textView in self.option.stickerDetail {
            let textViewDetail = textView.sticker
            let transform = textViewDetail!.transform
            let origin = textViewDetail?.frame.origin
            let size = textViewDetail?.frame.size
            print((origin?.x ?? 0) - xAxis)
            let frame = CGRect(x: (origin?.x ?? 0) - xAxis , y: (origin?.y ?? 0) - yAxis , width: (size?.width ?? 0), height: (size?.height ?? 0))

            var color = UIColor.white
            if customStickerArray.count > 0 {

            } else {

            }
            let colorManager = ColorManager()
            _ = colorManager.getColorsData()

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

    func backButtonClicked(isLandscape: Bool) {
        self.hideCrossTick()
        self.updateAspectRatioSelection(isLandscape: isLandscape)
        self.mainImageView.image = self.applyingAllFilters(false,false,true)
        if let defaultCropperState = self.initialState {
            self.restoreState(defaultCropperState)
        }
        self.backgroundView.transform = .identity
        if self.framesImageViewAngleRatio.image != nil {
            if let frame = selectedFrame as? String {
                self.toResetFrames(frame: frame)
            }
        }
    }

    // Example function to update the text and register undo/redo actions
    func updateTextViewText(addSticker: AddTextView, newText: String) {
        // Register the current state before making changes
        let oldText = addSticker.text

        undoManager?.registerUndo(withTarget: self) { targetSelf in
            // Undo block to revert the text change
            targetSelf.updateTextViewText(addSticker: addSticker, newText: oldText ?? "")
        }

        // Change the text
        addSticker.text = newText
    }

    // Example function to update the text color and register undo/redo actions
    func updateTextViewColor(addSticker: AddTextView, newColor: UIColor) {
        guard let oldColor = addSticker.textColor else { return }

        undoManager?.registerUndo(withTarget: self) { targetSelf in
            // Undo block to revert the color change
            targetSelf.updateTextViewColor(addSticker: addSticker, newColor: oldColor)
        }

        // Change the color
        addSticker.textColor = newColor
    }

    // Example function to update the font and register undo/redo actions
    func updateTextViewFont(addSticker: AddTextView, newFont: UIFont) {
        guard let oldFont = addSticker.font else { return }

        undoManager?.registerUndo(withTarget: self) { targetSelf in
            // Undo block to revert the font change
            targetSelf.updateTextViewFont(addSticker: addSticker, newFont: oldFont)
        }

        // Change the font
        addSticker.font = newFont
    }

    func presentRatioCropView() {
        let rulerViewController = CustomRulerCanvasViewController(nibName: CustomRulerCanvasViewController.className, bundle: nil)
        rulerViewController.image = self.getMainImage()
        rulerViewController.sliderCanvasImageValue = self.selectedRatioWith
        rulerViewController.isBlankCanvasRuler = false
        rulerViewController.isFromPaperLength = false
        rulerViewController.rulerCanvasDelegate = self
        rulerViewController.navigateFromEditScreen = true

        if self.paperLengthImageMovement == nil && self.paperLengthImageRotation == nil {
            rulerViewController.paperLengthImageMovement = self.mainImageView.transform
            rulerViewController.paperLengthImageRotation = self.mainImageView.transform
            rulerViewController.isImageAlreadyEdited = true
        } else {
            rulerViewController.isImageAlreadyEdited = self.isImageAlreadyEdited
        }
        rulerViewController.scrollViewBounds = self.scrollView.bounds
        rulerViewController.zoomScrollView = self.scrollView.zoomScale
        rulerViewController.scrollViewZoomScale = self.scrollViewZoomScale
        rulerViewController.scrollviewPaperLengthFrame = self.scrollviewPaperLengthFrame
        rulerViewController.isFillImage = mainImageView.contentMode == .scaleAspectFill ? true:false//self.isFillImage
  //    rulerViewController.isFillImage = self.isFillImage

        rulerViewController.isLandscape = isLandscape
        rulerViewController.option.stickerDetail = self.option.stickerDetail


        // Sticker
        let stickerView = UIView(frame: self.stickerTextView.frame)
        stickerView.transform = self.stickerTextView.transform
        stickerView.clipsToBounds = true
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let addSticker = subview as? AddSticker {
                    let tempSticker =  AddSticker(frame: addSticker.frame)
                    tempSticker.image = addSticker.image
                    tempSticker.transform = addSticker.transform
                    tempSticker.tintColor = addSticker.tintColor
                    stickerView.addSubview(tempSticker)
                }
            }

            if subview is AddTextView {
                if let addSticker = subview as? AddTextView {
                    let customView = AddTextView(frame: addSticker.frame)

                    // Register undo for text change
                    updateTextViewText(addSticker: customView, newText: addSticker.text ?? "")

                    // Register undo for color change
                    updateTextViewColor(addSticker: customView, newColor: addSticker.textColor ?? .black)

                    // Register undo for font change
                    updateTextViewFont(addSticker: customView, newFont: addSticker.font ?? UIFont.systemFont(ofSize: 12))

                    // Additional properties
                    customView.textAlignment = addSticker.textAlignment
                    customView.backgroundColor = addSticker.backgroundColor
                    customView.transform = addSticker.transform

                    stickerView.addSubview(customView)
                }
            }

        }

        // Drawing
        let paintView = DrawingView()
        paintView.strokeColor = self.viewPaintDrawing.strokeColor
        paintView.strokeWidth = self.viewPaintDrawing.strokeWidth
        paintView.strokeOpacity = self.viewPaintDrawing.strokeOpacity
        paintView.brushSharpness = self.viewPaintDrawing.brushSharpness
        paintView.lines = self.viewPaintDrawing.lines

        //Screenshot second approach
        let drawingScreenshot = self.viewPaintDrawing.takeScreenshot()
        rulerViewController.drawingImage = drawingScreenshot
        rulerViewController.editSelectedFrame = selectedFrame
        rulerViewController.stickerView = stickerView
        rulerViewController.drawingStickerImage = self.getStickerTextImage()
        rulerViewController.viewPaint = paintView

        self.navigationController?.pushViewController(rulerViewController, animated: true)
    }

    func notPresentRatioCropView() {
        self.isCropRatio = false
    }

    func cropViewControllerDidCrop(cropped: UIImage) {
        self.imageTransform = cropped
        self.mainImageView.image = self.applyingAllFilters(false,false,false)
        self.saveEdit()
        dismiss(animated: false)
        if self.isCropRatio ?? false {
            let rulerViewController = CustomRulerCanvasViewController(nibName: CustomRulerCanvasViewController.className, bundle: nil)
            rulerViewController.image = self.imageTransform
            rulerViewController.isLandscape = isLandscape
            rulerViewController.sliderCanvasImageValue = self.selectedRatioWith
            rulerViewController.isBlankCanvasRuler = false
            rulerViewController.isFromPaperLength = false
            rulerViewController.rulerCanvasDelegate = self
            rulerViewController.selectedColor = .white
            self.navigationController?.pushViewController(rulerViewController, animated: true)
        }
    }

    func cropViewControllerDidCancel() {
        self.hideCrossTick()
        dismiss(animated: false)
    }

    func resetTransform() {
    }

    func applyTransform() {
        self.option.isTransform = true
    }
}

extension CAEditViewController {

    func updatingTransform() {
        cropBoxPanGesture = UIPanGestureRecognizer(target: self, action: #selector(cropBoxPan(_:)))
        cropBoxPanGesture.delegate = self
        navigationController?.navigationBar.isHidden = true

        if self.imageOrignal.size.width < 1 || self.imageOrignal.size.height < 1 {
            return
        }

        view.backgroundColor =  UIColor.init(red: 45 / 255.0, green: 42 / 255.0, blue: 45 / 255.0, alpha: 1)
        self.scrollView.addSubview(self.mainImageView)

        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }

        self.view.setNeedsDisplay()
        self.view.layoutIfNeeded()
        //self.scrollViewContainer.scrollView = scrollView



//        self.constraintTop.isHidden = false
//        self.bottomConstraint.isHidden = false
//        self.leadingConstraint.isHidden = false
//        self.trailingConstraint.isHidden = false
//        self.centerXConstraint.isHidden = false
//        self.centerYConstraint.isHidden = false

        self.scrollViewContainer.addGestureRecognizer(cropBoxPanGesture)
        self.scrollView.panGestureRecognizer.require(toFail: cropBoxPanGesture)
        self.scrollViewContainer.frame = CGRectMake(0, 0, self.transformMainView.frame.size.width, self.transformMainView.frame.size.height)
        self.backgroundView.frame = CGRectMake(0, 0, self.transformMainView.frame.size.width, self.transformMainView.frame.size.height)
        switch UIDevice.current.type {
        case .iPhoneSE, .iPhone5, .iPhone5S:
            angleRuler.frame.origin.x = 30
            angleRuler.frame.size.width = 147
        case .iPhone6, .iPhone7, .iPhone8, .iPhone6S, .iPhoneX:
            angleRuler.frame.origin.x = 30
            angleRuler.frame.size.width = view.width - 110 - 60
        default:
            angleRuler.frame.origin.x = 30
            angleRuler.frame.size.width = view.width - 110 - 60
        }
        self.transformBottomView.addSubview(angleRuler)
        self.angleView.addSubview(self.transformBottomView)
        switch UIDevice.current.type {
        case .iPhoneSE, .iPhone5, .iPhone5S, .iPhone6, .iPhone6S:
            self.constraintsBottomtransform.constant = 0
        case .iPhone7, .iPhone8, .iPhoneX:
            self.constraintsBottomtransform.constant = 35
        default:
            self.constraintsBottomtransform.constant = 35
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.scrollViewContainer.frame = CGRectMake(0, 0, self.transformMainView.frame.size.width, self.transformMainView.frame.size.height)
            self.backgroundView.frame = CGRectMake(0, 0, self.transformMainView.frame.size.width, self.transformMainView.frame.size.height)
            //--
            self.scrollViewContainer.addSubview(self.scrollView)
            self.scrollViewContainer.addSubview(self.framesImageViewAngleRatio)
            self.mainImageView.addSubview(self.stickerTextView)
            self.mainImageView.addSubview(self.viewPaintDrawing)
            //--
            self.backgroundView.addSubview(self.overlay)





            self.resetToDefaultLayout()
        }
    }
//    func updatingTransform() {
//        cropBoxPanGesture = UIPanGestureRecognizer(target: self, action: #selector(cropBoxPan(_:)))
//        cropBoxPanGesture.delegate = self
//        navigationController?.navigationBar.isHidden = true
//
//        if self.imageOrignal.size.width < 1 || self.imageOrignal.size.height < 1 {
//            return
//        }
//
//        view.backgroundColor = UIColor(red: 45 / 255.0, green: 42 / 255.0, blue: 45 / 255.0, alpha: 1)
//        self.scrollView.addSubview(self.mainImageView)
//
//        if #available(iOS 11.0, *) {
//            self.scrollView.contentInsetAdjustmentBehavior = .never
//        } else {
//            automaticallyAdjustsScrollViewInsets = false
//        }
//
//        self.view.setNeedsDisplay()
//        self.view.layoutIfNeeded()
//        self.scrollViewContainer.scrollView = scrollView
//
//        self.scrollViewContainer.addGestureRecognizer(cropBoxPanGesture)
//        self.scrollView.panGestureRecognizer.require(toFail: cropBoxPanGesture)
//        self.scrollViewContainer.frame = CGRectMake(0, 0, self.transformMainView.frame.size.width, self.transformMainView.frame.size.height)
//        self.backgroundView.frame = CGRectMake(0, 0, self.transformMainView.frame.size.width, self.transformMainView.frame.size.height)
//
////        constraintsBottom
////        constraintsTop
////        constraintsLeading
////        constraintsTrailing
////        constraintsCenterVertical
////        constraintsCenterHorizontal
//
//            // Collect constraints dynamically
////            var constraintsToActivate: [NSLayoutConstraint] = []
////
////            if let topConstraint = constraintsTop { constraintsToActivate.append(topConstraint) }
////            if let bottomConstraint = constraintsBottom { constraintsToActivate.append(bottomConstraint) }
////            if let leadingConstraint = constraintsLeading { constraintsToActivate.append(leadingConstraint) }
////            if let trailingConstraint = constraintsTrailing { constraintsToActivate.append(trailingConstraint) }
////            if let centerVerticalConstraint = constraintsCenterVertical, constraintsTop == nil, constraintsBottom == nil {
////                constraintsToActivate.append(centerVerticalConstraint)
////            }
////            if let centerHorizontalConstraint = constraintsCenterHorizontal, constraintsLeading == nil, constraintsTrailing == nil {
////                constraintsToActivate.append(centerHorizontalConstraint)
////            }
////
////            // Activate constraints
////            NSLayoutConstraint.activate(constraintsToActivate)
//
//            let topConstraint = constraintTop(item: label, item2: scrollView, constant: 20)
//            let bottomConstraint = constraintBottom(item: constraintsBottom, item2: scrollView, constant: -20)
//            let leadingConstraint = constraintLeading(item: constraintsLeading, item2: scrollView, constant: 20)
//            let trailingConstraint = constraintTrailing(item: label, item2: scrollView, constant: -20)
//            let centerXConstraint = constraintCenterX(item: label, item2: scrollView)
//            let centerYConstraint = constraintCenterY(item: label, item2: scrollView)
//
//            NSLayoutConstraint.activate([
//                topConstraint,
//                bottomConstraint,
//                leadingConstraint,
//                trailingConstraint,
//                centerXConstraint,
//                centerYConstraint
//            ])
//
//
//
//        // Update scrollView content size
//        self.scrollView.layoutIfNeeded()
//
//        switch UIDevice.current.type {
//        case .iPhoneSE, .iPhone5, .iPhone5S:
//            angleRuler.frame.origin.x = 30
//            angleRuler.frame.size.width = 147
//        case .iPhone6, .iPhone7, .iPhone8, .iPhone6S, .iPhoneX:
//            angleRuler.frame.origin.x = 30
//            angleRuler.frame.size.width = view.width - 110 - 60
//        default:
//            angleRuler.frame.origin.x = 30
//            angleRuler.frame.size.width = view.width - 110 - 60
//        }
//        self.transformBottomView.addSubview(angleRuler)
//        self.angleView.addSubview(self.transformBottomView)
//
//        switch UIDevice.current.type {
//        case .iPhoneSE, .iPhone5, .iPhone5S, .iPhone6, .iPhone6S:
//            self.constraintsBottomtransform.constant = 0
//        case .iPhone7, .iPhone8, .iPhoneX:
//            self.constraintsBottomtransform.constant = 35
//        default:
//            self.constraintsBottomtransform.constant = 35
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.scrollViewContainer.frame = CGRectMake(0, 0, self.transformMainView.frame.size.width, self.transformMainView.frame.size.height)
//            self.backgroundView.frame = CGRectMake(0, 0, self.transformMainView.frame.size.width, self.transformMainView.frame.size.height)
//            self.scrollViewContainer.addSubview(self.scrollView)
//            self.scrollViewContainer.addSubview(self.framesImageViewAngleRatio)
//            self.mainImageView.addSubview(self.stickerTextView)
//            self.mainImageView.addSubview(self.viewPaintDrawing)
//            self.backgroundView.addSubview(self.overlay)
//            self.resetToDefaultLayout()
//        }
//    }

    func constraintLeading(item: UILabel, item2: UIScrollView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: .leading, relatedBy: .equal, toItem: item2, attribute: .leading, multiplier: 1, constant: constant)
    }

    func constraintTrailing(item: UIView, item2: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: .trailing, relatedBy: .equal, toItem: item2, attribute: .trailing, multiplier: 1, constant: constant)
    }

    func constraintCenterX(item: UIView, item2: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: .centerX, relatedBy: .equal, toItem: item2, attribute: .centerX, multiplier: 1, constant: constant)
    }

    func constraintCenterY(item: UIView, item2: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: .centerY, relatedBy: .equal, toItem: item2, attribute: .centerY, multiplier: 1, constant: constant)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainImageScaledSizeForText = scrollView.bounds.size
        if self.option.isTransformActual == false {
            isCropBoxPanEnabled = false
            manualZoomed = false
            overlay.cropBoxAlpha = 0
        } else {
            isCropBoxPanEnabled = true
            manualZoomed = false
            overlay.cropBoxAlpha = 1
        }
    }

    func resetToDefaultLayout(isResetClick : Bool = false, isSetPaperLength : Bool = false) {
        aspectRatioPicker.frame = angleRuler.frame

        cropRegionInsets = UIEdgeInsets(top: cropContentInset.top,
                                        left: cropContentInset.left,
                                        bottom: cropContentInset.bottom,
                                        right: cropContentInset.right)

        maxCropRegion = CGRect(x: cropRegionInsets.left,
                               y: cropRegionInsets.top,
                               width: self.backgroundView.bounds.width - cropRegionInsets.left - cropRegionInsets.right,
                               height: self.backgroundView.bounds.height - cropRegionInsets.top - cropRegionInsets.bottom)
        defaultCropBoxCenter = CGPoint(x: self.backgroundView.width / 2.0, y: cropRegionInsets.top + maxCropRegion.size.height / 2.0)
        defaultCropBoxSize = {
            var size: CGSize
            let scaleW = self.imageOrignal.size.width / self.maxCropRegion.size.width
            let scaleH = self.imageOrignal.size.height / self.maxCropRegion.size.height
            let scale = max(scaleW, scaleH)
            size = CGSize(width: self.imageOrignal.size.width / scale, height: self.imageOrignal.size.height / scale)
            return size
        }()

        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 20
        self.scrollView.zoomScale = 1
        self.scrollView.transform = .identity
        self.scrollView.bounds = CGRect(x: 0, y: 0, width: defaultCropBoxSize.width, height: defaultCropBoxSize.height)
        self.scrollView.contentSize = defaultCropBoxSize
        self.scrollView.contentOffset = .zero
        self.scrollView.center = self.transformMainView.convert(defaultCropBoxCenter, to: scrollViewContainer)
        self.mainImageView.transform = .identity
        self.mainImageView.frame = scrollView.bounds
        self.mainImageView.isUserInteractionEnabled = true
        self.mainImageView.clipsToBounds = true
        self.scrollView.clipsToBounds = true
        self.scrollViewContainer.clipsToBounds = true

        mainImageScaledSizeForText = overlay.cropBox.bounds.size


        overlay.frame = backgroundView.bounds
        overlay.cropBoxFrame = CGRect(center: defaultCropBoxCenter, size: defaultCropBoxSize)
        overlay.blur = true
        overlay.gridLinesAlpha = 0
        overlay.cropBoxAlpha = 0

        let newRect = CGRect(x: 0, y: 0, width: overlay.cropBox.bounds.width, height: overlay.cropBox.bounds.height)
        self.framesImageViewAngleRatio.frame = newRect//scrollView.frame//overlay.cropBox.bounds
        self.framesImageViewAngleRatio.center = scrollViewContainer.center
        if isResetClick == false {

            self.stickerTextView.transform = .identity
            self.stickerTextView.frame = newRect
            self.stickerTextView.center = mainImageView.center

            self.viewPaintDrawing.transform = .identity
            self.viewPaintDrawing.frame = newRect
            self.viewPaintDrawing.center = mainImageView.center
            self.viewPaintDrawing.setPaint()

            self.framesImageView.transform = .identity
            self.framesImageView.frame = newRect
            self.framesImageView.center = mainImageView.center

        }
        if self.isFlippedSelected && self.isMirroredSelected {
            self.scrollViewContainer.transform = CGAffineTransform(scaleX: -1, y: -1)
        } else if self.isFlippedSelected {
            self.scrollViewContainer.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else if self.isMirroredSelected {
            self.scrollViewContainer.transform = CGAffineTransform(scaleX: 1, y: -1)
        } else {
            self.scrollViewContainer.transform = .identity
        }

        straightenAngle = 0
        rotationAngle = 0
        flipAngle = 0
        aspectRatioLocked = false
        currentAspectRatioValue = 1
        let image = mainImageView.image
        mainImageView.image = image?.withOrientation(fliped ? .up : .up)
        if isCircular ?? false {
            isCropBoxPanEnabled = false
            overlay.isCircular = true
            aspectRatioPicker.isHidden = true
            angleRuler.isHidden = true
            cropBoxFrame = CGRect(center: defaultCropBoxCenter, size: CGSize(width: maxCropRegion.size.width, height: maxCropRegion.size.width))
            matchScrollViewAndCropView()
        } else {
            if imageOrignal.size.width / imageOrignal.size.height < cropBoxMinSize / maxCropRegion.size.height { // very long
                cropBoxFrame = CGRect(x: (transformMainView.width - cropBoxMinSize) / 2, y: cropRegionInsets.top, width: cropBoxMinSize, height: maxCropRegion.size.height)
                matchScrollViewAndCropView()
            } else if imageOrignal.size.height / imageOrignal.size.width < cropBoxMinSize / maxCropRegion.size.width { // very wide
                cropBoxFrame = CGRect(x: cropRegionInsets.left, y: cropRegionInsets.top + (maxCropRegion.size.height - cropBoxMinSize) / 2, width: maxCropRegion.size.width, height: cropBoxMinSize)
                matchScrollViewAndCropView()
            }
        }

        defaultCropperState = saveState()
        if isResetClick == false {
            initialState = saveState()
        }

        angleRuler.value = 0.0
        updateAspectRatio()
        updateButtons()
        //anu comment to uncomment this task in sprint 6
//        let topConstraint = self.constraintTop(item: self.topAlignMargin, item2: self.scrollView, constant: 8)
//        let bottomConstraint = self.constraintBottom(item: self.bottomAlignMargin, item2: self.scrollView, constant: -8)
//        let leadingConstraint = self.constraintLeading(item: self.leftAlignMargin, item2: self.scrollView, constant: 8)
//        let trailingConstraint = self.constraintTrailing(item: self.rightAlignMargin, item2: self.scrollView, constant: -8)
//        let centerXConstraint = self.constraintCenterX(item: self.centerVerticalMargin, item2: self.scrollView, constant: 0)
//        let centerYConstraint = self.constraintCenterY(item: self.centerHorizontalMargin, item2: self.scrollView, constant: 0)
//        NSLayoutConstraint.activate([topConstraint,
//                                   leadingConstraint,
//                                     bottomConstraint,
//                                   trailingConstraint,
//                                   centerXConstraint,
//                                   centerYConstraint])

    }

    @IBAction func actionMirrorTransform(_ sender: UIButton) {
        self.mirrorButtonPressed(sender)
    }

    @IBAction func actionFlipTransform(_ sender: UIButton) {
        self.flipButtonPressed(sender)
    }

    @objc
    func flipButtonPressed(_: UIButton) {
        if !isMirrored && isFlipped {
            self.scrollViewContainer.transform = CGAffineTransform(scaleX: -1, y: -1)
            isMirrored = true
        } else if !isMirrored {
            self.scrollViewContainer.transform = CGAffineTransform(scaleX: 1, y: -1)
            isMirrored = true
        } else {
            if isFlipped {
                self.scrollViewContainer.transform = CGAffineTransform(scaleX: -1, y: 1)
            } else {
                self.scrollViewContainer.transform = CGAffineTransformIdentity
            }
            isMirrored = false
        }
    }

    @objc
    func rotateButtonPressed(_: UIButton) {
        rotate90degrees()
    }

    @objc
    func mirrorButtonPressed(_ sender: UIButton) {
        if !isFlipped && isMirrored {
            self.scrollViewContainer.transform = CGAffineTransform(scaleX: -1, y: -1)
            isFlipped = true
        } else if !isFlipped {
            self.scrollViewContainer.transform = CGAffineTransform(scaleX: -1, y: 1)
            isFlipped = true
        } else {
            if isMirrored {
                self.scrollViewContainer.transform = CGAffineTransform(scaleX: 1, y: -1)
            } else {
                self.scrollViewContainer.transform = CGAffineTransformIdentity
            }
            isFlipped = false
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

    func photoTranslation() -> CGPoint {
        let rect = mainImageView.convert(mainImageView.bounds, to: self.transformMainView)
        let point = CGPoint(x: rect.origin.x + rect.size.width / 2, y: rect.origin.y + rect.size.height / 2)
        let zeroPoint = CGPoint(x: transformMainView.frame.width / 2, y: defaultCropBoxCenter.y)

        return CGPoint(x: point.x - zeroPoint.x, y: point.y - zeroPoint.y)
    }

    @IBAction func actionAspectRatioLandscape(_ sender: UIButton) {
        self.framesImageView.isHidden = true
        self.framesImageViewAngleRatio.isHidden = false
        self.isLandscape = true
        self.verticalView.layer.borderWidth     = 0
        self.horizontalView.layer.borderWidth   = 2
        self.resetView.layer.borderWidth        = 0
        self.setPaperView.layer.borderWidth     = 0
        self.aspectRatioPickerDidSelectedAspectRatio(.ratio(width: selectedRation, height: 2))
        self.updatingLayerFrames(contentOffset: self.scrollView.contentOffset)
        if self.framesImageViewAngleRatio.image != nil {
            if let frame = selectedFrame as? String {
                toResetFrames(frame: frame)
            }
        }
    }

    @IBAction func actionAspectRatioPotrait(_ sender: UIButton) {
        self.framesImageView.isHidden = true
        self.framesImageViewAngleRatio.isHidden = false
        self.isLandscape = false
        self.verticalView.layer.borderWidth = 2
        self.horizontalView.layer.borderWidth = 0
        self.resetView.layer.borderWidth = 0
        self.setPaperView.layer.borderWidth = 0
        self.aspectRatioPickerDidSelectedAspectRatio(.ratio(width: 2, height: selectedRation))
        self.updatingLayerFrames(contentOffset: self.scrollView.contentOffset)
        if self.framesImageViewAngleRatio.image != nil {
            if let frame = selectedFrame as? String {
                toResetFrames(frame: frame)
            }
        }
    }

    @IBAction func actionBlankCanvas(_ sender: UIButton) {
        self.verticalView.layer.borderWidth = 0
        self.horizontalView.layer.borderWidth = 0
        self.resetView.layer.borderWidth = 0
        self.setPaperView.layer.borderWidth = 2
        self.rationButtonPressed(sender)
    }

    @IBAction func actionRotate(_ sender: UIButton) {
        self.framesImageView.isHidden = true
        self.framesImageViewAngleRatio.isHidden = false
        self.isRotationImage = true
        self.rotateButtonPressed(sender)
        self.updatingLayerFrames(contentOffset: self.scrollView.contentOffset)
    }

    @IBAction func actionReset(_ sender: UIButton) {
        self.framesImageViewAngleRatio.transform = .identity

        self.isRotationImage = false
        self.framesImageView.isHidden = true
        self.framesImageViewAngleRatio.isHidden = false
        self.selectedRatioWith = self.orignalSelectedRatioWith ?? 0
        self.mainImageScaledSizeForText = overlay.cropBox.bounds.size
        self.verticalView.layer.borderWidth = 0
        self.horizontalView.layer.borderWidth = 0
        self.resetView.layer.borderWidth = 2
        self.setPaperView.layer.borderWidth = 0
        self.resetButtonPressed(sender)
        let imageHeigth = self.overlay.cropBox.size.height
        let imageWidth = self.overlay.cropBox.size.width
        var selectedRation = 0.0
        if imageHeigth > imageWidth {
            //-- Portrait
            isLandscape = false
            self.verticalView.layer.borderWidth = 2
            self.horizontalView.layer.borderWidth = 0
            self.resetView.layer.borderWidth = 0
            self.setPaperView.layer.borderWidth = 0
            selectedRation = round(((imageHeigth/imageWidth) * 2) * 10) / 10.0
        } else {
            //-- landscape
            isLandscape = true
            self.verticalView.layer.borderWidth     = 0
            self.horizontalView.layer.borderWidth   = 2
            self.resetView.layer.borderWidth        = 0
            self.setPaperView.layer.borderWidth     = 0
            selectedRation = round(((imageWidth/imageHeigth) * 2) * 10) / 10.0
        }

        if imageHeigth > imageWidth {
            self.aspectRatioPickerDidSelectedAspectRatio(.ratio(width: 2, height: selectedRation))
        } else {
            self.aspectRatioPickerDidSelectedAspectRatio(.ratio(width: selectedRation, height: 2))
        }
        
        if self.framesImageViewAngleRatio.image != nil {
            if let frame = selectedFrame as? String {
                self.toResetFrames(frame: frame)
            }
        }
        isFlipped = false
        isMirrored = false
        self.scrollViewContainer.transform = CGAffineTransformIdentity

    }

    @IBAction func actionAngle(_ sender: UIButton) {
        self.cancelButton.isHidden = true
        self.cancelImageView.isHidden = true
        self.resetButton.isHidden = true
        self.view.bringSubviewToFront(self.angleView)
        self.angleView.isHidden = !self.angleView.isHidden
    }

    @objc
    func rationButtonPressed(_ sender: UIButton) {
        let rulerViewController = CustomRulerCanvasViewController(nibName: CustomRulerCanvasViewController.className, bundle: nil)
        rulerViewController.image = self.imageOrignalBackUp
        rulerViewController.sliderCanvasImageValue = self.selectedRatioWith
        rulerViewController.isBlankCanvasRuler = false
        rulerViewController.isFromPaperLength = false
        rulerViewController.rulerCanvasDelegate = self
        if self.paperLengthImageMovement == nil && self.paperLengthImageRotation == nil {
            rulerViewController.paperLengthImageMovement = self.mainImageView.transform
            rulerViewController.paperLengthImageRotation = self.mainImageView.transform
            rulerViewController.isImageAlreadyEdited = true
        } else {
            rulerViewController.paperLengthImageMovement = self.paperLengthImageMovement
            rulerViewController.paperLengthImageRotation = self.paperLengthImageRotation
            rulerViewController.isImageAlreadyEdited = self.isImageAlreadyEdited
        }
        rulerViewController.scrollViewZoomScale = self.scrollViewZoomScale
        rulerViewController.scrollviewPaperLengthFrame = self.scrollviewPaperLengthFrame
        rulerViewController.isFillImage = true
        rulerViewController.isLandscape = isLandscape
        rulerViewController.previousImageViewTransform = self.previousImageViewTransform
        self.navigationController?.pushViewController(rulerViewController, animated: true)
    }

    @objc
    func resetButtonPressed(_: UIButton) {
        overlay.blur = false
        overlay.gridLinesAlpha = 0
        overlay.cropBoxAlpha = 0
        bottomView.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.25, animations: {
            self.resetToDefaultLayout(isResetClick: true)
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, animations: {
                self.overlay.cropBoxAlpha = 1
                self.overlay.blur = true
            }, completion: { _ in
                self.bottomView.isUserInteractionEnabled = true
            })
        })
    }


    func updateAspectRatio() {
        if Double(self.selectedRatioWith).rounded(toPlaces: 1) != 2.0 {
            self.innerSquarePortraitView.isHidden = true
            self.innerPortraitView.isHidden = false
            self.horizontalView.showView()
        } else {
            self.innerSquarePortraitView.isHidden = false
            self.innerPortraitView.isHidden = true
            self.horizontalView.hideView()
        }
        self.labelPotrait?.text = "2:\(Double(self.selectedRatioWith ).rounded(toPlaces: 1))"
        self.labelLandscape?.text = "\(Double(self.selectedRatioWith ).rounded(toPlaces: 1)):2"
    }

    func updateAspectRatioSelection(isLandscape: Bool) {
        if isLandscape == true {
            self.verticalView.layer.borderWidth     = 0
            self.horizontalView.layer.borderWidth   = 2
            self.resetView.layer.borderWidth        = 0
            self.setPaperView.layer.borderWidth     = 0
        } else {
            self.verticalView.layer.borderWidth     = 2
            self.horizontalView.layer.borderWidth   = 0
            self.resetView.layer.borderWidth        = 0
            self.setPaperView.layer.borderWidth     = 0
        }
    }

    func updatingLayerFrames(contentOffset: CGPoint){
        self.mainImageScaledSizeForText = overlay.cropBox.bounds.size
        let newRect = CGRect(x: 0, y: 0, width: overlay.cropBox.bounds.width, height: overlay.cropBox.bounds.height)
        _ = CGRect(x: 0, y: 0, width: self.scrollView.bounds.width, height: self.scrollView.bounds.height)

        self.framesImageViewAngleRatio.frame = newRect
        self.framesImageViewAngleRatio.center = scrollViewContainer.center

        let imageHeigth = self.overlay.cropBox.size.height
        let imageWidth = self.overlay.cropBox.size.width

        if imageHeigth > imageWidth {
            //-- Portrait
            isLandscape = false
            self.verticalView.layer.borderWidth = 2
            self.horizontalView.layer.borderWidth = 0
            self.resetView.layer.borderWidth = 0
            self.setPaperView.layer.borderWidth = 0
            //self.selectedRatioWith = round(((imageHeigth/imageWidth) * 2) * 10) / 10.0
        } else {
            //-- landscape
            isLandscape = true
            self.verticalView.layer.borderWidth     = 0
            self.horizontalView.layer.borderWidth   = 2
            self.resetView.layer.borderWidth        = 0
            self.setPaperView.layer.borderWidth     = 0
            //self.selectedRatioWith = round(((imageWidth/imageHeigth) * 2) * 10) / 10.0
        }
        
        if self.framesImageViewAngleRatio.image != nil {
            if let frame = selectedFrame as? String {
                //toResetFrames(frame: frame)
            }
        }
    }
}


extension CAEditViewController: UniqueActivity, CropBoxEdgeDraggable, AngleAssist {}
extension CAEditViewController: Rotatable, StateRestorable, Flipable, AspectRatioSettable {}
