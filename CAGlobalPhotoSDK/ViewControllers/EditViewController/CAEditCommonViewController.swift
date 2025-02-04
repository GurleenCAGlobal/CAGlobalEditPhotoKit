//
//  CAEditCommonViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 21/11/23.
//

import UIKit

class CAEditCommonViewController: CAEditViewController {
}
extension CAEditViewController {
    // MARK: - Common functions and methods
    func setupAutoLayoutForBottomView(newView: UIView, bottomView: UIView) {
        self.constraintsBottomViewHeight.constant = 80
        newView.translatesAutoresizingMaskIntoConstraints = false
        let attribute = NSLayoutConstraint.Attribute.self
        let equal = NSLayoutConstraint.Relation.equal
        let top = self.constraintTop(item: newView, item2: bottomView)
        let bottom = self.constraintBottom(item: newView, item2: bottomView)
        let leading = NSLayoutConstraint(item: newView, attribute: attribute.leading, relatedBy: equal, toItem: bottomView, attribute: attribute.leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: newView, attribute: attribute.trailing, relatedBy: equal, toItem: bottomView, attribute: attribute.trailing, multiplier: 1, constant: 0)
        bottomView.addConstraints([top, bottom, leading, trailing])
    }
    

    func setupAutoLayoutForBottomMargin(newView: UIView, bottomView: UIView) {
        newView.translatesAutoresizingMaskIntoConstraints = false
        let attribute = NSLayoutConstraint.Attribute.self
        let equal = NSLayoutConstraint.Relation.equal
        let top = self.constraintTop(item: newView, item2: bottomView)
        let bottom = self.constraintBottom(item: newView, item2: bottomView, constant: 20)
        let leading = NSLayoutConstraint(item: newView, attribute: attribute.leading, relatedBy: equal, toItem: bottomView, attribute: attribute.leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: newView, attribute: attribute.trailing, relatedBy: equal, toItem: bottomView, attribute: attribute.trailing, multiplier: 1, constant: 0)
        bottomView.addConstraints([top, bottom, leading, trailing])
    }

    func constraintTop(item: UIView, item2: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        let top = NSLayoutConstraint.Attribute.top
        let equal = NSLayoutConstraint.Relation.equal
        return NSLayoutConstraint(item: item, attribute: top, relatedBy: equal, toItem: item2, attribute: top, multiplier: 1, constant: constant)
    }
     
    func constraintBottom(item: UIView, item2: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        return item.bottomAnchor.constraint(equalTo: item2.bottomAnchor, constant: constant)
    }

    func addPanGestureMainEdit() {
        self.framePanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panActionmoveImage))
        self.framePanGesture.minimumNumberOfTouches = 1
        self.framePanGesture.maximumNumberOfTouches = 1
        self.mainImageView.addGestureRecognizer(self.framePanGesture)
        self.scrollViewContainer.addGestureRecognizer(self.framePanGesture)
    }
    
    func removePanGestureMainEdit() {
        self.mainImageView.removeGestureRecognizer(self.framePanGesture)
        self.scrollViewContainer.removeGestureRecognizer(self.framePanGesture)
    }
    
    func addGesturesStickerTextView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.stickerTextView.addGestureRecognizer(tapGesture)
        
        /**
         UIRotationGestureRecognizer - Rotating Objects
         */
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(recognizer:)))
        rotate.delegate = self
        self.scrollViewContainer.addGestureRecognizer(rotate)

        /**
         UIPinchGestureRecognizer - Pinching Objects
         */
        self.addPinchRecognized()
        
        
        /**
         UITapGestureRecognizer - Double Tap Objects
         */
        
        let tapDoubleGesture = UITapGestureRecognizer(target: self,
                                                      action: #selector(handleDoubleTap(_:)))
        tapDoubleGesture.delegate = self
        tapDoubleGesture.numberOfTapsRequired = 2
        self.transformMainView.addGestureRecognizer(tapDoubleGesture)
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if !self.option.isTransformActual {
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {() -> Void in
                if let defaultCropperState = self.initialState {
                    self.restoreState(defaultCropperState)
                }
                self.backgroundView.transform = .identity
            }, completion: { _ in
                // completion block without using `finished`
            })
        }
    }
    
    func addPinchRecognized() {
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(pinchRecognized(pinchGesture:)))
        pinchGesture.delegate = self

        self.stickerTextView.addGestureRecognizer(pinchGesture)
    }
    
    @objc func panActionmoveImage(gesture: UIPanGestureRecognizer) {
        if  self.option.isFramesSelected == false {
            let currentScale = sqrt(abs(backgroundView.transform.a * backgroundView.transform.d - backgroundView.transform.b * backgroundView.transform.c))
            
            if gesture.state == .began {
                // Register the starting position before moving
                let oldCenter = backgroundView.center
                
                undoManager?.registerUndo(withTarget: self) { targetSelf in
                    // Restore the original position
                    targetSelf.backgroundView.center = oldCenter
                }
            }
            
            if currentScale > 1 {
                let translation = gesture.translation(in: backgroundView)
                backgroundView.transform = backgroundView.transform.translatedBy(x: translation.x, y: translation.y)
                gesture.setTranslation(.zero, in: backgroundView)
                
                // Additional logic to constrain the movement
                let minX = max(-backgroundView.bounds.width / 2, min(backgroundView.center.x, transformMainView.bounds.width - backgroundView.bounds.width / 2))
                let minY = max(-backgroundView.bounds.height / 2, min(backgroundView.center.y, transformMainView.bounds.height - backgroundView.bounds.height / 2))
                backgroundView.center = CGPoint(x: minX, y: minY)
            }
            
            //            let currentScale = sqrt(abs(self.backgroundView.transform.a * self.backgroundView.transform.d - self.backgroundView.transform.b * self.backgroundView.transform.c))
            //            if currentScale > 1 {
            //                // // Move UIImageView
            //                let translation = gesture.translation(in: backgroundView)
            //                backgroundView.transform = backgroundView.transform.translatedBy(x: translation.x, y: translation.y)
            //                gesture.setTranslation(CGPoint.zero, in: stickerTextView)
            //                
            //                // Ensure the view doesn't go away with pan gesture from the visible view
            //                let minX = max(-backgroundView.bounds.width / 2, min(backgroundView.center.x, self.transformMainView.bounds.width - backgroundView.bounds.width / 2))
            //                let minY = max(-backgroundView.bounds.height / 2, min(backgroundView.center.y, transformMainView.bounds.height - backgroundView.bounds.height / 2))
            //                print(minX,minY)
            //                backgroundView.center = CGPoint(x: minX, y: minY)
            //            }
        } else {
            let currentScale = sqrt(abs(self.mainImageView.transform.a * self.mainImageView.transform.d - self.mainImageView.transform.b * self.mainImageView.transform.c))
            if currentScale > 1 {
                // // Move UIImageView
                let translation = gesture.translation(in: mainImageView)
                mainImageView.transform = mainImageView.transform.translatedBy(x: translation.x, y: translation.y)
                gesture.setTranslation(CGPoint.zero, in: mainImageView)
                
                // Ensure the view doesn't go away with pan gesture from the visible view
                let minX = max(-mainImageView.bounds.width / 2, min(mainImageView.center.x, self.transformMainView.bounds.width - mainImageView.bounds.width / 2))
                let minY = max(-mainImageView.bounds.height / 2, min(mainImageView.center.y, transformMainView.bounds.height - mainImageView.bounds.height / 2))
                print(minX,minY)
                mainImageView.center = CGPoint(x: minX, y: minY)
            }
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        
        if self.scrollViewContainer.frame.contains(location) {
            // Pass the touch event to the bottom view
            let convertedLocation = gesture.location(in: scrollViewContainer)
            let tappedSubview = scrollViewContainer.hitTest(convertedLocation, with: nil)
            // Handle tap on the subview if needed
            if tappedSubview != nil {
                // Handle tap on subview
                print("Tapped subview: \(tappedSubview!)")
                if let view = tappedSubview as? AddSticker {
                    self.showCrossOnTap(gestureView: view)
                }
            } else {
                // Handle tap on the bottom view itself
                print("Tapped bottom view")
            }
        }
    }
    
    func showCrossOnTap(gestureView: UIView) {
        if gestureView is UIImageView {
            if gestureView.tag == stickerTempTags {
                gestureView.tag = stickerMoveTempTags
            }
            if gestureView.tag == stickerSavedTags {
                gestureView.tag = stickerMoveSavedTags
            }
        }
        if let stickerView = gestureView as? AddSticker {
            self.addRemoveButtonFromSticker(sticker: stickerView, tag: gestureView.tag, stickerSelection: "")
        }
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        //anu comment for sprint 6
       // self.alignment()
       // self.alignmentText()
        if gestureRecognizer.state == .changed {
            if self.selectedAddSticker != nil {
                self.panWhenChangedForSticker(gestureRecognizer)
            }
            if self.selectedAddTextView != nil {
                self.panWhenChangedForTextView(gestureRecognizer)
            }
        }
        if gestureRecognizer.state == .ended {
            self.removeAlignmentLines()
        }
    }
    
    func panWhenChangedForSticker(_ gestureRecognizer: UIPanGestureRecognizer) {
        _ = gestureRecognizer.translation(in: self.stickerTextView)
        let point = gestureRecognizer.location(in: self.stickerTextView)
        let superview = self.stickerTextView
        let restrictByPoint : CGFloat = 30.0
        let xAxis = superview.bounds.origin.x + restrictByPoint
        let yAxis = superview.bounds.origin.y + restrictByPoint
        let width = superview.bounds.size.width - 2*restrictByPoint
        let height = superview.bounds.size.height - 2*restrictByPoint
        let superBounds = CGRect(x: xAxis, y: yAxis, width: width, height: height)
        if (superBounds.contains(point)) {
            let translation = gestureRecognizer.translation(in: self.stickerTextView)
            self.selectedAddSticker?.center = CGPoint(x: (self.selectedAddSticker?.center.x ?? 0) + translation.x, y: (self.selectedAddSticker?.center.y ?? 0) + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.stickerTextView)
        }
    }
    
    func panWhenChangedForTextView(_ gestureRecognizer: UIPanGestureRecognizer) {
        _ = gestureRecognizer.translation(in: self.stickerTextView)
        let point = gestureRecognizer.location(in: self.stickerTextView)
        let superview = self.stickerTextView
        let restrictByPoint : CGFloat = 30.0
        let xAxis = superview.bounds.origin.x + restrictByPoint
        let yAxis = superview.bounds.origin.y + restrictByPoint
        let width = superview.bounds.size.width - 2*restrictByPoint
        let height = superview.bounds.size.height - 2*restrictByPoint
        let superBounds = CGRect(x: xAxis, y: yAxis, width: width, height: height)
        if (superBounds.contains(point)) {
            let translation = gestureRecognizer.translation(in: self.stickerTextView)
            self.selectedAddTextView?.center = CGPoint(x: (self.selectedAddTextView?.center.x ?? 0) + translation.x, y: (self.selectedAddTextView?.center.y ?? 0) + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.stickerTextView)
        }
    }

    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(named: .stickerColor, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)?.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [7, 3] // 7 is the length of dash, 3 is length of the gap.

        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
    
    @objc func pinchRecognized(pinchGesture: UIPinchGestureRecognizer) {

        print("pinch ")
        if let view = self.selectedAddSticker {
            if pinchGesture.state == .began || pinchGesture.state == .changed {
                let pinchScale: CGFloat = pinchGesture.scale

                if stickerScale * pinchScale < 100.0 && stickerScale * pinchScale > 0.3 {
                    stickerScale *= pinchScale
                    view.transform = (view.transform.scaledBy(x: pinchScale, y: pinchScale))
                }
                pinchGesture.scale = 1.0
                
            }
            if pinchGesture.state == .ended {
                self.removeAlignmentLines()
            }
        }

        if let view = self.selectedAddTextView {
            //anu comment for sprint 6

          //  self.alignmentText()
            guard let pinchView = pinchGesture.view else { return }
            let textLabel = view as UILabel

            if pinchGesture.state == .began {
                let font = textLabel.font
                pointSize = font!.pointSize // Store the original point size
                pinchGesture.scale = 1.0 // Reset the gesture's scale to avoid compounding
            }

            if pinchGesture.state == .changed {
                // Adjust font size using the stored point size and the pinch gesture's scale
                let newPointSize = max(pointSize * pinchGesture.scale, 8) // Ensure a minimum font size
                let font = UIFont(name: textLabel.font!.fontName, size: newPointSize)
                let text = textLabel.text ?? ""

                // Calculate the size of the text label using the updated font
                let info = sizeForView(text: text, font: font!)

                // Update the text label's properties
                textLabel.font = font
                textLabel.bounds.size.height = info.0.height
                textLabel.bounds.size.width = info.0.width + 8
            }

            if pinchGesture.state == .ended {
                self.removeAlignmentLines()
            }
        }



        if self.selectedAddSticker == nil && self.selectedAddTextView == nil {
            if pinchGesture.state == .began {
                if pinchGesture.scale < 1.0 {
                    pinchGesture.scale = 1.0
                }
            } else if pinchGesture.state == .changed {
                if self.option.isFramesSelected == false {
                    let transform = self.backgroundView.transform.scaledBy(x: pinchGesture.scale, y: pinchGesture.scale)
                    self.backgroundView.transform = transform
                } else {
                    let transform = self.mainImageView.transform.scaledBy(x: pinchGesture.scale, y: pinchGesture.scale)
                    self.mainImageView.transform = transform
                }
                pinchGesture.scale = 1
            }

            if pinchGesture.state == .ended {
                var tmpScale: CGFloat = 1.0
                if self.option.isFramesSelected == false {
                    let currentScale = sqrt(abs(self.backgroundView.transform.a * self.backgroundView.transform.d - self.backgroundView.transform.b * self.backgroundView.transform.c))
                    if currentScale <= self.minScaleImage {
                        tmpScale = self.minScaleImage
                        UIView.animate(withDuration: 0.2, animations: {
                            self.backgroundView.transform = CGAffineTransform(scaleX: tmpScale, y: tmpScale)
                        })
                    } else if self.maxScaleImage <= currentScale {
                        tmpScale = self.maxScaleImage
                        UIView.animate(withDuration: 0.2, animations: {
                            self.backgroundView.transform = CGAffineTransform(scaleX: tmpScale, y: tmpScale)
                        })
                    }
                } else {
                    let currentScale = sqrt(abs(self.mainImageView.transform.a * self.mainImageView.transform.d - self.mainImageView.transform.b * self.mainImageView.transform.c))
                    if currentScale <= self.minScaleImage {
                        tmpScale = self.minScaleImage
                        UIView.animate(withDuration: 0.2, animations: {
                            self.mainImageView.transform = CGAffineTransform(scaleX: tmpScale, y: tmpScale)
                        })
                    } else if self.maxScaleImage <= currentScale {
                        tmpScale = self.maxScaleImage
                        UIView.animate(withDuration: 0.2, animations: {
                            self.mainImageView.transform = CGAffineTransform(scaleX: tmpScale, y: tmpScale)
                        })
                    }
                }
            }
        }
    }
    
    @objc func handleRotate(recognizer: UIRotationGestureRecognizer) {
        print("rotate")
        if let view = selectedAddSticker {
            if recognizer.state == .began {
                // Register the current transform before rotating
                let oldTransform = view.transform
                
                undoManager?.registerUndo(withTarget: self) { targetSelf in
                    view.transform = oldTransform // Restore the old transform
                }
            }
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
            //anu commnet for sprint6
//
//            self.centerDashLineMargin.center = view.center
//            self.centerDashLineMargin.isHidden = false
            
            if recognizer.state == .ended {
                self.removeAlignmentLines()
            }

        }
        if let view = selectedAddTextView {
            if recognizer.state == .began {
                // Register the current transform before rotating
                let oldTransform = view.transform
                
                undoManager?.registerUndo(withTarget: self) { targetSelf in
                    view.transform = oldTransform // Restore the old transform
                }
            }
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
            //anu commnet for sprint6

//            self.centerDashLineMargin.center = view.center
//            self.centerDashLineMargin.isHidden = false
            
            if recognizer.state == .ended {
                self.removeAlignmentLines()
            }
        }
    }
    
    
    //    @objc func handleRotate(recognizer : UIRotationGestureRecognizer) {
    //        if let view = self.selectedAddSticker {
    //            view.transform = view.transform.rotated(by: recognizer.rotation)
    //            recognizer.rotation = 0
    //        }
    //        
    //        if let view = self.selectedAddTextView {
    //            view.transform = view.transform.rotated(by: recognizer.rotation)
    //            recognizer.rotation = 0
    //        }
    //    }
    
    func calculatingMainImageViewSize() {
        //Getting height width from orignal image to apply it on textViewTransparent
        let gettingImage : UIImage
        gettingImage = mainImageView.image ?? imageOrignal
        let imageSize = gettingImage.size
        let imageViewSize = self.mainImageViewSize
        let imageViewAspectRatio = imageViewSize!.width / imageViewSize!.height
        let imageAspectRatio = imageSize.width / imageSize.height
        if imageAspectRatio > imageViewAspectRatio {
            // Image is wider, scale based on width
            let scaleFactor = (imageViewSize?.width ?? 0) / imageSize.width
            let height = imageSize.height * scaleFactor
            mainImageScaledSize = CGSize(width: imageViewSize?.width ?? 0, height: height)
        } else {
            // Image is taller, scale based on height
            let scaleFactor = (imageViewSize?.height ?? 0.0) / imageSize.height
            let width = imageSize.width * scaleFactor
            mainImageScaledSize = CGSize(width: width, height: imageViewSize?.height ?? 0)
        }
    }
    
    
    
    func stickersText(text: TextStickersOption,textModel: TextModel? = nil, color: UIColor? = nil, fontName: String? = "", index: Int? = 0, dictionary: [String:Any]? = nil, opacity: CGFloat = 0.0, isText: Bool) {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if isText {
                if subview is AddTextView {
                    if let view = subview as? AddTextView {
                        switch text {
                        case .showDeleteButton:
                            if view.tag == textTempTags || view.tag == textMoveTempTags {
                                self.setupAddDeleteFlipAndOnTopButtons(isHidden: false)
                                view.isSelected = true
                                view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
                                view.layer.borderWidth = 1
                                self.selectedAddTextView = view
                            } else {
                                self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
                                view.isSelected = false
                                view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
                                view.layer.borderWidth = 0
                            }
                        case .hideSelection:
                            view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
                            view.layer.borderWidth = 0
                            view.isSelected = false
                        case .hideDeleteButton:
                            self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
                            view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
                            view.layer.borderWidth = 0
                            view.isSelected = false
                            self.selectedAddTextView = nil
                        case .showDeleteButtonOnTap:
                            if view.tag == textMoveTempTags || view.tag == textMoveSavedTags || view.tag == textEditTags || view.tag == textTempEditTags {
                                view.layer.borderWidth = 1
                                view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
                                self.setupAddDeleteFlipAndOnTopButtons(isHidden: false)
                                view.isSelected = true
                                self.selectedAddTextView = view
                                let textModel = TextModel()
                                textModel.color = view.selectedColor
                                textModel.selectedColorIndex = view.selectedColorIndex
                                textModel.previousColor = view.previousColor
                                textModel.previousSelectedColorIndex = view.previousSelectedColorIndex
                                self.selectedTextModel = textModel
                            } else {
                                view.isSelected = false
                                view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
                                view.layer.borderWidth = 0
                            }
                        case .replace:
                            break
                        case .edit:
                            if view.tag == textEditTags || view.tag == textTempEditTags {
                                view.text = dictionary?[EditStaticStrings.text] as? String
                                let font = dictionary?[EditStaticStrings.font] as? String
                                view.font = UIFont.init(name: font ?? "", size: view.font.pointSize)
                                let color = dictionary?[EditStaticStrings.color] as? UIColor
                                view.textColor = color
                                let width = (view.text?.widthOfString(usingFont: view.font) ?? 0) + 50
                                _ = heightForView(text: view.text ?? "" , font: view.font, width: width) + 50
                                view.alpha = textViewOpacity
                                view.textAlignment = dictionary?[EditStaticStrings.selectedAlignment] as? NSTextAlignment ?? NSTextAlignment.left
                                
                                let maxWidth: CGFloat = self.mainImageScaledSizeForText.width
                                let maxHeight: CGFloat = self.mainImageScaledSizeForText.height
                              //  let newPointSize = max(pointSize * pinchGesture.scale, 8) // Ensure a minimum font size

                                let info = sizeForView(text: view.text!, font: view.font)
                                view.bounds.size.height = info.0.height
                                view.bounds.size.width = info.0.width + 8
                                view.transform = view.transform

//                                view.frame.origin.x = view.frame.origin.x
//                                view.frame.origin.y = view.frame.origin.y
                                view.setNeedsDisplay()

                                view.button.frame.origin.x = view.bounds.size.width - 40
                                view.button.setNeedsDisplay()
                                view.tag = textTempTags
                                self.stickersText(text: .resetEdit, isText: true)
                            }
//                            if view.tag == textEditTags || view.tag == textTempEditTags {
//                                // Temporarily reset the transform to avoid layout distortions
//                                let currentTransform = view.transform
//                                view.transform = .identity
//
//                                // Update text and properties
//                                view.text = dictionary?[EditStaticStrings.text] as? String
//                                let fontName = dictionary?[EditStaticStrings.font] as? String ?? view.font.fontName
//                                view.font = UIFont(name: fontName, size: view.font.pointSize)
//                                let color = dictionary?[EditStaticStrings.color] as? UIColor
//                                view.textColor = color
//                                view.numberOfLines = 1 // Ensure single-line display
//
//                                // Calculate the new width and height
//                                let maxWidth: CGFloat = self.mainImageScaledSizeForText.width
//                                let maxHeight: CGFloat = self.mainImageScaledSizeForText.height
////                                let textSize = sizeForView(text: view.text ?? "", font: view.font, maxSize: CGSize(width: maxWidth, height: maxHeight))
////
////                                // Apply the calculated size to the view's bounds
////                                view.bounds.size = CGSize(width: textSize.width, height: textSize.height)
//
//                                let (textSize, _) = sizeForView(text: view.text ?? "", font: view.font, maxSize: CGSize(width: maxWidth, height: maxHeight))
//
//                                // Now you can access textSize.width and textSize.height
//                                view.bounds.size = CGSize(width: textSize.width, height: textSize.height)
//
//
//                                // Restore the transform
//                                view.transform = currentTransform
//
//                                // Adjust button position
//                                view.button.frame.origin.x = view.bounds.size.width - 40
//                                view.button.setNeedsDisplay()
//                                view.tag = textTempTags
//
//                                // Reset the editing state
//                                self.stickersText(text: .resetEdit, isText: true)
//                            }

                        case .resetMove:
                            if view.tag == textMoveSavedTags {
                                view.tag = textSavedTags
                            }
                            if view.tag == textMoveTempTags {
                                view.tag = textTempTags
                            }
                        case .resetEdit:
                            if view.tag == textEditTags {
                                view.tag = textSavedTags
                            }
                            if view.tag == textTempEditTags {
                                view.tag = textTempTags
                            }
                        case .removeAll:
                            view.removeFromSuperview()
                        case .withoutTick:
                            if view.tag == textTempTags {
                                view.removeFromSuperview()
                            }
                        case .saved:
                            view.tag = textSavedTags
                        case .setColor:
                            if view.isSelected == true {
                                let previousColor = view.textColor
                                
                                if index == 100 {
                                    view.textColor = color
                                    view.selectedColor = color ?? .black
                                    view.selectedColorIndex = 100
                                    view.previousColor = textModel?.previousColor ?? .black
                                    view.previousSelectedColorIndex = textModel?.previousSelectedColorIndex ?? 0
                                } else if index == 101 {
                                    let rgba = color?.rgba
                                    let alpha = rgba?.alpha ?? 1
                                    view.textColor = UIColor(red: rgba?.red ?? 0, green: rgba?.green ?? 0, blue: rgba?.blue ?? 0 , alpha: alpha)
                                    
                                    view.selectedColor = color ?? .black
                                    view.selectedColorIndex = 101
                                    view.previousColor = textModel?.previousColor ?? .black
                                    view.previousSelectedColorIndex = textModel?.previousSelectedColorIndex ?? 0
                                } else {
                                    view.textColor = textModel?.color ?? .black
                                    view.selectedColor = textModel?.color ?? .black
                                    view.selectedColorIndex = textModel?.selectedColorIndex ?? 0
                                    view.previousColor = textModel?.previousColor ?? .black
                                    view.previousSelectedColorIndex = textModel?.previousSelectedColorIndex ?? 0
                                }
                                let data: [String: Any] = [
                                    "view": view,
                                    "color": view.textColor,
                                    "previousColor": previousColor,
                                    "viewType": "text"
                                ]
                                
                                // Integrate undo/redo for adding color action
                                Editor.performAction(type: .color, data: data)
                            }
                        case .setFont:
                            if view.isSelected == true {
                                let currentFont = view.font
                                
                                view.font = UIFont.init(name: textModel?.fontCustom ?? "", size: view.font.pointSize)
                                view.selectedFontIndex = textModel?.selectedFontIndex ?? 0
                                view.selectedFont = textModel?.fontCustom ?? ""
                                view.selectedPreviousFont = textModel?.previousFont ?? ""
                                view.selectedFontIndex = textModel?.selectedFontIndex ?? 0
                                view.selectedPreviousFontIndex = textModel?.previousSelectedFontIndex ?? 0
                                view.selectedText = textModel?.textString ?? ""
                                view.previousText = textModel?.previousTextString ?? ""
                                let maxWidth: CGFloat = self.mainImageScaledSizeForText.width
                                let maxHeight: CGFloat = self.mainImageScaledSizeForText.height
                                let info = sizeForView(text: view.text!, font: view.font, maxSize: CGSize(width: maxWidth, height: maxHeight))
                                view.bounds.size.height = info.0.height
                                view.bounds.size.width = info.0.width + 8
                                
                                view.frame.origin.x = view.frame.origin.x
                                view.frame.origin.y = view.frame.origin.y
                                view.setNeedsDisplay()
                                let data: [String: Any] = [
                                    "view": view,
                                    "font": view.font,
                                    "previousFont": currentFont
                                ]
                                
                                // Integrate undo/redo for adding color action
                                Editor.performAction(type: .font, data: data)
                            }
                        case .setOpacity:
                            if view.isSelected == true {
                                let currentOpacity = view.alpha
                                
                                view.alpha = opacity
                                let data: [String: Any] = [
                                    "view": view,
                                    "opacity": view.alpha,
                                    "previousOpacity": currentOpacity
                                ]
                                
                                // Integrate undo/redo for adding color action
                                Editor.performAction(type: .opacity, data: data)
                            }
                        case .mirror:
                            break
                        case .onTop:
                            if  view.isSelected == true {
                                view.bringSubviewToFront(view)
                            }
                        case .setLeft:
                            if view.isSelected == true {
                                view.textAlignment = .left
                            }
                        case .setRight:
                            if view.isSelected == true {
                                view.textAlignment = .right
                            }
                        case .setCenter:
                            if view.isSelected == true {
                                view.textAlignment = .center
                            }
                        case .align:
                            if  view.isSelected == true {
                                self.selectedAddTextView = view
                            }
                        }
                    }
                }
            } else {
                if subview is AddSticker {
                    if let view = subview as? AddSticker {
                        switch text {
                        case .showDeleteButton:
                            if view.tag == stickerTempTags || view.tag == stickerMoveTempTags {
                                self.setupAddDeleteFlipAndOnTopButtons(isHidden: false)
                                view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
                                view.layer.borderWidth = 1
                                view.isSelected = true
                                self.selectedAddSticker = view
                            } else {
                                self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
                                view.isSelected = false
                                view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
                                view.layer.borderWidth = 0
                            }
                        case .hideSelection:
                            view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
                            view.layer.borderWidth = 0
                            view.isSelected = false
                        case .hideDeleteButton:
                            self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
                            view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
                            view.layer.borderWidth = 0
                            view.isSelected = false
                            self.selectedAddSticker = nil
                        case .showDeleteButtonOnTap:
                            if view.tag == stickerMoveTempTags || view.tag == stickerMoveSavedTags || view.tag == stickerEditTags || view.tag == stickerTempEditTags {
                                self.setupAddDeleteFlipAndOnTopButtons(isHidden: false)
                                view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
                                view.layer.borderWidth = 1
                                view.isSelected = true
                                self.selectedAddSticker = view
                            } else {
                                view.isSelected = false
                                view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
                                view.layer.borderWidth = 0
                            }
                        case .edit:
                            if view.tag == stickerEditTags || view.tag == stickerTempEditTags {
                                view.tag = stickerTempTags
                                self.stickersText(text: .resetEdit, isText: false)
                            }
                        case .resetMove:
                            if view.tag == stickerMoveSavedTags {
                                view.tag = stickerSavedTags
                            }
                            if view.tag == stickerMoveTempTags {
                                view.tag = stickerTempTags
                            }
                        case .resetEdit:
                            if view.tag == stickerEditTags {
                                view.tag = stickerSavedTags
                            }
                            if view.tag == stickerTempEditTags {
                                view.tag = stickerTempTags
                            }
                        case .removeAll:
                            view.removeFromSuperview()
                        case .withoutTick:
                            if view.tag == stickerTempTags {
                                view.removeFromSuperview()
                            }
                            self.selectedAddSticker = nil
                        case .saved:
                            view.tag = stickerSavedTags
                        case .setColor:
                            if view.isSelected == true {
                                let previousColor = view.tintColor
                                
                                // Load your image
                                let originalImage = view.image!
                                let image = originalImage.withRenderingMode(.alwaysTemplate)
                                view.image = image
                                view.tintColor = color
                                let data: [String: Any] = [
                                    "view": view,
                                    "color": view.tintColor,
                                    "previousColor": previousColor,
                                    "viewType": "sticker"
                                ]
                                
                                // Integrate undo/redo for adding color action
                                Editor.performAction(type: .color, data: data)
                            }
                        case .setFont:
                            if view.isSelected == true {
                                
                            }
                        case .setOpacity:
                            if  view.isSelected == true {
                                let currentOpacity = view.alpha
                                
                                view.alpha = opacity
                                let data: [String: Any] = [
                                    "view": view,
                                    "opacity": view.alpha,
                                    "previousOpacity": currentOpacity
                                ]
                                
                                // Integrate undo/redo for adding color action
                                Editor.performAction(type: .opacity, data: data)
                            }
                        case .mirror:
                            if  view.isSelected == true {
                                
                                var currentImage = view.image!
                                var orignalImage = view.orignalImage!
                                let orientation = currentImage.imageOrientation
                                switch orientation {
                                case .up:
                                    flipAngleSticker = "up"
                                case .upMirrored:
                                    flipAngleSticker = "upMirrored"
                                case .down, .left, .right, .downMirrored, .leftMirrored, .rightMirrored:
                                    currentImage = self.fixOrientation(img: view.image!)
                                    orignalImage = self.fixOrientation(img: view.orignalImage!)
                                    break;
                                @unknown default:
                                    break
                                }
                                let flippedImage = self.setEffectOn(image:currentImage, effect:.mirror)
                                let orignalFlippedImage = self.setEffectOn(image:orignalImage, effect:.mirror)
                                view.image = flippedImage
                                view.orignalImage = orignalFlippedImage
                                view.flipAngleSticker = flipAngleSticker

                                if view.stickerSelection == "shapes" || view.stickerSelection == "badges"  || view.stickerSelection == "arrow" || view.stickerSelection == "spray" {
                                    view.image = view.image?.withRenderingMode(.alwaysTemplate)
                                    view.orignalImage = view.orignalImage?.withRenderingMode(.alwaysTemplate)
                                    view.tintColor = self.stickerOption.colorButton.backgroundColor
                                }
                                
                                
                                for index in 0...stickersFromApi.count {
                                    print(index)
                                    if view.stickerSelection == "api" {
                                        view.image = flippedImage
                                        view.orignalImage = orignalFlippedImage
                                        view.tintColor = .clear
                                    }
                                }
                            }
                        case .onTop:
                            if  view.isSelected == true {
                                view.bringSubviewToFront(view: view)
                            }
                        case .setLeft:
                            break
                        case .setRight:
                            break
                        case .setCenter:
                            break
                        case .align:
                            if  view.isSelected == true {
                                self.selectedAddSticker = view
                            }
                        case .replace:
                            if view.tag == stickerMoveSavedTags || view.tag == stickerSavedTags {
                                view.tag = stickerReplaceTags
                            }
                        }
                    }
                }
            }
        }
    }

    func fixOrientation(img:UIImage) -> UIImage {
        
        if (img.imageOrientation == .up) {
            return img;
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
        
    }
    
    func toShowDeleteButtonForText(view : AddTextView, isDelete: Bool) {
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: !isDelete)
        view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
        view.layer.borderWidth = isDelete ? 1 : 0
        view.isSelected = isDelete
        self.selectedAddTextView = view
    }
    
    func toHideDeleteButtonAndSelectionForText(view : AddTextView, isDelete: Bool) {
        view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
        view.layer.borderWidth = 0
        view.isSelected = isDelete
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: !isDelete)
    }
    
    func toEditText(view: AddTextView, dictionary: [String:Any]? = nil) {
        view.text = dictionary?[EditStaticStrings.text] as? String
        let font = dictionary?[EditStaticStrings.font] as? String
        view.font = UIFont.init(name: font ?? "", size: view.font.pointSize)
        let color = dictionary?[EditStaticStrings.color] as? UIColor
        view.textColor = color
        view.bounds.size = CGSize(width: view.intrinsicContentSize.width + view.gutterSize,height: view.intrinsicContentSize.height + view.gutterSize)
        view.setNeedsDisplay()
        view.button.frame.origin.x = view.bounds.size.width - 40
        view.button.setNeedsDisplay()
        view.tag = textTempTags
        self.stickersText(text: .resetEdit, isText: true)
        
    }
    
    func deleteSticker(view : AddSticker, isDelete: Bool) {
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: !isDelete)
        view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
        view.layer.borderWidth = isDelete ? 1 : 0
        view.isSelected = isDelete
        self.selectedAddSticker = view
    }
    
    func toHideDeleteButtonAndSelectionForSticker(view : AddSticker, isDelete: Bool) {
        view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
        view.layer.borderWidth = 0
        view.isSelected = isDelete
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: !isDelete)
    }
    
    func toShowFlipOnSticker(view : AddSticker) {
        let originalImage = view.image!
        let orientation = originalImage.imageOrientation
        switch orientation {
        case .up:
            flipAngleSticker = "up"
        case .upMirrored:
            flipAngleSticker = "upMirrored"
        case .down:
            flipAngleSticker = "down"
        case .left:
            flipAngleSticker = "left"
        case .right:
            flipAngleSticker = "right"
        case .leftMirrored:
            flipAngleSticker = "leftMirrored"
        case .rightMirrored:
            flipAngleSticker = "rightMirrored"
        @unknown default:
            break
        }
        let flippedImage = self.setEffectOn(image:originalImage, effect:.mirror)
        view.image = flippedImage
        if view.stickerSelection == "shapes" || view.stickerSelection == "badges"  || view.stickerSelection == "arrow" || view.stickerSelection == "spray" {
            view.image = view.image?.withRenderingMode(.alwaysTemplate)
            view.tintColor = stickerOption.colorButton.tintColor
        }
        
        for index in 0...stickersFromApi.count {
            print(index)
            if view.stickerSelection == "api" {
                view.image = flippedImage
                view.tintColor = .clear
            }
        }
    }
    
    // Create a function to replace white with a new color
    func replaceWhiteColor(in image: UIImage?, with color: UIColor) -> UIImage? {
        guard let image = image else { return nil }
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        image.draw(in: rect)
        
        // Define the color to replace white
        let replacementColor = color.cgColor
        context.setFillColor(replacementColor)
        
        for xPoint in 0..<Int(image.size.width) {
            for yPoint in 0..<Int(image.size.height) {
                if let pixelColor = image.getPixelColor(xAxis: xPoint, yAxis: yPoint) {
                    if pixelColor.isWhite() {
                        context.fill(CGRect(x: CGFloat(xPoint), y: CGFloat(yPoint), width: 1, height: 1))
                    }
                }
            }
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    private func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    
    func enableDisableUIControl() {
        switch self.filterSelection {
            //        case .filter:
            //            undoButton.isEnabled = !undoStackFilter.isEmpty
            //            redoButton.isEnabled = !redoStackFilter.isEmpty
            // case .frame:
            //            undoButton.isEnabled = !undoStackFrames.isEmpty
            //            redoButton.isEnabled = !redoStackFrames.isEmpty
        case .text:
            if self.viewPaintDrawing.lines.count > 0 {
                undoButton.isEnabled = true
                redoButton.isEnabled = true
            } else{
                undoButton.isEnabled = !textModel.undoStack.isEmpty
                redoButton.isEnabled = !textModel.redoStack.isEmpty
            }
        case .brush:
            undoButton.isEnabled = !textModel.undoStack.isEmpty
            redoButton.isEnabled = !textModel.redoStack.isEmpty
        default:
            undoButton.isEnabled = false
            redoButton.isEnabled = false
        }
        
        
    } 
    
    
    func calculatingLeftRightAlignment(view : UIView) {
        let leftAlign = view.frame.origin.x
        let mainViewWidth = self.scrollView.frame.size.width - 16 - view.frame.size.width
        let rightAlign = leftAlign - mainViewWidth
        if  leftAlign <= 10 {
            if leftAlign == 8 {
                self.haptic()
            }
            self.leftAlignMargin.isHidden = false
        } else {
            self.leftAlignMargin.isHidden = true
        }
        
        if rightAlign >= 6  {
            print(rightAlign)
            if rightAlign == 8 {
                self.haptic()
            }
            self.rightAlignMargin.isHidden = false
        } else {
            self.rightAlignMargin.isHidden = true
            
        }
    }
    
    func calculatingTopBottomAlignment(view : UIView) {
        let topAlign = view.frame.origin.y
        let mainViewHeight = self.scrollView.frame.size.height - 16 - view.frame.size.height
        let bottomAlign = topAlign - mainViewHeight
        if  topAlign <= 10 {
            if topAlign == 8 {
                self.haptic()
            }
            self.topAlignMargin.isHidden = false
        } else {
            self.topAlignMargin.isHidden = true
        }

       if bottomAlign >= 6  {
            if bottomAlign == 8 {
                self.haptic()
            }
            self.bottomAlignMargin.isHidden = false
        } else {
            self.bottomAlignMargin.isHidden = true
        }
    }
    
    func calculatingCenterAlignment(view : UIView) {
        if view.center.y + 8 >= self.stickerTextView.bounds.midY + 6 && view.center.y + 8 <= self.stickerTextView.bounds.midY + 10 {
            if view.center.y == self.stickerTextView.frame.midY {
                self.haptic()
            }
            self.centerVerticalMargin.isHidden = false
        } else {
            self.centerVerticalMargin.isHidden = true
        }
        
        if view.center.x + 8 >= self.stickerTextView.bounds.midX + 6 && view.center.x + 8 <= self.stickerTextView.bounds.midX + 10 {
            if view.center.x == self.stickerTextView.frame.midX {
                self.haptic()
            }
            self.centerHorizontalMargin.isHidden = false
        } else {
            self.centerHorizontalMargin.isHidden = true
        }
    }
    
    func haptic() {
    }
    
    func removeAlignmentLines() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.leftAlignMargin.isHidden = true
            self.rightAlignMargin.isHidden = true
            self.topAlignMargin.isHidden = true
            self.bottomAlignMargin.isHidden = true
            self.centerVerticalMargin.isHidden = true
            self.centerHorizontalMargin.isHidden = true
            self.centerDashLineMargin.isHidden = true
        }
    }
    
    func isAnyOptionSelected() -> Bool {
        switch self.filterSelection {
        case .transform:
            return true
        case .text:
            return true
        case .sticker:
            return true
        case .frame:
            return true 
        case .brush:
            return true
        default:
            return false
        }
    }
    
    func addGesturesMainImageViewForSticker() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTapStickerView(_:)))
        tapGesture.delegate = self
        self.stickerTextView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTapStickerView(_ gestureRecognizer: UITapGestureRecognizer) {
        if self.magnifyingGlass.magnifiedView == nil {
            if let defaultCropperState = self.initialState {
                self.restoreState(defaultCropperState)
            }
            self.backgroundView.transform = .identity
            switch self.filterSelection {
            case .sticker:
                self.applySticker()
                self.applyImageView()
                self.hideCrossTickOnly()
                self.removeBottomSubViews()
                self.filterSelection = FilterSelection(rawValue: -1)
                self.mainCollectionView.isHidden = false
                
                //                self.undoButton.isHidden = true
                //                self.redoButton.isHidden = true
                self.mainCollectionView.reloadData()
            case .gallery:
                self.applySticker()
                self.applyImageView()
                self.hideCrossTickOnly()
                self.removeBottomSubViews()
                self.filterSelection = FilterSelection(rawValue: -1)
                self.mainCollectionView.isHidden = false
                //                self.undoButton.isHidden = true
                //                self.redoButton.isHidden = true
                self.mainCollectionView.reloadData()
            case .text:
                self.applySubOptionsForText()
                self.applyText()
                self.applyImageView()
                self.hideCrossTickOnly()
                self.removeBottomSubViews()
                self.filterSelection = FilterSelection(rawValue: -1)
                self.mainCollectionView.isHidden = false
                //                self.undoButton.isHidden = true
                //                self.redoButton.isHidden = true
                self.mainCollectionView.reloadData()
            default:
                break
            }
        }
    }
    
    func setupAddDeleteFlipAndOnTopButtons(isHidden: Bool) {
        
        switch self.filterSelection {
        case .sticker:
            self.plusButton.isHidden = false
            self.deleteAndAddButtons.isHidden = isHidden
            self.flipAndOntopButtons.isHidden = isHidden
        case .gallery:
            self.plusButton.isHidden = false
            self.deleteAndAddButtons.isHidden = isHidden
            self.flipAndOntopButtons.isHidden = isHidden
        case .text:
            self.plusButton.isHidden = false
            self.deleteAndAddButtons.isHidden = isHidden
            self.flipAndOntopButtons.isHidden = true
        case .brush:
            self.plusButton.isHidden = true
            self.deleteAndAddButtons.isHidden = isHidden
            self.flipAndOntopButtons.isHidden = true
        default:
            break
        }
    }
    
    func undoTextChanges() {
        if let previousTextDetail = self.previousTextDetail {
            self.restoreTextChanges(previousTextDetail: previousTextDetail)
        }
    }
    
    func changeFrame(to newFrame: CGRect) {
        // Save the current frame before making changes
        self.previousFrame = self.backgroundView.frame // or whatever view's frame you are changing
        
        // Change the frame
        self.backgroundView.frame = newFrame
    }
    
    func undoFrameChanges() {
        if let previousFrame = self.previousFrame {
            // Restore the previous frame
            self.backgroundView.frame = previousFrame
            
            // Optionally, you can reset previousFrame to nil if you don't want to keep undoing indefinitely
            self.previousFrame = nil
        }
    }
    
    func addBrushStroke(color: UIColor, points: [CGPoint]) {
        // Save current strokes to previousBrushStrokes before adding a new stroke
        // Ensure you extract valid points from lines
        let currentPoints = self.viewPaintDrawing.lines.map { $0.points }.flatMap { $0 ?? [] }
        previousBrushStrokes.append(TouchPointsAndColor(color: self.viewPaintDrawing.strokeColor, points: currentPoints))
        
        // Add the new stroke
        self.viewPaintDrawing.lines.append(TouchPointsAndColor(color: color, points: points))
        
        // Refresh the drawing view to show the new stroke
        self.viewPaintDrawing.setNeedsDisplay() // Refresh the drawing view
    }
    
    //    func undoBrushChanges() {
    //        // Check if there are any previous strokes to undo
    //        guard !previousBrushStrokes.isEmpty else { return }
    //
    //        // Remove the last stroke added
    //        previousBrushStrokes.removeLast()
    //
    //        // Assuming this removes the last stroke from the current drawing
    //        self.viewPaintDrawing.lines.removeLast()
    //
    //        // Refresh the drawing view to reflect the changes
    //        self.viewPaintDrawing.setNeedsDisplay()
    //    }
    func undoBrushChanges() {
        // Logic to undo the last brush stroke
        if !self.viewPaintDrawing.lines.isEmpty {
            self.viewPaintDrawing.lines.removeLast()
            self.viewPaintDrawing.setNeedsDisplay() // Redraw the painting canvas
        }
    }
    
    
}
