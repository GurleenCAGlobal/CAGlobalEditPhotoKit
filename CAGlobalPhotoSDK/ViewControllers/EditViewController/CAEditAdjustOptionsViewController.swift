//
//  CAEditAdjustOptionsViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by caglobal on 08/04/24.
//

// MARK: - Adjusts Option -

extension CAEditViewController {
    func setUpAdjustsView() {
        self.saveCrossView.showView()
        self.option.isAdjust = false
        self.removeBottomSubViews()
        let newView = AdjustsView()
        newView.delegate = self
        newView.brightness = Float(self.arrayBrightnesSliderSavedValues.last ?? 0.0)
        newView.contrast = Float(self.arrayContrastSliderSavedValues.last ?? 1.0)
        newView.saturation = Float(self.arraySaturationSliderSavedValues.last ?? 1.0)
        newView.temperature = Float(self.arrayTemperatureSliderSavedValues.last ?? 0.0)
        newView.exposure = Float(self.arrayExposureSliderSavedValues.last ?? 0.50)
        newView.updateSliderValues()
        self.bottomView.addSubview(newView)
        self.bottomView.isHidden = false
        self.setupAutoLayoutForBottomView(newView: newView, bottomView: self.bottomView)
    }
}

extension CAEditViewController: AdjustsViewDelegate {
    func resetAdjustment(adjustSelection: AdjustSelection) {
        self.arrayContrastSliderValues.append(CGFloat(1.0))
        self.arrayBrightnesSliderValues.append(CGFloat(0.0))
        self.arraySaturationSliderValues.append(CGFloat(1.0))
        
        imageTransform = imageOrignalBackUp
        self.mainImageView.image = self.applyingAllFilters()

//        if adjustSelection == .temperature {
//        } else if adjustSelection == .saturation {
//            self.arraySaturationSliderValues.append(CGFloat(1.0))
//            self.mainImageView.image = self.applyingAllFilters()
//        } else if adjustSelection == .contrast {
//            self.arrayContrastSliderValues.append(CGFloat(1.0))
//            self.mainImageView.image = self.applyingAllFilters()
//        } else if adjustSelection == .brightness {
//            self.arrayBrightnesSliderValues.append(CGFloat(0.0))
//            self.mainImageView.image = self.applyingAllFilters()
//        } else if adjustSelection == .exposure {
//            self.arrayExposureSliderValues.append(CGFloat(0.50))
//            self.mainImageView.image = self.applyingAllFilters()
//        }
        self.saveCrossView.showView()
        self.doneButton.isHidden = false
    }
    
    func selectedAdjustment(_ sender: UISlider, adjustSelection: AdjustSelection) {
        self.adjustSelection = adjustSelection
        if adjustSelection == .temperature {
            self.arrayTemperatureSliderValues.append(CGFloat(sender.value))
            self.mainImageView.image = self.applyingAllFilters()
        } else if adjustSelection == .saturation {
            self.arraySaturationSliderValues.append(CGFloat(sender.value))
            self.mainImageView.image = self.applyingAllFilters()
        } else if adjustSelection == .contrast {
            self.arrayContrastSliderValues.append(CGFloat(sender.value))
            self.mainImageView.image = self.applyingAllFilters()
        } else if adjustSelection == .brightness {
            self.arrayBrightnesSliderValues.append(CGFloat(sender.value))
            self.mainImageView.image = self.applyingAllFilters()
        } else if adjustSelection == .exposure {
            self.arrayExposureSliderValues.append(CGFloat(sender.value))
            self.mainImageView.image = self.applyingAllFilters()
        }
        self.saveCrossView.showView()
        self.doneButton.isHidden = false
    }
    
    func applyAdjust() {
        self.option.isAdjust = false
        if self.arrayTemperatureSliderSavedValues.last != 0 {
            self.option.isAdjust = true
        }
        if self.arraySaturationSliderValues.last != 1 {
            self.option.isAdjust = true
        }
        if self.arrayContrastSliderValues.last != 1 {
            self.option.isAdjust = true
        }
        if self.arrayBrightnesSliderValues.last != 0 {
            self.option.isAdjust = true
        }
        if self.arrayExposureSliderValues.last != 0.5 {
            self.option.isAdjust = true
        }
        self.arrayTemperatureSliderSavedValues.append(self.arrayTemperatureSliderValues.last ?? 0.0)
        self.arraySaturationSliderSavedValues.append(self.arraySaturationSliderValues.last ?? 1.0)
        self.arrayContrastSliderSavedValues.append(self.arrayContrastSliderValues.last ?? 1.0)
        self.arrayBrightnesSliderSavedValues.append(self.arrayBrightnesSliderValues.last ?? 0.0)
        self.arrayExposureSliderSavedValues.append(self.arrayExposureSliderValues.last ?? 0.50)
        self.addFilterUndoArray()
        self.undoButton.isHidden = false
        self.redoButton.isHidden = false
    }
    
    func resetAdjust() {
        self.arrayTemperatureSliderValues.removeAll()
        self.arraySaturationSliderValues.removeAll()
        self.arrayContrastSliderValues.removeAll()
        self.arrayBrightnesSliderValues.removeAll()
        self.arrayExposureSliderValues.removeAll()
        self.arrayTemperatureSliderValues.append(self.arrayTemperatureSliderSavedValues.last ?? 0.0)
        self.arraySaturationSliderValues.append(self.arraySaturationSliderSavedValues.last ?? 1.0)
        self.arrayContrastSliderValues.append(self.arrayContrastSliderSavedValues.last ?? 1.0)
        self.arrayBrightnesSliderValues.append(self.arrayBrightnesSliderSavedValues.last ?? 0.0)
        self.arrayExposureSliderValues.append(self.arrayExposureSliderSavedValues.last ?? 0.50)
        imageTransform = imageOrignalBackUp
        self.mainImageView.image = self.applyingAllFilters()
    }
}
