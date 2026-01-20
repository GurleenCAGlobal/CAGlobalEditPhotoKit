//
//  CAEditCommonViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 21/11/23.
//

import UIKit

struct StickerTransformState {
    let bounds: CGRect
    let center: CGPoint
    let transform: CGAffineTransform
}

struct TextTransformState: Codable {
    let frame: CGRect
    let center: CGPoint
    let transform: CGAffineTransform
    let pointSize: CGFloat
}

class CAEditCommonViewController: CAEditViewController {
    // Main class implementation remains empty as functionality is in extensions
}

// MARK: - Auto Layout Setup
extension CAEditViewController {
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
}

// MARK: - Gesture Handling
extension CAEditViewController {
    // MARK: - Gesture Setup
    func addPanGestureMainEdit() {
        self.framePanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panActionmoveImage))
        self.framePanGesture.minimumNumberOfTouches = 1
        self.framePanGesture.maximumNumberOfTouches = 1
        //self.stickerTextView.addGestureRecognizer(self.framePanGesture)
        self.scrollViewContainer.addGestureRecognizer(self.framePanGesture)
    }

    func removePanGestureMainEdit() {
        self.mainImageView.removeGestureRecognizer(self.framePanGesture)
        self.scrollViewContainer.removeGestureRecognizer(self.framePanGesture)
    }

    func addGesturesStickerTextView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(recognizer:)))
        rotate.delegate = self
        self.scrollViewContainer.addGestureRecognizer(rotate)
        
        self.addPinchRecognized()
        
        let tapDoubleGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        tapDoubleGesture.delegate = self
        tapDoubleGesture.numberOfTapsRequired = 2
        self.transformMainView.addGestureRecognizer(tapDoubleGesture)
    }

    func addPinchRecognized() {
        self.stickerTextPinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchRecognized(pinchGesture:)))
        self.stickerTextView.addGestureRecognizer(self.stickerTextPinchGesture)
    }

    func addGesturesMainImageViewForSticker() {
        tapMainGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapStickerView(_:)))
        tapMainGesture.delegate = self
        self.transformMainView.addGestureRecognizer(tapMainGesture)
    }

    // MARK: - Gesture Actions
    @objc func panActionmoveImage(gesture: UIPanGestureRecognizer) {
        if self.option.isFramesSelected == false {
            let currentScale = sqrt(abs(backgroundView.transform.a * backgroundView.transform.d - backgroundView.transform.b * backgroundView.transform.c))

            if gesture.state == .began {
                let oldCenter = backgroundView.center
            }

            if currentScale > 1 {
                let translation = gesture.translation(in: backgroundView)
                backgroundView.transform = backgroundView.transform.translatedBy(x: translation.x, y: translation.y)
                gesture.setTranslation(.zero, in: backgroundView)

                let minX = max(-backgroundView.bounds.width / 2, min(backgroundView.center.x, transformMainView.bounds.width - backgroundView.bounds.width / 2))
                let minY = max(-backgroundView.bounds.height / 2, min(backgroundView.center.y, transformMainView.bounds.height - backgroundView.bounds.height / 2))
                backgroundView.center = CGPoint(x: minX, y: minY)
            }
        } else {
            let currentScale = sqrt(abs(self.mainImageView.transform.a * self.mainImageView.transform.d - self.mainImageView.transform.b * self.mainImageView.transform.c))

            if currentScale > 1 {
                let translation = gesture.translation(in: mainImageView)
                mainImageView.transform = mainImageView.transform.translatedBy(x: translation.x, y: translation.y)
                gesture.setTranslation(CGPoint.zero, in: mainImageView)

                _ = max(-mainImageView.bounds.width / 2, min(mainImageView.center.x, self.transformMainView.bounds.width - mainImageView.bounds.width / 2))
                let minY = max(-mainImageView.bounds.height / 2, min(mainImageView.center.y, transformMainView.bounds.height - mainImageView.bounds.height / 2))
            }
        }
    }

    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if !self.option.isTransformActual && !self.option.isText {
            if self.option.isText {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {() -> Void in
                    if let defaultCropperState = self.initialState {
                        self.restoreState(defaultCropperState)
                    }
                    self.backgroundView.transform = .identity
                }, completion: { _ in })
            }
        }
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if !self.option.isTransformActual && !self.option.isText {
            let location = gesture.location(in: view)
            self.selectedAddTextView?.removeOutline()
            self.selectedAddSticker?.handles.forEach { $0.isHidden = true }
            
            if self.scrollViewContainer.frame.contains(location) {
                let convertedLocation = gesture.location(in: scrollViewContainer)
                let tappedSubview = scrollViewContainer.hitTest(convertedLocation, with: nil)
                
                if tappedSubview != nil {
                    if let view = tappedSubview as? AddSticker {
                        self.showCrossOnTap(gestureView: view)
                    }
                }
            }
        }
    }

    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if let textView = self.selectedAddTextView {
            if self.isPanEnableWhileHandlers {
                handlePanForTextView(gestureRecognizer, textView: textView)
            }
        }
    }

    @objc func handleDisablePanGesture(_ notification: Notification) {
        let userInfo = notification.userInfo as? [String: Any]
        self.isPanEnableWhileHandlers = userInfo?["isEnable"] as? Bool ?? false
    }

    @objc func handleUpdatedFrames(_ notification: Notification) {
        let userInfo = notification.userInfo as? [String: Any]
        let updatedFrames = userInfo?["frames"]
        self.updateFramesAfterHandlers(frame: updatedFrames as! CGRect)
    }

    // MARK: - Undo Redo Transform State Capture and Restore For Sticker
    func captureTransformState(for view: UIView) -> StickerTransformState {
        print("Captured state: bounds=\(view.bounds), center=\(view.center), transform=\(view.transform)")
        return StickerTransformState(
            bounds: view.bounds,
            center: view.center,
            transform: view.transform
        )
    }

    func restoreTransformState(_ state: StickerTransformState, to view: UIView) {
        print("Restoring state: bounds=\(state.bounds), center=\(state.center), transform=\(state.transform)")
        view.bounds = state.bounds
        view.center = state.center
        view.transform = state.transform
    }
    
    func registerTransformUndoRedo(for sticker: UIView, from initialState: StickerTransformState) {
        let finalState = captureTransformState(for: sticker)

        undoRedoManager.registerUndo(withTarget: self) { [weak self] target in
            print("Undo: restoring to initial state")
            self?.restoreTransformState(initialState, to: sticker)
            target.registerRedo(for: sticker, from: finalState)
        }

        undoRedoManager.setActionName("Transform Sticker")
        isEnableRedoUndo()
        print("Undo registered")
    }

    func registerRedo(for sticker: UIView, from state: StickerTransformState) {
        let currentState = captureTransformState(for: sticker)

        undoRedoManager.registerUndo(withTarget: self) { [weak self] target in
            print("Redo: restoring to redo state")
            self?.restoreTransformState(state, to: sticker)
            target.registerRedo(for: sticker, from: currentState)
        }

        undoRedoManager.setActionName("Transform Sticker")
        isEnableRedoUndo()
        print("Redo registered")
    }
    
    // MARK: - Undo Redo Transform State Capture and Restore For Text
    func captureTextTransformState(for textView: UILabel) -> TextTransformState {
        return TextTransformState(
            frame: textView.frame,
            center: textView.center,
            transform: textView.transform,
            pointSize: textView.font?.pointSize ?? 17
        )
    }

    func restoreTextTransformState(_ state: TextTransformState, to textView: UILabel) {
        textView.transform = state.transform
        textView.center = state.center
        updateTextViewFrameToFitText(textView as! AddTextView, fontSize: state.pointSize)
    }
    
    func registerTextTransformUndoRedo(for text: UILabel, from initialState: TextTransformState) {
        let finalState = captureTextTransformState(for: text)

        undoRedoManager.registerUndo(withTarget: self) { [weak self] target in
            print("Undo: restoring to initial state")
            self?.restoreTextTransformState(initialState, to: text)
            target.registerTextRedo(for: text, from: finalState)
        }

        undoRedoManager.setActionName("Transform Text")
        isEnableRedoUndo()
        print("Undo registered")
    }

    func registerTextRedo(for text: UILabel, from state: TextTransformState) {
        let currentState = captureTextTransformState(for: text)

        undoRedoManager.registerUndo(withTarget: self) { [weak self] target in
            print("Redo: restoring to redo state")
            self?.restoreTextTransformState(state, to: text)
            target.registerTextRedo(for: text, from: currentState)
        }

        undoRedoManager.setActionName("Transform Text")
        isEnableRedoUndo()
        print("Redo registered")
    }
    
    // MARK: - Pinch Gesture Recognizers for Stickers and Text
    @objc func pinchRecognized(pinchGesture: UIPinchGestureRecognizer) {
        if let selcStickerView = self.selectedAddSticker {
            switch pinchGesture.state {
            case .began:
                // Capture initial state
                if selcStickerView.layer.value(forKey: "initialState") == nil {
                    let state = captureTransformState(for: selcStickerView)
                    selcStickerView.layer.setValue(state, forKey: "initialState")
                    print("Pinch began - captured initial state")
                }
            case .changed:
                let pinchScale: CGFloat = pinchGesture.scale
                if stickerScale * pinchScale < 100.0 && stickerScale * pinchScale > 0.3 {
                    stickerScale *= pinchScale
                    selcStickerView.transform = selcStickerView.transform.scaledBy(x: pinchScale, y: pinchScale)
                }
                pinchGesture.scale = 1.0
            case .ended:
                self.selectedAddSticker?.handles.forEach { $0.isHidden = false }
                // Register undo
                self.removeAlignmentLines()
                if let initialState = selcStickerView.layer.value(forKey: "initialState") as? StickerTransformState {
                    self.registerTransformUndoRedo(for: selcStickerView, from: initialState)
                    selcStickerView.layer.setValue(nil, forKey: "initialState")
                    print("Pinch ended - registered undo")
                }
                self.removeAlignmentLines()

            default:
                break
            }
        }
        
        if let textView = self.selectedAddTextView {
            //let textView = self.selectedText()
            if pinchGesture.state == .began {
                if let font = textView.font {
                    pointSize = font.pointSize
                }
                
                if textView.layer.value(forKey: "initialTextState") == nil {
                    let state = captureTextTransformState(for: textView)
                    textView.layer.setValue(state, forKey: "initialTextState")
                }
                
                pinchGesture.scale = 1.0
            }
            
            if pinchGesture.state == .changed {
                let newSize = pointSize * pinchGesture.scale
                let clampedSize = max(10, min(newSize, 500)) // Limit font size

                
                // Use updateTextViewFrameToFitText to apply the font and resize
                updateTextViewFrameToFitText(textView, fontSize: clampedSize)
            }
            
            if pinchGesture.state == .ended {
                areAlignmentLinesVisible = false
                removeAlignmentLines()
                if let initialState = textView.layer.value(forKey: "initialTextState") as? TextTransformState {
                    registerTextTransformUndoRedo(for: textView, from: initialState)
                    textView.layer.setValue(nil, forKey: "initialTextState")
                }
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
                    let transform = self.scrollView.transform.scaledBy(x: pinchGesture.scale, y: pinchGesture.scale)
                    self.scrollView.transform = transform
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
                    let currentScale = sqrt(abs(self.scrollView.transform.a * self.scrollView.transform.d - self.scrollView.transform.b * self.scrollView.transform.c))
                    if currentScale <= self.minScaleImage {
                        tmpScale = self.minScaleImage
                        UIView.animate(withDuration: 0.2, animations: {
                            self.scrollView.transform = CGAffineTransform(scaleX: tmpScale, y: tmpScale)
                            if let defaultCropperState = self.initialState {
                                self.restoreState(defaultCropperState)
                            }
                        })
                    } else if self.maxScaleImage <= currentScale {
                        tmpScale = self.maxScaleImage
                        UIView.animate(withDuration: 0.2, animations: {
                            self.scrollView.transform = CGAffineTransform(scaleX: tmpScale, y: tmpScale)
                        })
                    }
                }
            }
        }
    }

    // MARK: - Rotate Gesture Recognizers for Stickers and Text
    
    @objc func handleRotate(recognizer: UIRotationGestureRecognizer) {
        if let view = selectedAddSticker {
            if recognizer.state == .began {
                // Capture initial state
                if view.layer.value(forKey: "initialState") == nil {
                    let state = captureTransformState(for: view)
                    view.layer.setValue(state, forKey: "initialState")
                    print("Rotate began - captured initial state")
                }
            } else if recognizer.state == .changed {
                let originalCenter = view.center
                var rotationAngle = recognizer.rotation
                
                if isFlippedSelected {
                    rotationAngle = -rotationAngle
                }
                if isMirroredSelected {
                    rotationAngle = -rotationAngle
                }
                
                view.transform = view.transform.rotated(by: rotationAngle)
                recognizer.rotation = 0
                view.center = originalCenter
                //self.centerDashLineMargin.center = view.center
                //self.centerDashLineMargin.isHidden = false
            } else if recognizer.state == .ended {
                self.selectedAddSticker?.handles.forEach { $0.isHidden = false }
                
                // Register undo
                if let initialState = view.layer.value(forKey: "initialState") as? StickerTransformState {
                    self.registerTransformUndoRedo(for: view, from: initialState)
                    view.layer.setValue(nil, forKey: "initialState")
                    print("Rotate ended - registered undo")
                }
            }
        }
        
        guard let view = selectedAddTextView else { return }
        
        if recognizer.state == .began {
            if textView.layer.value(forKey: "initialTextState") == nil {
                let state = captureTextTransformState(for: view)
                view.layer.setValue(state, forKey: "initialTextState")
            }
            
        } else if recognizer.state == .changed {
            let originalCenter = view.center
            view.transform = view.transform.rotated(by: recognizer.rotation)
            self.selectedAddTextView?.updatingTransformOfTextView(transform: view.transform.rotated(by: recognizer.rotation))
            recognizer.rotation = 0
            view.center = originalCenter
            
            let maxWidth: CGFloat = UIScreen.main.bounds.width * 0.9
            let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.9
            let minSize: CGFloat = 50
            
            if view.bounds.width > maxWidth {
                view.bounds.size.width = maxWidth
            } else if view.bounds.width < minSize {
                view.bounds.size.width = minSize
            }
            
            if view.bounds.height > maxHeight {
                view.bounds.size.height = maxHeight
            } else if view.bounds.height < minSize {
                view.bounds.size.height = minSize
            }
            
            //self.centerDashLineMargin.center = view.center
            //self.centerDashLineMargin.isHidden = false
        } else if recognizer.state == .ended {
            areAlignmentLinesVisible = false
            removeAlignmentLines()
            if let initialState = view.layer.value(forKey: "initialTextState") as? TextTransformState {
                registerTextTransformUndoRedo(for: view, from: initialState)
                view.layer.setValue(nil, forKey: "initialTextState")
            }
        }
    }

    @objc func handleTapStickerView(_ gestureRecognizer: UITapGestureRecognizer) {
        if isEditAddPhoto == false {
            if !self.option.isTransformActual {
                switch gestureRecognizer.state {
                case .ended:
                    print(doubleTapRecognizedRecently)
                    
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
                        if self.filterSelection == .gallery, self.isTextSelected() {
                            self.filterSelection = .text
                        }
                        
                        switch self.filterSelection {
                        case .sticker:
                            self.applySticker()
                            self.applyImageView()
                            self.hideCrossTickOnly()
                            self.removeBottomSubViews()
                            self.filterSelection = FilterSelection(rawValue: -1)
                            self.mainCollectionView.isHidden = false
                            self.isShowingRedoUndo()
                            self.mainCollectionView.reloadData()
                            
                        case .gallery:
                            self.applySticker()
                            self.applyImageView()
                            self.hideCrossTickOnly()
                            self.removeBottomSubViews()
                            self.filterSelection = FilterSelection(rawValue: -1)
                            self.mainCollectionView.isHidden = false
                            self.isShowingRedoUndo()
                            self.mainCollectionView.reloadData()
                        case .text:
                            self.isShowingRedoUndo()
                            self.applySubOptionsForText()
                            self.applyText()
                            self.applyImageView()
                            self.hideCrossTickOnly()
                            self.removeBottomSubViews()
                            self.filterSelection = FilterSelection(rawValue: -1)
                            self.mainCollectionView.isHidden = false
                            self.mainCollectionView.reloadData()
                        default:
                            break
                        }
                        isEnableRedoUndo()
                        isShowingRedoUndo()
                    }
                case .began:
                    print("fff")
                case .possible: break
                    
                case .changed: break
                    
                case .cancelled: break
                    
                case .failed: break
                    
                @unknown default: break
                    
                }
            }
        }
    }

    @objc func posGesturesToStickerTextView() {
        if let existingPanGesture = self.stickerPanGesture {
            self.stickerTextView.removeGestureRecognizer(existingPanGesture)
        }

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        self.stickerTextView.addGestureRecognizer(pan)
        self.stickerPanGesture = pan
    }

    // MARK: - Pan Gesture Handling for Stickers and Text
    func handlePanForSticker(_ gestureRecognizer: UIPanGestureRecognizer, stickerView: UIView) {
        if self.magnifyingGlass.magnifiedView == nil, self.option.isFramesSelected == false {
            //self.alignment()
            switch gestureRecognizer.state {
            case .began:
                // Capture initial state
                if gestureRecognizer.view?.layer.value(forKey: "initialState") == nil {
                    let state = captureTransformState(for: gestureRecognizer.view!)
                    gestureRecognizer.view?.layer.setValue(state, forKey: "initialState")
                    print("Pan began - captured initial state")
                }
            case .changed:
                self.panWhenChangedForSticker(gestureRecognizer)
            case .ended:
                self.selectedAddSticker?.handles.forEach { $0.isHidden = false }
                
                // Register undo
                if let initialState = gestureRecognizer.view?.layer.value(forKey: "initialState") as? StickerTransformState {
                    self.registerTransformUndoRedo(for: gestureRecognizer.view!, from: initialState)
                    gestureRecognizer.view?.layer.setValue(nil, forKey: "initialState")
                    print("Pan ended - registered undo")
                }
            default:
                break
            }
        }
    }

    private func handlePanForTextView(_ gestureRecognizer: UIPanGestureRecognizer, textView: UIView) {
        guard selectedAddTextView == textView else { return }

        if self.magnifyingGlass.magnifiedView == nil {
            //self.alignmentText()
            switch gestureRecognizer.state {
            case .began:
                // Capture initial state
                if textView.layer.value(forKey: "initialTextState") == nil {
                    let state = captureTextTransformState(for: textView as! UILabel)
                    textView.layer.setValue(state, forKey: "initialTextState")
                    print("Pan began - captured initial state")
                }
            case .changed:
                let translation = gestureRecognizer.translation(in: textView.superview)
                if abs(translation.x) > 2 || abs(translation.y) > 2 {
                    textView.center = CGPoint(x: textView.center.x + translation.x,
                                            y: textView.center.y + translation.y)
                    gestureRecognizer.setTranslation(.zero, in: textView.superview)
                }
            case .ended:
                if let initialState = textView.layer.value(forKey: "initialTextState") as? TextTransformState {
                    registerTextTransformUndoRedo(for: textView as! UILabel, from: initialState)
                    textView.layer.setValue(nil, forKey: "initialTextState")
                }
                areAlignmentLinesVisible = false
            default:
                break
            }
        }
    }

    func panWhenChangedForSticker(_ gestureRecognizer: UIPanGestureRecognizer) {
        _ = gestureRecognizer.translation(in: self.stickerTextView)
        let point = gestureRecognizer.location(in: self.stickerTextView)
        let superview = self.stickerTextView
        let restrictByPoint : CGFloat = 9.0
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

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}

// MARK: - Helper Methods
extension CAEditViewController {
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

    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(named: .stickerColor)?.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [7, 3]

        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }

    func calculatingMainImageViewSize() {
        let gettingImage : UIImage
        gettingImage = mainImageView.image ?? imageOrignal
        let imageSize = gettingImage.size
        let imageViewSize = self.mainImageViewSize
        let imageViewAspectRatio = imageViewSize!.width / imageViewSize!.height
        let imageAspectRatio = imageSize.width / imageSize.height
        
        if imageAspectRatio > imageViewAspectRatio {
            let scaleFactor = (imageViewSize?.width ?? 0) / imageSize.width
            let height = imageSize.height * scaleFactor
            mainImageScaledSize = CGSize(width: imageViewSize?.width ?? 0, height: height)
        } else {
            let scaleFactor = (imageViewSize?.height ?? 0.0) / imageSize.height
            let width = imageSize.width * scaleFactor
            mainImageScaledSize = CGSize(width: width, height: imageViewSize?.height ?? 0)
        }
    }
}

// MARK: - Undo/Redo Operations
extension CAEditViewController {
    func moveSticker(to frame: CGRect, transform: CGAffineTransform, for sticker: AddSticker) {
        let currentFrame = sticker.frame
        let currentTransform = sticker.transform

        sticker.frame = frame
        sticker.transform = transform

        undoRedoManager.registerUndo(withTarget: self) { target in
            target.moveSticker(to: currentFrame, transform: currentTransform, for: sticker)
        }
        undoRedoManager.setActionName("Move Sticker")
        self.isEnableRedoUndo()
        self.removeAlignmentLines()
    }

    func moveText(to frame: CGRect, transform: CGAffineTransform, for text: AddTextView) {
        let currentFrame = text.frame
        let currentTransform = text.transform

        text.frame = frame
        text.transform = transform

        undoRedoManager.registerUndo(withTarget: self) { target in
            target.moveText(to: currentFrame, transform: currentTransform, for: text)
        }
        undoRedoManager.setActionName("Move Text")
        self.isEnableRedoUndo()
        self.removeAlignmentLines()
    }

    func resizeSticker(to pinchScale: CGAffineTransform, for sticker: AddSticker) {
        let previousScale = sticker.transform
        sticker.transform = pinchScale

        undoRedoManager.registerUndo(withTarget: self) { target in
            target.resizeSticker(to: previousScale, for: sticker)
        }
        undoRedoManager.setActionName("Resize Sticker")
        isEnableRedoUndo()
        self.removeAlignmentLines()
    }

    func resizeText(to frame: CGRect, transform: CGAffineTransform, pointSize: CGFloat, previosPointSize: CGFloat, for text: AddTextView) {
        let currentFrame = text.frame
        let currentTransform = text.transform

        updateTextViewFrameToFitText(text, fontSize: pointSize)

        undoRedoManager.registerUndo(withTarget: self) { target in
            target.resizeText(to: currentFrame, transform: currentTransform, pointSize: previosPointSize, previosPointSize: pointSize, for: text)
        }
        undoRedoManager.setActionName("Resize text")
        isEnableRedoUndo()
        self.removeAlignmentLines()
    }

    func rotateSticker(to bounds: CGRect, transform: CGAffineTransform, center: CGPoint, for sticker: AddSticker) {
        let currentCenter = sticker.center
        let currentBounds = sticker.bounds
        let currentTransform = sticker.transform

        sticker.transform = .identity
        sticker.bounds = bounds
        sticker.center = center
        sticker.transform = transform

        undoRedoManager.registerUndo(withTarget: self) { target in
            target.rotateSticker(to: currentBounds, transform: currentTransform, center: currentCenter, for: sticker)
        }
        undoRedoManager.setActionName("Rotate Sticker")
        isEnableRedoUndo()
        self.removeAlignmentLines()
    }

    func rotateText(to bounds: CGRect, transform: CGAffineTransform, center: CGPoint, for text: AddTextView) {
        let currentCenter = text.center
        let currentBounds = text.bounds
        let currentTransform = text.transform

        text.transform = .identity
        text.bounds = bounds
        text.center = center
        text.transform = transform

        undoRedoManager.registerUndo(withTarget: self) { target in
            target.rotateText(to: currentBounds, transform: currentTransform, center: currentCenter, for: text)
        }
        undoRedoManager.setActionName("Rotate Text")
        isEnableRedoUndo()
        self.removeAlignmentLines()
    }

    func performUndoFontChange(view: AddTextView, fontName: String, font: UIFont, fontIndex: Int, originalSize: CGSize, maxSize: CGSize) {
        let currentFont = view.font ?? UIFont.systemFont(ofSize: 18)
        let currentFontName = view.selectedFont
        let currentFontIndex = view.selectedFontIndex

        view.font = UIFont(name: fontName, size: font.pointSize) ?? font
        view.selectedFont = fontName
        view.selectedFontIndex = fontIndex

        let maxWidth: CGFloat = self.mainImageScaledSizeForText.width
        let maxHeight: CGFloat = self.mainImageScaledSizeForText.height
        let originalSize = view.bounds.size

        let undoSize = sizeForView(
            text: view.text ?? "",
            font: currentFont,
            maxSize: CGSize(width: maxWidth, height: maxHeight),
            padding: 10.0
        ).0

        view.bounds.size.width = max(originalSize.width, undoSize.width)
        view.bounds.size.height = max(originalSize.height, undoSize.height)
        view.setNeedsDisplay()

        updateTextViewFrameToFitText(view, fontSize: font.pointSize)

        self.textView.setUpTextAndColor(views: [view])

        undoRedoManager.registerUndo(withTarget: self) { target in
            target.performUndoFontChange(
                view: view,
                fontName: currentFontName,
                font: currentFont,
                fontIndex: currentFontIndex,
                originalSize: originalSize,
                maxSize: maxSize
            )
        }
        self.textView.setUpTextAndColor(views: [view])
        undoRedoManager.setActionName("Change Text Font")
        isEnableRedoUndo()
    }

    func performUndoColorChange(view: AddTextView, previousColor: UIColor, previousIndex: Int) {
        let currentTextColor = view.textColor
        _ = view.selectedColor
        let currentSelectedColorIndex = view.selectedColorIndex
        if currentSelectedColorIndex == 100 {
            self.textView.setUpPickerColor(views: [view], color: previousColor)
        } else {
            self.textView.updateFontColor(color: previousColor)

        }
        view.textColor = previousColor
        view.selectedColor = previousColor
        view.selectedColorIndex = previousIndex

        self.textView.setUpTextAndColor(views: [view])
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()

        undoRedoManager.registerUndo(withTarget: self) { target in
            target.performUndoColorChange(view: view, previousColor: currentTextColor!, previousIndex: currentSelectedColorIndex)
            target.undoRedoManager.setActionName("Change Text Color")
            target.isEnableRedoUndo()
        }
        self.textView.setUpTextAndColor(views: [view])
        self.textView.updateFontColor(color: previousColor)

    }

    func performUndoStickerColorChange(view: AddSticker, previousColor: UIColor, previousIndex: Int, model: ColorModel) {
        let currentTextColor = view.tintColor
        _ = view.selectedColor
        let currentSelectedColorIndex = view.selectedColorIndex
        if currentSelectedColorIndex == 100 {
            self.stickerOption.setUpPickerColor(color: previousColor, model: model)
        } else {
            self.stickerOption.setUpColor(color: previousColor, model: model)

        }
        view.tintColor = previousColor
        view.selectedColor = previousColor
        view.selectedColorIndex = previousIndex

        
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()

        undoRedoManager.registerUndo(withTarget: self) { target in
            target.performUndoStickerColorChange(view: view, previousColor: currentTextColor!, previousIndex: currentSelectedColorIndex, model: model)
            target.undoRedoManager.setActionName("Change Sticker Color")
            target.isEnableRedoUndo()
        }
        if currentSelectedColorIndex == 100 {
            self.stickerOption.setUpPickerColor(color: previousColor, model: model)
        } else {
            self.stickerOption.setUpColor(color: previousColor, model: model)

        }
    }
    
    private func applyFlipState(to view: AddSticker, with state: StickerFlipState) {
        view.image = state.image

        undoRedoManager.registerUndo(withTarget: self) { target in
            target.stickersText(text: .mirror, isText: false)
        }

        self.undoRedoManager.setActionName("Mirror Sticker")
        self.isEnableRedoUndo()
    }

    func changeStickerOpacity(view: AddSticker, opacity: CGFloat) {
        let previousOp = view.alpha
        view.alpha = opacity
        self.stickerOption.updatingColor(views: [view])
        undoRedoManager.registerUndo(withTarget: self) { target in
            target.stickersText(text: .setOpacityEnd, opacity: previousOp, isText: false)
        }
        self.stickerOption.updatingColor(views: [view])
        undoRedoManager.setActionName("Change Opacity")
        isEnableRedoUndo()
    }

    func changeTextOpacity(view: AddTextView, opacity: CGFloat) {
        let previousOpacity = view.alpha
        view.alpha = opacity
        self.textView.setUpOpacity(views: [view])
        undoRedoManager.registerUndo(withTarget: self) { target in
            target.stickersText(text: .setOpacityEnd, opacity: previousOpacity, isText: true)
        }
        self.textView.setUpOpacity(views: [view])
        undoRedoManager.setActionName("Change Text Opacity")
        isEnableRedoUndo()
    }

    func applyTextAlignmentRight(_ alignment: NSTextAlignment, to view: AddTextView) {
        let previous = view.textAlignment
        if alignment == .center {
            view.textPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else if alignment == .left {
            view.textPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
        } else if alignment == .right {
            view.textPadding = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        }
        view.textAlignment = alignment
        view.setNeedsDisplay()
        self.textView.setUpAlignment(views: [view])
        undoRedoManager.registerUndo(withTarget: self) { target in
            self.stickersText(text: .setRight, isText: true)
        }
        self.textView.setUpAlignment(views: [view])
        undoRedoManager.setActionName("Change Text Right Alignment")
        isEnableRedoUndo()
    }

    func applyTextAlignmentLeft(_ alignment: NSTextAlignment, to view: AddTextView) {
        let previous = view.textAlignment
        if alignment == .center {
            view.textPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else if alignment == .left {
            view.textPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
        } else if alignment == .right {
            view.textPadding = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        }
        view.textAlignment = alignment
        view.setNeedsDisplay()
        self.textView.setUpAlignment(views: [view])
        undoRedoManager.registerUndo(withTarget: self) { target in
            self.stickersText(text: .setLeft, isText: true)
        }
        self.textView.setUpAlignment(views: [view])
        undoRedoManager.setActionName("Change Text Left Alignment")
        isEnableRedoUndo()
    }

    func applyTextAlignmentCenter(_ alignment: NSTextAlignment, to view: AddTextView) {
        let previous = view.textAlignment

        if alignment == .center {
            view.textPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else if alignment == .left {
            view.textPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
        } else if alignment == .right {
            view.textPadding = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        }
        view.textAlignment = alignment
        view.setNeedsDisplay()
        self.textView.setUpAlignment(views: [view])
        undoRedoManager.registerUndo(withTarget: self) { target in
            self.stickersText(text: .setCenter, isText: true)
        }
        self.textView.setUpAlignment(views: [view])
        undoRedoManager.setActionName("Change Text Center Alignment")
        isEnableRedoUndo()
    }

    func isEnableRedoUndo() {
        self.undoRedoManager.levelsOfUndo = 10
        undoButton.isEnabled = self.undoRedoManager.canUndo
        redoButton.isEnabled = self.undoRedoManager.canRedo
        self.removeAlignmentLines()
    }

    func isShowingRedoUndo() {
        undoButton.isHidden = true
        redoButton.isHidden = true
    }

    func isShownRedoUndo() {
        undoButton.isHidden = true
        redoButton.isHidden = true
    }
    
    func globalUndoRedo(currentFilterSelection: FilterSelection) {
        self.resetImageView()
        self.filterSelection = currentFilterSelection
        if currentFilterSelection == .none {
            self.mainCollectionView.isHidden = false
            self.stickerTextView.isUserInteractionEnabled = true
        } else {
            self.stickerTextView.isUserInteractionEnabled = true
            self.mainCollectionView.isHidden = true
        }
        if let defaultCropperState = self.initialState {
            self.restoreState(defaultCropperState)
        }
        self.backgroundView.transform = .identity
    }
}

// MARK: - Text View Management
extension CAEditViewController {
    func updateTextViewFrameToFitText(_ textView: AddTextView, fontSize: CGFloat? = nil) {
        guard let text = textView.text, !text.isEmpty else {
            textView.bounds.size = CGSize(width: 80, height: 55)  // Minimum size when empty
            return
        }
        
        textView.numberOfLines = 0 // Enable multiline
        textView.clipsToBounds = false  // allow text overflow if needed
        
        // Optional: apply new font size if provided
        if let fontSize = fontSize, let fontName = textView.font?.fontName {
            textView.font = UIFont(name: fontName, size: fontSize)
        }

        let minWidth: CGFloat = 80
        let maxWidth: CGFloat = self.mainImageScaledSizeForText.width
        let maxHeight: CGFloat = self.mainImageScaledSizeForText.height
        var padding: CGFloat = 16 * (fontSize!/24) // Adjust padding based on font size

        if textView.textAlignment == .right {
            textView.textPadding = UIEdgeInsets(top: 0, left: 2 * (fontSize!/24), bottom: 0, right: 15 * (fontSize!/24))
        } else if textView.textAlignment == .left {
            textView.textPadding = UIEdgeInsets(top: 0, left: 15 * (fontSize!/24), bottom: 0, right: 2 * (fontSize!/24))
        } else {
            textView.textPadding = UIEdgeInsets(top: 0, left: 5 * (fontSize!/24), bottom: 0, right: 5 * (fontSize!/24))
        }
        

        // Calculate new size for text
        let boundingSize = CGSize(width: maxWidth, height: maxHeight)
        let textSize = textView.sizeThatFits(boundingSize)
        
        let updatedWidth = max(textSize.width + 2 * padding, minWidth)
        //max(minWidth, min(maxWidth, textSize.width + (2 * padding) + 30))
        //let updatedHeight = max(55, min(maxHeight, textSize.height + (2 * padding)))
        let updatedHeight = max(textSize.height + 2 * padding, 55)
        
        
        let originalCenter = textView.center
        
        textView.bounds.size = CGSize(width: updatedWidth, height: updatedHeight)
        
        textView.clipsToBounds = false  // allow text overflow if needed
        textView.adjustsFontSizeToFitWidth = true

    }
    /*
     func updateTextViewFrameToFitText(_ textView: UILabel, fontSize: CGFloat? = nil) {
         // Set the label to support multiple lines
         textView.numberOfLines = 0

         // Update the font size if provided
         if let fontSize = fontSize, let fontName = textView.font?.fontName {
             textView.font = UIFont(name: fontName, size: fontSize)
         }

         // Get the current width and height from the label itself
         let currentWidth = textView.bounds.width
         let currentHeight = textView.bounds.height
         let maxWidth: CGFloat = UIScreen.main.bounds.width - 16

         let padding: CGFloat = 16

         // Calculate the bounding size based on the current dimensions
         let boundingSize = CGSize(width: currentWidth - 2 * padding, height: CGFloat.greatestFiniteMagnitude)
         let textSize = textView.sizeThatFits(boundingSize)

         let updatedWidth = max(55, min(maxWidth, textSize.width + 2 * padding))
         let updatedHeight = max(textSize.height + 2 * padding, 55)

         // Preserve the original center
         let originalCenter = textView.center

         // Update the label size
         textView.bounds.size = CGSize(width: updatedWidth, height: updatedHeight)
         textView.center = originalCenter

         // Update the outline if present
         if let outlineLayer = textView.layer.sublayers?.first(where: { $0 is CAShapeLayer }) as? CAShapeLayer {
             let path = UIBezierPath(rect: textView.bounds.insetBy(dx: 8, dy: 8))
             outlineLayer.path = path.cgPath
             outlineLayer.frame = textView.bounds
         }
     }**/

    func calculateTextSize(text: String, font: UIFont, maxWidth: CGFloat) -> CGSize {
        let constraintSize = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let boundingBox = text.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        return CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
    }
}

// MARK: - Alignment Helpers
extension CAEditViewController {
    func calculatingLeftRightAlignment(view: UIView) -> Bool {
        var shouldShowOutline = false

        let leftAlign = view.frame.origin.x
        let mainViewWidth = self.scrollView.frame.size.width - 16 - view.frame.size.width
        let rightAlign = leftAlign - mainViewWidth

        if leftAlign <= 10 {
            self.haptic()
            self.leftAlignMargin.isHidden = false
            shouldShowOutline = true
        } else {
            self.leftAlignMargin.isHidden = true
        }

        if rightAlign >= 6 {
            self.haptic()
            self.rightAlignMargin.isHidden = false
            shouldShowOutline = true
        } else {
            self.rightAlignMargin.isHidden = true
        }

        return shouldShowOutline
    }

    func calculatingTopBottomAlignment(view: UIView) -> Bool {
        var shouldShowOutline = false

        let topAlign = view.frame.origin.y
        let mainViewHeight = self.scrollView.frame.size.height - 16 - view.frame.size.height
        let bottomAlign = topAlign - mainViewHeight

        if topAlign <= 10 {
            self.haptic()
            self.topAlignMargin.isHidden = false
            shouldShowOutline = true
        } else {
            self.topAlignMargin.isHidden = true
        }

        if bottomAlign >= 6 {
            self.haptic()
            self.bottomAlignMargin.isHidden = false
            shouldShowOutline = true
        } else {
            self.bottomAlignMargin.isHidden = true
        }

        return shouldShowOutline
    }

    func calculatingCenterAlignment(view: UIView) -> Bool {
        var shouldShowOutline = false

        if view.center.y + 8 >= self.stickerTextView.bounds.midY + 6 && view.center.y + 8 <= self.stickerTextView.bounds.midY + 10 {
            self.haptic()
            self.centerVerticalMargin.isHidden = false
            shouldShowOutline = true
        } else {
            self.centerVerticalMargin.isHidden = true
        }

        if view.center.x + 8 >= self.stickerTextView.bounds.midX + 6 && view.center.x + 8 <= self.stickerTextView.bounds.midX + 10 {
            self.haptic()
            self.centerHorizontalMargin.isHidden = false
            shouldShowOutline = true
        } else {
            self.centerHorizontalMargin.isHidden = true
        }

        return shouldShowOutline
    }

    func updateAlignment(view: UIView) {
        let leftRight = calculatingLeftRightAlignment(view: view)
        let topBottom = calculatingTopBottomAlignment(view: view)

        let shouldShowOutline = leftRight || topBottom

        selectedAddTextView?.toggleOutline(show: shouldShowOutline)
        areAlignmentLinesVisible = shouldShowOutline
    }

    func hideAllMargin() {
        if self.leftAlignMargin.isHidden == false && self.rightAlignMargin.isHidden == false
            && self.topAlignMargin.isHidden == false
            && self.bottomAlignMargin.isHidden == false
            && self.centerVerticalMargin.isHidden == false
            && self.centerHorizontalMargin.isHidden == false {
            self.leftAlignMargin.isHidden = true
            self.rightAlignMargin.isHidden = true
            self.topAlignMargin.isHidden = true
            self.bottomAlignMargin.isHidden = true
            self.centerVerticalMargin.isHidden = true
            self.centerHorizontalMargin.isHidden = true
        }
    }

    func haptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func removeAlignmentLines() {
        self.selectedAddTextView?.removeOutline()
        alignmentHideTimer?.invalidate()
        alignmentHideTimer = nil
        self.selectedAddTextView?.outlineLayer?.isHidden = true

        self.leftAlignMargin.isHidden = true
        self.rightAlignMargin.isHidden = true
        self.topAlignMargin.isHidden = true
        self.bottomAlignMargin.isHidden = true
        self.centerVerticalMargin.isHidden = true
        self.centerHorizontalMargin.isHidden = true
        self.centerDashLineMargin.isHidden = true
    }
}

// MARK: - Sticker and Text Management
extension CAEditViewController {
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

    func toShowDeleteButtonForText(view: AddTextView, isDelete: Bool) {
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: !isDelete)
        view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
        view.layer.borderWidth = isDelete ? 1 : 0
        view.isSelected = isDelete
        self.selectedAddTextView = view
    }

    func toHideDeleteButtonAndSelectionForText(view: AddTextView, isDelete: Bool) {
        view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
        view.borderView.isHidden = true
        view.isSelected = isDelete
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: !isDelete)
    }

    func toEditText(view: AddTextView, dictionary: [String:Any]? = nil) {
        view.text = dictionary?[EditStaticStrings.text] as? String
        let font = dictionary?[EditStaticStrings.font] as? String
        view.font = UIFont.init(name: font ?? "", size: view.font.pointSize)
        let color = dictionary?[EditStaticStrings.color] as? UIColor
        view.textColor = color
        view.setNeedsDisplay()
        view.button.frame.origin.x = view.bounds.size.width - 40
        view.button.setNeedsDisplay()
        view.tag = textTempTags
        self.stickersText(text: .resetEdit, isText: true)
    }

    func deleteSticker(view: AddSticker, isDelete: Bool) {
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: !isDelete)
        view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
        view.layer.borderWidth = isDelete ? 1 : 0
        view.isSelected = isDelete
        self.selectedAddSticker = view
    }

    func toHideDeleteButtonAndSelectionForSticker(view: AddSticker, isDelete: Bool) {
        view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
        view.layer.borderWidth = 0
        view.isSelected = isDelete
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: !isDelete)
    }

    func toShowFlipOnSticker(view: AddSticker) {
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
        case .downMirrored:
            break
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

    func replaceWhiteColor(in image: UIImage?, with color: UIColor) -> UIImage? {
        guard let image = image else { return nil }
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        image.draw(in: rect)

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
}

// MARK: - Utility Methods
extension CAEditViewController {
    func isAnyOptionSelected() -> Bool {
        switch self.filterSelection {
        case .transform, .text, .sticker, .frame, .brush:
            return true
        default:
            return false
        }
    }

    func removePanGesture() {
        if let pan = self.stickerPanGesture {
            self.stickerTextView.removeGestureRecognizer(pan)
            self.stickerPanGesture = nil
        }
    }
    
    func stickersText(text: TextStickersOption,textModel: TextModel? = nil, color: ColorModel? = nil, fontName: String? = "", index: Int? = 0, dictionary: [String:Any]? = nil, opacity: CGFloat = 0.0, isText: Bool) {
        
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
                                view.borderView.isHidden = false
                                self.selectedAddTextView = view
                                self.selectedAddTextView?.handles.forEach { handle in
                                    self.selectedAddTextView?.bringSubviewToFront(handle)
                                }
                            } else {
                                self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
                                view.isSelected = false
                                view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
                                view.borderView.isHidden = true
                            }
                        case .hideSelection:
                            view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
                            view.borderView.isHidden = true
                            view.isSelected = false
                        case .hideDeleteButton:
                            self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
                            view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
                            view.layer.borderWidth = 0
                            view.borderView.isHidden = true
                            view.isSelected = false
                            self.selectedAddTextView = nil
                            
                        case .showDeleteButtonOnTap:
                            if view.tag == textMoveTempTags || view.tag == textMoveSavedTags || view.tag == textEditTags || view.tag == textTempEditTags {
                                view.borderView.isHidden = false
                                view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
                                self.setupAddDeleteFlipAndOnTopButtons(isHidden: false)
                                view.isSelected = true
                                self.selectedAddTextView = view
                                let textModel = TextModel()
                                textModel.color = view.selectedColor
                                textModel.selectedColorIndex = view.selectedColorIndex
                                textModel.previousColor = view.previousColor
                                textModel.previousSelectedColorIndex = view.previousSelectedColorIndex
                                textModel.backgroungColor = view.selectedBackgroundColor
                                textModel.selectedBackGrounfColorIndex = view.selectedBackGrounfColorIndex
                                textModel.previousBackgroundColor = view.previousBackgroundColor
                                textModel.previousSelectedBackgroundColorIndex = view.previousSelectedBackgroundColorIndex

                                self.selectedTextModel = textModel
                            } else {
                                view.isSelected = false
                                view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
                                view.borderView.isHidden = true
                            }
                        case .replace:
                            break
                        case .edit:
                            
                            if view.tag == textEditTags || view.tag == textTempEditTags {
                                print(view.frame)
                                let oldFrame = view.bounds
                                let oldTransformText = view.transform
                                let center = view.center
                                _ = view.bounds.size.width
                                
                                // Update text, font, and color
                                view.text = dictionary?[EditStaticStrings.text] as? String
                                let font = dictionary?[EditStaticStrings.font] as? String
                                view.font = UIFont(name: font ?? "", size: view.font.pointSize)
                                let color = dictionary?[EditStaticStrings.color] as? UIColor
                                let backgroundColor = dictionary?[EditStaticStrings.backgroundColor] as? UIColor
                                view.textColor = color
                                view.backgroundColor = backgroundColor
                                view.alpha = textViewOpacity
                                if dictionary?[EditStaticStrings.selectedAlignment] as? String == "center" {
                                    view.textAlignment = .center
                                    view.textPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

                                } else if dictionary?[EditStaticStrings.selectedAlignment] as? String == "left" {
                                    view.textAlignment = .left
                                    view.textPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)

                                } else if dictionary?[EditStaticStrings.selectedAlignment] as? String == "right" {
                                    view.textAlignment = .right
                                    view.textPadding = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
                                }
                                //self.updateTextViewFrameToFitText(view, fontSize: view.font.pointSize)
                                view.frame = oldFrame
                                view.center = center
                                view.transform = oldTransformText
                                view.sizeToFit()
                                self.updateTextViewFrameToFitText(view, fontSize: view.font.pointSize)
                                view.tag = textTempTags
                                self.stickersText(text: .resetEdit, isText: true)
                                print(view.frame)
                            }
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
                                _ = view.textColor ?? .black
                                _ = view.selectedColorIndex
                                
                                var newColor: UIColor = .black
                                var newColorIndex: Int = 0
                                
                                
                                if index == 100 {
                                    newColor = color?.color ?? .black
                                    newColorIndex = 100
                                    // Apply new color
                                    view.textColor = newColor
                                    view.selectedColor = newColor
                                    view.selectedColorIndex = newColorIndex
                                    view.previousColor = textModel?.previousColor ?? .black
                                    view.previousSelectedColorIndex = textModel?.previousSelectedColorIndex ?? 0
                                    
                                    self.textView.setUpPickerColor(views: [view], color: newColor)
                                    
                                } else if index == 101 {
                                    let rgba = color?.color.rgba
                                    let alpha = rgba?.alpha ?? 1
                                    newColor = UIColor(red: rgba?.red ?? 0, green: rgba?.green ?? 0, blue: rgba?.blue ?? 0, alpha: alpha)
                                    newColorIndex = 101
                                    // Apply new color
                                    view.textColor = newColor
                                    view.selectedColor = newColor
                                    view.selectedColorIndex = newColorIndex
                                    view.previousColor = textModel?.previousColor ?? .black
                                    view.previousSelectedColorIndex = textModel?.previousSelectedColorIndex ?? 0
                                    
                                    
                                } else {
                                    
                                    newColor = textModel?.color ?? .black
                                    newColorIndex = textModel?.selectedColorIndex ?? 0
                                    // Apply new color
                                    view.textColor = newColor
                                    view.selectedColor = newColor
                                    view.selectedColorIndex = newColorIndex
                                    view.previousColor = textModel?.previousColor ?? .black
                                    view.previousSelectedColorIndex = textModel?.previousSelectedColorIndex ?? 0
                                }
                            }
                            
                        case .setFont:
                            if view.isSelected == true {
                                //Save previous font state before making changes
                                let initialFont = view.font ?? UIFont.systemFont(ofSize: 18)
                                let initialFontName = view.selectedFont
                                let initialFontIndex = view.selectedFontIndex
                                
                                //Get new font details from text model
                                let currentFontName = textModel?.fontCustom ?? ""
                                let currentFont = UIFont(name: currentFontName, size: initialFont.pointSize) ?? initialFont
                                let currentFontIndex = textModel?.selectedFontIndex ?? 0
                                
                                //Apply new font
                                view.font = currentFont
                                view.selectedFont = currentFontName
                                view.selectedFontIndex = currentFontIndex
                                view.selectedPreviousFont = textModel?.previousFont ?? ""
                                view.selectedPreviousFontIndex = textModel?.previousSelectedFontIndex ?? 0
                                view.selectedText = textModel?.textString ?? ""
                                view.previousText = textModel?.previousTextString ?? ""
                                
                                let maxWidth: CGFloat = self.mainImageScaledSizeForText.width
                                let maxHeight: CGFloat = self.mainImageScaledSizeForText.height
                                let originalSize = view.bounds.size
                                
                                // Get new size with padding
                                let newSize = sizeForView(
                                    text: view.text ?? "",
                                    font: currentFont,
                                    maxSize: CGSize(width: maxWidth, height: maxHeight),
                                    padding: 10.0
                                ).0
                                
                                view.lineBreakMode = .byWordWrapping
                                updateTextViewFrameToFitText(view, fontSize: initialFont.pointSize)
                            }
                        case .setOpacity:
                            if view.isSelected == true {
                                view.alpha = opacity
                            }
                        case .mirror:
                            break
                        case .onTop:
                            if  view.isSelected == true {
                                view.bringSubviewToFront(view)
                            }
                        case .setRight:
                            if view.isSelected == true {
                                let previousAlignment = view.textAlignment
                                let newAlignment: NSTextAlignment = .right
                                // Set the text alignment to the left
                                selectedAddTextView?.textAlignment = .right
                                // Apply padding to the text (adjust the right padding as needed)
                                view.textPadding = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
                                view.setNeedsDisplay()
                                //  editor.updateTextView(textView: view, text: view.text ?? "", textColor: view.textColor, font: view.font ?? UIFont.systemFont(ofSize: 12), opacity: view.alpha, alignment: view.textAlignment)
                                // Register undo
                                self.textView.setUpAlignment(views: [view])
                                self.updateTextViewFrameToFitText(view, fontSize: view.font.pointSize)
                            }
                        case .setLeft:
                            if view.isSelected == true {
                                let previousAlignment = view.textAlignment
                                let newAlignment: NSTextAlignment = .left
                                // Set the text alignment to the left
                                selectedAddTextView?.textAlignment = .left
                                view.textPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)
                                self.textView.setUpAlignment(views: [view])
                                self.updateTextViewFrameToFitText(view, fontSize: view.font.pointSize)
                            }
                            
                        case .setCenter:
                            if view.isSelected == true {
                                let previousAlignment = view.textAlignment
                                let newAlignment: NSTextAlignment = .center
                                // Set the text alignment to the left
                                selectedAddTextView?.textAlignment = .center
                               view.textPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                                self.textView.setUpAlignment(views: [view])
                                self.updateTextViewFrameToFitText(view, fontSize: view.font.pointSize)

                            }
                        case .align:
                            if  view.isSelected == true {
                                self.selectedAddTextView = view
                            }
                        case .setOpacityEnd:
                            if view.isSelected == true {
                                let previousOpacity = view.alpha
                                view.alpha = opacity
                                self.textView.setUpOpacity(views: [view])
                            }
                        case .setBackgroundColor:
                            if view.isSelected == true {
                                var newColor: UIColor = .black
                                var newColorIndex: Int = 0
                                if index == 100 {
                                    newColor = color?.color ?? .black
                                    newColorIndex = 100
                                    // Apply new color
                                    view.backgroundColor = newColor
                                    view.selectedBackgroundColor = newColor
                                    view.selectedBackGrounfColorIndex = newColorIndex
                                    view.previousBackgroundColor = textModel?.previousBackgroundColor ?? .black
                                    view.previousSelectedBackgroundColorIndex = textModel?.previousSelectedBackgroundColorIndex ?? 0
                                    self.textView.setUpPickerBackGroundColor(views: [view], color: newColor)
                                } else if index == 101 {
                                    let rgba = color?.color.rgba
                                    let alpha = rgba?.alpha ?? 1
                                    newColor = UIColor(red: rgba?.red ?? 0, green: rgba?.green ?? 0, blue: rgba?.blue ?? 0, alpha: alpha)
                                    newColorIndex = 101
                                    // Apply new color
                                    view.backgroundColor = newColor
                                    view.selectedBackgroundColor = newColor
                                    view.selectedBackGrounfColorIndex = newColorIndex
                                    view.previousBackgroundColor = textModel?.previousBackgroundColor ?? .black
                                    view.previousSelectedBackgroundColorIndex = textModel?.previousSelectedBackgroundColorIndex ?? 0
                                } else {
                                    newColor = textModel?.backgroungColor ?? .clear
                                    newColorIndex = textModel?.selectedBackGrounfColorIndex ?? 0
                                    // Apply new color
                                    view.backgroundColor = newColor
                                    view.selectedBackgroundColor = newColor
                                    view.selectedBackGrounfColorIndex = newColorIndex
                                    view.previousBackgroundColor = textModel?.previousBackgroundColor ?? .black
                                    view.previousSelectedBackgroundColorIndex = textModel?.previousSelectedBackgroundColorIndex ?? 0
                                }
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
                                view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
                                view.layer.borderWidth = 2
                                view.isSelected = true
                                self.selectedAddSticker = view
                            } else {
                                self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
                                view.isSelected = false
                                view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
                                view.layer.borderWidth = 0
                            }
                        case .hideSelection:
                            view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
                            view.layer.borderWidth = 0
                            view.isSelected = false
                            //  view.overlayForStickerText.gridLinesAlpha = 0
                        case .hideDeleteButton:
                            self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
                            view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
                            view.layer.borderWidth = 0
                            view.isSelected = false
                            self.selectedAddSticker = nil
                            self.selectedAddTextView?.handles.forEach { $0.isHidden = true }
                            
                        case .showDeleteButtonOnTap:
                            if view.tag == stickerMoveTempTags || view.tag == stickerMoveSavedTags || view.tag == stickerEditTags || view.tag == stickerTempEditTags {
                                    self.setupAddDeleteFlipAndOnTopButtons(isHidden: false)
                                    view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
                                    view.layer.borderWidth = 2
                                    view.isSelected = true
                                    self.selectedAddSticker = view
                            } else {
                                view.isSelected = false
                                view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
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
                            self.selectedAddTextView?.handles.forEach { $0.isHidden = true }
                            
                        case .saved:
                            view.tag = stickerSavedTags
                        case .setColor:
                            if view.isSelected == true {
                                if let originalImage = view.orignalImage {
                                    
                                    let previousColor = view.tintColor!
                                    let previousColorIndex = view.selectedColorIndex
                                    
                                    var newColor: UIColor = .black
                                    var newColorIndex: Int = 0
                                    
                                    
                                    if index == 100 {
                                        newColor = color?.color ?? .black
                                        newColorIndex = 100
                                        // Apply new color
                                        // Apply new color
                                        let originalImage = originalImage
                                        let image = originalImage.withRenderingMode(.alwaysTemplate)
                                        view.image = image
                                        view.tintColor = newColor
                                        view.selectedColor = newColor
                                        view.selectedColorIndex = newColorIndex
                                        view.previousColor = textModel?.previousColor ?? .black
                                        view.previousSelectedColorIndex = textModel?.previousSelectedColorIndex ?? 0
                                        
                                        //self.textView.setUpPickerColor(views: [view], color: newColor)
                                        
                                    } else if index == 101 {
//                                        let rgba = color?.color.rgba
//                                        let alpha = rgba?.alpha ?? 1
//                                        newColor = UIColor(red: rgba?.red ?? 0, green: rgba?.green ?? 0, blue: rgba?.blue ?? 0, alpha: alpha)
                                        let image = originalImage.withRenderingMode(.alwaysTemplate)
                                        view.image = image
                                        newColorIndex = 101
                                        // Apply new color
                                        view.tintColor = color?.color
                                        view.selectedColor = color?.color ?? .black
                                        view.selectedColorIndex = newColorIndex
                                        view.previousColor = textModel?.previousColor ?? .black
                                        view.previousSelectedColorIndex = textModel?.previousSelectedColorIndex ?? 0
                                    } else {
                                        newColor = color?.color ?? .black
                                        newColorIndex = color?.selectedColorIndex ?? 0
                                        
                                        // Apply new color
                                        let originalImage = view.orignalImage!
                                        let image = originalImage.withRenderingMode(.alwaysTemplate)
                                        view.image = image
                                        view.tintColor = newColor
                                        view.selectedColor = newColor
                                        view.selectedColorIndex = newColorIndex
                                        view.previousColor = color?.previousColor ?? .black
                                        view.previousSelectedColorIndex = color?.previousColorIndex ?? 0
                                        
                                    }
                                }
                            }
                        case .setFont:
                            if view.isSelected == true {
                                
                            }
                        case .setOpacity:
                            if view.isSelected == true {
                                view.alpha = opacity
                            }
                            
                        case .setOpacityEnd:
                            if view.isSelected == true {
                                let previousOpacity = view.alpha
                                view.alpha = opacity
                                
                                self.stickerOption.updatingColor(views: [view])
                            }
                        case .mirror:
                            
                            if  view.isSelected == true {
                                
                                var originalImage = view.image!
                                let orientation = originalImage.imageOrientation
                                switch orientation {
                                case .up:
                                    flipAngleSticker = "up"
                                case .upMirrored:
                                    flipAngleSticker = "upMirrored"
                                case .down, .left, .right, .downMirrored, .leftMirrored, .rightMirrored:
                                    originalImage = self.fixOrientation(img: view.image!)
                                    break;
                                @unknown default:
                                    break
                                }
                                
                                // Store original state for undo
                                let initialState = StickerFlipState(
                                    image: originalImage,
                                    transform: view.transform,
                                    center: view.center
                                )
                                
                                let flippedImage = self.setEffectOn(image:originalImage, effect:.mirror)
                                _ = self.setEffectOn(image: originalImage, effect: .mirror)
                                view.image = flippedImage
                                
                                
                                if view.stickerSelection == "shapes" || view.stickerSelection == "badges"  || view.stickerSelection == "arrow" || view.stickerSelection == "spray" || view.stickerSelection == "customSticker" {
                                    view.image = view.image?.withRenderingMode(.alwaysTemplate)
                                    view.tintColor = stickerOption.colorButton.backgroundColor
                                }
                                
                                
                                for index in 0...stickersFromApi.count {
                                    print(index)
                                    if view.stickerSelection == "api" {
                                        view.image = flippedImage
                                        view.tintColor = .clear
                                    }
                                }
                                
                                view.handles.forEach { $0.isHidden = false }
                                
                                // Store final state for redo
                                _ = StickerFlipState(
                                    image: view.image!,
                                    transform: view.transform,
                                    center: view.center
                                )
                                
                                // Register undo with redo
                                undoRedoManager.registerUndo(withTarget: self) { target in
                                    target.applyFlipState(to: view, with: initialState)
                                }
                                undoRedoManager.setActionName("Mirror Sticker")
                                isEnableRedoUndo()
                            }
                        case .onTop:
                            if view.isSelected == true {
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
                        case .setBackgroundColor:
                            break
                        }
                    }
                }
            }
        }
    }
}
