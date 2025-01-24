//
//  CAEditBrushViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 08/04/24.
//

import UIKit

// MARK: - Brush Option -

extension CAEditViewController: BrushViewDelegate, DrawingViewDelegate {
    
    func backButtonBrushSubCategory() {
        self.saveCrossView.showView()
        self.saveCrossSubOptionsView.hideView()
    }
    
    func setSharpness(sliderValue: CGFloat) {
        // Calculate the inverse sharpness
        let invertedValue = sliderValue

        // Apply the inverted sharpness to DrawingView

        self.viewPaintDrawing.brushSharpness = invertedValue
        self.viewPaintDrawing.setNeedsDisplay()
    }

    func removePickColorForBrush() {
        self.viewPaintDrawing.isUserInteractionEnabled = true
        self.stickerTextView.isUserInteractionEnabled = false
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()
    }
    
    
    func pickColorForBrush(callBack: (UIColor) -> Void?) {
        self.selectedAddTextView = nil
        self.selectedAddSticker = nil
        self.removeGesturesMainImageViewForMagnify()
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanColorPickerMagnify(_:)))
        pan.delegate = self
        self.mainImageView.addGestureRecognizer(pan)
        self.viewPaintDrawing.isUserInteractionEnabled = false
        self.stickerTextView.isUserInteractionEnabled = false
        self.magnifyingGlass.magnifiedView = self.mainImageView
        self.magnifyingGlass.magnify(at: self.overlay.cropBox.center)
        let color = self.scrollViewContainer.getPixelColorAt(point: self.overlay.center)
        self.option.selectedBrushColorIndex = 100
        self.viewPaintDrawing.strokeColor = color
        
        self.drawingViewWillBeginDraw()
        callBack(color)
    }

    func setUpBrushView() {
        self.stickerTextView.isUserInteractionEnabled = false
        self.saveCrossView.showView()
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: false)
        self.removeBottomSubViews()
        self.doneButton.isHidden = false
        setupPaintView()
        self.brushView.delegate = self
        self.brushView.actionOnSubOptionTick()
        self.brushView.colorModel.selectedColorIndex = self.option.selectedBrushColorIndex
        self.brushView.colorButton.backgroundColor = self.viewPaintDrawing.strokeColor
        self.brushView.widthSlider.value = Float(self.viewPaintDrawing.strokeWidth )
        self.brushView.opacitySlider.value = Float(self.viewPaintDrawing.strokeOpacity )
        if self.brushView.sharpnessSlider.value == 10.0 {
            self.brushView.sharpnessSlider.value = 1.0
        }   else {
            self.brushView.sharpnessSlider.value = Float(self.viewPaintDrawing.brushSharpness )
            
        }
//        if self.brushView.opacitySlider.value == 1.0 {
//            self.brushView.opacitySlider.value = 1.0
//        } else {
//            self.brushView.opacitySlider.value = Float(self.viewPaintDrawing.strokeOpacity )
//        }

        self.brushView.setupUI()
        self.bottomView.addSubview(self.brushView)
        self.bottomView.isHidden = false
        self.setupAutoLayoutForBottomView(newView: self.brushView, bottomView: self.bottomView)
    }
    
    func setupPaintView() {
        let value = self.option.appliedBrushDetails.last
        
        if self.option.appliedBrushDetails.count == 0 {
            self.option.selectedBrushColorIndex = 0
        }
        
        self.viewPaintDrawing.strokeColor = value?.color ?? UIColor(named: .blackColorName)!
        self.viewPaintDrawing.strokeWidth = value?.width ?? 10
        self.viewPaintDrawing.strokeOpacity = value?.opacity ?? 1
        self.viewPaintDrawing.brushSharpness = value?.sharpness ?? 1
        self.viewPaintDrawing.isUserInteractionEnabled = true
        self.viewPaintDrawing.isHidden = false
        self.viewPaintDrawing.delegate = self
    }
    
    func resetColor() {
        let array = self.viewPaintDrawing.lines
        if array.count > 0 {
            // Use the color of the last drawn line
            let lastColor = self.viewPaintDrawing.lines.last?.color ?? UIColor(named: .blackColorName)!
            self.viewPaintDrawing.strokeColor = lastColor
            self.brushView.colorModel.selectedColorIndex = self.option.selectedBrushColorIndex

            // Update the color picker and button if necessary
            if self.option.savedBrushColorIndex == 100 || self.option.selectedBrushColorIndex == 100 {
                self.option.selectedBrushColorIndex = self.option.savedBrushColorIndex
                self.brushView.colorPickerView.backgroundColor = lastColor
                self.brushView.colorButton.backgroundColor = lastColor
            } else {
                self.brushView.colorPickerView.backgroundColor = UIColor(named: .blackColorName)!
                self.brushView.colorButton.backgroundColor = lastColor
            }

            // Set the stroke color in other related views
            self.brushView.sharpnessColorLbl.backgroundColor = self.viewPaintDrawing.strokeColor
            self.brushView.brushTransparencyLabel.backgroundColor = self.viewPaintDrawing.strokeColor
            self.brushView.brushSizeLabel.backgroundColor = self.viewPaintDrawing.strokeColor
            self.brushView.colorOptionButton.hideView()
        } else {
            // If no lines are drawn, use the last applied brush details
            let value = self.option.appliedBrushDetails.last
            if self.option.appliedBrushDetails.count == 0 {
                self.option.selectedBrushColorIndex = 0
            }

            let selectedColor = value?.color ?? UIColor(named: .blackColorName)!
            self.viewPaintDrawing.strokeColor = selectedColor
            self.brushView.colorModel.selectedColorIndex = self.option.selectedBrushColorIndex
            self.brushView.sharpnessColorLbl.backgroundColor = selectedColor
            self.brushView.brushTransparencyLabel.backgroundColor = selectedColor
            self.brushView.brushSizeLabel.backgroundColor = selectedColor
            self.brushView.colorOptionButton.hideView()

            // Default color settings for picker and button
            self.brushView.colorPickerView.backgroundColor = UIColor(named: .blackColorName)!
            self.brushView.colorButton.backgroundColor = UIColor(named: .blackColorName)!
        }
    }
    func setReset() {
        self.drawingViewWillBeginDraw()
        self.viewPaintDrawing.undoDraw()
    }
    
    func setSize(sliderValue: CGFloat) {
        self.drawingViewWillBeginDraw()
        self.viewPaintDrawing.strokeWidth = sliderValue
    }

    func opacityDidEnd(sliderValue: CGFloat) {
        self.brushSharpenessView.isHidden = true
    }

    func setOpacity(sliderValue: CGFloat) {
        self.drawingViewWillBeginDraw()
        self.viewPaintDrawing.strokeOpacity = sliderValue
        self.brushSharpenessView.isHidden = false
        self.brushSharpenessImageView.alpha = sliderValue
    }
    
    func applyColor(_ brushView: BrushView, colorModel: ColorModel) {
        self.viewPaintDrawing.isUserInteractionEnabled = true
        self.stickerTextView.isUserInteractionEnabled = false
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()
        self.option.selectedBrushColorIndex = colorModel.selectedColorIndex
        self.drawingViewWillBeginDraw()
        self.viewPaintDrawing.strokeColor = colorModel.color
        self.viewPaintDrawing.strokeOpacity = 1.0

    }
    
    // MARK: - Perform Drawing Action
//        func performDrawing(newDrawing: UIImage) {
//            // Save the current drawing state before updating it
//            let oldDrawing = drawingView.image
//
//            // Register the undo action, so you can revert to the old state
//            undoMng.registerUndo(withTarget: self) { target in
//                target.performUndoDrawing(previousImage: oldDrawing!)
//            }
//
//            // Update the current drawing with the new image
//            drawingView.image = newDrawing
//            currentDrawing = newDrawing // Keep track of the new drawing
//
//            // Update UI controls
//            enableDisableUIControl()
//        }
//
//        // MARK: - Undo Drawing Action
//        func performUndoDrawing(previousImage: UIImage) {
//            let currentImage = drawingView.image
//
//            // Register redo action, so you can redo the drawing
//            undoMng.registerUndo(withTarget: self) { target in
//                target.performDrawing(newDrawing: currentImage!)
//            }
//
//            // Restore the previous drawing
//            drawingView.image = previousImage
//            currentDrawing = previousImage
//
//            // Update UI controls
//            enableDisableUIControl()
//        }
    func applyBrush() {
     //   performDrawing(newDrawing: <#T##UIImage#>)
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()
        let array = self.viewPaintDrawing.lines
        self.option.removedBrushDetails.removeAll()
        
        if array.count > 0 {
            self.option.isBrush = true
            let array = self.viewPaintDrawing.lines
            for (i,isSave) in array.enumerated() {
                var param = isSave
                param.isSaveLine = true
                self.viewPaintDrawing.lines[i] = param
            }
            self.option.appliedBrushDetails = self.viewPaintDrawing.lines
        } else {
            self.option.appliedBrushDetails.removeAll()
            self.option.isBrush = false
        }
        self.viewPaintDrawing.isUserInteractionEnabled = false
        self.option.savedBrushColorIndex = self.option.selectedBrushColorIndex
    }
    
    func resetBrush() {
        self.option.isBrush = false
        self.viewPaintDrawing.isUserInteractionEnabled = false
        self.stickerTextView.isUserInteractionEnabled = true
        let array = self.viewPaintDrawing.lines
        if array.count > 0 {
            if self.option.appliedBrushDetails.count > 0 {
                self.viewPaintDrawing.reDraw(lines: self.option.appliedBrushDetails)
            } else {
                self.viewPaintDrawing.clearCanvasView()
            }
        } else {
            if self.option.removedBrushDetails.count > 0 {
                let array = self.option.removedBrushDetails
                var arraySaved = [TouchPointsAndColor]()
                for isSave in array{
                    if isSave.isSaveLine == true {
                        arraySaved.append(isSave)
                    }
                }
                self.viewPaintDrawing.reDraw(lines: arraySaved.reversed())
                self.option.removedBrushDetails.removeAll()
            }
        }
    }
    
    func setLine() {
        self.drawingViewWillBeginDraw()
    }
    
    func drawingViewWillBeginDraw() {
        self.option.isBrush = false
        self.saveCrossView.showView()
        self.doneButton.isHidden = false
    }
    
    func setFurtherColor() {
        let colorPickerViewController = AMColorPickerViewController()
        colorPickerViewController.selectedColor = self.viewPaintDrawing.strokeColor
        colorPickerViewController.selectedOpacity = self.viewPaintDrawing.strokeOpacity
        colorPickerViewController.delegate = self
        present(colorPickerViewController, animated: true, completion: nil)
    }
    
    func tickAndCrossForSubOptionsBrush(name: String) {
        if name == "color" {
            self.brushSelection = .color
        } else if name == "transparency" {
            self.brushSelection = .transperancy
        } else if name == "size" {
            self.brushSelection = .size
        } else if name == "sharpness" {
            self.brushSelection = .sharpness
        }
        if self.option.selectedBrushColorIndex == 0 {
            self.brushView.colorModel.selectedColorIndex = self.option.selectedBrushColorIndex
            self.brushView.colorButton.backgroundColor = (UIColor(named: .blackColorName)!)
            self.brushView.colorOptionButton.hideView()
            self.brushView.colorPickerView.backgroundColor = (UIColor(named: .blackColorName)!)
            self.brushView.colorButton.backgroundColor = (UIColor(named: .blackColorName)!)
        }
        self.isSubOptions = true
        self.constraintsBottomViewHeight.constant = 80
        self.saveCrossView.hideView()
        self.saveCrossSubOptionsView.showView()
    }

    func backButtonColorBrush() {
        self.magnifyingGlass.magnifiedView = nil
        self.removeGesturesMainImageViewForMagnify()
        self.deleteAndAddButtons.isHidden = false
        self.textView.actionCrossForText()
    }
}

