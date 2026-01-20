//
//  CAEditTextViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 22/11/23.
//

import UIKit

extension CAEditViewController: TextViewDelegate, AddTextViewDelegate, TextViewControllerDelegate {
    func handleGestureText(_ gestureRecognizer: UIPanGestureRecognizer) {
        
    }
    
    
    func removeTextHandles() {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddTextView {
                if let addSticker = subview as? AddTextView {
                    addSticker.handles.forEach { $0.isHidden = true }
                }
            }
        }
    }
    
    func changeSubOptionsForUndoRedo(textModel: TextModel) {
         
    }
    
    
    func colorPicker() {
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()
        self.selectedAddTextView?.isSelected = true
     //   self.mainImageView.addGestureRecognizer(self.framePanGesture)
    }

//feature_sprint8/ Sprint 8 (iOS)-https://app.asana.com/1/1208716811881067/project/1209075234922947/task/1209362905736906?focus=true)
    func backButtonColortext() {
        // Clear any previous magnified view
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()
        self.scrollViewContainer.addGestureRecognizer(self.framePanGesture)

        // // // Show delete button for text views // self.stickersText(text: .showDeleteButton, isText: true)

        // Unhide the delete and add buttons
        self.deleteAndAddButtons.isHidden = false
        //toShowDeleteButtonForText(view: self.selectedAddTextView ?? AddTextView(), isDelete: true)

        self.selectedAddTextView?.isSelected = true
        // self.selectedAddTextView?.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
        // self.selectedAddTextView?.layer.borderWidth = 1
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: false) // Show buttons for the selected text
    }

    func didChangeTextProperties(textModel: TextModel) {

    }

    func setFurtherColorText(color: UIColor, opacity: CGFloat, isBackground: Bool) {
        let colorPickerViewController = AMColorPickerViewController()
        colorPickerViewController.selectedColor = color
        colorPickerViewController.selectedOpacity = opacity
        colorPickerViewController.isBackground = isBackground

        colorPickerViewController.delegate = self
        colorPickerViewController.modalPresentationStyle = .fullScreen
        present(colorPickerViewController, animated: true, completion: nil)
    }
    
    
    func applySubOptionsForText() {
        // Save the current state before applying changes
        self.previousTextDetail = self.option.textDetail.map { detail in
            // Create a copy of each detail
            return (
                txtVw: detail.txtVw,
                text: detail.text,
                frame: detail.frame,
                font: detail.font,
                index: detail.index,
                color: detail.color,
                colorIn: detail.colorIn,
                previousColor: detail.previousColor,
                previousColorIndex: detail.previousColorIndex,
                trnf: detail.trnf,
                slider: detail.slider,
                opacity: detail.opacity,
                textAlignment: detail.textAlignment,
                fontCustom: detail.fontCustom,
                previousfont: detail.previousfont,
                textString: detail.textString,
                previousTextString: detail.previousTextString,
                selectedFontIndex: detail.selectedFontIndex,
                selectedPreviousFontIndex: detail.selectedPreviousFontIndex
            )
        }

        // Now proceed with applying the text options
        //self.applyText() // Make sure you define this function accordingly
        self.textView.actionCrossForText()
        self.selectedTextModel.previousFont = self.selectedTextModel.fontCustom
        self.selectedTextModel.previousSelectedFontIndex = self.selectedTextModel.selectedFontIndex
        self.selectedTextModel.previousColor = self.selectedTextModel.color
        self.selectedTextModel.previousSelectedColorIndex = self.selectedTextModel.selectedColorIndex
        self.saveColorFontProperty()
    }
    
    func opacityWillStart(_ textView: TextView, isOpen: Bool) {
//        self.previousOpacity = CGFloat(textView.opacitySlider.value)
        let previousOpacity = CGFloat(self.textView.opacitySlider.value)
        
        undoRedoManager.registerUndo(withTarget: self) { target in
            target.stickersText(text: .setOpacityEnd, opacity: previousOpacity, isText: true)

        }
        undoRedoManager.setActionName("Change Text Opacity")
        isEnableRedoUndo()

        if isOpen {
            self.deleteAndAddButtons.isHidden = true
            self.constraintsBottomViewHeight.constant = 80 
        } else {
            self.deleteAndAddButtons.isHidden = false
            self.constraintsBottomViewHeight.constant = 80
        }
    }
    
    func tickAndCrossForSubOptions(isAlign: Bool) {

        self.isSubOptions = true
        self.constraintsBottomViewHeight.constant = 80
        if isAlign {
            self.deleteAndAddButtons.isHidden = false
            self.saveCrossView.showView()
            self.saveCrossSubOptionsView.hideView()
        } else {
            self.deleteAndAddButtons.isHidden = true
            self.saveCrossView.hideView()
            self.saveCrossSubOptionsView.showView()
        }
    }
    
    func alignLeft() {
        self.constraintsBottomViewHeight.constant = 80
        self.stickersText(text: .setLeft, isText: true)
    }
    
    func alignRight() {
        self.constraintsBottomViewHeight.constant = 80
        self.stickersText(text: .setRight, isText: true)
    }
    
    func alignCenter() {
        self.constraintsBottomViewHeight.constant = 80
        self.stickersText(text: .setCenter, isText: true)
    }
    
    func pickColor(isBackground: Bool, callBack: (ColorModel) -> Void?) {
        //self.selectedAddTextView = nil
        self.selectedAddSticker = nil
        /**
         UIPanGestureRecognizer - Pan Objects
         */
        self.removeGesturesMainImageViewForMagnify()
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanColorPickerMagnify(_:)))
        pan.delegate = self
        self.stickerTextView.addGestureRecognizer(pan)
        self.magnifyingGlass.magnifiedView = self.mainImageView
        self.magnifyingGlass.magnify(at: self.overlay.cropBox.center)
        let color = self.scrollViewContainer.getPixelColorAt(point: self.overlay.cropBox.center)
        let textModel = TextModel()
        textModel.color = color
        textModel.isBackgroundColor = isBackground
        textModel.backgroungColor = color
        textModel.selectedColorIndex = 100
        textModel.selectedBackGrounfColorIndex = 100
        textModel.previousColor = self.selectedTextModel.previousColor
        textModel.previousSelectedColorIndex = self.selectedTextModel.previousSelectedColorIndex
        
        textModel.previousBackgroundColor = self.selectedTextModel.previousBackgroundColor
        textModel.previousSelectedBackgroundColorIndex = self.selectedTextModel.previousSelectedBackgroundColorIndex

        textModel.selectedFontIndex = self.selectedTextModel.selectedFontIndex
        textModel.previousSelectedFontIndex = self.selectedTextModel.previousSelectedFontIndex
        textModel.textString = self.selectedTextModel.textString
        textModel.previousTextString = self.selectedTextModel.previousTextString
        textModel.fontCustom = self.selectedTextModel.fontCustom
        textModel.previousFont = self.selectedTextModel.previousFont
        self.selectedTextModel = textModel
        
        let colorModel = ColorModel()
        colorModel.selectedColorIndex = 100
        colorModel.isColor = true
        colorModel.color = color
        
        if isBackground {
            self.stickersText(text: .setBackgroundColor, color: colorModel, index: 100, isText: true)
        } else {
            self.stickersText(text: .setColor, color: colorModel, index: 100, isText: true)
        }
        callBack(colorModel)
    }
    
    @objc func handlePanColorPickerMagnify(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .changed {
            if self.filterSelection == .text, !self.option.isText {
                if magnifyingGlass.magnifiedView != nil {
                    let point = gestureRecognizer.location(in: self.transformMainView)
                    let changepoint = CGPointMake(point.x , point.y - 93)
                    self.magnifyingGlass.magnifiedView = view
                    self.magnifyingGlass.magnify(at: point)
                    let color = self.transformMainView.getPixelColorAt(point: changepoint)
                    let textModel = TextModel()
                    textModel.isBackgroundColor = self.selectedTextModel.isBackgroundColor
                    textModel.backgroungColor = color
                    textModel.selectedColorIndex = 100
                    textModel.selectedBackGrounfColorIndex = 100
                    textModel.previousColor = self.selectedTextModel.previousColor
                    textModel.previousSelectedColorIndex = self.selectedTextModel.previousSelectedColorIndex
                    
                    textModel.previousBackgroundColor = self.selectedTextModel.previousBackgroundColor
                    textModel.previousSelectedBackgroundColorIndex = self.selectedTextModel.previousSelectedBackgroundColorIndex

                    textModel.color = color
                    textModel.selectedFontIndex = self.selectedTextModel.selectedFontIndex
                    textModel.previousSelectedFontIndex = self.selectedTextModel.previousSelectedFontIndex
                    textModel.textString = self.selectedTextModel.textString
                    textModel.previousTextString = self.selectedTextModel.previousTextString
                    textModel.fontCustom = self.selectedTextModel.fontCustom
                    textModel.previousFont = self.selectedTextModel.previousFont
                    self.selectedTextModel = textModel
                    
                    let colorModel = ColorModel()
                    colorModel.selectedColorIndex = 100
                    colorModel.isColor = true
                    colorModel.color = color
                    
                    if self.selectedTextModel.isBackgroundColor {
                        self.stickersText(text: .setBackgroundColor, color: colorModel, index: 100, isText: true)
                        self.textView.setUpPickerBackGroundColor(views: self.stickerTextView.subviews, color: color)
                    } else {
                        self.stickersText(text: .setColor, color: colorModel, index: 100, isText: true)
                        self.textView.setUpPickerColor(views: self.stickerTextView.subviews, color: color)
                    }

                }
            } else if self.filterSelection == .brush, !self.option.isBrush {
                if magnifyingGlass.magnifiedView != nil {
                    let point = gestureRecognizer.location(in: self.transformMainView)
                    let changepoint = CGPointMake(point.x , point.y - 93)
                    self.magnifyingGlass.magnifiedView = view
                    self.magnifyingGlass.magnify(at: point)
                    let color = self.transformMainView.getPixelColorAt(point: changepoint)
                    self.option.selectedBrushColorIndex = 100
                    self.viewPaintDrawing.strokeColor = color
                    self.brushView.colorButton.backgroundColor = color
                    self.brushView.brushSizeLabel.backgroundColor = color
                    self.brushView.sharpnessColorLbl.backgroundColor = color
                    self.brushView.brushTransparencyLabel.backgroundColor = color
                    self.brushView.updateFontColorThroughPicker(color: color)
                    self.drawingViewWillBeginDraw()
                }
            } else if self.filterSelection == .sticker, !self.option.isSticker {
                if magnifyingGlass.magnifiedView != nil {
                    let point = gestureRecognizer.location(in: self.transformMainView)
                    let changepoint = CGPointMake(point.x , point.y - 93)
                    self.magnifyingGlass.magnifiedView = view
                    self.magnifyingGlass.magnify(at: point)
                    let color = self.transformMainView.getPixelColorAt(point: changepoint)
                    self.selectedStickerColor = color
                    
                    let colorModel = ColorModel()
                    colorModel.selectedColorIndex = 100
                    colorModel.isColor = true
                    colorModel.color = color

                    self.stickersText(text: .setColor, color: colorModel, index: 100, isText: false)
                    self.stickerOption.updateFontColorPickColor(color: color)
                    gestureRecognizer.setTranslation(CGPoint.zero, in: self.transformMainView)
                }
            }
        }
    }
    
    func setUpTextView(isSaveCross: Bool) {
        self.stickerTextView.isUserInteractionEnabled = true
        self.option.isText = false
        self.addTextBottomView()
        self.showTextViewController(isSaveCross: isSaveCross)
    }
    
    func addTextBottomView() {
        self.removeBottomSubViews()
        self.bottomView.isHidden = false
        self.doneButton.isHidden = false
        self.textView = TextView()
        self.textView.delegate = self
        self.textView.setUpTextAndColor(views: self.stickerTextView.subviews)
        self.textView.setUpOpacity(views: self.stickerTextView.subviews)
        self.bottomView.addSubview(self.textView)
        self.bottomView.isHidden = false
        self.setupAutoLayoutForBottomView(newView: self.textView, bottomView: self.bottomView)
    }
    
    func showTextViewController(isSaveCross: Bool) {
        let bundlePath = Bundle(for: CAEditViewController.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let resourceBundle = bundlePath != nil ? Bundle(path: bundlePath!) : nil
        let viewTextViewController = TextViewController(nibName: "TextViewController", bundle: resourceBundle)
        viewTextViewController.delegate = self
        viewTextViewController.isBtnCrossShowing = isSaveCross
        self.view.addSubview(viewTextViewController.view)
        self.addChild(viewTextViewController)
        viewTextViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
    }
    // adding text to view
    func addTextLabelToView(object : [String : Any]) {
        // Register undo before adding new text
        let dictionary = object
        if let isNew = dictionary[EditStaticStrings.newText] as? Bool {
            self.selectedAddTextView?.handles.forEach { $0.isHidden = false }

            if !isNew {
                self.setupAddDeleteFlipAndOnTopButtons(isHidden: false)
                self.stickersText(text: .edit, dictionary: dictionary, isText: true)
            } else {
                let visibleRect = scrollView.convert(scrollView.bounds, to: self.stickerTextView)
                let centerX = visibleRect.midX
                let centerY = visibleRect.midY
                let stickerCenter = CGPoint(x: centerX, y: centerY)

                let frame = CGRect(origin: stickerCenter, size: CGSizeMake(70, 70))

                let transform = CGAffineTransform(rotationAngle: self.rotation(from: view.transform))
                let text = dictionary[EditStaticStrings.text] as? String ?? ""

                let font =  UIFont.init(name: dictionary[EditStaticStrings.font] as? String ?? "", size: 36)!

                let color = dictionary[EditStaticStrings.color] as? UIColor ?? .blue
                let backgroundColor = dictionary[EditStaticStrings.backgroundColor] as? UIColor ?? .clear
                var arrayTextViewDetail = [Any]( )
                arrayTextViewDetail.append(frame)
                arrayTextViewDetail.append(text)
                arrayTextViewDetail.append(font)
                arrayTextViewDetail.append(color)
                arrayTextViewDetail.append(backgroundColor)
                
                let view = self.textManager.addText(delegate: self, textViewDetail: arrayTextViewDetail, isTransform: false, transform: transform, tag: textTempTags, alpha: 1, textAlignment: NSTextAlignment.left)

                let selectedColorIndex = dictionary[EditStaticStrings.selectedColorIndex] as? Int
                let selectedBackgroundColorIndex = dictionary[EditStaticStrings.selectedBackgroundColorIndex] as? Int
                view.selectedColor = dictionary[EditStaticStrings.color] as? UIColor ?? .black
                view.selectedColorIndex = selectedColorIndex ?? 0
                view.previousColor = dictionary[EditStaticStrings.previousColor] as? UIColor ?? .black
                view.previousSelectedColorIndex = dictionary[EditStaticStrings.selectedPreviousColorIndex] as? Int ?? 0

                view.selectedBackgroundColor = dictionary[EditStaticStrings.backgroundColor] as? UIColor ?? .black
                view.selectedBackGrounfColorIndex = selectedBackgroundColorIndex ?? 0
                view.previousBackgroundColor = dictionary[EditStaticStrings.previousBackgroundColor] as? UIColor ?? .black
                view.previousSelectedBackgroundColorIndex = dictionary[EditStaticStrings.selectedBackgroundPreviousColorIndex] as? Int ?? 0

                view.selectedFontIndex = dictionary[EditStaticStrings.selectedFontIndex] as? Int ?? 0
                view.selectedPreviousFontIndex = dictionary[EditStaticStrings.selectedPreviousFontIndex] as? Int ?? 0
                view.selectedFont = dictionary[EditStaticStrings.font] as? String ?? ""
                view.selectedPreviousFont = dictionary[EditStaticStrings.previousFont] as? String ?? ""
                view.selectedText = dictionary[EditStaticStrings.text] as? String ?? ""
                view.previousText = dictionary[EditStaticStrings.previousText] as? String ?? ""
                view.alpha = textViewOpacity
                print(dictionary[EditStaticStrings.selectedAlignment]!)
                if dictionary[EditStaticStrings.selectedAlignment] as? String == "center" {
                    view.textAlignment = .center
                    view.textPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

                } else if dictionary[EditStaticStrings.selectedAlignment] as? String == "left" {
                    view.textAlignment = .left
                    view.textPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30)

                } else if dictionary[EditStaticStrings.selectedAlignment] as? String == "right" {
                    view.textAlignment = .right
                    view.textPadding = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
                }
                _ = (text.widthOfString(usingFont: font)) + 50
               // _ = heightForView(text: text , font: font, width: width) + 50

//                let minHeight: CGFloat = 55
//                let minWidth: CGFloat = 80
//                let maxWidth: CGFloat = self.mainImageScaledSizeForText.width
//                let maxHeight: CGFloat = self.mainImageScaledSizeForText.height
//
//                let info = sizeForView(text: text, font: font, maxSize: CGSize(width: maxWidth, height: maxHeight))
//
//                // Calculate the width based on the text size but enforce a minimum width
//                let calculatedWidth = info.0.width + 8 // Add padding for better spacing
//
//                view.bounds.size.height = max(minHeight, info.0.height)/currentZoomScale
//                view.bounds.size.width = max(minWidth, min(maxWidth, calculatedWidth))/currentZoomScale
                if selectedRation >= 8 {
                    self.updateTextViewFrameToFitText(view, fontSize: 16)
                } else {
                    self.updateTextViewFrameToFitText(view, fontSize: 26)
                }
                view.frame.origin.x = view.frame.origin.x - (view.bounds.size.width / 2)
                view.frame.origin.y = view.frame.origin.y - (view.bounds.size.height / 2)

                let rotationTransform = CGAffineTransform(rotationAngle: -totalAngle)
                //view.transform = rotationTransform

                if isFlippedSelected && isMirroredSelected {
                    // Create the rotation transform
                    let rotationTransform = CGAffineTransform(rotationAngle: -totalAngle)
                    // Create the scaling transform
                    let scaleTransform = CGAffineTransform(scaleX: -1, y: -1)
                    // Combine both transforms
                    let combinedTransform = scaleTransform.concatenating(rotationTransform)
                    view.transform = combinedTransform
                } else if isFlippedSelected {
                    // Create the rotation transform
                    let rotationTransform = CGAffineTransform(rotationAngle: -totalAngle)
                    // Create the scaling transform
                    let scaleTransform = CGAffineTransform(scaleX: -1, y: 1)
                    // Combine both transforms
                    let combinedTransform = scaleTransform.concatenating(rotationTransform)
                    view.transform = combinedTransform
                } else if isMirroredSelected {
                    // Create the rotation transform
                    let rotationTransform = CGAffineTransform(rotationAngle: -totalAngle)
                    // Create the scaling transform
                    let scaleTransform = CGAffineTransform(scaleX: 1, y: -1)
                    // Combine both transforms
                    let combinedTransform = scaleTransform.concatenating(rotationTransform)
                    view.transform = combinedTransform
                }
                
                view.setNeedsDisplay()
               // view.height = 50
                self.stickerTextView.addSubview(view)

                // Resize after adding
                updateTextViewFrameToFitText(view)

                self.saveCrossView.showView()
                let textModel = TextModel()
                textModel.color = view.selectedColor
                textModel.selectedColorIndex = view.selectedColorIndex
                textModel.previousColor = view.previousColor
                textModel.previousSelectedColorIndex = view.previousSelectedColorIndex
                textModel.selectedFontIndex = view.selectedFontIndex
                textModel.previousSelectedFontIndex = view.selectedPreviousFontIndex
                textModel.fontCustom = view.selectedFont
                textModel.previousFont = view.selectedPreviousFont
                textModel.textString = view.selectedText
                textModel.previousTextString = view.previousText
                textModel.opacity = view.selectedOpacity
                textModel.backgroungColor = view.selectedBackgroundColor
                textModel.selectedBackGrounfColorIndex = view.selectedBackGrounfColorIndex
                textModel.previousBackgroundColor = view.previousBackgroundColor
                textModel.previousSelectedBackgroundColorIndex = view.previousSelectedBackgroundColorIndex
                self.selectedTextModel = textModel
                self.stickersText(text: .showDeleteButton, isText: true)

            }
        }
        self.stickersText(text: .showDeleteButton, isText: true)
        self.selectedAddTextView?.handles.forEach { $0.isHidden = false }
        // 1. Add border to the main view
        
        // 2. Add all handles as subviews (if not already added)
        selectedAddTextView?.handles.forEach { handle in
            selectedAddTextView?.addSubview(handle)
        }

        // 3. Bring handles above the border
        selectedAddTextView?.handles.forEach { handle in
            selectedAddTextView?.bringSubviewToFront(handle)
        }
        self.mainCollectionView.isHidden = true
        self.isShownRedoUndo()
        self.addTextBottomView()
         
        self.isEnableRedoUndo()
    }
    func updateTextViewFrameToFitText(_ textView: AddTextView) {
        guard let text = textView.text, !text.isEmpty else {
            textView.bounds.size = CGSize(width: 80, height: 55)  // Minimum size if empty
            return
        }

        textView.numberOfLines = 0  // Enable multiline

        let minWidth: CGFloat = 80
        let maxWidth: CGFloat = self.mainImageScaledSizeForText.width
        let padding: CGFloat = 16

        let boundingSize = CGSize(width: maxWidth - 2 * padding, height: CGFloat.greatestFiniteMagnitude)

        let textSize = textView.sizeThatFits(boundingSize)

        let updatedWidth = max(minWidth, min(maxWidth, textSize.width + padding * 2))
        let updatedHeight = max(55, textSize.height + padding * 2)

        let originalCenter = textView.center

        textView.bounds.size = CGSize(width: updatedWidth, height: updatedHeight)
        textView.center = originalCenter

        if let outlineLayer = textView.layer.sublayers?.first(where: { $0 is CAShapeLayer }) as? CAShapeLayer {
            let path = UIBezierPath(rect: textView.bounds.insetBy(dx: 8, dy: 8))
            outlineLayer.path = path.cgPath
            outlineLayer.frame = textView.bounds
        }
    }

    func addRemoveButtonOnText() {
        
        self.saveCrossView.showView()
        self.option.isText = false
        self.stickersText(text: .showDeleteButtonOnTap, isText: true)
        //self.stickersText(text: .resetMove, isText: true)
    }
    
    func editTextLblOnView() {
        
        let viewTextViewController = TextViewController(nibName: TextViewController.className, bundle: nil)
        viewTextViewController.delegate = self
        viewTextViewController.textModel = self.selectedTextModel
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddTextView {
                if let txtLbl = subview as? AddTextView {
                    viewTextViewController.textModel.textString = txtLbl.text ?? ""
                    viewTextViewController.newText = false
                    viewTextViewController.textModel.color = txtLbl.textColor
                    viewTextViewController.textModel.backgroungColor = txtLbl.backgroundColor ?? .clear
                    viewTextViewController.textModel.fontCustom = txtLbl.font.familyName
                    viewTextViewController.textModel.textString = txtLbl.text ?? ""
                    viewTextViewController.textModel.alignment = txtLbl.textAlignment
                    viewTextViewController.textModel.opacity = txtLbl.alpha
                }
            }
        }
        
        self.view.addSubview(viewTextViewController.view)
        self.addChild(viewTextViewController)
        viewTextViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.saveCrossView.showView()
        self.option.isText = false
        self.selectedAddSticker?.handles.forEach { $0.isHidden = false }

    }
    
    func resetFramesText() {
        self.stickersText(text: .removeAll, isText: true)
        self.updateFramesText()
    }
    
    func updateFramesText() {
        // Clear existing text views before adding new ones
        //stickerTextView.subviews.forEach { $0.removeFromSuperview() }

        // Iterate through each text detail and create text views
        for textViewDetail in self.option.textDetail {
            let transform = textViewDetail.trnf!
            let frame = textViewDetail.frame
            let text = textViewDetail.text ?? ""
            let font = textViewDetail.font ?? UIFont.systemFont(ofSize: 10)
            let color = textViewDetail.color ?? .black
            let alignment = textViewDetail.textAlignment ?? .left
            let center = textViewDetail.center
            // Prepare the text view details for creating the text view
            let arrayTextViewDetail: [Any] = [ frame!, text, font, color, center! ]

            // Create the text view using the text manager
            let view = self.textManager.addText(delegate: self, textViewDetail: arrayTextViewDetail, isTransform: true, transform: transform, tag: textSavedTags, alpha: textViewDetail.opacity ?? 1.0, textAlignment: alignment)

            // Additional setup for the text view
            self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
            view.isSelected = false

            // Set properties for the view based on textViewDetail
            view.selectedColorIndex = textViewDetail.colorIn ?? 0
            view.selectedColor = color
            view.previousColor = textViewDetail.previousColor ?? .black
            view.previousSelectedColorIndex = textViewDetail.previousColorIndex ?? 0

            view.selectedBackGrounfColorIndex = textViewDetail.bcolorIn ?? 0
            view.selectedBackgroundColor = textViewDetail.bcolor ?? .clear
            view.previousBackgroundColor = textViewDetail.previousbColor ?? .clear
            view.previousSelectedBackgroundColorIndex = textViewDetail.previousbColorIndex ?? 0
            view.backgroundColor = textViewDetail.previousbColor ?? .clear
            view.selectedFontIndex = textViewDetail.selectedFontIndex ?? 0
            view.selectedPreviousFontIndex = textViewDetail.selectedPreviousFontIndex ?? 0
            view.selectedFont = textViewDetail.fontCustom ?? ""
            view.selectedPreviousFont = textViewDetail.previousfont ?? ""
            view.selectedText = textViewDetail.textString ?? ""
            view.previousText = textViewDetail.previousTextString ?? ""
            //self.updateTextViewFrameToFitText(view, fontSize: textViewDetail.font?.pointSize)
            view.removeOutline()
            view.frame = frame!
            view.center = center ?? CGPoint(x: 0, y: 0)
            view.transform = transform
            self.updateTextViewFrameToFitText(view, fontSize: textViewDetail.font?.pointSize ?? 10)

            // Add the newly created text view to the stickerTextView
            self.stickerTextView.addSubview(view)
        }
    }

    
    func saveAppliedTextFromView() {
        self.option.textDetail.removeAll()
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddTextView {
                if let view = subview as? AddTextView {
                    let string = view.text
                    let frame = view.bounds
                    let font = view.font
                    
                    let index = view.selectedFontIndex
                    let selectedColorIndex = view.selectedColorIndex
                    let previousColor = view.previousColor
                    let previousSelectedColorIndex = view.previousSelectedColorIndex

                    let tBColor = view.selectedBackgroundColor
                    let selectedBColorIndex = view.selectedBackGrounfColorIndex
                    let previousBColor = view.selectedBackgroundColor
                    let previousSelectedBColorIndex = view.selectedBackGrounfColorIndex

                    let fontCustom = view.selectedFont
                    let previousfont = view.selectedPreviousFont
                    let textString = view.selectedText
                    let previousTextString = view.previousText
                    let selectedFontIndex = view.selectedFontIndex
                    let selectedPreviousFontIndex = view.selectedPreviousFontIndex
                    let trans = view.transform
                    let tColor = view.textColor
                    let alignment = view.textAlignment
                    let slider = self.textSliderValue
                    self.option.textDetail.append((txtVw: view, text: string, frame: frame, center: view.center, trnf: trans, font: font, index: index, color: tColor, colorIn: selectedColorIndex, previousColor: previousColor, previousColorIndex: previousSelectedColorIndex, bcolor: tBColor, bcolorIn: selectedBColorIndex,previousbColor: previousBColor,previousbColorIndex: previousSelectedBColorIndex,slider: slider, opacity: view.alpha, textAlignment: alignment,fontCustom: fontCustom, previousfont: previousfont, textString: textString, previousTextString: previousTextString, selectedFontIndex: selectedFontIndex, selectedPreviousFontIndex: selectedPreviousFontIndex))

                    
                }
            }
        }
    }
    
    func applyText() {

       isEnableRedoUndo()
        
        self.selectedAddTextView = nil
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()
        self.scrollViewContainer.addGestureRecognizer(self.framePanGesture)
        self.option.isText = true
        self.stickersText(text: .saved, isText: true)
        self.stickersText(text: .hideDeleteButton, isText: true)
        self.saveAppliedTextFromView()
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)        

    }
    
    func isText() -> Bool {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddTextView {
                return true
            }
        }
        return false
    }
    
    func updateFramesAfterHandlers(frame: CGRect) {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddTextView {
                if let view = subview as? AddTextView {
                    if view.isSelected == true {
                        view.frame = frame
                    }
                }
            }
        }
    }
    
    func selectedText() -> AddTextView {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddTextView {
                if let view = subview as? AddTextView {
                    if view.isSelected == true {
                        return view
                    }
                }
            }
        }
        return AddTextView()
    }
    
    func isTextSelected() -> Bool {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddTextView {
                if let view = subview as? AddTextView {
                    return view.isSelected
                }
            }
        }
        return false
    }
    
    func isPhotoSelected() -> Bool {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let view = subview as? AddSticker {
                    if view.isStickers == true {
                        return view.isSelected
                    }
                }
            }
        }
        return false
    }
    
    func isStickerSelected() -> Bool {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let view = subview as? AddSticker {
                    return view.isSelected
                }
            }
        }
        return false
    }
    
    func resetDoubleStickerSelected() {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddSticker {
                if let view = subview as? AddSticker {
                    if view != self.selectedAddSticker {
                        view.isSelected = false
                        view.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
                        view.layer.borderWidth = 0
                        view.tag = stickerSavedTags
                    }
                }
            }
        }
    }
//    func selectColorAndText(_: TextView, textModel: TextModel) {
//
//        registerUndoForTextChanges()
//
//        self.selectedTextModel = textModel
//        self.magnifyingGlass.magnifiedView = nil
//            self.removeGesturesMainImageViewForMagnify()
//        if textModel.isColor == true {
//            self.stickersText(text: .setColor,textModel: textModel, isText: true)
//        } else {
//            self.stickersText(text: .setFont,textModel: textModel, isText: true)
//        }
//    }
    
    func selectColorAndText(_: TextView, textModel: TextModel) {
        //  enableDisableUIControl()
        //  registerUndoForTextChanges()
        
        // Capture current state before changing
        getColorFontProperty()
        
        self.selectedTextModel = textModel
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()
        
        if textModel.isColor == true {
            self.stickersText(text: .setColor, textModel: textModel, isText: true)
        } else if textModel.isBackgroundColor == true  {
            self.stickersText(text: .setBackgroundColor, textModel: textModel, isText: true)
        } else {
            self.stickersText(text: .setFont, textModel: textModel, isText: true)
        }
        // Call updateFramesText to refresh UI immediately after change
        // updateFramesText()
    }


    func denyColorAndText(textModel: TextModel) {
        // Register undo before denying color/font changes
          //  registerUndoForTextChanges()

        if textModel.isColor == true {
            self.stickersText(text: .setColor,textModel: textModel, isText: true)
            self.textView.updateFontColor(color: textModel.previousColor)
        } else {
            self.stickersText(text: .setFont,textModel: textModel, isText: true)
            self.textView.updateFont(index: textModel.previousSelectedFontIndex)
            self.stickersText(text: .setColor,textModel: textModel, isText: true)
            self.textView.updateFontColor(color: textModel.previousColor)
            self.magnifyingGlass.magnifiedView = nil
            self.removeGesturesMainImageViewForMagnify()
        }
    }
    
    func opacityDidStart(_: TextView, sliderValue: CGFloat) {
        self.textSliderValue = sliderValue
        self.stickersText(text: .setOpacity, opacity: sliderValue, isText: true)
    }
    
    func opacityDidEnd(_: TextView, sliderValue: CGFloat) {
        self.textSliderValue = sliderValue
        self.stickersText(text: .setOpacityEnd, opacity: sliderValue, isText: true)
    }
    
    func addTextToTextView(_: TextViewController, object: [String : Any]) {
        self.filterSelection = FilterSelection(rawValue: 5)
        self.addTextLabelToView(object: object)
    }
    
    func backToEdit(_: TextViewController) {
        self.mainCollectionView.showView()
        self.stickersText(text: .hideDeleteButton, isText: true)
        self.removeBottomSubViews()
        self.saveCrossView.hideView()
        self.isShowingRedoUndo()
    }
    
    func editTextLabel(_: AddTextView) {
        print(self.filterSelection ?? .none)
        if self.magnifyingGlass.magnifiedView == nil && self.filterSelection == FilterSelection.none {
            self.editTextLblOnView()
        }
    }
    
    func addRemoveButtonFromText(_: AddTextView, tag: Int) {
        self.selectedAddSticker?.handles.forEach { $0.isHidden = true }

        // add handlers
        if self.magnifyingGlass.magnifiedView == nil, self.option.isFramesSelected == false, self.filterSelection != .adjust, self.filterSelection != .filter {
            self.stickersText(text: .showDeleteButtonOnTap, isText: true)
            self.stickersText(text: .onTop, isText: true)
            self.mainCollectionView.isHidden = true
            self.isEnableRedoUndo()
            self.isShownRedoUndo()
            self.addTextBottomView()
            // Ensure handlers are shown
            self.selectedAddTextView?.handles.forEach { $0.isHidden = false }
            self.selectedAddSticker?.handles.forEach { $0.isHidden = true }
            self.stickersText(text: .hideSelection, isText: false)
            if self.filterSelection == FilterSelection.none || self.filterSelection == FilterSelection.sticker {
                 
                //self.selectedAddSticker = nil
                self.stickersText(text: .hideSelection, isText: false)
                self.filterSelection = FilterSelection(rawValue: 5)
                self.addRemoveButtonOnText()
                self.mainCollectionView.reloadData()
            }
        }
    }
    
    func alignmentText() {
        self.forTextAlignment()
    }
    
    func forTextAlignment() {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddTextView {
                if let view = subview as? AddTextView {
                    if view.isSelected == true {
                        self.calculatingLeftRightAlignment(view: view)
                        self.calculatingTopBottomAlignment(view: view)
                        self.calculatingCenterAlignment(view: view)
                        self.updateAlignment(view: view)
                    }
                }
            }
        }
    }
//    func saveColorFontProperty() {
//        let subViews = self.stickerTextView.subviews
//        for subview in subViews {
//            if subview is AddTextView {
//                if let view = subview as? AddTextView, view.isSelected == true {
//                    // Capture the current state before changes
//                    view.previousColor = view.selectedColor
//                    view.previousSelectedColorIndex = view.selectedColorIndex
////                    view.previousFont = view.selectedFont
////                    view.previousSelectedFontIndex = view.selectedFontIndex
//                    view.previousText = view.selectedText
//
//                    // Save the new state
//                    view.selectedColor = self.selectedTextModel.color
//                    view.selectedColorIndex = self.selectedTextModel.selectedColorIndex
//                    view.selectedFontIndex = self.selectedTextModel.selectedFontIndex
//                    view.selectedFont = self.selectedTextModel.fontCustom
//                    view.selectedText = self.selectedTextModel.textString
//                }
//            }
//        }
//    }


    func saveColorFontProperty() {
            let subViews = self.stickerTextView.subviews
            for subview in subViews {
                if subview is AddTextView {
                    if let view = subview as? AddTextView {
                        if view.isSelected == true {
                            view.selectedColor = self.selectedTextModel.color
                            view.selectedColorIndex = self.selectedTextModel.selectedColorIndex
                            view.previousColor = self.selectedTextModel.previousColor
                            view.previousSelectedColorIndex = self.selectedTextModel.previousSelectedColorIndex
                            
                            view.selectedFontIndex = self.selectedTextModel.selectedFontIndex
                            view.selectedPreviousFontIndex = self.selectedTextModel.previousSelectedFontIndex
                            view.selectedText = self.selectedTextModel.textString
                            view.previousText = self.selectedTextModel.previousTextString
                            view.selectedFont = self.selectedTextModel.fontCustom
                            view.selectedPreviousFont = self.selectedTextModel.previousFont
                            
                        }
                    }
                }
            }
        }
    
    func getColorFontProperty() {
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddTextView {
                if let view = subview as? AddTextView {
                    if view.isSelected == true {
                        let textModel = TextModel()
                        textModel.color = view.selectedColor
                        textModel.selectedColorIndex = view.selectedColorIndex
                        let text = self.option.textDetail.last
                        textModel.previousColor = text?.color ?? .black
                        textModel.previousSelectedColorIndex = view.previousSelectedColorIndex
                        
                        textModel.selectedFontIndex = view.selectedFontIndex
                        textModel.previousSelectedFontIndex = view.selectedPreviousFontIndex
                        textModel.textString = view.selectedText
                        textModel.previousTextString = view.previousText
                        textModel.fontCustom = view.selectedFont
                        textModel.previousFont = view.selectedPreviousFont
                        textModel.backgroungColor = view.backgroundColor ?? .clear
                        textModel.selectedBackGrounfColorIndex = view.selectedBackGrounfColorIndex
                        textModel.previousBackgroundColor = view.previousBackgroundColor
                        textModel.previousSelectedBackgroundColorIndex = view.previousSelectedBackgroundColorIndex
                        self.selectedTextModel = textModel
                    }
                }
            }
        }
       // self.updateSubMenuOptions()  // Ensure submenu updates

    }
    
//    // 🔹 Call this after undo/redo actions
//        func updateSubMenuOptions() {
//            DispatchQueue.main.async {
//                self.updateColorSelection()
//               updateFontSelection()
//            }
//        }
//    // 🔹 Call this when undo/redo button is tapped
//       func handleUndoRedoAction() {
//           self.getColorFontProperty() // Refresh text properties
//       }
//    func handleGestureText(_ gestureRecognizer: UIPanGestureRecognizer) {
//        print("handle gesture")
//        if self.magnifyingGlass.magnifiedView == nil {
//            self.alignmentText()
//            if gestureRecognizer.state == .changed {
//                if self.selectedAddTextView != nil {
//                    let point = gestureRecognizer.location(in: self.stickerTextView)
//                    let superview = self.stickerTextView
//                    let restrictByPoint : CGFloat = 30.0
//                    let xAxis = superview.bounds.origin.x + restrictByPoint
//                    let yAxis = superview.bounds.origin.y + restrictByPoint
//                    let width = superview.bounds.size.width - 2*restrictByPoint
//                    let height = superview.bounds.size.height - 2*restrictByPoint
//                    let superBounds = CGRect(x: xAxis, y: yAxis, width: width, height: height)
//                    
//                    if (superBounds.contains(point)) {
//                        let translation = gestureRecognizer.translation(in: self.stickerTextView)
//                        self.selectedAddTextView?.center = CGPoint(x: (self.selectedAddTextView?.center.x ?? 0) + translation.x, y: (self.selectedAddTextView?.center.y ?? 0) + translation.y)
//                        gestureRecognizer.setTranslation(CGPoint.zero, in: self.stickerTextView)
//                    }
//                }
//            }
//            
//            if gestureRecognizer.state == .ended {
//                self.removeAlignmentLines()
//            }
//        }
//    }
//    func handleGestureText(_ gestureRecognizer: UIPanGestureRecognizer) {
//        if self.magnifyingGlass.magnifiedView == nil {
//            self.alignmentText()
//            if gestureRecognizer.state == .changed {
//                if self.selectedAddTextView != nil {
//                    let point = gestureRecognizer.location(in: self.stickerTextView)
//                    let superview = self.stickerTextView
//                    let restrictByPoint : CGFloat = 30.0
//                    let xAxis = superview.bounds.origin.x + restrictByPoint
//                    let yAxis = superview.bounds.origin.y + restrictByPoint
//                    let width = superview.bounds.size.width - 2*restrictByPoint
//                    let height = superview.bounds.size.height - 2*restrictByPoint
//                    let superBounds = CGRect(x: xAxis, y: yAxis, width: width, height: height)
//
//                    if (superBounds.contains(point)) {
//                        let translation = gestureRecognizer.translation(in: self.stickerTextView)
//                        self.selectedAddTextView?.center = CGPoint(x: (self.selectedAddTextView?.center.x ?? 0) + translation.x, y: (self.selectedAddTextView?.center.y ?? 0) + translation.y)
//                        gestureRecognizer.setTranslation(CGPoint.zero, in: self.stickerTextView)
//                    }
//                }
//            }
//
//            if gestureRecognizer.state == .ended {
//                self.removeAlignmentLines()
//            }
//        }
//    }

//    func handleGestureText(_ gestureRecognizer: UIPanGestureRecognizer) {
//        guard let selectedTextView = self.selectedAddTextView else { return }
//
//        if self.magnifyingGlass.magnifiedView == nil {
//            self.alignmentText()
//            let point = gestureRecognizer.location(in: self.stickerTextView)
//            let superview = self.stickerTextView
//            let restrictByPoint: CGFloat = 30.0
//            let restrictedBounds = superview.bounds.insetBy(dx: restrictByPoint, dy: restrictByPoint)
//
//            switch gestureRecognizer.state {
//            case .began:
//                // Store initial position in the undo stack
//                let initialPosition = selectedTextView.center
//              //  stickerEditor.updateTextPosition(textView: selectedTextView, from: initialPosition, to: initialPosition)
//                Editor.trackTextMovement(textView: selectedTextView, from: initialPosition, to: initialPosition)
//                isEnableRedoUndo()
//
//            case .changed:
//                if restrictedBounds.contains(point) {
//                    let translation = gestureRecognizer.translation(in: self.stickerTextView)
//                    selectedTextView.center = CGPoint(x: selectedTextView.center.x + translation.x,
//                                                      y: selectedTextView.center.y + translation.y)
//                    gestureRecognizer.setTranslation(.zero, in: self.stickerTextView)
//                }
//
//            case .ended:
//                print("ended text state")
//                // Update the final position in the last undo stack entry
//                let finalPosition = selectedTextView.center
//              //  stickerEditor.finalizeTextPositionUpdate(textView: selectedTextView, to: finalPosition)
//                Editor.trackTextMovement(textView: selectedTextView, from: Editor.getPreviousTextPosition(for: selectedTextView) ?? selectedTextView.center, to: finalPosition)
//              //  self.selectedAddTextView?.removeOutline()
//                self.removeAlignmentLines()
//
//            default:
//                break
//            }
//            
//            
//        }
//    }


//    func handleGestureText(_ gestureRecognizer: UIPanGestureRecognizer) {
//        if self.magnifyingGlass.magnifiedView == nil {
//            self.alignmentText() // Check for snapping
//
//            if gestureRecognizer.state == .changed {
//                if self.selectedAddTextView != nil {
//                    let point = gestureRecognizer.location(in: self.stickerTextView)
//                    let superview = self.stickerTextView
//                    let restrictByPoint: CGFloat = 30.0
//                    let xAxis = superview.bounds.origin.x + restrictByPoint
//                    let yAxis = superview.bounds.origin.y + restrictByPoint
//                    let width = superview.bounds.size.width - 2 * restrictByPoint
//                    let height = superview.bounds.size.height - 2 * restrictByPoint
//                    let superBounds = CGRect(x: xAxis, y: yAxis, width: width, height: height)
//
//                    if superBounds.contains(point) {
//                        let translation = gestureRecognizer.translation(in: self.stickerTextView)
//
//                        // Calculate the new center
//                        var newCenter = CGPoint(
//                            x: (self.selectedAddTextView?.center.x ?? 0) + translation.x,
//                            y: (self.selectedAddTextView?.center.y ?? 0) + translation.y
//                        )
//
//                        // Snap and hold logic
//                        newCenter = self.snapToEdgeLines(newCenter)
//
//                        // Apply the new center
//                        self.selectedAddTextView?.center = newCenter
//
//                        // Start or reset the timer if near the edges
//                        if isNearEdge {
//                            startHoldTimer()
//                        }
//
//                        // Reset the gesture translation
//                        gestureRecognizer.setTranslation(CGPoint.zero, in: self.stickerTextView)
//                    }
//                }
//            }
//
//            if gestureRecognizer.state == .ended {
//                self.removeAlignmentLines()
//                holdTimer?.invalidate()
//                isNearEdge = false
//                isSnapped = false
//            }
//        }
//    }
//
//    func snapToEdgeLines(_ center: CGPoint) -> CGPoint {
//        let snapThreshold: CGFloat = 10.0 // Distance threshold for snapping
//        var snappedCenter = center
//
//        // Snap to left edge
//        if abs(center.x - self.stickerTextView.bounds.minX) <= snapThreshold {
//            snappedCenter.x = self.stickerTextView.bounds.minX + (self.selectedAddTextView?.frame.width ?? 0) / 2
//            self.leftAlignMargin.isHidden = false
//            isNearEdge = true
////            hapticFeedback()
//        } else {
//            self.leftAlignMargin.isHidden = true
//        }
//
//        // Snap to right edge
//        if abs(center.x - self.stickerTextView.bounds.maxX) <= snapThreshold {
//            snappedCenter.x = self.stickerTextView.bounds.maxX - (self.selectedAddTextView?.frame.width ?? 0) / 2
//            self.rightAlignMargin.isHidden = false
//            isNearEdge = true
////            hapticFeedback()
//        } else {
//            self.rightAlignMargin.isHidden = true
//        }
//
//        // Snap to top edge
//        if abs(center.y - self.stickerTextView.bounds.minY) <= snapThreshold {
//            snappedCenter.y = self.stickerTextView.bounds.minY + (self.selectedAddTextView?.frame.height ?? 0) / 2
//            self.topAlignMargin.isHidden = false
//            isNearEdge = true
////            hapticFeedback()
//        } else {
//            self.topAlignMargin.isHidden = true
//        }
//
//        // Snap to bottom edge
//        if abs(center.y - self.stickerTextView.bounds.maxY) <= snapThreshold {
//            snappedCenter.y = self.stickerTextView.bounds.maxY - (self.selectedAddTextView?.frame.height ?? 0) / 2
//            self.bottomAlignMargin.isHidden = false
//            isNearEdge = true
////            hapticFeedback()
//        } else {
//            self.bottomAlignMargin.isHidden = true
//        }
//
//        return snappedCenter
//    }
//
//
//    func startHoldTimer() {
//        holdTimer?.invalidate() // Reset any existing timer
//
//        // Start a new timer for 2 seconds
//        holdTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(performMoveAfterHold), userInfo: nil, repeats: false)
//    }
//
//
//    @objc func performMoveAfterHold() {
//        if isNearEdge {
//            isSnapped = true
//            isNearEdge = false
//
//            // Hide alignment lines
//            hideAlignmentLines()
//        }
//    }
//
//
//
//    func hideAlignmentLines() {
//        self.leftAlignMargin.isHidden = true
//        self.rightAlignMargin.isHidden = true
//        self.topAlignMargin.isHidden = true
//        self.bottomAlignMargin.isHidden = true
//    }
//

//=======
//    func handleGestureText(_ gestureRecognizer: UIPanGestureRecognizer) {
//        if self.magnifyingGlass.magnifiedView == nil {
//            self.alignmentText()
//            if gestureRecognizer.state == .changed {
//                if self.selectedAddTextView != nil {
//                    let point = gestureRecognizer.location(in: self.stickerTextView)
//                    let superview = self.stickerTextView
//                    let restrictByPoint : CGFloat = 30.0
//                    let xAxis = superview.bounds.origin.x + restrictByPoint
//                    let yAxis = superview.bounds.origin.y + restrictByPoint
//                    let width = superview.bounds.size.width - 2*restrictByPoint
//                    let height = superview.bounds.size.height - 2*restrictByPoint
//                    let superBounds = CGRect(x: xAxis, y: yAxis, width: width, height: height)
//                    
//                    if (superBounds.contains(point)) {
//                        let translation = gestureRecognizer.translation(in: self.stickerTextView)
//                        self.selectedAddTextView?.center = CGPoint(x: (self.selectedAddTextView?.center.x ?? 0) + translation.x, y: (self.selectedAddTextView?.center.y ?? 0) + translation.y)
//                        gestureRecognizer.setTranslation(CGPoint.zero, in: self.stickerTextView)
//                    }
//                }
//            }
//            
//            if gestureRecognizer.state == .ended {
//                self.removeAlignmentLines()
//            }
//        }
//    }
//>>>>>>> feature_sprint_4_7_8
}
