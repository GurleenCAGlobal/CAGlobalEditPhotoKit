//
//  AdjustsView.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 05/07/23.
//

import UIKit

// Define a protocol for the cell's data source
protocol AdjustsViewDelegate: AnyObject {
    /*
     Called when the user select adjust
     */
    func selectedAdjustment(_ sender: UISlider, adjustSelection: AdjustSelection)
    /*
     Called when the user select reset
     */
    func resetAdjustment(adjustSelection: AdjustSelection)
}

class AdjustsView: UIView {
    // MARK: Outlets
    // This outlet represents to the main view in the interface builder
    @IBOutlet weak var mainView: UIView!
    // This outlet represents to the container view for CollectionView
    @IBOutlet weak var adjustCollectionViewContainerView: UIView!
    // This outlet represents to the collection view for selecting adjusts
    @IBOutlet weak var adjustCollectionView: UICollectionView!
    // This outlet represents to the container view for displaying opacity options
    @IBOutlet weak var sliderBrightnessContainerView: UIView!
    // This outlet represents to the container view for displaying opacity options
    @IBOutlet weak var sliderContrastContainerView: UIView!
    // This outlet represents to the container view for displaying opacity options
    @IBOutlet weak var sliderTempratureContainerView: UIView!
    // This outlet represents to the container view for displaying opacity options
    @IBOutlet weak var sliderSaturationContainerView: UIView!
    // This outlet represents to the container view for displaying opacity options
    @IBOutlet weak var sliderExposureContainerView: UIView!
    // This outlet represents to the button used for color selection
    @IBOutlet weak var backButton: UIButton!
    // This outlet represents to the slider used for adjusting opacity
    @IBOutlet weak var opacityBrightnessSlider: UISlider!
    // This outlet represents to the slider used for adjusting opacity
    @IBOutlet weak var opacityContrastSlider: UISlider!
    // This outlet represents to the slider used for adjusting opacity
    @IBOutlet weak var opacityTemperatureSlider: UISlider!
    // This outlet represents to the slider used for adjusting opacity
    @IBOutlet weak var opacitySaturationSlider: UISlider!
    // This outlet represents to the slider used for adjusting opacity
    @IBOutlet weak var opacityExposureSlider: UISlider!
    
    // MARK: Properties
    weak var delegate: AdjustsViewDelegate?
    private var editViewModel = CAEditViewModel()
    var adjustSelection = AdjustSelection(rawValue: -1)
    var brightness = Float()
    var contrast = Float()
    var saturation = Float()
    var temperature = Float()
    var exposure = Float()
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        backgroundColor = .clear
        mainView = loadViewFromNib()
        mainView.frame = bounds
        mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainView.translatesAutoresizingMaskIntoConstraints = true
        addSubview(mainView)
        initCollectionView()
    }
    
    private func loadViewFromNib() -> UIView {
        let bundlePath = Bundle(for: AdjustsView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = bundlePath != nil ? Bundle(path: bundlePath!) : nil

        let nib = UINib(nibName: AdjustsView.className, bundle: bundle)
        guard let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Failed to load TextView from nib.")
        }
        return nibView
    }
    
    private func initCollectionView() {
        if let bundlePath = Bundle(for: EditOptionsCell.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle"),
           let bundle = Bundle(path: bundlePath) {
            
            // Register the NIB from the correct bundle
            let nib = UINib(nibName: "EditOptionsCell", bundle: bundle)
            adjustCollectionView.register(nib, forCellWithReuseIdentifier: EditOptionsCell.className)
            adjustCollectionView.dataSource = self
            adjustCollectionView.delegate = self

        } else {
            // Handle error if the bundle is not found
            print("Error: Unable to find CAGlobalPhotoSDKResources.bundle")
        }
    }
    
    func updateSliderValues() {
        
        self.opacityBrightnessSlider.minimumValue = -0.5
        self.opacityBrightnessSlider.maximumValue = 0.5
        self.opacityContrastSlider.minimumValue = 0.5
        self.opacityContrastSlider.maximumValue = 1.5
        self.opacitySaturationSlider.minimumValue = 0
        self.opacitySaturationSlider.maximumValue = 2
        self.opacityExposureSlider.minimumValue = -2
        self.opacityExposureSlider.maximumValue = 2
        
        self.opacityContrastSlider.value = self.contrast
        self.opacityBrightnessSlider.value = self.brightness
        self.opacitySaturationSlider.value = self.saturation
        self.opacityTemperatureSlider.value = self.temperature
        self.opacityExposureSlider.value = self.exposure
    }
    
    // MARK: Actions
    @IBAction func actionCrossContainer(_ sender: UISlider) {
        self.adjustCollectionViewContainerView.isHidden = false
        self.sliderBrightnessContainerView.isHidden = true
        self.sliderContrastContainerView.isHidden = true
        self.sliderTempratureContainerView.isHidden = true
        self.sliderSaturationContainerView.isHidden = true
        self.sliderExposureContainerView.isHidden = true
    }
    @IBAction func temperatureSliderValueChanged(_ sender: UISlider) {
        DispatchQueue.main.async {
            self.delegate?.selectedAdjustment(sender, adjustSelection: self.adjustSelection ?? .none)
        }
    }
    @IBAction func actionReset(_ sender: UISlider) {
            self.opacitySaturationSlider.value = 1.0
            self.opacityContrastSlider.value = 1.0
            self.opacityBrightnessSlider.value = 0.0
        
        self.delegate?.resetAdjustment(adjustSelection: self.adjustSelection ?? .none)
    }
    
    @IBAction func actionBrightness(_ sender: UISlider) {
        let currentAdjustSelection = AdjustSelection(rawValue: 0) ?? .none
        self.adjustSelection = currentAdjustSelection
        self.adjustCollectionViewContainerView.isHidden = true
        self.sliderBrightnessContainerView.isHidden = true
        self.sliderContrastContainerView.isHidden = true
        self.sliderTempratureContainerView.isHidden = true
        self.sliderSaturationContainerView.isHidden = true
        self.sliderExposureContainerView.isHidden = true
        if currentAdjustSelection == .temperature {
            self.sliderTempratureContainerView.isHidden = false
        } else if currentAdjustSelection == .saturation {
            self.sliderSaturationContainerView.isHidden = false
        } else if currentAdjustSelection == .contrast {
            self.sliderContrastContainerView.isHidden = false
        } else if currentAdjustSelection == .brightness {
            self.sliderBrightnessContainerView.isHidden = false
        } else if currentAdjustSelection == .exposure {
            self.sliderExposureContainerView.isHidden = false
        }
    }
    @IBAction func actionContrast(_ sender: UISlider) {
        let currentAdjustSelection = AdjustSelection(rawValue: 1) ?? .none
        self.adjustSelection = currentAdjustSelection
        self.adjustCollectionViewContainerView.isHidden = true
        self.sliderBrightnessContainerView.isHidden = true
        self.sliderContrastContainerView.isHidden = true
        self.sliderTempratureContainerView.isHidden = true
        self.sliderSaturationContainerView.isHidden = true
        self.sliderExposureContainerView.isHidden = true
        if currentAdjustSelection == .temperature {
            self.sliderTempratureContainerView.isHidden = false
        } else if currentAdjustSelection == .saturation {
            self.sliderSaturationContainerView.isHidden = false
        } else if currentAdjustSelection == .contrast {
            self.sliderContrastContainerView.isHidden = false
        } else if currentAdjustSelection == .brightness {
            self.sliderBrightnessContainerView.isHidden = false
        } else if currentAdjustSelection == .exposure {
            self.sliderExposureContainerView.isHidden = false
        }
    }
    @IBAction func actionSaturation(_ sender: UISlider) {
        let currentAdjustSelection = AdjustSelection(rawValue: 2) ?? .none
        self.adjustSelection = currentAdjustSelection
        self.adjustCollectionViewContainerView.isHidden = true
        self.sliderBrightnessContainerView.isHidden = true
        self.sliderContrastContainerView.isHidden = true
        self.sliderTempratureContainerView.isHidden = true
        self.sliderSaturationContainerView.isHidden = true
        self.sliderExposureContainerView.isHidden = true
        if currentAdjustSelection == .temperature {
            self.sliderTempratureContainerView.isHidden = false
        } else if currentAdjustSelection == .saturation {
            self.sliderSaturationContainerView.isHidden = false
        } else if currentAdjustSelection == .contrast {
            self.sliderContrastContainerView.isHidden = false
        } else if currentAdjustSelection == .brightness {
            self.sliderBrightnessContainerView.isHidden = false
        } else if currentAdjustSelection == .exposure {
            self.sliderExposureContainerView.isHidden = false
        }
    }
}

// MARK: - UICollectionViewDataSource and UICollectionViewDelegate  -
extension AdjustsView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.editViewModel.adjustData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditOptionsCell.className, for: indexPath) as? EditOptionsCell else {
            let cell = EditOptionsCell()
            return cell
        }
        
        cell.delegate = self
        cell.dataSource = self
        let data = self.editViewModel.adjustData[indexPath.row]
        cell.configureAdjust(with: data, isSelect: self.adjustSelection?.rawValue == indexPath.row)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    @objc(collectionView:layout:insetForSectionAtIndex:)  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {

        let totalCellWidth = 80 * self.editViewModel.adjustData.count
        let totalSpacingWidth = 10 * (self.editViewModel.adjustData.count - 1)

        let leftInset = (self.adjustCollectionView.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? EditOptionsCell
        let currentAdjustSelection = AdjustSelection(rawValue: indexPath.row) ?? .none
        cell?.handleSelectionAdjust(adjustSelection: self.adjustSelection ?? .none, currentAdjustSelection: currentAdjustSelection)
    }
}

// MARK: - Collecting filter options in array -
extension AdjustsView: EditOptionsCellDataSource {
    func getFilterData() -> [FilterModel] {
        return self.editViewModel.filterData
    }
}

extension AdjustsView: EditOptionsCellDelegate {
    func didSelectCellAdjust(adjustSelection: AdjustSelection, currentAdjustSelection: AdjustSelection) {
        self.adjustSelection = currentAdjustSelection
        self.adjustCollectionViewContainerView.isHidden = true
        self.sliderBrightnessContainerView.isHidden = true
        self.sliderContrastContainerView.isHidden = true
        self.sliderTempratureContainerView.isHidden = true
        self.sliderSaturationContainerView.isHidden = true
        self.sliderExposureContainerView.isHidden = true
        if currentAdjustSelection == .temperature {
            self.sliderTempratureContainerView.isHidden = false
        } else if currentAdjustSelection == .saturation {
            self.sliderSaturationContainerView.isHidden = false
        } else if currentAdjustSelection == .contrast {
            self.sliderContrastContainerView.isHidden = false
        } else if currentAdjustSelection == .brightness {
            self.sliderBrightnessContainerView.isHidden = false
        } else if currentAdjustSelection == .exposure {
            self.sliderExposureContainerView.isHidden = false
        }
        self.adjustCollectionView.reloadData()
    }
}
