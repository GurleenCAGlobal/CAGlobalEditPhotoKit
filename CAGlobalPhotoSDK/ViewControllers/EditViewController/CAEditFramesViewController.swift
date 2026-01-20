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

    
//    func selectedFramesImage(image: String, isEdit:Bool) {
//
//        if let defaultCropperState = self.initialState {
//            self.restoreState(defaultCropperState)
//        }
//        self.backgroundView.transform = .identity
//        var frameImage = UIImage()
//        frameImage = UIImage.init(named: image) ?? UIImage()
//        var newImage = frameImage
//
//        _ = atan2(framesImageViewAngleRatio.transform.b, framesImageViewAngleRatio.transform.a)
//        if image != "none" {
//            if isFlippedSelected && isMirroredSelected {
//                newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .down)
//            } else if isFlippedSelected {
//                newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .upMirrored)
//            } else if isMirroredSelected {
//                newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .downMirrored)
//            } else {
//                if image != "none" {
//                    if rotationAngle == 1.5707963267948966 {
//                        newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .left)
//                    } else if rotationAngle == 3.141592653589793 {
//                        newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .down)
//                    } else if rotationAngle == 4.71238898038469 {
//                        newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .right)
//                    }
//                }
//            }
//        }
//
//        if image != "none" {
//            if rotationAngle == 1.5707963267948966 {
//                if isFlippedSelected && isMirroredSelected {
//                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .right)
//                } else if isFlippedSelected {
//                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .leftMirrored) //leftmirrored
//                } else if isMirroredSelected {
//                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .rightMirrored)
//                } else {
//                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .left)
//                }
//            } else if rotationAngle == 3.141592653589793 {
//                if isFlippedSelected && isMirroredSelected {
//                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .up)
//                } else if isFlippedSelected {
//                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .downMirrored) //leftmirrored
//                } else if isMirroredSelected {
//                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .upMirrored)
//                } else {
//                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .down)
//                }
//            } else if rotationAngle == 4.71238898038469 {
//                if isFlippedSelected && isMirroredSelected {
//                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .left)
//                } else if isFlippedSelected {
//                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .rightMirrored) //leftmirrored
//                } else if isMirroredSelected {
//                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .leftMirrored)
//                } else {
//                    newImage = UIImage(cgImage: (frameImage.cgImage)!, scale: frameImage.scale, orientation: .right)
//                }
//            }
//        }
//
//        self.framesImageView.isHidden = true
//        self.framesImageViewAngleRatio.isHidden = false
//        isCategoryFrame = false
//        self.saveCrossSubOptionsView.showView()
//        selectedFrame = image
//
//        if image != "none" {
//            self.framesImageView.image = newImage
//            self.framesImageViewAngleRatio.image = newImage
//
//        } else {
//            self.framesImageViewAngleRatio.image = nil
//            self.framesImageView.image = nil
//        }
//    }
    
    func selectedFramesImage(image: String, isEdit: Bool) {
        if let defaultCropperState = self.initialState {
            self.restoreState(defaultCropperState)
        }

        self.backgroundView.transform = .identity
        
        var frameImage2 = UIImage()
        let bundlePath = Bundle(for: EditOptionsCell.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = bundlePath != nil ? Bundle(path: bundlePath!) : nil
        if let fileURL = URL(string: image) {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                if let image2 = UIImage(contentsOfFile: fileURL.path) {
                    frameImage2 = image2
                } else {
                    print("Failed to load image.")
                }
            } else {
                print("File does not exist at path: \(fileURL.path)")
            }
        }
        
        guard image != "none" else {
            self.selectedFrame = "none"
            self.framesImageView.image = nil
            self.framesImageViewAngleRatio.image = nil
            return
        }

        var orientation: UIImage.Orientation = .up

        switch rotationAngle {
        case .pi / 2: // 90°
            if isFlippedSelected && isMirroredSelected {
                orientation = .right
            } else if isFlippedSelected {
                orientation = .leftMirrored
            } else if isMirroredSelected {
                orientation = .rightMirrored
            } else {
                isRotateWithCorrectFrame = true
                orientation = .left
            }
        case .pi: // 180°
            if isFlippedSelected && isMirroredSelected {
                orientation = .up
            } else if isFlippedSelected {
                orientation = .downMirrored
            } else if isMirroredSelected {
                orientation = .upMirrored
            } else {
                isRotateWithCorrectFrame = true
                orientation = .down
            }
        case 3 * .pi / 2: // 270°
            if isFlippedSelected && isMirroredSelected {
                orientation = .left
            } else if isFlippedSelected {
                orientation = .rightMirrored
            } else if isMirroredSelected {
                orientation = .leftMirrored
            } else {
                isRotateWithCorrectFrame = true
                orientation = .right
            }
        default:
            if isFlippedSelected && isMirroredSelected {
                orientation = .down
            } else if isFlippedSelected {
                orientation = .upMirrored
            } else if isMirroredSelected {
                orientation = .downMirrored
            } else {
                isRotateWithCorrectFrame = true
                orientation = .up
            }
        }

        
        
        let newImage = UIImage(cgImage: frameImage2.cgImage!, scale: frameImage2.scale, orientation: orientation)

        

        self.framesImageView.isHidden = true
        self.framesImageViewAngleRatio.isHidden = false
        self.saveCrossSubOptionsView.showView()
        self.selectedFrame = image
        self.framesImageView.image = newImage
        self.framesImageViewAngleRatio.image = newImage
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
        //newView.createFramesArray(isLandscape: (self.selectedRatioWith == 0.5) ? !self.isLandscape:!self.isLandscape , selectedRatio: self.selectedRatioWith, isEdit: isEdit)

        newView.createFramesArray()
        self.bottomView.addSubview(newView)
        self.bottomView.isHidden = false
        self.setupAutoLayoutForBottomView(newView: newView, bottomView: self.bottomView)
        self.constraintsBottomViewHeight.constant = 88
        currentFrameView = newView
    }
    
    func setUpFrameView(isEdit : Bool = false) {
        self.stickerTextView.isUserInteractionEnabled = false
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

        let previousOpacity = CGFloat(self.stickerOption.opacitySlider.value)
        
        self.stickerOption.updatingColor(views: [view])
        // Register undo action
        undoRedoManager.registerUndo(withTarget: self) { target in
            target.changeStickerOpacity(view: self.selectedAddSticker!, opacity: previousOpacity)
        }
        undoRedoManager.setActionName("Change Opacity")
        isEnableRedoUndo()
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
    
    /*
     {
         let filter = self.option.appliedFilterDetails.last
         // Store current state before changes for undo
         let previousFilter = filter?.filterName
         let previousOpacity = filter?.opacityValue

         // Register Undo Operation
         undoRedoManager.registerUndo(withTarget: self) { target in
             target.selectedFilter = previousFilter ?? ""
             target.selectedFilterOpacity = previousOpacity ?? 1.0
             target.applyFilter() // Optional if you want to re-trigger UI changes
             self.selectedFilter = previousFilter ?? ""
             self.mainImageView.image = self.applyingAllFilters(false, true, false)
         }

         // Apply the new filter logic
         if self.selectedFilter == "" {
             self.option.isFilter = false
         } else {
             self.option.isFilter = true
         }

         self.option.appliedFilterDetails.append((filterName: self.selectedFilter, opacityValue: self.selectedFilterOpacity))
         
         undoRedoManager.setActionName("Filter")
         self.isEnableRedoUndo()

     }
     **/
    func applyFrames(isUndoRedo : Bool = true) {
        if isUndoRedo {
            let frame = self.option.appliedFramesDetails.last
            // Store current state before changes for undo
            let previousFramesName = frame?.framesName ?? "none"
            let previousOpacity = frame?.opacityValue ?? 1.0
            let previousImageOrientation = frame?.imageOrientation ?? UIImage.Orientation.up
            
            // Register Undo Operation
            undoRedoManager.registerUndo(withTarget: self) { target in
                target.selectedFrame = previousFramesName as? String ?? "none"
                target.selectedFrameOpacity = previousOpacity
                target.applyFrames() // Optional if you want to re-trigger UI changes
                self.selectedFrame = previousFramesName as? String ?? ""
                self.selectedFrameOpacity = previousOpacity
                
                if previousFramesName as! String != "none", let frameImage = UIImage(named: previousFramesName as! String) {
                    let orientation: UIImage.Orientation = .up
                    let newImage = UIImage(cgImage: frameImage.cgImage!, scale: frameImage.scale, orientation: previousImageOrientation)
                    self.framesImageViewAngleRatio.image = newImage
                    self.framesImageViewAngleRatio.alpha = previousOpacity
                    self.globalUndoRedo(currentFilterSelection: .filter)
                    self.removeBottomSubViews()
                    self.setUpFrameView()

                } else {
                    self.framesImageViewAngleRatio.image = nil
                    self.framesImageViewAngleRatio.alpha = 1
                    self.globalUndoRedo(currentFilterSelection: .none)
                    self.removeBottomSubViews()

                }

            }
            
            undoRedoManager.setActionName("Frame")
            self.isEnableRedoUndo()
        }
        
        self.option.appliedFramesDetails.append((framesName: selectedFrame, opacityValue: selectedFrameOpacity, imageOrientation: self.framesImageViewAngleRatio.image?.imageOrientation, isRotate_new: self.isRotateWithCorrectFrame, isAspect: true) as! (framesName: Any, opacityValue: CGFloat, imageOrientation: UIImage.Orientation?, isRotate_new: Bool, isAspect: Bool))
    }

    
//    func resetFramesOnCross() {
//        self.framesImageViewAngleRatio.image = nil
//        if self.option.appliedFramesDetails.count > 0 {
//            for framesDetail in self.option.appliedFramesDetails {
//                self.selectedFrameOpacity = framesDetail.opacityValue
//                if let frame = framesDetail.framesName as? String {
//                    selectedFrame = frame
//                    if frame  != "none" {
//                        let frameImage = UIImage.init(named: frame)
//                        var newImage = frameImage
//
////                        switch framesDetail.imageOrientation {
////                        case .up:
////                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .up)
////                        case .down:
////                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .down)
////                        case .left:
////                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .left)
////                        case .right:
////                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .right)
////                        default:
////                            print("Image has a mirrored orientation or an unknown orientation")
////                        }
//                        if rotationAngle == 1.5707963267948966 {
//                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .up)
//                        } else if rotationAngle == 3.141592653589793 {
//                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .upMirrored)
//                        } else if rotationAngle == 4.71238898038469 {
//                            newImage = UIImage(cgImage: (frameImage?.cgImage)!, scale: frameImage?.scale ?? 1, orientation: .downMirrored)
//                        }
//                        self.framesImageViewAngleRatio.image = newImage
//                        self.framesImageViewAngleRatio.alpha = framesDetail.opacityValue
//
//                    } else {
//                        self.framesImageViewAngleRatio.image = nil
//                        self.framesImageViewAngleRatio.alpha = 1
//                    }
//
//                } else if let image = framesDetail.framesName as? UIImage {
//                    //selectedFrame = image
//
//                    var newImage = image
//
//                    _ = atan2(framesImageViewAngleRatio.transform.b, framesImageViewAngleRatio.transform.a)
//                        if rotationAngle == 1.5707963267948966 {
//                            newImage = UIImage(cgImage: (image.cgImage)!, scale: image.scale, orientation: .left)
//                        } else if rotationAngle == 3.141592653589793 {
//                            newImage = UIImage(cgImage: (image.cgImage)!, scale: image.scale, orientation: .down)
//                        } else if rotationAngle == 4.71238898038469 {
//                            newImage = UIImage(cgImage: (image.cgImage)!, scale: image.scale, orientation: .right)
//                        }
//
//                    self.framesImageViewAngleRatio.image = newImage
//                    self.framesImageViewAngleRatio.alpha = framesDetail.opacityValue
//
//                } else {
//                    self.framesImageViewAngleRatio.image = nil
//                    self.framesImageViewAngleRatio.alpha = 1
//
//                }
//            }
//        } else {
//            self.selectedFrameOpacity = 1
//            selectedFrame = "none"
//            self.framesImageViewAngleRatio.image = nil
//            self.framesImageViewAngleRatio.alpha = 1
//
//        }
//    }
    
//    func resetFramesOnCross2() {
//        self.framesImageViewAngleRatio.image = nil
//
//        guard !self.option.appliedFramesDetails.isEmpty else {
//            // No previous frame: reset everything
//            self.selectedFrameOpacity = 1
//            self.selectedFrame = "none"
//            self.framesImageViewAngleRatio.alpha = 1
//            return
//        }
//
//        // Restore last applied frame (if multiple, takes the most recent one)
//        for framesDetail in self.option.appliedFramesDetails {
//            self.selectedFrameOpacity = framesDetail.opacityValue
//            
//            if let frameName = framesDetail.framesName as? String {
//                selectedFrame = frameName
//                
//                if frameName != "none", let frameImage = UIImage(named: frameName) {
//                    let orientation: UIImage.Orientation = .up
//                    let newImage = UIImage(cgImage: frameImage.cgImage!, scale: frameImage.scale, orientation: framesDetail.imageOrientation ?? orientation)
//                    self.framesImageViewAngleRatio.image = newImage
//                    self.framesImageViewAngleRatio.alpha = framesDetail.opacityValue
//                } else {
//                    self.framesImageViewAngleRatio.image = nil
//                    self.framesImageViewAngleRatio.alpha = 1
//                }
//                
//            } else if let frameImage = framesDetail.framesName as? UIImage {
//                let orientation: UIImage.Orientation = .up
//                let newImage = UIImage(cgImage: frameImage.cgImage!, scale: frameImage.scale, orientation: framesDetail.imageOrientation ?? orientation)
//                self.framesImageViewAngleRatio.image = newImage
//                self.framesImageViewAngleRatio.alpha = framesDetail.opacityValue
//                
//            } else {
//                self.framesImageViewAngleRatio.image = nil
//                self.framesImageViewAngleRatio.alpha = 1
//            }
//        }
//    }
    
    func resetFramesOnCross() {
        self.framesImageViewAngleRatio.image = nil
        if self.option.appliedFramesDetails.count > 0 {
            for framesDetail in self.option.appliedFramesDetails {
                self.selectedFrameOpacity = framesDetail.opacityValue
                if let frame = framesDetail.framesName as? String {
                    selectedFrame = frame
                    if frame  != "none" {
                        var frameImage = UIImage.init(named: frame)

                        if let fileURL = URL(string: frame) {
                            if FileManager.default.fileExists(atPath: fileURL.path) {
                                if let image = UIImage(contentsOfFile: fileURL.path) {
                                    frameImage = image
                                }
                            }
                        }
                        //var newImage = frameImage
                        let orientation: UIImage.Orientation = .up
                        let newImage = UIImage(cgImage: (frameImage?.cgImage!)!, scale: frameImage!.scale, orientation: framesDetail.imageOrientation ?? orientation)

                        self.framesImageViewAngleRatio.image = newImage
                        self.framesImageViewAngleRatio.alpha = framesDetail.opacityValue

                    } else {
                        self.framesImageViewAngleRatio.image = nil
                        self.framesImageViewAngleRatio.alpha = 1
                    }
                    
                } else if let frameImage = framesDetail.framesName as? UIImage {
                    
                    let orientation: UIImage.Orientation = .up
                    let newImage = UIImage(cgImage: (frameImage.cgImage!), scale: frameImage.scale, orientation: framesDetail.imageOrientation ?? orientation)

                    self.framesImageViewAngleRatio.image = newImage
                    self.framesImageViewAngleRatio.alpha = framesDetail.opacityValue
                        } else if rotationAngle == 4.71238898038469 {
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
