//
//  CAEditFramesViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 08/04/24.
//


import UIKit

// MARK: - Frames Option -

extension CAEditViewController: FramesViewDelegate, FrameOptionsDelegate, FrameViewDelegate {
    func backButtonSubCategory() {
        isCategoryFrame = true
        selectedCategoryDetail = nil
        self.filterSelection = .frame
    }
    
    func selectedFramesImage(image: String, isEdit:Bool) {
        
        if let defaultCropperState = self.initialState {
            self.restoreState(defaultCropperState)
        }
        self.backgroundView.transform = .identity
        var frameImage = UIImage()
        if let bundlePath = Bundle(for: EditOptionsCell.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle"), let bundle = Bundle(path: bundlePath) {
            frameImage = UIImage(named: image, in: bundle, compatibleWith: nil)!

        }
        var newImage = frameImage
        
        _ = atan2(framesImageViewAngleRatio.transform.b, framesImageViewAngleRatio.transform.a)
        if image != "none" {
            if isFlippedSelected && isMirroredSelected {
                newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .down)
            } else if isFlippedSelected {
                newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .upMirrored)
            } else if isMirroredSelected {
                newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .downMirrored)
            } else {
                if image != "none" {
                    if rotationAngle == 1.5707963267948966 {
                        newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .left)
                    } else if rotationAngle == 3.141592653589793 {
                        newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .down)
                    } else if rotationAngle == 4.71238898038469 {
                        newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .right)
                    }
                }
            }
        }
        
        if image != "none" {
            if rotationAngle == 1.5707963267948966 {
                if isFlippedSelected && isMirroredSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .right)
                } else if isFlippedSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .leftMirrored) //leftmirrored
                } else if isMirroredSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .rightMirrored)
                } else {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .left)
                }
            } else if rotationAngle == 3.141592653589793 {
                if isFlippedSelected && isMirroredSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .up)
                } else if isFlippedSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .downMirrored) //leftmirrored
                } else if isMirroredSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .upMirrored)
                } else {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .down)
                }
            } else if rotationAngle == 4.71238898038469 {
                if isFlippedSelected && isMirroredSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .left)
                } else if isFlippedSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .rightMirrored) //leftmirrored
                } else if isMirroredSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .leftMirrored)
                } else {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .right)
                }
            }
        }
        
        self.framesImageView.isHidden = true
        self.framesImageViewAngleRatio.isHidden = false
        isCategoryFrame = false
        self.saveCrossSubOptionsView.showView()
        selectedFrame = image
        
        if image != "none" {
            self.framesImageView.image = newImage
            self.framesImageViewAngleRatio.image = newImage
            
        } else {
            self.framesImageViewAngleRatio.image = nil
            self.framesImageView.image = nil
        }
    }
    
    func setFrames(nameString: String, sliderValue: CGFloat) {
        
    }
    
    func setUpFrameOldView(isEdit : Bool = false) {
        if framePreviousImage == nil {
            framePreviousImage = UIImage.init(named: "empty")
        }
        
        self.saveCrossView.showView()
        self.removeBottomSubViews()
        self.doneButton.isHidden = false
        let newView = FrameView()
        isCategoryFrame = true
        newView.createFramesArray(isLandscape: self.isLandscape , selectedRatio: self.selectedRatioWith, isEdit: isEdit)
        newView.isEdit = isEdit
        if selectedFrame == "none" {
            selectedFrameOpacity = 1
        }
        if isEdit == false {
            framesImageView.alpha = selectedFrameOpacity
            framesImageViewAngleRatio.alpha = selectedFrameOpacity
        }
        newView.selectedFrame = self.selectedFrame
        newView.delegate = self
        self.bottomView.addSubview(newView)
        self.bottomView.isHidden = false
        self.setupAutoLayoutForBottomView(newView: newView, bottomView: self.bottomView)
        self.constraintsBottomViewHeight.constant = 88
        currentFrameView = newView
    }
    
    func setUpFrameView(isEdit : Bool = false) {
//        self.frameTitleLabel.text = "Select Frame Category"
//        self.frameTitleLabel2.text = "Select Frame Category"
        self.option.isFramesSelected = true
        if isOldFrame == true {
            self.setUpFrameOldView(isEdit: isEdit)
            return
        } else {
            self.option.isFrames = false
            self.bottomView.isHidden = false
            self.doneButton.isHidden = false
            let newView = FramesView()
            newView.delegate = self
            newView.isEdit = isEdit
            if isEdit == false {
                framesImageView.alpha = 1
                framesImageViewAngleRatio.alpha = 1
                selectedFrameOpacity = framesImageView.alpha
            }
            self.stickerBaseView.addSubview(newView)
            newView.createFramesArray(isLandscape: self.isLandscape , selectedRatio: self.selectedRatioWith )
            self.stickerVisualEffectView.isHidden = false
            self.setupAutoLayoutForBottomView(newView: newView, bottomView: self.stickerBaseView)
        }
    }
    
    func setUpFrameOptionView(isReset: Bool) {
        self.removeBottomSubViews()
        let newView = FrameOptions()
        newView.delegate = self
        newView.setUpData(alpha: framesImageView.alpha, isReset: isReset)
        self.bottomView.addSubview(newView)
        self.bottomView.isHidden = false
        self.setupAutoLayoutForBottomView(newView: newView, bottomView: self.bottomView)
    }
    
    func selectedFramesImageApi(image: UIImage) {
        self.framesImageView.image = image
        self.framesImageViewAngleRatio.image = image
        self.setUpStickerOptionsAfterSelection(isReset: false)
    }
    
    func selectedFramesCategory(with data: String) {
    }
    
    func selectedFramesImage(image: UIImage, isEdit:Bool, noFrame: Bool) {
        if let defaultCropperState = self.initialState {
            self.restoreState(defaultCropperState)
        }
        self.backgroundView.transform = .identity
        let frameImage = image
        var newImage = frameImage
        
        _ = atan2(framesImageViewAngleRatio.transform.b, framesImageViewAngleRatio.transform.a)
        if !noFrame {
            if isFlippedSelected && isMirroredSelected {
                newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .down)
            } else if isFlippedSelected {
                newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .upMirrored)
            } else if isMirroredSelected {
                newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .downMirrored)
            } else {
                if !noFrame {
                    if rotationAngle == 1.5707963267948966 {
                        newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .left)
                    } else if rotationAngle == 3.141592653589793 {
                        newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .down)
                    } else if rotationAngle == 4.71238898038469 {
                        newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .right)
                    }
                }
            }
        }
        
        if !noFrame {
            if rotationAngle == 1.5707963267948966 {
                if isFlippedSelected && isMirroredSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .right)
                } else if isFlippedSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .leftMirrored) //leftmirrored
                } else if isMirroredSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .rightMirrored)
                } else {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .left)
                }
            } else if rotationAngle == 3.141592653589793 {
                if isFlippedSelected && isMirroredSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .up)
                } else if isFlippedSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .downMirrored) //leftmirrored
                } else if isMirroredSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .upMirrored)
                } else {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .down)
                }
            } else if rotationAngle == 4.71238898038469 {
                if isFlippedSelected && isMirroredSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .left)
                } else if isFlippedSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .rightMirrored) //leftmirrored
                } else if isMirroredSelected {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .leftMirrored)
                } else {
                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .right)
                }
            }
        }
        
        self.framesImageView.isHidden = true
        self.framesImageViewAngleRatio.isHidden = false
        //self.frameTitleLabel2.text = self.frameTitleLabel.text
        isCategoryFrame = false
        self.saveCrossSubOptionsView.showView()
        //selectedFrame = image
        
        if !noFrame {
            self.framesImageView.image = newImage
            self.framesImageViewAngleRatio.image = newImage
            
        } else {
            self.framesImageViewAngleRatio.image = nil
            self.framesImageView.image = nil
        }
    }
    
    

    
    func setUpStickerOptionsAfterSelection(isReset: Bool) {
        self.stickerVisualEffectView.isHidden = true
        self.setUpFrameOptionView(isReset: isReset)
        self.saveCrossView.showView()
        self.doneButton.isHidden = false
    }
    
    func resetFrames(_: FrameOptions) {
        self.framesImageView.image = nil
        self.framesImageViewAngleRatio.image = nil
        self.setUpStickerOptionsAfterSelection(isReset: true)
    }
    
    func opacityDidStart(_: FrameOptions, sliderValue: CGFloat) {
        selectedFrameOpacity = sliderValue
        self.framesImageView.alpha = sliderValue
        self.framesImageViewAngleRatio.alpha = sliderValue
    }
    
    func opacityClicked(isOpacity: Bool) {
        if isOpacity == true {
            self.constraintsBottomViewHeight.constant = 80
        } else {
            self.constraintsBottomViewHeight.constant = 80 + 60
        }
    }
    
    func replaceFrames(_: FrameOptions) {
        if let defaultCropperState = self.initialState {
            self.restoreState(defaultCropperState)
        }
        self.backgroundView.transform = .identity
        self.setUpFrameView(isEdit: true)
    }
    
//    func applyFrames() {
//        self.isRotationImage = false
//        if selectedFrame as? String != "none" {
//            self.option.isFrames = true
//        } else {
//            self.option.isFrames = false
//        }
//        if let frame = selectedFrame as? String {
//            self.option.appliedFramesDetails.append((framesName: frame, opacityValue: selectedFrameOpacity))
//        } else if let image = selectedFrame as? UIImage {
//            self.option.appliedFramesDetails.append((framesName: image, opacityValue: selectedFrameOpacity))
//        }
//    }
    func applyFrames() {
        if selectedFrame as? String != "none" {
            self.option.isFrames = true
        } else {
            self.option.isFrames = false
        }
        if let frame = selectedFrame as? String {
            self.option.appliedFramesDetails.append((framesName: frame, opacityValue: selectedFrameOpacity, imageOrientation: self.framesImageViewAngleRatio.image?.imageOrientation))
        } else if let image = selectedFrame as? UIImage {
            self.option.appliedFramesDetails.append((framesName: image, opacityValue: selectedFrameOpacity, imageOrientation: self.framesImageViewAngleRatio.image?.imageOrientation))
        }
    }

//    func applyFrames() {
//        self.isRotationImage = false
//        let currentFrameState = FrameModel(frame: selectedFrame, opacity: selectedFrameOpacity)
//        print("Applying frames...")
//        undoStackFrames.append(currentFrameState)
//        
//        print("Undo Stack Frames: \(undoStackFrames)")
//
//        if selectedFrame as? String != "none" {
//            self.option.isFrames = true
//        } else {
//            self.option.isFrames = false
//        }
//
//        if let frame = selectedFrame as? String {
//            self.option.appliedFramesDetails.append((framesName: frame, opacityValue: selectedFrameOpacity))
//        } else if let image = selectedFrame as? UIImage {
//            self.option.appliedFramesDetails.append((framesName: image, opacityValue: selectedFrameOpacity))
//        }
//    }
    
    func resetFrames() {
        self.framesImageViewAngleRatio.image = nil
        if self.option.appliedFramesDetails.count > 0 {
            for framesDetail in self.option.appliedFramesDetails {
                self.selectedFrameOpacity = framesDetail.opacityValue
                if let frame = framesDetail.framesName as? String {
                    selectedFrame = frame
                    if frame  != "none" {
                        let frameImage = UIImage.init(named: frame)
                        var newImage = frameImage
                        
//                        switch framesDetail.imageOrientation {
//                        case .up:
//                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .up)
//                        case .down:
//                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .down)
//                        case .left:
//                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .left)
//                        case .right:
//                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .right)
//                        default:
//                            print("Image has a mirrored orientation or an unknown orientation")
//                        }
                        if rotationAngle == 1.5707963267948966 {
                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .left)
                        } else if rotationAngle == 3.141592653589793 {
                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .down)
                        } else if rotationAngle == 4.71238898038469 {
                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .right)
                        }
                        self.framesImageViewAngleRatio.image = newImage
                        self.framesImageViewAngleRatio.alpha = framesDetail.opacityValue

                    } else {
                        self.framesImageViewAngleRatio.image = nil
                        self.framesImageViewAngleRatio.alpha = 1
                    }
                    
                } else if let image = framesDetail.framesName as? UIImage {
                    //selectedFrame = image
                    
                    var newImage = image
                    
                    _ = atan2(framesImageViewAngleRatio.transform.b, framesImageViewAngleRatio.transform.a)
                        if rotationAngle == 1.5707963267948966 {
                            newImage = UIImage(cgImage: (image.cgImage)!, scale: image.scale, orientation: .left)
                        } else if rotationAngle == 3.141592653589793 {
                            newImage = UIImage(cgImage: (image.cgImage)!, scale: image.scale, orientation: .down)
                        } else if rotationAngle == 4.71238898038469 {
                            newImage = UIImage(cgImage: (image.cgImage)!, scale: image.scale, orientation: .right)
                        }
                    
                    self.framesImageViewAngleRatio.image = newImage
                    self.framesImageViewAngleRatio.alpha = framesDetail.opacityValue
                    
                } else {
                    self.framesImageViewAngleRatio.image = nil
                    self.framesImageViewAngleRatio.alpha = 1
                    
                }
            }
        } else {
            self.selectedFrameOpacity = 1
            selectedFrame = "none"
            self.framesImageViewAngleRatio.image = nil
            self.framesImageViewAngleRatio.alpha = 1
            
        }
    }
}
