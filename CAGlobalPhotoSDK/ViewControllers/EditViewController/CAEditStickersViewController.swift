//
//  CAEditStickersViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/05/23.
//

import UIKit
import CoreData

class CAEditStickersViewController: CAEditViewController {
    
}

extension CAEditViewController: StickerOptionsDelegate, AddStickerViewDelegate, StickersViewDelegate, PGCustomStickerDelegate {
    func colorPickerSticker() {
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()
    }
    
    
    func setFurtherColorSticker(color: UIColor, opacity: CGFloat) {
        let colorPickerViewController = AMColorPickerViewController()
        colorPickerViewController.selectedColor = color
        colorPickerViewController.selectedOpacity = opacity
        
        colorPickerViewController.delegate = self
        colorPickerViewController.modalPresentationStyle = .fullScreen
        present(colorPickerViewController, animated: true, completion: nil)
    }
    
    func selectColorAndSticker(_: StickerOptions, textModel: ColorModel) {
        
        self.stickersText(text: .setColor, color: textModel, index: 101, isText: false)
        
    }
    
    func removeStickerHandles() {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let addSticker = subview as? AddSticker {
                    addSticker.handles.forEach { $0.isHidden = true }
                }
            }
        }
    }
    
    func removeBackgroundFromImage() {
        //  if !(stickerEditor.undoStack.isEmpty) {
        let remover = BackgroundRemover()
        // Perform background removal
        var selectedImage = getImageFromSelectedSticker()
        let orientation = selectedImage?.imageOrientation
        let ciimage = selectedImage?.cgImage!
        switch orientation {
        case .up:
            selectedImage = UIImage(cgImage: ciimage!, scale: 1.0, orientation: .up)
        case .upMirrored:
            selectedImage = UIImage(cgImage: ciimage!, scale: 1.0, orientation: .upMirrored)
        case .down, .left, .right, .downMirrored, .leftMirrored, .rightMirrored:
            //            selectedImage = self.fixOrientation(img: getImageFromSelectedSticker()!)
            break;
        case .none:
            break;
        @unknown default:
            break
        }
        
        remover.removeBackground(from: selectedImage!) { [weak self] resultImage in
            guard let self = self else { return }
            if let resultImage = resultImage {
                DispatchQueue.main.async {
                    self.removeBackgroundImage(oldImage: self.getImageFromSelectedSticker()!, oldImageTintColor: self.getColorFromSelectedSticker(), image: resultImage, stickerSelection: "image", isBackground: true)
                    self.stickersText(text: .replace, isText: false)
                }
            } else {
                print("Background removal failed.")
            }
        }
    }
    
    func unremoveBackgroundFromImage() {
        if let oldImage = getImageFromSelectedSticker(),
           let originalImage = getOrignalImageFromSelectedSticker() {
            let oldImageTintColor = getColorFromSelectedSticker()
            self.removeBackgroundImage(oldImage: oldImage, oldImageTintColor: oldImageTintColor, image: originalImage, stickerSelection: "image", isBackground: false)
            self.stickersText(text: .replace, isText: false)
        } else {
            print("Failed to retrieve images. One of them is nil.")
        }
    }
    
    func removePickColorForColor() {
        self.constraintsBottomViewHeight.constant = 80
    }
    
    func pickColorFromStickers(callBack: (ColorModel) -> Void?) {
        self.removeGesturesMainImageViewForMagnify()
        /**
         UIPanGestureRecognizer - Pan Objects
         */
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanColorPickerMagnify(_:)))
        pan.delegate = self
        self.stickerTextView.addGestureRecognizer(pan)
        
        magnifyingGlass.magnifiedView = self.mainImageView
        magnifyingGlass.magnify(at: self.mainImageView.center)
        
        let color = self.scrollViewContainer.getPixelColorAt(point: self.overlay.center)
        
        let colorModel = ColorModel()
        colorModel.selectedColorIndex = 100
        colorModel.isColor = true
        colorModel.color = color
        
        self.selectedStickerColor = color
        
        self.stickersText(text: .setColor, color: colorModel,index: 100, isText: false)
        callBack(colorModel)
    }
    
    // MARK: - Stickers Option -
    
    func opacityWillStart(_ textView: StickerOptions, isOpen: Bool) {
        if isOpen {
            self.constraintsBottomViewHeight.constant = 80 + 40
        } else {
            self.constraintsBottomViewHeight.constant = 80
        }
    }
    
    func setUpStickerOptionView(stickerSelection: String, isFromGallery:Bool?=false,isImageDepth:Bool?=false,isBackgroundRemoved:Bool?=false) {
        self.removeBottomSubViews()
        stickerOption.delegate = self
        stickerOption.setUpData(views: self.stickerTextView.subviews, stickerSelection: stickerSelection,isFromGallery:isFromGallery,isImageDepth:isImageDepth, isBackgroundRemoved: isBackgroundRemoved )
        self.bottomView.addSubview(stickerOption)
        self.bottomView.isHidden = false
        self.setupAutoLayoutForBottomView(newView: stickerOption, bottomView: self.bottomView)
    }
    
    
    func setUpStickerView(isEdit : Bool = false) {
        self.stickerView.configureCustomStickerArray()
        self.stickerTextView.isUserInteractionEnabled = true
        self.option.isSticker = false
        self.bottomView.isHidden = false
        self.doneButton.isHidden = false
        self.stickerView.delegate = self
        self.stickerView.isEdit = isEdit
        self.isReplacingSticker = isEdit
        if isEdit == true {
            self.stickerView.oldImage = self.getImageFromSelectedSticker()!
            self.stickerView.oldImageTintColor = self.getColorFromSelectedSticker()
        }
        self.stickerBaseView.addSubview( self.stickerView)
        self.stickerVisualEffectView.isHidden = false
        self.setupAutoLayoutForBottomView(newView: self.stickerView, bottomView: self.stickerBaseView)
        
        self.stickerView.stickerCollectionView.reloadData()
        self.stickerView.subStickerCollectionView.reloadData()
        //showNotEnoughSpaceMessage()
    }
    
    
    // Adding new sticker on view
    /// Adds a new sticker to the view with the specified image and properties.
    /// - Parameters:
    ///   - image: The image to be used for the sticker.
    ///   - stickerSelection: The type of sticker being added (e.g., "shapes").
    ///   - stickerUrl: The URL of the sticker (if applicable).
    ///   - isImageDepth: A flag indicating whether the image has depth information.
    func selectedStickerImage(image: UIImage, stickerSelection: String, stickerUrl: String, isImageDepth: Bool? = false) {
        
        // Reset the flip angle for the sticker
        self.flipAngleSticker = ""
        
        // Calculate the center position for the sticker within the visible area of the scroll view
        let visibleRect = scrollView.convert(scrollView.bounds, to: self.stickerTextView)
        let centerX = visibleRect.midX
        let centerY = visibleRect.midY
        let stickerCenter = CGPoint(x: centerX - 75, y: centerY - 75)
        
        // Define the initial frame and transformation for the sticker
        let frame = CGRect(origin: stickerCenter, size: CGSize(width: 150, height: 150))
        let transform = CGAffineTransform(rotationAngle: self.rotation(from: view.transform))
        var isSticker: Bool = true
        
        // Determine if the action is for a sticker or a gallery item
        switch self.filterSelection {
        case .sticker:
            isSticker = true
        case .gallery:
            isSticker = false
        default:
            break
        }
        
        var color = UIColor(named: .white, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)
        
        // Set color based on selection
        
        // Adjust the color based on the sticker selection
        if customStickerArray.count > 0 {
            if stickerSelection == "shapes" {
                color = UIColor(named: .stickerColor, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!
            }
        } else {
            if stickerSelection == "shapes" {
                color = UIColor(named: .stickerColor, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!
            }
        }
        
        // Handle the sticker URL if provided (currently no implementation)
        if stickerUrl.count > 0 {
            // Placeholder for handling sticker URL
        }
        
        // Prepare the image for the sticker, applying flip and mirror transformations if needed
        let frameImage = image
        var newImage = frameImage
        
        if isFlippedSelected && isMirroredSelected {
            newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .down)
        } else if isFlippedSelected {
            newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .upMirrored)
        } else if isMirroredSelected {
            newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .downMirrored)
        }
        
        // Add the sticker to the view using the sticker manager
        let view = stickerManager.addSticker(
            delegate: self,
            frame: frame,
            image: newImage,
            isTransform: false,
            transform: transform,
            tag: stickerTempTags,
            sticker: stickerSelection,
            isSticker: isSticker,
            color: color!
        )
        view.isDepthImage = isImageDepth ?? false
        view.isBackgroundRemoved = false
        view.orignalImage = newImage
        
        // Apply additional transformations and properties to the sticker
        //view.transform = CGAffineTransform(rotationAngle: -totalAngle)
        view.flipAngleSticker = "up"
        
        // Add the sticker to the sticker text view
        self.stickerTextView.addSubview(view)
        self.stickerTextView.isUserInteractionEnabled = true
        self.stickerVisualEffectView.isHidden = true
        
        // Update UI and state for the newly added sticker
        self.stickersText(text: .showDeleteButton, isText: false)
        self.setUpStickerOptionView(
            stickerSelection: stickerSelection,
            isFromGallery: !isSticker,
            isImageDepth: isImageDepth,
            isBackgroundRemoved: false
        )
        self.saveCrossView.showView()
        self.doneButton.isHidden = false
        self.mainCollectionView.isHidden = true
        self.arrayTransformRotationValues.append(0.0)
        stickerScale = 1.0
        
        //        // Register undo
        //        undoRedoManager.registerUndo(withTarget: self) { target in
        //            target.removeStickerFromCanvas(
        //                sticker: view,
        //                transform: view.transform,
        //                frame: view.frame,
        //                orntn: target.flipAngleSticker,
        //                isSticker: true,
        //                color: view.tintColor,
        //                image: view.image,
        //                stickerName: stickerSelection,
        //                straightenAngle: 0,
        //                rotationAngle: 0,
        //                alpha: 1.0,
        //                flipAngle: 0
        //            )
        //        }
        //        undoRedoManager.setActionName("Add Sticker")
        isEnableRedoUndo()
    }
    
    func removeStickerFromCanvas(sticker: AddSticker?,
                                 transform: CGAffineTransform,
                                 frame: CGRect?,
                                 orntn: String?,
                                 isSticker: Bool?,
                                 color: UIColor?,
                                 image: UIImage?,
                                 stickerName: String?,
                                 straightenAngle: CGFloat?,
                                 rotationAngle: CGFloat?,
                                 alpha: CGFloat?,
                                 flipAngle: CGFloat?) {
        
        guard let stickerView = sticker else { return }
        
        // Register redo (re-adding it back)
        undoRedoManager.registerUndo(withTarget: self) { target in
            target.selectedStickerImage(image: image!, stickerSelection: stickerName ?? "", stickerUrl: "", isImageDepth: sticker?.isDepthImage)
        }
        undoRedoManager.setActionName("Remove Sticker")
        
        // Remove from superview and detail array
        isEnableRedoUndo()
        self.stickersText(text: .hideDeleteButton, isText: false)
        self.globalUndoRedo(currentFilterSelection: .none)
        self.removeBottomSubViews()
        self.hideCrossTickOnly()
        stickerView.removeFromSuperview()
    }
    
    
    // Editing existing sticker by pressing replace button
    func removeBackgroundImage(oldImage: UIImage, oldImageTintColor: UIColor, image: UIImage, stickerSelection: String, isBackground: Bool) {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let addSticker = subview as? AddSticker {
                    if addSticker.isSelected {
                        
                        // Save the current state for undo
                        let previousImage = addSticker.image
                        let previousBackgroundRemovedImage = addSticker.backgroundRemovedImage
                        let previousSelection = addSticker.stickerSelection
                        let previousBackgroundState = addSticker.isBackgroundRemoved
                        
                        // Register undo action
                        undoRedoManager.registerUndo(withTarget: self) { target in
                            target.removeBackgroundImage(
                                oldImage: previousImage ?? UIImage(),
                                oldImageTintColor: oldImageTintColor,
                                image: previousImage ?? UIImage(),
                                stickerSelection: previousSelection,
                                isBackground: previousBackgroundState
                            )
                        }
                        undoRedoManager.setActionName("Undo Background Removal")
                        isEnableRedoUndo()
                        addSticker.image = image
                        addSticker.backgroundRemovedImage = image
                        addSticker.stickerSelection = stickerSelection
                        addSticker.isBackgroundRemoved = isBackground
                    }
                }
            }
        }
        self.stickerVisualEffectView.isHidden = true
        self.stickersText(text: .edit, isText: false)
        self.setUpStickerOptionView(stickerSelection: stickerSelection, isFromGallery: true, isImageDepth: true, isBackgroundRemoved: isBackground)
        self.saveCrossView.showView()
        self.doneButton.isHidden = false
        stickerScale = 1.0
    }
    
    
    //Editing existing sticker by pressing replace button
    func editStickerImage(oldImage: UIImage, orignaloldImage: UIImage, oldImageTintColor: UIColor, image: UIImage, orignalImage: UIImage, stickerSelection: String, pStickerSelection: String, isImageDepth:Bool?=false,isBackgroundRemoved:Bool?=false,isGallery:Bool?=false) {
        var isImageDepthFinal = isImageDepth ?? false
        let frameImage = image
        var newImage = frameImage
        let remover = BackgroundRemover()
        var currentStickerSelection = stickerSelection
        remover.hasForeground(in: orignalImage) { [weak self] hasForeground in
            guard let self = self else { return }
            isImageDepthFinal = hasForeground
            DispatchQueue.main.async {
                self.isEditAddPhoto = false
                
                let subViews = self.stickerTextView.subviews
                for subview in subViews {
                    if subview is AddSticker {
                        if let addSticker = subview as? AddSticker {
                            if addSticker.isSelected {
                                if self.isFlippedSelected && self.isMirroredSelected {
                                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .down)
                                } else if self.isFlippedSelected {
                                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .upMirrored)
                                } else if self.isMirroredSelected {
                                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .downMirrored)
                                }
                                
                                addSticker.image = newImage
                                addSticker.isBackgroundRemoved = isBackgroundRemoved ?? false
                                addSticker.isDepthImage = isImageDepthFinal
                                
                                if isImageDepthFinal == true {
                                    if isBackgroundRemoved == true {
                                        let remover = BackgroundRemover()
                                        // Perform background removal
                                        remover.removeBackground(from: self.getImageFromSelectedSticker()!) { [weak self] resultImage in
                                            guard self != nil else { return }
                                            if let resultImage = resultImage {
                                                DispatchQueue.main.async {
                                                    let frameImage = resultImage
                                                    let newImage = frameImage
                                                    addSticker.image = newImage
                                                }
                                            } else {
                                                print("Background removal failed.")
                                            }
                                        }
                                    }
                                } else {
                                    addSticker.isBackgroundRemoved = false
                                }
                                addSticker.orignalImage = orignalImage
                                addSticker.transform = CGAffineTransform(rotationAngle: -self.totalAngle)
                                addSticker.image = self.fixOrientation(img: newImage)
                                addSticker.orignalImage = self.fixOrientation(img: orignalImage)
                                addSticker.transform = CGAffineTransform(rotationAngle: -self.totalAngle)
                                addSticker.image = self.fixOrientation(img: newImage)
                                addSticker.stickerSelection = stickerSelection
                                self.changeTags(addSticker: addSticker, oldImageTintColor: oldImageTintColor)
                            }
                        }
                    }
                }
                
                self.stickerVisualEffectView.isHidden = true
                self.stickersText(text: .edit, isText: false)
                self.setUpStickerOptionView(stickerSelection: stickerSelection, isFromGallery: isGallery, isImageDepth:isImageDepthFinal, isBackgroundRemoved: isBackgroundRemoved)
                self.saveCrossView.showView()
                self.doneButton.isHidden = false
                self.stickerScale = 1.0
                self.isEnableRedoUndo()
            }
        }
        
        // --- Register undo ---
        self.undoRedoManager.registerUndo(withTarget: self) { target in
            target.editStickerImage(
                oldImage: newImage, orignaloldImage: orignalImage,
                oldImageTintColor: oldImageTintColor,
                image: oldImage, orignalImage: orignaloldImage,
                stickerSelection: currentStickerSelection, pStickerSelection: stickerSelection,
                isImageDepth: isImageDepthFinal,
                isBackgroundRemoved: isBackgroundRemoved,
                isGallery: isGallery
            )
        }
    }
    
    func applyStickerState(_ state: StickerEditState) {
        let sticker = state.stickerRef
        sticker.image = state.image
        sticker.orignalImage = state.image
        sticker.transform = state.transform
        sticker.isBackgroundRemoved = state.isBackgroundRemoved
        sticker.stickerSelection = state.stickerSelection
        changeTags(addSticker: sticker, oldImageTintColor: state.tintColor)
    }
    
    
    func changeTags(addSticker: AddSticker, oldImageTintColor: UIColor) {
        if addSticker.stickerSelection == "shapes" || addSticker.stickerSelection == "badges"  || addSticker.stickerSelection == "arrow" || addSticker.stickerSelection == "spray" {
            addSticker.image = addSticker.image?.withRenderingMode(.alwaysTemplate)
            addSticker.tintColor = oldImageTintColor
            if oldImageTintColor.isWhite() {
                if addSticker.stickerSelection == "shapes" {
                    let color = UIColor(named: .stickerColor, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!
                    addSticker.tintColor = color
                }
            }
            if oldImageTintColor == UIColor(named: .stickerColor, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)! {
                if addSticker.stickerSelection == "badges"  || addSticker.stickerSelection == "arrow" || addSticker.stickerSelection == "spray" {
                    addSticker.image = addSticker.image?.withRenderingMode(.alwaysTemplate)
                    let color = UIColor(named: .white, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!
                    addSticker.tintColor = color
                }
            }
        }
        
        if addSticker.tag == stickerTempTags {
            addSticker.tag = stickerTempEditTags
        }
        if addSticker.tag == stickerSavedTags {
            addSticker.tag = stickerEditTags
        }
    }
    
    // Tapping on stickers converting into selected state
    func addRemoveButtonFromSticker(sticker: AddSticker, tag: Int, stickerSelection: String) {
        self.selectedAddTextView?.handles.forEach { $0.isHidden = true }
        self.selectedAddSticker?.handles.forEach { $0.isHidden = true }
        self.selectedAddTextView = nil
        if self.magnifyingGlass.magnifiedView == nil, self.option.isFramesSelected == false, self.filterSelection != .adjust, self.filterSelection != .filter {
            self.mainCollectionView.isHidden = true
            self.stickersText(text: .showDeleteButtonOnTap, isText: false)
            self.stickersText(text: .onTop, isText: false)
            if isSticker() {
                self.setUpStickerOptionView(stickerSelection: stickerSelection, isFromGallery: false)
            } else {
                self.setUpStickerOptionView(stickerSelection: stickerSelection, isFromGallery: true, isImageDepth: self.isDepthImage(), isBackgroundRemoved: self.isBackgroundRemoved())
            }
            // enableDisableUIControl()
            self.isShownRedoUndo()
            self.stickersText(text: .hideSelection, isText: true) // Hiding Text Selection in sticker editor
            self.selectedAddSticker?.handles.forEach { $0.isHidden = false }
            self.resetDoubleStickerSelected()
            if self.filterSelection == FilterSelection.none ||  self.filterSelection == FilterSelection.text {
                
                // self.selectedAddTextView = nil
                self.stickersText(text: .hideSelection, isText: true) // Hiding Text Selection in sticker editor
                if isSticker() {
                    self.filterSelection = FilterSelection(rawValue: 4)
                } else {
                    self.filterSelection = FilterSelection(rawValue: 7)
                }
                self.addRemoveButtonOnSticker()
                self.mainCollectionView.reloadData()
            }
            
            // Show the overlay when a sticker is tapped
            // toggleOverlay(for: sticker, shouldShow: true)
            // self.selectedAddSticker?.handles.forEach { $0.isHidden = false }
            // selectedAddSticker = nil
        }
    }
    
    func getImageFromSelectedSticker() -> UIImage? {
        
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let addSticker = subview as? AddSticker {
                    if addSticker.isSelected {
                        return addSticker.image ?? UIImage()
                    }
                }
            }
        }
        return nil
    }
    
    
    func getOrignalImageFromSelectedSticker() -> UIImage? {
        
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let addSticker = subview as? AddSticker {
                    if addSticker.isSelected {
                        return addSticker.orignalImage ?? UIImage()
                    }
                }
            }
        }
        return nil
    }
    
    func isSticker() -> Bool {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let addSticker = subview as? AddSticker {
                    if addSticker.isSelected {
                        return addSticker.isStickers
                    }
                }
            }
        }
        return false
    }
    
    func isDepthImage() -> Bool {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let addSticker = subview as? AddSticker {
                    if addSticker.isSelected {
                        return addSticker.isDepthImage
                    }
                }
            }
        }
        return false
    }
    
    func isBackgroundRemoved() -> Bool {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let addSticker = subview as? AddSticker {
                    if addSticker.isSelected {
                        return addSticker.isBackgroundRemoved
                    }
                }
            }
        }
        return false
    }
    
    func getColorFromSelectedSticker() -> UIColor {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let addSticker = subview as? AddSticker {
                    if addSticker.isSelected {
                        return addSticker.tintColor
                    }
                }
            }
        }
        return .white
    }
    
    func openPhotoLibrary(isEdit:Bool) {
        isEditAddPhoto = isEdit
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationCapturesStatusBarAppearance = true
            imagePicker.isModalInPresentation = false
            imagePicker.modalPresentationStyle = .fullScreen // Set to full screen
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openCameraForCustomSticker(isEdit:Bool) {
        let rulerViewController = CustomStickerViewController(nibName: CustomStickerViewController.className, bundle: nil)
        rulerViewController.delegate = self
        self.navigationController?.pushViewController(rulerViewController, animated: true)
    }
    
    //Tick button when clicked
    func applySticker(isGalleryAddButton: Bool = false) {
        
        
        self.isShowingRedoUndo()
        self.isEnableRedoUndo()
        
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()
        self.scrollViewContainer.addGestureRecognizer(self.framePanGesture)
        
        self.option.isSticker = true
        self.stickersText(text: .saved, isText: false)
        if !isGalleryAddButton {
            self.stickersText(text: .hideDeleteButton, isText: false)
        }
        self.saveAppliedStickersFromView()
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
        
    }
    /*
     <CAGlobalPhotoSDK.AddSticker: 0x10f4c9b00; baseClass = UIImageView; frame = (61.4002 195.678; 222.644 222.644); transform = [0.7754314584759856, -0.70886273781420106, 0.70886273781420117, 0.7754314584759846, 0, 0]; opaque = NO; tintColor = UIExtendedGrayColorSpace 1 1; tag = 10; gestureRecognizers = <NSArray: 0x10f528560>; image = <UIImage:0x1062ea620 CGImage "heart_football3_px"; (700 700)@1>; layer = <CALayer: 0x107a58960>>
     
     <CAGlobalPhotoSDK.AddSticker: 0x10f4c9b00; baseClass = UIImageView; frame = (61.4002 186.16; 222.644 241.681); transform = [0.7754314584759856, -0.70886273781420106, 0.70886273781420117, 0.7754314584759846, 0, 0]; opaque = NO; tintColor = UIExtendedGrayColorSpace 1 1; tag = 10; gestureRecognizers = <NSArray: 0x10f528560>; image = <UIImage:0x1062ea620 CGImage "heart_football3_px"; (700 700)@1>; layer = <CALayer: 0x107a58960>>

     **/
    func saveAppliedStickersFromView() {
        
        self.option.stickerDetail.removeAll()
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let view = subview as? AddSticker {
                    let transform = view.transform
                    self.option.stickerDetail.append((
                        sticker: view,
                        trns: transform,
                        frame: view.bounds,
                        cnter: view.center,
                        orntn: flipAngleSticker,
                        isSticker: view.isStickers,
                        color: view.tintColor,
                        image: view.image,
                        stickerName: view.stickerSelection,
                        straightenAngle: view.straightenAngle,
                        rotationAngle: view.rotationAngle,
                        alpha: view.alpha,
                        flipAngle: view.flipAngle))
                }
            }
        }
    }
    
    func addRemoveButtonOnSticker() {
        self.saveCrossView.showView()
        self.doneButton.isHidden = false
        self.option.isSticker = false
        self.stickersText(text: .showDeleteButtonOnTap, isText: false)
        self.stickersText(text: .resetMove, isText: false)
    }
    
    func resetFramesStickers() {
        self.stickersText(text: .removeAll, isText: false)
        self.updateFramesSticker()
    }
    
    func updateFramesSticker() {
        var isFrameSticker: Bool = true
        for textView in self.option.stickerDetail {
            let textViewDetail = textView.sticker
            var view = AddSticker(frame: CGRectMake(0, 0, 0, 0))
            view = textViewDetail!
            let frame = textView.frame ?? CGRectMake(0, 0, 0, 0)
            //let transform = CGAffineTransform(rotationAngle: self.rotation(from: textViewDetail!.transform))
            var isSticker: Bool = true
            let center = textView.cnter

            // Determine whether it's a sticker or gallery mode
            switch self.filterSelection {
            case .sticker:
                isSticker = true
                isFrameSticker = true
            case .gallery:
                isSticker = false
                isFrameSticker = false
            default:
                break
            }
            
            var color = UIColor.white
            if customStickerArray.count > 0 {
                // Add custom sticker logic here if needed
            } else {
                // Default behavior here
            }
            
            let colorManager = ColorManager()
            _ = colorManager.getColorsData()
            
            if textView.stickerName == "shapes" {
                color = (UIColor(named: .stickerColor, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!)
            } else {
                color = (UIColor(named: .white, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!)
            }
            
            // Adding the sticker view
            view = self.stickerManager.addStickerReset(stickerView: view, delegate: self, frame: frame, image: textView.image!, isTransform: true, transform: textView.trns, tag: stickerSavedTags, sticker: textView.stickerName ?? "", isSticker: textView.isSticker ?? false, color: textView.color ?? color)
            
            self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
            view.isSelected = false
            view.selectedColorIndex = textViewDetail?.selectedColorIndex ?? 0
            view.isDepthImage = textViewDetail?.isDepthImage ?? false
            view.isBackgroundRemoved = textViewDetail?.isBackgroundRemoved ?? false
            self.flipAngleSticker = textView.orntn ?? ""
            view.alpha = textView.alpha ?? 1.0
            view.bounds = frame
            view.center = center ?? CGPoint(x: 0, y: 0)
            view.transform = textView.trns

            self.stickerTextView.addSubview(view)
            stickerScale = 1.0
        }
    }
    
    @objc func updateStickerTimer() {
        if self.isStickersFetch == true {
            stickerTimer?.invalidate()
        }
    }
    
    func mainDatabaseSaveOperationForSticker(event: [String: Any]) {
        stickersFromApi.removeAll()
        subStickersFromApi.removeAll()
        let eventId = event["id"] as? Int ?? 0
        let name = event["name"] as? String ?? ""
        let start = event["start_date"] as? String ?? ""
        let end = event["end_date"] as? String ?? ""
        let create = event["created_at"] as? String ?? ""
        let update = event["updated_at"] as? String ?? ""
        let delete = event["deleted_at"] as? String ?? ""
        let ver = event["version"] as? String ?? ""
        let stickerModel = StickerModel()
        stickerModel.id = eventId
        stickerModel.name = name
        stickerModel.startDate = start
        stickerModel.endDate = end
        stickerModel.createdAt = create
        stickerModel.updatedAt = update
        stickerModel.deletedAll = delete
        stickerModel.version = ver
        
        stickersFromApi.append(stickerModel)
        
        if let stickers = event["stickers"] as? [[String:Any]] {
            for sticker in stickers {
                let evId = sticker["id"] as? Int ?? 0
                let eventId = sticker["event_id"] as? Int ?? 0
                let name = sticker["name"] as? String ?? ""
                let thumbnail = sticker["thumbnail"] as? String ?? ""
                let image = sticker["image"] as? String ?? ""
                
                let stickerModel = SubStickerModel(id: evId, eventId: eventId, name: name, thumbnail: thumbnail, image: image, imagePath: "", isDownloaded: false)
                subStickersFromApi.append(stickerModel)
            }
        }
        isStickersFetch = false
    }
    
    func mainDatabaseSaveOperationForFrames(event:[String:Any]){
        framesFromApi.removeAll()
        subFramesFromApi.removeAll()
        let eventId = event["id"] as? Int ?? 0
        let name = event["name"] as? String ?? ""
        let start = event["start_date"] as? String ?? ""
        let end = event["end_date"] as? String ?? ""
        let create = event["created_at"] as? String ?? ""
        let update = event["updated_at"] as? String ?? ""
        let delete = event["deleted_at"] as? String ?? ""
        let ver = event["version"] as? String ?? ""
        let stickerModel = FramesModel(id: eventId, name: name, startDate: start, endDate: end, createdAt: create, updatedAt: update, deletedAll: delete, version: ver)
        framesFromApi.append(stickerModel)
        
        if let stickers = event["frames"] as? [[String:Any]] {
            for sticker in stickers {
                let evId = sticker["id"] as? Int ?? 0
                let eventId = sticker["event_id"] as? Int ?? 0
                let name = sticker["name"] as? String ?? ""
                let thumbnail = sticker["thumbnail"] as? String ?? ""
                let image = sticker["image"] as? String ?? ""
                let stickerModel = SubFramesModel(id: evId, eventId: eventId, name: name, thumbnail: thumbnail, image: image, imagePath: "", isDownloaded: false)
                subFramesFromApi.append(stickerModel)
            }
        }
        self.isFramesFetch = false
    }
    
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let defaultCropperState = self.initialState {
            self.restoreState(defaultCropperState)
        }
        // Check if an image is already being processed
        guard !isProcessingImage else { return }
        
        isProcessingImage = true // Set the flag to true to prevent further taps
        
        guard let image = info[.originalImage] as? UIImage else {
            isProcessingImage = false // Reset the flag if no image is found
            return
        }
        
        let remover = BackgroundRemover()
        remover.hasForeground(in: image) { [weak self] hasForeground in
            guard let self = self else { return }
            
            self.dismiss(animated: true) {
                // Reset the flag after the image processing is done
                defer { self.isProcessingImage = false }
                
                if self.isEditAddPhoto! {
                    self.editStickerImage(
                        oldImage: self.getImageFromSelectedSticker()!,
                        orignaloldImage: self.getOrignalImageFromSelectedSticker()!,
                        oldImageTintColor: self.getColorFromSelectedSticker(),
                        image: image,
                        orignalImage: image,
                        stickerSelection: "image", pStickerSelection: "image",
                        isImageDepth: hasForeground,
                        isBackgroundRemoved: self.isBackgroundRemoved(),
                        isGallery: true
                    )
                } else {
                    self.filterSelection = .gallery
                    self.selectedStickerImage(
                        image: image,
                        stickerSelection: "image",
                        stickerUrl: "",
                        isImageDepth: hasForeground
                    )
                }
            }
        }
    }
    
    
    
    
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        
        if let defaultCropperState = self.initialState {
            self.restoreState(defaultCropperState)
        }
        self.dismiss(animated: true) {
            switch self.filterSelection {
            case .sticker:
                self.stickerView.setSelectionOnCancelAddPhoto()
            case .gallery:
                if self.isEditAddPhoto == true {
                    self.isEditAddPhoto = false
                    self.mainCollectionView.isHidden = true
                } else {
                    self.selectedAddSticker?.handles.forEach { $0.isHidden = false }
                    self.mainCollectionView.isHidden = false
                    self.stickerTextView.isUserInteractionEnabled = true
                    self.mainCollectionView.reloadData()
                    
                    
                }
                if self.isPlusAddPhoto == true {
                    self.isPlusAddPhoto = false
                    self.mainCollectionView.isHidden = true
                    self.setupAddDeleteFlipAndOnTopButtons(isHidden: false)
                }
            default:
                break
            }
        }
    }
    
    func applyColor(_: StickerOptions, colorModel: ColorModel) {
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()
        // Save the old color before applying the new one
        self.previousSickerColorModel = self.selectedSickerColorModel
        self.selectedStickerColor = colorModel.color
        self.selectedSickerColorModel = colorModel
        self.stickersText(text: .setColor, color: colorModel, index: colorModel.selectedColorIndex, isText: false)
    }
    
    func applyColorUndoRedo( sticker: AddSticker, colorModel: ColorModel) {
        self.previousSickerColorModel = self.selectedSickerColorModel
        // Load your image
        let originalImage = sticker.orignalImage!
        //   guard var originalImage = view.image, var originalImage = view.orignalImage else { return }
        
        let image = originalImage.withRenderingMode(.alwaysTemplate)
        sticker.image = image
        sticker.tintColor = colorModel.color
        
        
        self.undoRedoManager.registerUndo(withTarget: self) { target in
            self.stickersText(text: .setColor, color: self.previousSickerColorModel, isText: false)
            
            // Optional: Set a user-friendly name
            target.undoRedoManager.setActionName("Change Sticker Color")
        }
        
        isEnableRedoUndo()
    }
    
    func alignment() {
        forStickerAlignment()
    }
    
    func forStickerAlignment() {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let view = subview as? AddSticker {
                    if view.isSelected == true {
                        self.calculatingLeftRightAlignment(view: view)
                        self.calculatingTopBottomAlignment(view: view)
                        self.calculatingCenterAlignment(view: view)
                    }
                }
            }
        }
    }
    
    func replaceSticker(_: StickerOptions) {
        switch self.filterSelection {
        case .sticker:
            self.setUpStickerView(isEdit: true)
        case .gallery:
            self.openPhotoLibrary(isEdit: true)
        default:
            break
        }
        self.stickersText(text: .replace, isText: false)
    }
    
    func mirrorSticker(_: StickerOptions) {
        self.stickersText(text: .mirror, isText: false)
    }
    
    func onTopSticker(_: StickerOptions) {
        self.stickersText(text: .onTop, isText: false)
    }
    
    func opacityDidStart(_ stickerOptions: StickerOptions, sliderValue: CGFloat) {
        self.stickersSliderValue = sliderValue
        self.stickersText(text: .setOpacity, opacity: sliderValue, isText: false)
    }
    
    
    func opacityDidEnd(_: StickerOptions, sliderValue: CGFloat) {
        self.stickersText(text: .setOpacityEnd, opacity: sliderValue, isText: false)
    }
    
    func handleGestureSticker(_ gestureRecognizer: UIPanGestureRecognizer) {
        if let stickerView = self.selectedAddSticker {
            self.handlePanForSticker(gestureRecognizer, stickerView: stickerView)
        }
    }
    
    func backButtonColor() {
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()
        self.stickerOption.updatingColor(views: self.stickerTextView.subviews)
    }
    
    func nextStickerNumber() -> Int {
        let lastStickerNumber = UserDefaults.standard.integer(forKey: kPGCSMLastStickerNumberKey)
        return lastStickerNumber + 1
    }
    
    func stickerDirectoryURL() -> URL? {
        let manager = FileManager.default
        
        guard let documentsDirectory = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let stickerDirectory = documentsDirectory.appendingPathComponent(kPGCustomStickerManagerDirectory)
        
        do {
            try manager.createDirectory(at: stickerDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            // Handle any errors that may occur during directory creation
            print("Error creating directory: \(error.localizedDescription)")
            return nil
        }
        
        return stickerDirectory
    }
    
    func saveSticker(_ sticker: UIImage, thumbnail: UIImage) {
        let number = nextStickerNumber()
        
        // Appending a random suffix to prevent caching by imgly
        let unique = String(UUID().uuidString.prefix(4))
        
        if let stickerDirectoryURL = stickerDirectoryURL() {
            let stickerURL = stickerDirectoryURL.appendingPathComponent(String(format: "%0*ld-%@.png", kCustomStickerManagerPrefixLength, number, unique))
            if let stickerData = sticker.pngData() {
                do {
                    try stickerData.write(to: stickerURL, options: .atomic)
                } catch {
                    print("Error writing sticker data: \(error.localizedDescription)")
                }
            }
            
            let thumbnailURL = stickerDirectoryURL.appendingPathComponent(String(format: "%0*ld-%@%@.png", kCustomStickerManagerPrefixLength, number, unique, kCustomStickerManagerThumbnailSuffix))
            if let thumbnailData = thumbnail.pngData() {
                do {
                    try thumbnailData.write(to: thumbnailURL, options: .atomic)
                } catch {
                    print("Error writing thumbnail data: \(error.localizedDescription)")
                }
            }
            UserDefaults.standard.set(number, forKey: kPGCSMLastStickerNumberKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    func getCustomSticker(stickerImage: UIImage, thumbnailImage: UIImage) {
        customStickerArray.append(stickerImage)
        self.setUpStickerView()
    }
    
    func getCrossButton() {
        self.stickerView.toRefreshSelection()
    }
    
    func setFurtherColorSticker(color: UIColor) {
        let colorPickerViewController = AMColorPickerViewController()
        colorPickerViewController.selectedColor = color
        colorPickerViewController.selectedOpacity = self.viewPaintDrawing.strokeOpacity
        colorPickerViewController.delegate = self
        colorPickerViewController.modalPresentationStyle = .fullScreen
        present(colorPickerViewController, animated: true, completion: nil)
    }
    
    func showNotEnoughSpaceMessage() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: "Storage Issue",
                message: "Your device doesn't have enough storage to download the update. Please open Settings and go to General > iPhone Storage to free up space.",
                preferredStyle: .alert
            )
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertController.addAction(settingsAction)
            alertController.addAction(cancelAction)
            
            if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
               var topController = keyWindow.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                topController.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
class StickerView: UIView {
    private let cornerSize: CGFloat = 20
    
    private let topLeftHandle = TopLeftLShapeHandle()
    private let topRightHandle = TopRightLShapeHandle()
    private let bottomLeftHandle = BottomLeftLShapeHandle()
    private let bottomRightHandle = BottomRightLShapeHandle()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHandles()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHandles()
    }
    
    private func setupHandles() {
        // Set initial frame sizes
        topLeftHandle.frame = CGRect(x: 0, y: 0, width: cornerSize, height: cornerSize)
        topRightHandle.frame = CGRect(x: bounds.width - cornerSize, y: 0, width: cornerSize, height: cornerSize)
        bottomLeftHandle.frame = CGRect(x: 0, y: bounds.height - cornerSize, width: cornerSize, height: cornerSize)
        bottomRightHandle.frame = CGRect(x: bounds.width - cornerSize, y: bounds.height - cornerSize, width: cornerSize, height: cornerSize)
        
        addSubview(topLeftHandle)
        addSubview(topRightHandle)
        addSubview(bottomLeftHandle)
        addSubview(bottomRightHandle)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Ensure handles stay at corners when the sticker resizes
        topLeftHandle.frame = CGRect(x: 0, y: 0, width: cornerSize, height: cornerSize)
        topRightHandle.frame = CGRect(x: bounds.width - cornerSize, y: 0, width: cornerSize, height: cornerSize)
        bottomLeftHandle.frame = CGRect(x: 0, y: bounds.height - cornerSize, width: cornerSize, height: cornerSize)
        bottomRightHandle.frame = CGRect(x: bounds.width - cornerSize, y: bounds.height - cornerSize, width: cornerSize, height: cornerSize)
    }
    func showHandles() {
        for handle in self.subviews where handle is UIImageView {
            handle.isHidden = false
        }
    }
    
    
}
