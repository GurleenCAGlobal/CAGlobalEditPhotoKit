//
//  FilterView.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 21/06/23.
//

import UIKit


struct FilterState: Equatable {
    var filterName: String
    var opacity: CGFloat

    func copyState() -> FilterState {
        return FilterState(filterName: self.filterName, opacity: self.opacity)
    }
}
// Define a protocol for the cell's data source
protocol FilterViewDelegate: AnyObject {
    /*
     Called when the user select any filter
     */
    func selectedFilterImage(nameString: String, isEmpty:Bool, sliderValue: CGFloat)
    
    /*
     Called when the user starts changing the opacity of the filter
     */
    func filterOpacity(sliderValue: CGFloat)
    
}

class FilterView: UIView {
    // MARK: - Outlets
    
    // Outlet for the base view of the filter view
    @IBOutlet weak var baseView: UIView!
    
    // Outlets for the Collection View
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
    // Outlet for the opacity view of the filter view
    @IBOutlet weak var filterView: UIView!
    
    // Outlet for the opacity slider of the filter view
    @IBOutlet weak var filterSlider: UISlider!
    
    private var filterManager = FiltersManager()
    private(set) var filterData = [String]()
    var selectedFilter = String()
    var imageOrignal = UIImage()
    var filterImages = [UIImage]()

    weak var delegate: FilterViewDelegate?


   // var filterOpacity: CGFloat = 1.0  // Keep track of the current opacity

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    deinit {
        print("FilterView deallocated")
    }
    private func nibSetup() {
        backgroundColor = .clear
        baseView = loadViewFromNib()
        baseView.frame = bounds
        baseView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        baseView.translatesAutoresizingMaskIntoConstraints = true
        addSubview(baseView)
        self.filterData = self.filterManager.getFilterData()
        self.initCollectionView()
        filterSlider.addTarget(self, action: #selector(angleRulerTouchEnded(_:)), for: [.editingDidEnd])

    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: FilterView.self)
        let nib = UINib(nibName: FilterView.className, bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return nibView ?? UIView()
    }
    
    private func initCollectionView() {
        let nib = UINib(nibName: FilterCell.className, bundle: nil)
        filterCollectionView.register(nib, forCellWithReuseIdentifier: FilterCell.className)
        filterCollectionView.dataSource = self
        filterCollectionView.delegate = self
        // Initialize current filter state if no filters are applied yet
        currentFilterState = FilterState(filterName: "", opacity: 1.0)
    }
    
    func updateSliderValue(value : CGFloat) {
        if selectedFilter == "" {
            self.filterSlider.isHidden = true
        }
        self.filterSlider.value = Float(value)
    }
    
    @IBAction func actionSliderValue(_ sender: UISlider) {
        delegate?.filterOpacity(sliderValue: CGFloat(sender.value))

        // Update the current filter state with new opacity
        currentFilterState.opacity = CGFloat(sender.value)

        // You might need to reapply the filter with the new opacity
        //  applyFilterState(currentFilterState)
    }
    
    @objc
    func angleRulerTouchEnded(_: AnyObject) {
        
    }
    
    @IBAction func actionChange(_ sender: UISlider) {
        self.filterCollectionView.isHidden = false
        self.filterView.isHidden = true
    }

    // Function to apply a new filter
    func applyFilter(filterName: String, opacity: CGFloat) {
        selectedFilter = filterName
        filterOpacityValue = opacity
        applyCIFilter(filterName: filterName, opacity: opacity)
    }

    // Apply the filter using CoreImage
    func applyCIFilter(filterName: String, opacity: CGFloat) {
        guard let _ = CIFilter.filter(withLUT: filterName, dimension: 64) else { return }
        print("Applying filter: \(filterName) with opacity: \(opacity)")
    }

}

extension FilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of cells in the table view
        return self.filterData.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterCell.className, for: indexPath) as? FilterCell else {
            let cell = FilterCell()
            return cell
        }
        // Set the cell's data source and delegate
        cell.dataSource = self
        cell.delegate = self
        if indexPath.row == 0 {
            cell.configure(with: "", selectedOverlay: self.selectedFilter, image: UIImage.init(named: "filters")!)
        } else  {
            let data = self.filterData[indexPath.row - 1]
            let image = self.filterImages[indexPath.row - 1]
            cell.configure(with: data, selectedOverlay: selectedFilter, image: image)
        }

        return cell
    }
}

extension FilterView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? FilterCell
        if indexPath.row == 0 {
            cell?.handleSelection(with: "", isEmpty:true)
            self.filterSlider.isHidden = true
        } else {
            let data = self.filterData[indexPath.row - 1]
            cell?.handleSelection(with: data, isEmpty:false)
            self.filterSlider.isHidden = false
        }
    }
}

extension FilterView: FilterCellDataSource {
    func getImage() -> [String] {
        // Return the image for the cell at the specified index path
        return self.filterData
    }
}

extension FilterView: FilterCellDelegate {
    func didSelectCell(with data: String, isEmpty:Bool) {
        // Handle cell selection
        self.filterSlider.value = 1
        self.delegate?.selectedFilterImage(nameString: data, isEmpty:isEmpty, sliderValue: 1)
        selectedFilter = data
        // Call the applyFilter method whenever a filter is selected
        applyFilter(filterName: data, opacity: 1.0)  // Assuming opacity starts at 1.0
       // undoStack.append(<#T##newElement: FilterState##FilterState#>)

        
        self.filterCollectionView.reloadData()
    }
}

