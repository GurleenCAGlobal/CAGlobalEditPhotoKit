//
//  CAEditFiltersViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 08/04/24.
//

// MARK: - Filter Option  
 
import UIKit

extension CAEditViewController: FilterViewDelegate {
    func setUpFilter() {
        self.removeBottomSubViews()
        if isFilterFetched == true {
            setUpFilterView()
        } else {
            self.setFilterArray()
        }
    }
    
    func setUpFilterView() {
        self.saveCrossView.showView()
        self.removeBottomSubViews()
        self.doneButton.isHidden = false
        let newView = FilterView()
        newView.filterImages = self.filterImages
        newView.selectedFilter = self.selectedFilter
        newView.updateSliderValue(value: self.selectedFilterOpacity)
        newView.delegate = self
        self.bottomView.addSubview(newView)
        self.bottomView.isHidden = false
        self.setupAutoLayoutForBottomView(newView: newView, bottomView: self.bottomView)
        if self.selectedFilter == "" {
            self.constraintsBottomViewHeight.constant = 80
        } else {
            self.constraintsBottomViewHeight.constant = 130
        }
    }

    func selectedFilterImage(nameString: String, isEmpty:Bool, sliderValue: CGFloat) {
        self.selectedFilterOpacity = sliderValue
        if isEmpty {
            self.constraintsBottomViewHeight.constant = 80
            self.selectedFilter = nameString
            self.mainImageView.image = self.applyingAllFilters(false, true, false)
            self.saveCrossView.showView()
            self.doneButton.isHidden = false
        } else {
            self.constraintsBottomViewHeight.constant = 130
            self.selectedFilter = nameString
            self.mainImageView.image = self.applyingAllFilters()
            self.saveCrossView.showView()
            self.doneButton.isHidden = false
        }
    }
    
    //anu
//    func selectedFilterImage(nameString: String, isEmpty:Bool, sliderValue: CGFloat) {
//        self.selectedFilterOpacity = sliderValue
//        if isEmpty {
//            self.constraintsBottomViewHeight.constant = 80
//            self.selectedFilter = nameString
//            self.mainImageView.image = self.applyingAllFilters(false, true, false)
//            self.saveCrossView.showView()
//            self.doneButton.isHidden = false
//        } else {
//            self.constraintsBottomViewHeight.constant = 130
//            self.selectedFilter = nameString
//            self.mainImageView.image = self.applyingAllFilters()
//            self.saveCrossView.showView()
//            self.doneButton.isHidden = false
//        }
//    }
    
    func filterOpacity(sliderValue: CGFloat) {
        self.selectedFilterOpacity = sliderValue
        self.mainImageView.image = self.applyingAllFilters()
        self.saveCrossView.showView()
        self.doneButton.isHidden = false
    }
    
    func applyFilter() {

        if self.selectedFilter == "" {
            self.option.isFilter = false
        } else {
            self.option.isFilter = true
        }
        
        self.option.appliedFilterDetails.append((filterName: self.selectedFilter, opacityValue: self.selectedFilterOpacity))
        
        // Integrate undo/redo for adding filter action
        //Editor.currentFilterSelection = .filter // Set the current selection
        self.addFilterUndoArray()
        self.undoButton.isHidden = false
        self.redoButton.isHidden = false
    }
    
    func resetFilter() {
        self.selectedFilter = ""
        for filterDetail in self.option.appliedFilterDetails {
            self.selectedFilter = filterDetail.filterName
            self.selectedFilterOpacity = filterDetail.opacityValue
        }
        self.mainImageView.image = self.applyingAllFilters()
    }
    
    func setFilterArray() {
        // Converting images with Filter LUT
        IHProgressHUD.show(withStatus: "Fetching filters")
        DispatchQueue.global(qos: .userInitiated).async {
            self.filterData = self.filterManager.getFilterData()
            self.filterImages.removeAll()
            for data in self.filterData {
                if let image = self.imageOrignal {
                    let imageR = self.resizeImage(image: image, newWidth: 100)
                    let finalImage = imageR.applyLUTFilter(LUT: UIImage(named: data), volume: 1.0)
                    self.filterImages.append(finalImage)
                }
            }
        }
        filterTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateFilterTimer), userInfo: nil, repeats: true)
    }
    
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {

        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.draw(in: CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }
    
    @objc func updateFilterTimer() {
        if self.filterData.count == self.filterImages.count {
            IHProgressHUD.dismiss()
            filterTimer?.invalidate()
            self.isFilterFetched = true
            self.setUpFilterView()
        }
    }
}
