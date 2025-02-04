//
//  CAEditTextViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 22/11/23.
//

import UIKit

extension CAEditViewController: TextViewDelegate, AddTextViewDelegate, TextViewControllerDelegate {
    
    func backButtonColortext() {
       // self.deleteAndAddButtons.isHidden = false
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()
        self.mainImageView.addGestureRecognizer(self.framePanGesture)
        self.stickersText(text: .showDeleteButton, isText: true)

    }
    
    func didChangeTextProperties(textModel: TextModel) {

    }


    func registerUndoForTextChanges() {
        let currentText = self.textModel.textString
        let currentFont = self.textModel.fontCustom
        let currentColor = self.textModel.color
        let currentAlignment = self.textModel.alignment

        undoMng?.registerUndo(withTarget: self, handler: { target in
            let previousText = target.textModel.textString
            target.textModel.textString = currentText
            target.textModel.redoStack.append(self.textModel.copyState()) // Save redo state
            target.updateFramesText()
        })

        // Register font, color, and alignment in a similar way
    }

    func restoreTextChanges(previousTextDetail: [(txtVw: AddTextView?, text: String?, frame: CGRect?, font: UIFont?, index: Int?, color: UIColor?, colorIn: Int?, previousColor: UIColor?, previousColorIndex: Int?, trnf: CGAffineTransform?, slider: CGFloat?, opacity: CGFloat?, textAlignment: NSTextAlignment?, fontCustom: String?, previousfont: String?, textString: String?, previousTextString: String?, selectedFontIndex: Int?, selectedPreviousFontIndex: Int?)]) {
        
        // Clear current text views
        self.stickersText(text: .removeAll, isText: true)

        // Filter out tuples where txtVw is nil
        let filteredTextDetail = previousTextDetail.compactMap { detail -> (AddTextView, String?, CGRect?, UIFont?, Int?, UIColor?, Int?, UIColor?, Int?, CGAffineTransform?, CGFloat?, CGFloat?, NSTextAlignment?, String?, String?, String?, String?, Int?, Int?)? in
            guard let txtVw = detail.txtVw else { return nil }
            return (txtVw, detail.text, detail.frame, detail.font, detail.index, detail.color, detail.colorIn, detail.previousColor, detail.previousColorIndex, detail.trnf, detail.slider, detail.opacity, detail.textAlignment, detail.fontCustom, detail.previousfont, detail.textString, detail.previousTextString, detail.selectedFontIndex, detail.selectedPreviousFontIndex)
        }

        // Restore text views to their previous state
        for detail in filteredTextDetail {
            let (txtVw, text, frame, font, index, color, colorIn, previousColor, previousColorIndex, trnf, slider, opacity, textAlignment, fontCustom, previousfont, textString, previousTextString, selectedFontIndex, selectedPreviousFontIndex) = detail

            // Apply restored properties to each text view
            txtVw.text = textString ?? "" // Apply restored text
            txtVw.frame = frame ?? .zero // Apply restored frame
            txtVw.font = font // Restore font
            txtVw.textColor = color // Restore text color
            txtVw.transform = trnf ?? .identity // Restore transform (position, rotation, scaling)
            txtVw.alpha = opacity ?? 1.0 // Restore opacity
            txtVw.textAlignment = textAlignment ?? .left // Restore text alignment
            // Apply any other custom properties like fontCustom, index, etc.

            // Add text view back to the main view or its superview
            self.view.addSubview(txtVw)
        }

        // Update frames and other settings after restoring text views
        self.option.textDetail = filteredTextDetail
        self.updateFramesText() // Use the restored text details to update the views
    }

    func setFurtherColorText(color: UIColor, opacity: CGFloat) {
        let colorPickerViewController = AMColorPickerViewController()
        colorPickerViewController.selectedColor = color
        colorPickerViewController.selectedOpacity = opacity

        colorPickerViewController.delegate = self
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
        if isOpen {
            self.deleteAndAddButtons.isHidden = true
            self.constraintsBottomViewHeight.constant = 80 + 40
        } else {
            self.deleteAndAddButtons.isHidden = false
            self.constraintsBottomViewHeight.constant = 80
        }
    }
    
    func tickAndCrossForSubOptions(isAlign: Bool) {
        if self.selectedTextModel.selectedColorIndex == 0 {
            self.textView.textModel = self.selectedTextModel
            self.textView.colorButton.backgroundColor = (UIColor(named: .blackColorName, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!)
            self.textView.colorOptionButton.hideView()
            self.textView.colorPickerView.backgroundColor = (UIColor(named: .blackColorName, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!)
            self.textView.colorButton.backgroundColor = (UIColor(named: .blackColorName, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!)
        }
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
    
    func pickColor(callBack: (UIColor) -> Void?) {
        self.selectedAddTextView = nil
        self.selectedAddSticker = nil
        /**
         UIPanGestureRecognizer - Pan Objects
         */
        self.removeGesturesMainImageViewForMagnify()
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanColorPickerMagnify(_:)))
        pan.delegate = self
        self.mainImageView.addGestureRecognizer(pan)
        self.magnifyingGlass.magnifiedView = self.mainImageView
        self.magnifyingGlass.magnify(at: self.overlay.cropBox.center)
        let color = self.scrollViewContainer.getPixelColorAt(point: self.overlay.cropBox.center)
        let textModel = TextModel()
        textModel.color = color
        textModel.selectedColorIndex = 100
        textModel.previousColor = self.selectedTextModel.previousColor
        textModel.previousSelectedColorIndex = self.selectedTextModel.previousSelectedColorIndex
        
        textModel.selectedFontIndex = self.selectedTextModel.selectedFontIndex
        textModel.previousSelectedFontIndex = self.selectedTextModel.previousSelectedFontIndex
        textModel.textString = self.selectedTextModel.textString
        textModel.previousTextString = self.selectedTextModel.previousTextString
        textModel.fontCustom = self.selectedTextModel.fontCustom
        textModel.previousFont = self.selectedTextModel.previousFont
       // self.selectedTextModel = textModel
        self.stickersText(text: .setColor, color: color, index: 100, isText: true)
        callBack(color)
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
                    textModel.color = color
                    textModel.selectedColorIndex = 100
                    textModel.previousColor = self.selectedTextModel.previousColor
                    textModel.previousSelectedColorIndex = self.selectedTextModel.previousSelectedColorIndex
                    textModel.selectedFontIndex = self.selectedTextModel.selectedFontIndex
                    textModel.previousSelectedFontIndex = self.selectedTextModel.previousSelectedFontIndex
                    textModel.textString = self.selectedTextModel.textString
                    textModel.previousTextString = self.selectedTextModel.previousTextString
                    textModel.fontCustom = self.selectedTextModel.fontCustom
                    textModel.previousFont = self.selectedTextModel.previousFont
                    self.selectedTextModel = textModel
                    self.stickersText(text: .setColor, color: color, index: 100, isText: true)
                    self.textView.setUpPickerColor(views: self.stickerTextView.subviews, color: color)
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
                    self.selectedStickerColorModel = color
                    self.stickersText(text: .setColor, color: color, isText: false)
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
    
    func addTextLabelToView(object : [String : Any]) {
        // Register undo before adding new text
        let dictionary = object
        if  let isNew = dictionary[EditStaticStrings.newText] as? Bool {
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
                let font =  UIFont.init(name: dictionary[EditStaticStrings.font] as? String ?? "", size: 24)!
                let color = dictionary[EditStaticStrings.color] as? UIColor ?? .blue
                var arrayTextViewDetail = [Any]( )
                arrayTextViewDetail.append(frame)
                arrayTextViewDetail.append(text)
                arrayTextViewDetail.append(font)
                arrayTextViewDetail.append(color)
                
                let view = self.textManager.addText(delegate: self, textViewDetail: arrayTextViewDetail, isTransform: false, transform: transform, tag: textTempTags, alpha: 1, textAlignment: NSTextAlignment.left)
                
                let selectedColorIndex = dictionary[EditStaticStrings.selectedColorIndex] as? Int
                view.selectedColor = dictionary[EditStaticStrings.color] as? UIColor ?? .black
                view.selectedColorIndex = selectedColorIndex ?? 0
                view.previousColor = dictionary[EditStaticStrings.previousColor] as? UIColor ?? .black
                view.previousSelectedColorIndex = dictionary[EditStaticStrings.selectedPreviousColorIndex] as? Int ?? 0
                
                view.selectedFontIndex = dictionary[EditStaticStrings.selectedFontIndex] as? Int ?? 0
                view.selectedPreviousFontIndex = dictionary[EditStaticStrings.selectedPreviousFontIndex] as? Int ?? 0
                view.selectedFont = dictionary[EditStaticStrings.font] as? String ?? ""
                view.selectedPreviousFont = dictionary[EditStaticStrings.previousFont] as? String ?? ""
                view.selectedText = dictionary[EditStaticStrings.text] as? String ?? ""
                view.previousText = dictionary[EditStaticStrings.previousText] as? String ?? ""
                view.alpha = textViewOpacity
                view.textAlignment = dictionary[EditStaticStrings.selectedAlignment] as? NSTextAlignment ?? NSTextAlignment.left
                let width = (text.widthOfString(usingFont: font)) + 50
                _ = heightForView(text: text , font: font, width: width) + 50
                
                let maxWidth: CGFloat = self.mainImageScaledSizeForText.width
                let maxHeight: CGFloat = self.mainImageScaledSizeForText.height
                let info = sizeForView(text: text, font: font, maxSize: CGSize(width: maxWidth, height: maxHeight))
                view.bounds.size.height = info.0.height
                view.bounds.size.width = info.0.width + 8
                let rotationTransform = CGAffineTransform(rotationAngle: -totalAngle)
                view.transform = rotationTransform

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
                self.stickerTextView.addSubview(view)
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
                self.selectedTextModel = textModel

                Editor.currentFilterSelection = .text
                // Prepare the action data for undo/redo
                let actionData: [String: Any] = [
                    "view": view,
                    "previousState": [
                        "text": view.selectedText,
                        "font": view.selectedFont,
                        "color": view.selectedColor,
                        "frame": view.frame,
                        "transform": view.transform,
                        "selectedColorIndex": view.selectedColorIndex,
                        "selectedFontIndex": view.selectedFontIndex,
                        "textAlignment": view.textAlignment
                    ]
                ]

                // Perform the action for adding text
                Editor.performAction(type: .add, data: actionData)
            }
        }
        self.stickersText(text: .showDeleteButton, isText: true)

        self.mainCollectionView.isHidden = true
        self.addTextBottomView()
    }
    
    func addRemoveButtonOnText() {
        self.saveCrossView.showView()
        self.option.isText = false
        self.stickersText(text: .showDeleteButtonOnTap, isText: true)
        self.stickersText(text: .resetMove, isText: true)
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

            // Prepare the text view details for creating the text view
            let arrayTextViewDetail: [Any] = [ frame, text, font, color ]

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

            view.selectedFontIndex = textViewDetail.selectedFontIndex ?? 0
            view.selectedPreviousFontIndex = textViewDetail.selectedPreviousFontIndex ?? 0
            view.selectedFont = textViewDetail.fontCustom ?? ""
            view.selectedPreviousFont = textViewDetail.previousfont ?? ""
            view.selectedText = textViewDetail.textString ?? ""
            view.previousText = textViewDetail.previousTextString ?? ""

            // Add the newly created text view to the stickerTextView
            self.stickerTextView.addSubview(view)
        }
    }

    
    func saveAppliedTextFromView() {
        // Register undo before saving the current state
            registerUndoForTextChanges()

        self.option.textDetail.removeAll()
        let subViews = self.stickerTextView.subviews
        for subview in subViews {
            if subview is AddTextView {
                if let view = subview as? AddTextView {
                    let string = view.text
                    let frame = view.frame
                    let font = view.font
                    let index = view.selectedFontIndex
                    let selectedColorIndex = view.selectedColorIndex
                    let previousColor = view.previousColor
                    let previousSelectedColorIndex = view.previousSelectedColorIndex
                    
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
                    self.option.textDetail.append((txtVw: view, text: string, frame: frame, font: font, index: index, color: tColor, colorIn: selectedColorIndex, previousColor: previousColor, previousColorIndex: previousSelectedColorIndex, trnf: trans, slider: slider, opacity: view.alpha, textAlignment: alignment,fontCustom: fontCustom, previousfont: previousfont, textString: textString, previousTextString: previousTextString, selectedFontIndex: selectedFontIndex, selectedPreviousFontIndex: selectedPreviousFontIndex))

                    
                }
            }
        }
    }
    
    func applyText() {
     //   enableDisableUIControl()
        self.selectedAddTextView = nil
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()
        self.mainImageView.addGestureRecognizer(self.framePanGesture)
        self.option.isText = true
        self.stickersText(text: .saved, isText: true)
        self.stickersText(text: .hideDeleteButton, isText: true)
        self.saveAppliedTextFromView()
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
       // textModel.saveStateForUndo()
        //textModel.saveStateForRedo()
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
    
    func addTextToTextView(_: TextViewController, object: [String : Any]) {
        self.filterSelection = FilterSelection(rawValue: 5)
        self.addTextLabelToView(object: object)
    }
    
    func backToEdit(_: TextViewController) {
        self.mainCollectionView.showView()
        self.stickersText(text: .hideDeleteButton, isText: true)
        self.removeBottomSubViews()
        self.saveCrossView.hideView()
    }
    
    func editTextLabel(_: AddTextView) {

        if self.magnifyingGlass.magnifiedView == nil {
            self.editTextLblOnView()
        }

    }
    
    func addRemoveButtonFromText(_: AddTextView, tag: Int) {
        if self.magnifyingGlass.magnifiedView == nil, self.option.isFramesSelected == false {
            self.stickersText(text: .showDeleteButtonOnTap, isText: true)
            self.stickersText(text: .onTop, isText: true)
            self.mainCollectionView.isHidden = true
//            self.undoButton.isHidden = false
//            self.redoButton.isHidden = false
            self.addTextBottomView()
            if self.filterSelection == FilterSelection.none || self.filterSelection == FilterSelection.sticker {
                self.selectedAddSticker = nil
                self.stickersText(text: .hideSelection, isText: false)
                self.filterSelection = FilterSelection(rawValue: 5)
                self.mainCollectionView.reloadData()
            }
            self.addRemoveButtonOnText()
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

                        self.selectedTextModel = textModel
                    }
                }
            }
        }
    }
    
    func handleGestureText(_ gestureRecognizer: UIPanGestureRecognizer) {
        if self.magnifyingGlass.magnifiedView == nil {
            //anu comment for sprint 6
           // self.alignmentText()
            if gestureRecognizer.state == .changed {
                if self.selectedAddTextView != nil {
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
            }
            
            if gestureRecognizer.state == .ended {
                self.removeAlignmentLines()
            }
        }
    }

}
