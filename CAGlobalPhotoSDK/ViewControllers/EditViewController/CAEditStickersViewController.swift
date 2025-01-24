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

    func removeBackgroundFromImage() {
        let remover = BackgroundRemover()
        // Perform background removal
        remover.removeBackground(from: getImageFromSelectedSticker()!) { [weak self] resultImage in
            guard let self = self else { return }
            if let resultImage = resultImage {
                DispatchQueue.main.async {
                    self.removeBackgroundImage(oldImage: self.getImageFromSelectedSticker()!, oldImageTintColor: self.getColorFromSelectedSticker(), image: resultImage, stickerSelection: "customSticker", isBackground: true)
                    self.stickersText(text: .replace, isText: false)
                }
            } else {
                print("Background removal failed.")
            }
        }
    }
    
    func unremoveBackgroundFromImage() {
        self.removeBackgroundImage(oldImage: self.getImageFromSelectedSticker()!, oldImageTintColor: self.getColorFromSelectedSticker(), image: self.getOrignalImageFromSelectedSticker()!, stickerSelection: "customSticker", isBackground: false)
        self.stickersText(text: .replace, isText: false)
        
    }

    func removePickColorForColor() {
        self.constraintsBottomViewHeight.constant = 80
    }

    func pickColorFromStickers(callBack: (UIColor) -> Void?) {
        self.selectedAddTextView = nil
        self.selectedAddSticker = nil
        self.removeGesturesMainImageViewForMagnify()
        /**

         UIPanGestureRecognizer - Pan Objects
         */
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanColorPickerMagnify(_:)))
        pan.delegate = self
        self.mainImageView.addGestureRecognizer(pan)
        magnifyingGlass.magnifiedView = self.mainImageView
        magnifyingGlass.magnify(at: self.mainImageView.center)
        let color = self.scrollViewContainer.getPixelColorAt(point: self.overlay.center)
        self.selectedStickerColorModel = color
        self.stickersText(text: .setColor, color: color, isText: false)
        callBack(color)
    }
    
    // MARK: - Stickers Option -
    
    func opacityWillStart(_ textView: StickerOptions, isOpen: Bool) {
        if isOpen {
            self.constraintsBottomViewHeight.constant = 80 + 40
        } else {
            self.constraintsBottomViewHeight.constant = 80
        }
    }
    
    
    //Setting up emojis and shapes header
    func setUpStickerOptionView(stickerSelection: String, isFromGallery:Bool?=false,isImageDepth:Bool?=false,isBackgroundRemoved:Bool?=false) {
        self.removeBottomSubViews()
        stickerOption.delegate = self
        stickerOption.setUpData(views: self.stickerTextView.subviews, stickerSelection: stickerSelection,isFromGallery:isFromGallery,isImageDepth:isImageDepth, isBackgroundRemoved: isBackgroundRemoved )
        self.bottomView.addSubview(stickerOption)
        self.bottomView.isHidden = false
        self.setupAutoLayoutForBottomView(newView: stickerOption, bottomView: self.bottomView)
    }
    
    //Setting up view for emojis and shapes
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
    }
    
    // Adding new sticker on view
    func selectedStickerImage(image: UIImage, stickerSelection: String, stickerUrl: String,isImageDepth:Bool?=false) {
        // For loading directly
        self.flipAngleSticker = ""
        
        let visibleRect = scrollView.convert(scrollView.bounds, to: self.stickerTextView)
        let centerX = visibleRect.midX
        let centerY = visibleRect.midY
        let stickerCenter = CGPoint(x: centerX - 75, y: centerY - 75)

        let frame = CGRect(origin: stickerCenter, size: CGSizeMake(150, 150))
        let transform = CGAffineTransform(rotationAngle: self.rotation(from: view.transform))
        var isSticker: Bool = true
        
        // Determine if the action is for a sticker or gallery item1
        switch self.filterSelection {
        case .sticker:
            isSticker = true
        case .gallery:
            isSticker = false
        default:
            break
        }
        print(isSticker)
        
        var color = UIColor(named: .white)

        // Set color based on selection
        if customStickerArray.count > 0 {
            if stickerSelection == "shapes" {
                color = UIColor(named: .stickerColor)!
            }
        } else {
            if stickerSelection == "shapes" {
                color = UIColor(named: .stickerColor)!
            }
        }
        if stickerUrl.count > 0 {
            
        }
        let frameImage = image
        var newImage = frameImage

        if isFlippedSelected && isMirroredSelected {
            newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .down)
        } else if isFlippedSelected {
            newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .upMirrored)
        } else if isMirroredSelected {
            newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .downMirrored)
        }
        
        let view = stickerManager.addSticker(delegate:self, frame: frame, image: newImage,isTransform: false, transform: transform, tag: stickerTempTags, sticker: stickerSelection, isSticker: isSticker, color: color!)
        view.isDepthImage = isImageDepth ?? false
        view.isBackgroundRemoved = false
        view.orignalImage = newImage
//        addSticker.image = self.fixOrientation(img: newImage)
//        addSticker.orignalImage = self.fixOrientation(img: newImage)
        view.transform = CGAffineTransform(rotationAngle: -totalAngle)
        view.flipAngleSticker = "up"
        self.stickerTextView.addSubview(view)
        self.stickerTextView.isUserInteractionEnabled = true
        self.stickerVisualEffectView.isHidden = true
        self.stickersText(text: .showDeleteButton, isText: false)
        self.setUpStickerOptionView(stickerSelection: stickerSelection, isFromGallery: !isSticker,isImageDepth: isImageDepth, isBackgroundRemoved: false)
        self.saveCrossView.showView()
        self.doneButton.isHidden = false
        self.mainCollectionView.isHidden = true
        self.arrayTransformRotationValues.append(0.0)
        stickerScale = 1.0
        
        // Integrate undo/redo for adding sticker action
//        Editor.currentFilterSelection = .sticker // Set the current selection
//        let data: [String: Any] = [
//            "view": stickerView,
//            "name": stickerSelection,
//            "frame": frame,
//            "color": stickerView.tintColor,
//            "image": image
//        ]
//        Editor.performAction(type: .add, data: data)
    }


    //Editing existing sticker by pressing replace button
    func removeBackgroundImage(oldImage: UIImage, oldImageTintColor: UIColor, image: UIImage, stickerSelection: String, isBackground: Bool) {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let addSticker = subview as? AddSticker {
                    if addSticker.isSelected {
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
    func editStickerImage(oldImage: UIImage, oldImageTintColor: UIColor, image: UIImage, stickerSelection: String, isImageDepth:Bool?=false,isBackgroundRemoved:Bool?=false,isGallery:Bool?=false) {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let addSticker = subview as? AddSticker {
                    if addSticker.isSelected {
                        
                        let frameImage = image
                        var newImage = frameImage

                        if isFlippedSelected && isMirroredSelected {
                            newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .down)
                        } else if isFlippedSelected {
                            newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .upMirrored)
                        } else if isMirroredSelected {
                            newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .downMirrored)
                        }
                        
                        addSticker.image = newImage
                        addSticker.isBackgroundRemoved = isBackgroundRemoved ?? false
                        if isBackgroundRemoved == true {
                            if isImageDepth == true {
                                let remover = BackgroundRemover()
                                // Perform background removal
                                remover.removeBackground(from: getImageFromSelectedSticker()!) { [weak self] resultImage in
                                    guard let self = self else { return }
                                    if let resultImage = resultImage {
                                        DispatchQueue.main.async {
                                            let frameImage = resultImage
                                            var newImage = frameImage

//                                            if self.isFlippedSelected && self.isMirroredSelected {
//                                                newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .down)
//                                            } else if self.isFlippedSelected {
//                                                newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .upMirrored)
//                                            } else if self.isMirroredSelected {
//                                                newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .downMirrored)
//                                            }
                                            addSticker.image = newImage
                                        }
                                    } else {
                                        print("Background removal failed.")
                                    }
                                }
                            } else {
                                addSticker.isBackgroundRemoved = false
                            }
                        }
                        addSticker.orignalImage = newImage
                        addSticker.transform = CGAffineTransform(rotationAngle: -totalAngle)
                        addSticker.image = self.fixOrientation(img: newImage)
                        addSticker.orignalImage = self.fixOrientation(img: newImage)
//                        let orientation = oldImage.imageOrientation
//                        let ciimage = newImage.cgImage!
//                        switch orientation {
//                        case .up:
//                            addSticker.image = UIImage(cgImage: ciimage, scale: 1.0, orientation: .up)
//                        case .upMirrored:
//                            addSticker.image = UIImage(cgImage: ciimage, scale: 1.0, orientation: .upMirrored)
//                        case .down, .left, .right, .downMirrored, .leftMirrored, .rightMirrored:
//                            break;
//                        @unknown default:
//                            break
//                        }
                        addSticker.stickerSelection = stickerSelection
                        self.changeTags(addSticker: addSticker, oldImageTintColor: oldImageTintColor)
                    }
                }
            }
        }
        
        self.stickerVisualEffectView.isHidden = true
        self.stickersText(text: .edit, isText: false)
        self.setUpStickerOptionView(stickerSelection: stickerSelection, isFromGallery: isGallery, isImageDepth:isImageDepth, isBackgroundRemoved: isBackgroundRemoved)
        self.saveCrossView.showView()
        self.doneButton.isHidden = false
        stickerScale = 1.0
    }



    func changeTags(addSticker: AddSticker, oldImageTintColor: UIColor) {
        if addSticker.stickerSelection == "shapes" || addSticker.stickerSelection == "badges"  || addSticker.stickerSelection == "arrow" || addSticker.stickerSelection == "spray" {
            addSticker.image = addSticker.image?.withRenderingMode(.alwaysTemplate)
            addSticker.tintColor = oldImageTintColor
            if oldImageTintColor.isWhite() {
                if addSticker.stickerSelection == "shapes" {
                    let color = UIColor(named: .stickerColor)!
                    addSticker.tintColor = color
                }
            }
            if oldImageTintColor == UIColor(named: .stickerColor)! {
                if addSticker.stickerSelection == "badges"  || addSticker.stickerSelection == "arrow" || addSticker.stickerSelection == "spray" {
                    addSticker.image = addSticker.image?.withRenderingMode(.alwaysTemplate)
                    let color = UIColor(named: .white)!
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
    
    //Tapping on stickers converting into selected state
    func addRemoveButtonFromSticker(sticker: AddSticker, tag: Int, stickerSelection: String) {
        if self.magnifyingGlass.magnifiedView == nil, self.option.isFramesSelected == false {
            
            self.mainCollectionView.isHidden = true
            self.stickersText(text: .showDeleteButtonOnTap, isText: false)
            self.stickersText(text: .onTop, isText: false)
            if isSticker() {
                self.setUpStickerOptionView(stickerSelection: stickerSelection, isFromGallery: false)
            } else {
                self.setUpStickerOptionView(stickerSelection: stickerSelection, isFromGallery: true, isImageDepth: self.isDepthImage(), isBackgroundRemoved: self.isBackgroundRemoved())

            }
            if self.filterSelection == FilterSelection.none ||  self.filterSelection == FilterSelection.text {
                self.selectedAddTextView = nil
                self.stickersText(text: .hideSelection, isText: true) // Hiding Text Selection in sticker editor
                if isSticker() {
                    self.filterSelection = FilterSelection(rawValue: 4)
                } else {
                    self.filterSelection = FilterSelection(rawValue: 7)
                }
                self.addRemoveButtonOnSticker()
                
                self.mainCollectionView.reloadData()
            }
        }
    }
    
    func getImageFromSelectedSticker() -> UIImage? {

        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let addSticker = subview as? AddSticker {
                    if addSticker.isSelected {
                        return addSticker.image!
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
                        return addSticker.orignalImage!
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
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()
        self.mainImageView.addGestureRecognizer(self.framePanGesture)
        self.selectedAddSticker = nil
        self.option.isSticker = true
        self.stickersText(text: .saved, isText: false)
        if !isGalleryAddButton {
            self.stickersText(text: .hideDeleteButton, isText: false)
        }
        self.saveAppliedStickersFromView()
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)

    }
    
    func saveAppliedStickersFromView() {
        self.option.stickerDetail.removeAll()
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let view = subview as? AddSticker {
                    let transform = view.transform
                    self.option.stickerDetail.append((
                        sticker: view,
                        transform: transform,
                        frame: view.frame,
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
            let frame = textView.frame ?? CGRectMake(0, 0, 0, 0)
            let transform = CGAffineTransform(rotationAngle: self.rotation(from: textViewDetail!.transform))
            var isSticker: Bool = true

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
                color = (UIColor(named: .stickerColor)!)
            } else {
                color = (UIColor(named: .white)!)
            }

            // Logic for handling frame stickers
            if isFrameSticker {
                // If the sticker is considered a "frame," we might apply special properties
                // For example, adding a border, or making the frame more prominent
                // You can add specific frame logic here, e.g., adjusting the frame size or color
                view.layer.borderWidth = 2.0
                view.layer.borderColor = UIColor.black.cgColor
            }

            // Adding the sticker view
            let view = self.stickerManager.addSticker(delegate: self, frame: frame, image: textView.image!, isTransform: true, transform: transform, tag: stickerSavedTags, sticker: textView.stickerName ?? "", isSticker: textView.isSticker ?? false, color: textView.color ?? color)

            self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
            view.isSelected = false
            self.flipAngleSticker = textView.orntn ?? ""
            view.alpha = textView.alpha ?? 1.0
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
        guard let image = info[.originalImage] as? UIImage else { return }

            let remover = BackgroundRemover()
            remover.hasForeground(in: image) { [weak self] hasForeground in
                guard let self = self else { return }

                self.dismiss(animated: true) {

                    if self.isEditAddPhoto! {
                        self.editStickerImage(
                            oldImage: self.getImageFromSelectedSticker()!,
                            oldImageTintColor: self.getColorFromSelectedSticker(),
                            image: image,
                            stickerSelection: "customSticker",
                            isImageDepth: hasForeground,
                            isBackgroundRemoved: self.isBackgroundRemoved(),
                            isGallery: true
                        )
                    } else {
                        self.selectedStickerImage(
                            image: image,
                            stickerSelection: "customSticker",
                            stickerUrl: "",
                            isImageDepth: hasForeground
                        )
                    }
                }
            }
    }



    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        self.dismiss(animated: true) {
            switch self.filterSelection {
            case .sticker:
                self.stickerView.setSelectionOnCancelAddPhoto()
            case .gallery:
                if self.isEditAddPhoto == true {
                    self.mainCollectionView.isHidden = true
                } else {
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
        self.selectedStickerColorModel = colorModel.color
        self.stickersText(text: .setColor, color: colorModel.color, isText: false)
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
    
    func handleGestureSticker(_ gestureRecognizer: UIPanGestureRecognizer) {
        //anu comment for sprint6
//        self.alignment()
        
        // This will hold the original center before the pan begins
        var originalCenter: CGPoint?
        
        if gestureRecognizer.state == .began {
            // Capture the original position before any translation occurs
            originalCenter = self.selectedAddSticker?.center
        }
        
        if gestureRecognizer.state == .changed {
            if self.selectedAddSticker != nil {
                let point = gestureRecognizer.location(in: self.stickerTextView)
                let superview = self.stickerTextView
                let restrictByPoint: CGFloat = 30.0
                let xAxis = superview.bounds.origin.x + restrictByPoint
                let yAxis = superview.bounds.origin.y + restrictByPoint
                let width = superview.bounds.size.width - 2 * restrictByPoint
                let superBounds = CGRect(x: xAxis, y: yAxis, width: width, height: superview.bounds.size.height - 2 * restrictByPoint)
                
                if superBounds.contains(point) {
                    let translation = gestureRecognizer.translation(in: self.stickerTextView)
                    self.selectedAddSticker?.center = CGPoint(
                        x: (self.selectedAddSticker?.center.x ?? 0) + translation.x,
                        y: (self.selectedAddSticker?.center.y ?? 0) + translation.y
                    )
                    gestureRecognizer.setTranslation(CGPoint.zero, in: self.stickerTextView)
                }
            }
        }
        
        if gestureRecognizer.state == .ended {
            self.removeAlignmentLines()
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
        present(colorPickerViewController, animated: true, completion: nil)
    }
}
