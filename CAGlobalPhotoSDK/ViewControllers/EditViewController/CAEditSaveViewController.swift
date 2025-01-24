//
//  CAEditSaveViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/05/23.
//

import UIKit

class CAEditSaveViewController: CAEditViewController {
    
}

extension CAEditViewController {
    func isStickerAvailable() -> Bool {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                return true
            }
        }
        return false
    }
    
    func isBrushAvailable() -> Bool {
        if self.option.appliedBrushDetails.count > 0 {
            return true
        }
        return false
    }
    
    func applyingAllFilters(_ isBlurOption: Bool = false,
                            _ isFilter: Bool = false,
                            _ isAdjust: Bool = false) -> UIImage {

        var imageBackUp: UIImage!
        if let imageEdit = self.imageTransform {
            if isAuto() == true && isRedEye() == true {
                imageBackUp = self.autoEnhance(image: imageEdit, all: true, isRedEye: false)
            } else if isAuto() == false && isRedEye() == true {
                imageBackUp = self.redEye(image: imageEdit, isEnhance: false)
            } else if isAuto() == true && isRedEye() == false {
                imageBackUp = self.autoEnhance(image: imageEdit, isRedEye: false)
            } else if isAuto() == false && isRedEye() == false {
                imageBackUp = imageEdit
            }
            let imageBlur = imageBackUp
            if !isBlurOption, self.option.isBlur {
                self.blurManager.mainImageView = self.mainImageView.frame
                self.blurManager.circleView = self.circleView.frame
                self.blurManager.optionalmage = imageEdit
                if let blurImage = imageBlur {
                    if let gaussImage = blurImage.gaussBlur(blurLevel: 1) {
                        let image = self.blurManager.buildResultImage(blurImage, withBlurImage: gaussImage)
                        
                        imageBackUp = image
                    }
                }
            }
            var imageFilter = imageBackUp!
            if !isFilter || self.isFilter() , self.selectedFilter != "" {
                var imageR = self.resizeImage(image: imageBackUp, newWidth: 700)
                switch UIDevice.current.type {
                case .iPhoneSE, .iPhone5, .iPhone5S:
                    imageR = self.resizeImage(image: imageBackUp, newWidth: 400)
                case .iPhone6, .iPhone7, .iPhone8, .iPhone6S, .iPhoneX, .iPhoneXR:
                    imageR = self.resizeImage(image: imageBackUp, newWidth: 500)
                    break
                default:
                    break
                }
                let finalImage = imageR.applyLUTFilter(LUT: UIImage(named: selectedFilter), volume: Float(self.selectedFilterOpacity))
                imageBackUp = finalImage
            }
            
            if !isAdjust {
//                if self.arrayTemperatureSliderValues.count > 0 && self.arrayTemperatureSliderValues.last != 1.0 {
//                    var imageR = self.resizeImage(image: imageBackUp, newWidth: 700)
//                    switch UIDevice.current.type {
//                    case .iPhoneSE, .iPhone5, .iPhone5S:
//                        imageR = self.resizeImage(image: imageBackUp, newWidth: 400)
//                    case .iPhone6, .iPhone7, .iPhone8, .iPhone6S, .iPhoneX, .iPhoneXR:
//                        imageR = self.resizeImage(image: imageBackUp, newWidth: 500)
//                        break
//                    default:
//                        break
//                    }
//                    
//                    imageBackUp = self.temperature(imageR, byVal: self.arrayTemperatureSliderValues.last ?? 0.0)
//                }
                if self.arraySaturationSliderValues.count > 0 && self.arraySaturationSliderValues.last != 1.0 {
                    var imageR = self.resizeImage(image: imageBackUp, newWidth: 700)
                    switch UIDevice.current.type {
                    case .iPhoneSE, .iPhone5, .iPhone5S:
                        imageR = self.resizeImage(image: imageBackUp, newWidth: 400)
                    case .iPhone6, .iPhone7, .iPhone8, .iPhone6S, .iPhoneX, .iPhoneXR:
                        imageR = self.resizeImage(image: imageBackUp, newWidth: 500)
                        break
                    default:
                        break
                    }
                    
                    imageBackUp = self.increaseSaturation(imageR, byVal: self.arraySaturationSliderValues.last ?? 1.0)
                }
                if self.arrayContrastSliderValues.count > 0 && self.arrayContrastSliderValues.last != 1.0 {
                    var imageR = self.resizeImage(image: imageBackUp, newWidth: 700)
                    switch UIDevice.current.type {
                    case .iPhoneSE, .iPhone5, .iPhone5S:
                        imageR = self.resizeImage(image: imageBackUp, newWidth: 400)
                    case .iPhone6, .iPhone7, .iPhone8, .iPhone6S, .iPhoneX, .iPhoneXR:
                        imageR = self.resizeImage(image: imageBackUp, newWidth: 500)
                        break
                    default:
                        break
                    }
                    imageBackUp = self.increaseContrast(imageR, byVal: self.arrayContrastSliderValues.last ?? 1.0)
                }
                if self.arrayBrightnesSliderValues.count > 0 && self.arrayBrightnesSliderValues.last != 0.0{
                    var imageR = self.resizeImage(image: imageBackUp, newWidth: 700)
                    switch UIDevice.current.type {
                    case .iPhoneSE, .iPhone5, .iPhone5S:
                        imageR = self.resizeImage(image: imageBackUp, newWidth: 400)
                    case .iPhone6, .iPhone7, .iPhone8, .iPhone6S, .iPhoneX, .iPhoneXR:
                        imageR = self.resizeImage(image: imageBackUp, newWidth: 500)
                        break
                    default:
                        break
                    }
                    imageBackUp = self.increaseBrightness(for: imageR, byVal: self.arrayBrightnesSliderValues.last ?? 0.0)
                }
            }
        }
        if self.framesImageViewAngleRatio.image != nil {
            if let frame = selectedFrame as? String {
                self.toResetFrames(frame: frame)
            }
        }
        return imageBackUp ?? imageOrignalBackUp
    }
    
    func resizeImage(image: UIImage?, newWidth: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newWidth, false, 1.0)
        image?.draw(in: CGRect(x: 0, y: 0, width: newWidth.width, height: newWidth.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    /**
     Build description signature: f7cc62828be4850faba45d0e6fb7bee4
         Build description path: /Users/emp/Library/Developer/Xcode/DerivedData/Build/Intermediates.noindex/XCBuildData/f7cc62828be4850faba45d0e6fb7bee4.xcbuilddata
     
         note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in target 'App' from project 'App')
     
         error: SWIFT_VERSION '3.0' is unsupported, supported versions are: 4.0, 4.2, 5.0, 6.0. (in target 'App' from project 'App')
         error: SWIFT_VERSION '3.0' is unsupported, supported versions are: 4.0, 4.2, 5.0, 6.0. (in target 'App' from project 'App')
     
         note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in target 'Pods-App' from project 'Pods')
         note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in target 'caglobaledit' from project 'Pods')
     
         error: SWIFT_VERSION '3.0' is unsupported, supported versions are: 4.0, 4.2, 5.0, 6.0. (in target 'caglobaledit' from project 'Pods')
         error: SWIFT_VERSION '3.0' is unsupported, supported versions are: 4.0, 4.2, 5.0, 6.0. (in target 'caglobaledit' from project 'Pods')
     **/
    
    func toResetFrames(frame: String) {
        print(frame)
        if selectedFrame as? String != "none" {
            var frameNameArray = frame.components(separatedBy: "_")
            if frameNameArray.count > 0 {
                let photoLength: CGFloat = self.selectedRatioWith
                var sizeType = ""
                // 9 7 4 1
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
                selectedFrame = imageName
                print(imageName)
                let frameImage = UIImage.init(named: imageName)
                var newImage = frameImage
                
                if rotationAngle == 1.5707963267948966 {
                    newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .left)
                } else if rotationAngle == 3.141592653589793 {
                    newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .down)
                } else if rotationAngle == 4.71238898038469 {
                    newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .right)
                }
                if imageName != "none" {
//                    if isRotationImage == true {
//                        self.framesImageView.image = UIImage.init(named: imageName)
//                    } else {
                        self.framesImageViewAngleRatio.image = newImage
//                    }
                } else {
                    self.framesImageViewAngleRatio.image = nil
                }
            }
        }
    }
    
    func saveEdit() {
        switch self.filterSelection {
        case .transform:
            self.applyTransform()
        case .text:
            self.applyText()
        case .sticker:
            self.applySticker()
        case .frame:
            self.option.isFramesSelected = false
            self.applyFrames()
        case .brush:
            self.addPanGestureMainEdit()
            self.applyBrush()
        case .gallery:
            self.applySticker()
        case .filter:
            self.applyFilter()
        case .adjust:
            self.applyAdjust()
        default:
            break
        }
        self.stickerTextView.isUserInteractionEnabled = true
        self.applyImageView()
        self.hideCrossTickOnly()
        self.removeBottomSubViews()
        self.filterSelection = FilterSelection(rawValue: -1)
        self.mainCollectionView.isHidden = false
//        self.undoButton.isHidden = true
//        self.redoButton.isHidden = true
        self.mainCollectionView.reloadData()

    }
    
    func hideCrossTickOnly() {
        self.toShowHideSaveCrossButtons()
        self.saveCrossView.hideView()
        self.saveCrossSubOptionsView.hideView()
    }
    
    func removeBottomSubViews() {
        for view in self.bottomView.subviews {
            view.removeFromSuperview()
        }
        for view in self.stickerBaseView.subviews {
            view.removeFromSuperview()
        }
        self.bottomView.isHidden = true
        self.stickerVisualEffectView.isHidden = true
    }
    
    func toShowHideSaveCrossButtons() {
        if isAuto() || isRedEye() || isTransform() || self.isText() || isOverlay() || self.isSticker() || isFilter() || self.option.isFrames || self.option.isAdjust || self.option.isBrush {
            self.showSaveButtonOnEditingBegan()
        } else {
            self.hideSaveButtonOnEditingCancelled()
        }
    }
    func isAuto() -> Bool {
        return self.option.isAuto
    }
    func isRedEye() -> Bool {
        return self.option.isRedEye
    }
    func isTransform() -> Bool {
        return self.option.isTransform
    }
    func isOverlay() -> Bool {
        return self.option.isOverlay
    }
    func isFilter() -> Bool {
        return self.option.isFilter
    }
    
    func isFrame() -> Bool {
        return self.option.isFrames || self.framesImageViewAngleRatio.image != nil
    }
    
    func showSaveButtonOnEditingBegan() {
        self.doneButton.isHidden = false
    }
    
    func hideSaveButtonOnEditingCancelled() {
        self.doneButton.isHidden = false
    }
    
    func hideCrossTick() {
        self.mainCollectionView.isHidden = false
        self.removeBottomSubViews()
        self.removeEditSteps()
        self.hideCrossTickOnly()
    }
    
    func removeEditSteps() {
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
        if self.filterSelection == .text {
            self.magnifyingGlass.magnifiedView = nil
            self.removeGesturesMainImageViewForMagnify()
            self.mainImageView.addGestureRecognizer(self.framePanGesture)
            self.stickersText(text: .withoutTick, isText: true)
            self.stickersText(text: .hideDeleteButton, isText: true)
            self.resetFramesText()
        } else if self.filterSelection == .sticker || self.filterSelection == .gallery {
            self.magnifyingGlass.magnifiedView = nil
            self.removeGesturesMainImageViewForMagnify()
            self.mainImageView.addGestureRecognizer(self.framePanGesture)
            self.stickersText(text: .withoutTick, isText: false)
            self.stickersText(text: .hideDeleteButton, isText: false)
            self.resetFramesStickers()
        } else if self.filterSelection == .frame {
            self.option.isFramesSelected = false
            self.option.isFrames = false
            self.resetFrames()
        } else if self.filterSelection == .brush {
            self.magnifyingGlass.magnifiedView = nil
            self.removeGesturesMainImageViewForMagnify()
            self.mainImageView.addGestureRecognizer(self.framePanGesture)
            //self.resetColor()
            self.resetBrush()
        } else if self.filterSelection == .filter {
            self.resetFilter()
        }  else if self.filterSelection == .adjust {
            self.resetAdjust()
        }


        self.resetImageView()
        self.filterSelection = FilterSelection(rawValue: -1)
        self.stickerTextView.isUserInteractionEnabled = true
        self.mainCollectionView.reloadData()
    }
    
    func unsavedOptions() {
        self.removeBottomSubViews()
        self.removeEditSteps()
        self.hideCrossTickOnly()
        self.viewPaintDrawing.isUserInteractionEnabled = false
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
        if self.filterSelection == .text, !self.option.isText {
            self.magnifyingGlass.magnifiedView = nil
            self.removeGesturesMainImageViewForMagnify()
            self.mainImageView.addGestureRecognizer(self.framePanGesture)
            self.stickersText(text: .withoutTick, isText: true)
            self.stickersText(text: .hideDeleteButton, isText: true)
            self.resetFramesText()
        } else if self.filterSelection == .sticker || self.filterSelection == .gallery, !self.option.isSticker {
            self.stickersText(text: .withoutTick, isText: false)
            self.stickersText(text: .hideDeleteButton, isText: false)
            self.resetFramesStickers()
        } else if self.filterSelection == .frame {
            self.option.isFrames = false
            self.resetFrames()
        } else if self.filterSelection == .brush {
            self.magnifyingGlass.magnifiedView = nil
            self.removeGesturesMainImageViewForMagnify()
            self.mainImageView.addGestureRecognizer(self.framePanGesture)
            self.resetColor()
            self.resetBrush()
        }
        self.resetImageView()
    }
    
//    func showSaveToGalleryDialog() {
//        let alert = PNAlertController.alertControllerWith(title: "Save as new photo?".localisedString(), message: "If you do not save you will lose to any new edits you have applied.".localisedString())
//        alert.crossButtonEnabled = true
//        
//        let saveToGalleryAction = PNAlertAction(title: "Save to gallery".localisedString(), type: .bold) { _, _ in
//            let notificationName_saveImageToGallery = NSNotification.Name(rawValue: "photoEditViewController.saveImageToGallery")
//            self.captureEditImage()
//            NotificationCenter.default.post(name: notificationName_saveImageToGallery, object: self.finalImage, userInfo: nil)
//            
//            if self.isFromPhotoBooth {
//                self.navigationController?.popViewController(animated: true)
//
//            } else {
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
//        alert.addAction(saveToGalleryAction)
//        
//        let doNotSaveAction = PNAlertAction(title: "Do not save".localisedString(), type: .borderd) { _, _ in
//            if self.isFromPhotoBooth {
//                self.navigationController?.popViewController(animated: true)
//            } else {
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
//        alert.addAction(doNotSaveAction)
//        alert.presentFrom(self, completion: nil)
//    }
    
    func hasChanges() -> Bool {
        if isAuto() || isRedEye() || isTransform() || self.isText() || isOverlay() || self.isStickerAvailable() || isFilter() || isFrame() || self.option.isAdjust || self.option.isBrush || self.isImageAlreadyEdited || self.isFromPhotoBooth {
            return true
        } else {
            return false
        }
    }
    
    func captureEditImage() {
        let image = getFinalImage()
        finalImage = image
        UIImageWriteToSavedPhotosAlbum(finalImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)

    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Ok", style: .destructive) { (_) -> Void in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            ac.addAction(settingsAction)
            present(ac, animated: true)
        }
    }
    
    func showSaveToGalleryDialog() {
        let alert = PNAlertController.alertControllerWith(title: "Save as new photo?".localisedString(), message: "If you do not save you will lose to any new edits you have applied.".localisedString())
        alert.crossButtonEnabled = true

        let saveToGalleryAction = PNAlertAction(title: "Save to gallery".localisedString(), type: .bold) { _, _ in
            let notificationName_saveImageToGallery = NSNotification.Name(rawValue: "photoEditViewController.saveImageToGallery")
            let image = self.getFinalImage()
            self.finalImage = image
            UIImageWriteToSavedPhotosAlbum(self.finalImage, self, nil, nil)
            NotificationCenter.default.post(name: notificationName_saveImageToGallery, object: self.finalImage, userInfo: nil)

            if self.isFromPhotoBooth {
                self.navigationController?.popViewController(animated: true)

            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alert.addAction(saveToGalleryAction)

        let doNotSaveAction = PNAlertAction(title: "Do not save".localisedString(), type: .borderd) { _, _ in
            if self.isFromPhotoBooth {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alert.addAction(doNotSaveAction)
        alert.presentFrom(self, completion: nil)
    }

    func getStickerTextImage() -> UIImage {
        let scale = 1.0
        let stickerTextView = stickerTextView.takeScreenshotHD()
        
        let tempStickerTextView = UIImageView(frame: CGRect(x: mainImageView.frame.origin.x * scale, y: mainImageView.frame.origin.y * scale, width: mainImageView.frame.size.width * scale, height: mainImageView.frame.size.height * scale))
        tempStickerTextView.image = stickerTextView
        
        let tempScrollViewContainer = UIView(frame: CGRect(x: scrollViewContainer.frame.origin.x * scale, y: scrollViewContainer.frame.origin.y * scale, width: scrollViewContainer.frame.size.width * scale, height: scrollViewContainer.frame.size.height * scale))
        
        let tempScrollView = UIScrollView(frame: CGRect(x: scrollView.frame.origin.x * scale, y: scrollView.frame.origin.y * scale, width: scrollView.frame.size.width * scale, height: scrollView.frame.size.height * scale))
        
        tempScrollView.transform = CGAffineTransform(rotationAngle: self.totalAngle)
        tempScrollView.bounds = CGRect(x: 0, y: 0, width: scrollView.bounds.width * scale, height: scrollView.bounds.height * scale)
        tempScrollView.maximumZoomScale = scrollView.zoomScale
        tempScrollView.minimumZoomScale = scrollView.zoomScale
        tempScrollView.contentOffset = CGPointMake(scrollView.contentOffset.x * scale, scrollView.contentOffset.y * scale)
        tempScrollView.zoomScale = scrollView.zoomScale
        
        tempScrollView.addSubview(tempStickerTextView)
        
        tempScrollViewContainer.addSubview(tempScrollView)
        
        let image = tempScrollViewContainer.takeScreenshotHD()!
        let newfinalImage = self.capture(image: image, cropBoxFrame: CGRectMake(overlay.cropBox.frame.origin.x * scale, overlay.cropBox.frame.origin.y * scale, overlay.cropBox.frame.size.width * scale, overlay.cropBox.frame.size.height * scale))!
        
        return  newfinalImage
    }
    
    func getMainImage() -> UIImage {
        let scale = 1.0
        
        let tempStickerTextView = UIImageView(frame: CGRect(x: mainImageView.frame.origin.x * scale, y: mainImageView.frame.origin.y * scale, width: mainImageView.frame.size.width * scale, height: mainImageView.frame.size.height * scale))
        tempStickerTextView.image = self.mainImageView.image
        
        let tempScrollViewContainer = UIView(frame: CGRect(x: scrollViewContainer.frame.origin.x * scale, y: scrollViewContainer.frame.origin.y * scale, width: scrollViewContainer.frame.size.width * scale, height: scrollViewContainer.frame.size.height * scale))
        
        let tempScrollView = UIScrollView(frame: CGRect(x: scrollView.frame.origin.x * scale, y: scrollView.frame.origin.y * scale, width: scrollView.frame.size.width * scale, height: scrollView.frame.size.height * scale))
        
        tempScrollView.transform = CGAffineTransform(rotationAngle: self.totalAngle)
        tempScrollView.bounds = CGRect(x: 0, y: 0, width: scrollView.bounds.width * scale, height: scrollView.bounds.height * scale)
        tempScrollView.maximumZoomScale = scrollView.zoomScale
        tempScrollView.minimumZoomScale = scrollView.zoomScale
        tempScrollView.contentOffset = CGPointMake(scrollView.contentOffset.x * scale, scrollView.contentOffset.y * scale)
        tempScrollView.zoomScale = scrollView.zoomScale
        
        tempScrollView.addSubview(tempStickerTextView)
        
        tempScrollViewContainer.addSubview(tempScrollView)
        
        let image = tempScrollViewContainer.takeScreenshotHD()!
        let newfinalImage = self.capture(image: image, cropBoxFrame: CGRectMake(overlay.cropBox.frame.origin.x * scale, overlay.cropBox.frame.origin.y * scale, overlay.cropBox.frame.size.width * scale, overlay.cropBox.frame.size.height * scale))!
        
        return  newfinalImage
    }
    
    func getFinalImage() -> UIImage {
        let scale = 3.0
        let tempScrollViewContainer = UIView(frame: CGRect(x: scrollViewContainer.frame.origin.x * scale, y: scrollViewContainer.frame.origin.y * scale, width: scrollViewContainer.frame.size.width * scale, height: scrollViewContainer.frame.size.height * scale))
        
        let tempScrollView = UIScrollView(frame: CGRect(x: scrollView.frame.origin.x * scale, y: scrollView.frame.origin.y * scale, width: scrollView.frame.size.width * scale, height: scrollView.frame.size.height * scale))
        
        tempScrollView.transform = CGAffineTransform(rotationAngle: self.totalAngle)
        tempScrollView.bounds = CGRect(x: 0, y: 0, width: scrollView.bounds.width * scale, height: scrollView.bounds.height * scale)
        tempScrollView.maximumZoomScale = scrollView.zoomScale
        tempScrollView.minimumZoomScale = scrollView.zoomScale
        tempScrollView.contentOffset = CGPointMake(scrollView.contentOffset.x * scale, scrollView.contentOffset.y * scale)
        tempScrollView.zoomScale = scrollView.zoomScale
        
        let screenshortViewPaintDrawing = mainImageView.takeScreenshotHD()
        
        let tempmainImageView = UIImageView(frame: CGRect(x: mainImageView.frame.origin.x * scale, y: mainImageView.frame.origin.y * scale, width: mainImageView.frame.size.width * scale, height: mainImageView.frame.size.height * scale))
        tempmainImageView.image = screenshortViewPaintDrawing
        
        
        let imageViewFramesImageView = UIImageView(frame: CGRect(x: framesImageViewAngleRatio.frame.origin.x * scale, y: framesImageViewAngleRatio.frame.origin.y * scale, width: framesImageViewAngleRatio.frame.size.width * scale, height: framesImageViewAngleRatio.frame.size.height * scale))
        let frameImage = framesImageViewAngleRatio.image
        var newImage = frameImage
        if isFlippedSelected || isMirroredSelected {
                if selectedFrame as! String != "none" {
                    //imageViewFramesImageView.transform = self.scrollViewContainer.transform
                    newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: UIImage.Orientation(rawValue: (frameImage?.imageOrientation)!.rawValue) ?? .up)
                }
        }
        print("straightenAngle-------",straightenAngle)
        if isRotationImage == false && straightenAngle == 0.0 {
            imageViewFramesImageView.transform = CGAffineTransform(rotationAngle: self.rotationAngle)
            imageViewFramesImageView.bounds = CGRect(x: 0, y: 0, width: scrollView.bounds.width * scale, height: scrollView.bounds.height * scale)
            
        }
        
        if isRotationImage == true {
                if selectedFrame as! String != "none" {
                    if rotationAngle == 1.5707963267948966 {
                        if isFlippedSelected && isMirroredSelected {
                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .right)
                        } else if isFlippedSelected {
                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .right) //leftmirrored
                        } else if isMirroredSelected {
                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .right)
                        } else {
                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .right)
                        }
                    } else if rotationAngle == 3.141592653589793 {
                        if isFlippedSelected && isMirroredSelected {
                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .down)
                        } else if isFlippedSelected {
                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .down) //leftmirrored
                        } else if isMirroredSelected {
                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .down)
                        } else {
                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .down)
                        }
                    } else if rotationAngle == 4.71238898038469 {
                        if isFlippedSelected && isMirroredSelected {
                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .left)
                        } else if isFlippedSelected {
                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .left) //leftmirrored
                        } else if isMirroredSelected {
                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .left)
                        } else {
                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .left)
                        }
                    }
                }
        }
        //        if rotationAngle == 1.5707963267948966 {
        //            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .up)
        //        } else if rotationAngle == 3.141592653589793 {
        //            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .left)
        //        } else if rotationAngle == 4.71238898038469 {
        //            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .down)
        //        }
        imageViewFramesImageView.alpha = framesImageViewAngleRatio.alpha
        imageViewFramesImageView.image = newImage
        
        
        tempScrollView.addSubview(tempmainImageView)
        tempScrollViewContainer.addSubview(tempScrollView)
        tempScrollViewContainer.addSubview(imageViewFramesImageView)
        
        let image = tempScrollViewContainer.takeScreenshotHD()!
        
        
        let newfinalImage = self.capture(image: image, cropBoxFrame: CGRectMake(overlay.cropBox.frame.origin.x * scale, overlay.cropBox.frame.origin.y * scale, overlay.cropBox.frame.size.width * scale, overlay.cropBox.frame.size.height * scale))!
        
        let finalView = UIView(frame: CGRect(x: overlay.cropBox.frame.origin.x * scale, y: overlay.cropBox.frame.origin.y * scale, width: overlay.cropBox.frame.size.width * scale, height: overlay.cropBox.frame.size.height * scale))
        
        
        let finalImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: overlay.cropBox.frame.size.width * scale, height: overlay.cropBox.frame.size.height * scale))
        finalImageView.image = newfinalImage

        finalImageView.transform = self.scrollViewContainer.transform
        
        finalView.addSubview(finalImageView)
        
        
        let finale = finalView.takeScreenshotHD()!
        
        return  finale
    }
    
//    func moveToPnPreviewController(finalImage: UIImage) {
//        let image = finalImage
//        var canvasResult: UIImage
//
//        if GlobalHelper.sharedManager.selectedRatioWith < 2.0 {
//            canvasResult = CanvasRatioManager.shared.newGetImageAccordingPrintRatio(image: image, ratio: GlobalHelper.sharedManager.selectedRatioWith)
//        } else {
//            canvasResult = CanvasRatioManager.shared.getImageAccordingPrintRatio(image: image, ratio: GlobalHelper.sharedManager.selectedRatioWith)
//        }
//
//        GlobalHelper.sharedManager.isLandcape = false
//        if image.size.width > image.size.height {
//            GlobalHelper.sharedManager.isLandcape = true
//        }
//
//        let cMedia = HPPRCameraRollMedia()
//        cMedia.placeholderImage = canvasResult
//        cMedia.createdTime = Date()
//        cMedia.mediaType = .image
//        cMedia.videoPlaybackUri = nil
//        PGPhotoSelection.sharedInstance().select(cMedia)
//        GlobalHelper.sharedManager.fromPhotobooth = true
//
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
//        controller.isImageAlreadyEdited = self.hasChanges()
//        self.navigationController?.pushViewController(controller, animated: true)
//       // GlobalHelper.sharedManager.navigationController.pushViewController(controller, animated: true)
//    }
}

extension CAEditViewController {
//    @objc func printPreviewButtonAction() {
//        if let activePrinter = PGQueuePrinter.active() {
//            let activePritnerInfo = PGQueuePrinterInfo.init(printer: activePrinter)
//            if activePritnerInfo.connecting {
//                CopilotBridgingHelper.sharedManager.tapPrintEvent_editor("printer_status_connecting")
//            } else if activePritnerInfo.connected {
//                CopilotBridgingHelper.sharedManager.tapPrintEvent_editor("printer_status_connected")
//            } else {
//                CopilotBridgingHelper.sharedManager.tapPrintEvent_editor("printer_status_disconnected")
//            }
//        }
//        
//        if isBlankCanvasRuler {
//            if self.hasChanges() {
//                if UserDefaults.standard.integer(forKey: self.doNotShowGoToPrintDialogCount) >= 20 {
//                    UserDefaults.standard.set(false, forKey: self.doNotShowGoToPrintDialog)
//                    UserDefaults.standard.set(0, forKey: self.doNotShowGoToPrintDialogCount)
//                }
//                if UserDefaults.standard.bool(forKey: self.doNotShowGoToPrintDialog) == true {
//                    self.goToPrintPreview()
//                } else {
//                    self.showGoToPrintDialog()
//                }
//            } else {
//                self.showPrintBlankSheetDialog()
//            }
//        } else {
//            if UserDefaults.standard.integer(forKey: self.doNotShowGoToPrintDialogCount) >= 20 {
//                UserDefaults.standard.set(false, forKey: self.doNotShowGoToPrintDialog)
//                UserDefaults.standard.set(0, forKey: self.doNotShowGoToPrintDialogCount)
//            }
//            if UserDefaults.standard.bool(forKey: self.doNotShowGoToPrintDialog) == true {
//                self.goToPrintPreview()
//            } else {
//                self.showGoToPrintDialog()
//            }
//        }
//    }
    
//    func showPrintBlankSheetDialog() {
//        let alert = PNAlertController.alertControllerWith(title: "Print a blank sheet?".localisedString(), message: "Are you sure you want to print a blank sheet? You may want to first add photos or other elements.".localisedString())
//        
//        let doNotPrintAction = PNAlertAction(title: "Don’t print yet".localisedString(), type: .bold) { _, _ in
//            CopilotBridgingHelper.sharedManager.tapDontPrintYetEvent_editor()
//        }
//        alert.addAction(doNotPrintAction)
//        
//        let printBlankSheetAction = PNAlertAction(title: "Print blank sheet".localisedString(), type: .borderd) { _, _ in
//            CopilotBridgingHelper.sharedManager.tapPrintBlankSheetEvent_editor()
//            self.goToPrintPreview()
//        }
//        alert.addAction(printBlankSheetAction)
//        
//        alert.presentFrom(self, completion: nil)
//    }
    
//    func goToPrintPreview() {
//        print(self.isImageEdited)
//        print(self.selectedRatioWith)
//        GlobalHelper.sharedManager.isEditComplete = false//true
//        GlobalHelper.sharedManager.hadChanges = self.hasChanges()
//        GlobalHelper.sharedManager.finalEditImage = finalImage
//        GlobalHelper.sharedManager.selectedRatioWith = self.selectedRatioWith
//        self.updateGoToPrintAlertCount()
//        dismissToGallery()
//    }
    
    func getSnapshotImage(inView: UIView, cropView: UIScrollView) -> UIImage? {
        self.backgroundView.setNeedsDisplay()
        self.backgroundView.layoutIfNeeded()
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(cropView.bounds.size.width,cropView.bounds.size.height), false, 0)
        inView.drawHierarchy(in: cropView.frame, afterScreenUpdates: true)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return snapshotImage
    }
    
//    func showGoToPrintDialog() {
//        
//        let attrStr = NSMutableAttributedString(attributedString: NSAttributedString(string: ""))
//        
//        var tempAttrStr = NSAttributedString(string: "Your edits ".localisedString(), attributes: [ // Aman
//            NSAttributedString.Key.foregroundColor : UIColor.messageColor,
//            NSAttributedString.Key.font : PNAlertController.messageFont!
//        ])
//        attrStr.append(tempAttrStr)
//        
//        tempAttrStr = NSAttributedString(string: "cannot".localisedString(), attributes: [ //Aman
//            NSAttributedString.Key.foregroundColor : UIColor.messageColor,
//            NSAttributedString.Key.font : PNAlertController.messageFont!,
//            NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue
//        ])
//        attrStr.append(tempAttrStr)
//        
//        tempAttrStr = NSAttributedString(string: " be changed afterwards!".localisedString(), attributes: [ //Aman
//            NSAttributedString.Key.foregroundColor : UIColor.messageColor,
//            NSAttributedString.Key.font : PNAlertController.messageFont!
//        ])
//        attrStr.append(tempAttrStr)
//        
//        tempAttrStr = NSAttributedString(string: "\n\n", attributes: [
//            NSAttributedString.Key.font : PNAlertController.messageFont!
//        ])
//        attrStr.append(tempAttrStr)
//        
//        tempAttrStr = NSAttributedString(string: "Note: When you print, your work will be saved to gallery as a new image.".localisedString(), attributes: [
//            NSAttributedString.Key.foregroundColor : UIColor.messageColor,
//            NSAttributedString.Key.font : PNAlertController.messageFonLightt!
//        ])
//        attrStr.append(tempAttrStr)
//        
//        
//        let alert = PNAlertController.alertControllerWith(title: "Go to Print?".localisedString(), attributedMessage: attrStr, actionButtonsAxis: .horizontal)
//        alert.crossButtonEnabled = true
//        
//        let cancelAction = PNAlertAction(title: "Cancel".localisedString(), type: .borderd) { _, _ in
//            // Discard changes here.
//            //self.dismiss(animated: true)
//            CopilotBridgingHelper.sharedManager.tapGoToPrintCancelEvent_editor()
//        }
//        alert.addAction(cancelAction)
//        
//        let okAction = PNAlertAction(title: "OK".localisedString(), type: .bold) { _, _ in
//            CopilotBridgingHelper.sharedManager.tapGoToPrintOkEvent_editor()
//            self.goToPrintPreview()
//            self.updateGoToPrintAlertCount()
//        }
//        alert.addAction(okAction)
//        
//        let doNotShowAction = PNAlertAction(title: "Don’t show every time".localisedString(), type: .checkmark) { _, isChecked in
//            CopilotBridgingHelper.sharedManager.tapGoToPrintCheckboxEvent_editor()
//            UserDefaults.standard.set(isChecked, forKey: self.doNotShowGoToPrintDialog)
//        }
//        doNotShowAction.shouldDismissAlertWithAction = false
//        alert.addAction(doNotShowAction)
//        
//        alert.presentFrom(self, completion: nil)
//    }
    
//    func dismissToGallery() {
//        templateCount = 0
//        isTemplateApplied = false
//        
//        self.moveToPnPreviewController(finalImage: finalImage)
////        if self.presentingViewController != nil {
////            self.dismiss(animated: true)
////        } else {
////            self.navigationController?.popViewController(animated: true)
////        }
//    }
    
//    func updateGoToPrintAlertCount() {
//        let count = UserDefaults.standard.integer(forKey: self.doNotShowGoToPrintDialogCount)
//        if UserDefaults.standard.integer(forKey: self.doNotShowGoToPrintDialogCount) >= 20 {
//            UserDefaults.standard.set(0, forKey: self.doNotShowGoToPrintDialogCount)
//        } else {
//            self.navigationController?.popViewController(animated: true)
//        }
//    }
    
    func getTransformImage() -> UIImage {
        let scale = 1.0
        let tempScrollViewContainer = UIView(frame: CGRect(x: scrollViewContainer.frame.origin.x * scale, y: scrollViewContainer.frame.origin.y * scale, width: scrollViewContainer.frame.size.width * scale, height: scrollViewContainer.frame.size.height * scale))
        
        let tempScrollView = UIScrollView(frame: CGRect(x: scrollView.frame.origin.x * scale, y: scrollView.frame.origin.y * scale, width: scrollView.frame.size.width * scale, height: scrollView.frame.size.height * scale))
        
        tempScrollView.transform = CGAffineTransform(rotationAngle: self.totalAngle)
        tempScrollView.bounds = CGRect(x: 0, y: 0, width: scrollView.bounds.width * scale, height: scrollView.bounds.height * scale)
        tempScrollView.maximumZoomScale = scrollView.zoomScale
        tempScrollView.minimumZoomScale = scrollView.zoomScale
        tempScrollView.contentOffset = CGPointMake(scrollView.contentOffset.x * scale, scrollView.contentOffset.y * scale)
        tempScrollView.zoomScale = scrollView.zoomScale
        
        let screenshortViewPaintDrawing = mainImageView.takeScreenshotHD()
        
        let tempmainImageView = UIImageView(frame: CGRect(x: mainImageView.frame.origin.x * scale, y: mainImageView.frame.origin.y * scale, width: mainImageView.frame.size.width * scale, height: mainImageView.frame.size.height * scale))
        tempmainImageView.image = screenshortViewPaintDrawing

        tempScrollView.addSubview(tempmainImageView)
        tempScrollViewContainer.addSubview(tempScrollView)
        
        let image = tempScrollViewContainer.takeScreenshotHD()!
        let newfinalImage = self.capture(image: image, cropBoxFrame: CGRectMake(overlay.cropBox.frame.origin.x * scale, overlay.cropBox.frame.origin.y * scale, overlay.cropBox.frame.size.width * scale, overlay.cropBox.frame.size.height * scale))!
        
        return  newfinalImage
    }
}

extension UIView {
    func scaleSubviews(withScaleFactor scaleFactor: CGFloat) {
        print(self.subviews.count)
        for subview in self.subviews {
            subview.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            if let scrollView = subview as? UIScrollView {
                scrollView.contentSize = CGSize(width: scrollView.contentSize.width * scaleFactor, height: scrollView.contentSize.height * scaleFactor)
            } else {
                subview.scaleSubviews(withScaleFactor: scaleFactor)
            }
        }
    }
}
@objc extension UIView {
//
////    func scale(by scale: CGFloat) {
////        self.contentScaleFactor = scale
////        for subview in self.subviews {
////            subview.scale(by: scale)
////        }
////    }
//
//    @objc func takeScreenshot() -> UIImage {
//        let newScale = UIScreen.main.scale
//        self.scale(by: newScale)
//        let format = UIGraphicsImageRendererFormat()
//        format.scale = newScale
//
//        let renderer = UIGraphicsImageRenderer(size:self.bounds.size, format: format)
//        let image = renderer.image { rendererContext in
//            self.layer.render(in: rendererContext.cgContext)
//        }
//        return image
//    }
//
    
    func takeScreenshotHD() -> UIImage? {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            let screenshot = renderer.image { context in
                layer.render(in: context.cgContext)
            }
            return screenshot
        }
 
}
