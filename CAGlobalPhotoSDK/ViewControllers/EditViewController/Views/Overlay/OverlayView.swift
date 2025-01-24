//
//  OverlayView.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 19/05/23.
//

import UIKit

// Define a protocol for the cell's data source
protocol OverlayViewDelegate: AnyObject {
    /*
     Called when the user select any overlay
     */
    func setOverlay(nameString: String, sliderValue: CGFloat)
}

class OverlayView: UIView {
    
    // MARK: - Outlets
    
    // Outlet for the base view of the overlay view
    @IBOutlet weak var baseView: UIView!
    
    // Outlets for the Collection View
    @IBOutlet weak var overlayCollectionView: UICollectionView!
    
    // Outlet for the opacity view of the overlay view
    @IBOutlet weak var opacityView: UIView!
    
    // Outlet for the opacity slider of the overlay view
    @IBOutlet weak var opacitySlider: UISlider!
    
    private var opacityManager = OpacityManager()
    private(set) var filterData = [String]()
    var selectedOverlay = String()
    weak var delegate: OverlayViewDelegate?

    // MARK: - Initialization
    
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
        baseView = loadViewFromNib()
        baseView.frame = bounds
        baseView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        baseView.translatesAutoresizingMaskIntoConstraints = true
        addSubview(baseView)
        self.filterData = self.opacityManager.getOpacityData()
        self.initCollectionView()
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: OverlayView.self)
        let nib = UINib(nibName: OverlayView.className, bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return nibView ?? UIView()
    }
    
    private func initCollectionView() {
        let nib = UINib(nibName: OverlayCell.className, bundle: nil)
        overlayCollectionView.register(nib, forCellWithReuseIdentifier: OverlayCell.className)
        overlayCollectionView.dataSource = self
        overlayCollectionView.delegate = self
    }
    
    @IBAction func actionSliderValue(_ sender: UISlider) {
        self.delegate?.setOverlay(nameString: self.selectedOverlay, sliderValue: CGFloat(sender.value))
    }
    
    @IBAction func actionChange(_ sender: UISlider) {
        self.overlayCollectionView.isHidden = false
        self.opacityView.isHidden = true
    }
}

extension OverlayView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of cells in the table view
        return self.filterData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OverlayCell.className, for: indexPath) as? OverlayCell else {
            let cell = OverlayCell()
            return cell
        }
        cell.dataSource = self
        cell.delegate = self
        let data = self.filterData[indexPath.row]
        cell.configure(with: data, selectedOverlay: self.selectedOverlay)

        return cell
    }
}

extension OverlayView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? OverlayCell
        let data = self.filterData[indexPath.row]
        cell?.handleSelection(with: data)
    }
}

extension OverlayView: OverlayCellDataSource {
    func getImage() -> [String] {
        // Return the image for the cell at the specified index path
        return self.filterData
    }
}

extension OverlayView: OverlayCellDelegate {
    func didSelectCell(with data: String) {
        // Handle cell selection
        self.delegate?.setOverlay(nameString: data, sliderValue: 0.5)
        self.overlayCollectionView.isHidden = (data == "none") ? false : true
        self.opacityView.isHidden = (data == "none") ? true : false
        self.opacitySlider.value = 0.5
        self.selectedOverlay = data
        self.overlayCollectionView.reloadData()
    }
}
