//
//  FrameView.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 19/05/23.
//

import UIKit

// Define a protocol for the cell's data source
protocol FrameViewDelegate: AnyObject {
    func selectedFramesImage(image: String, isEdit:Bool)
    func selectedFramesImageApi(image: UIImage)
    func selectedFramesCategory(with data: String)
    func backButtonSubCategory()
}

var selectedCategoryDetail:FrameCategoryModel?

class FrameView: UIView {
        
    // MARK: - Outlets
    
    // Outlet for the base view of the frames view
    @IBOutlet weak var baseView: UIView!
    
    // Outlets for the collection View
    @IBOutlet weak var frameCollectionView: UICollectionView!
    
    // Outlet for the opacity view of the frames view
    @IBOutlet weak var opacityView: UIView!
    
    // Outlet for the opacity slider of the frames view
    @IBOutlet weak var opacitySlider: UISlider!

    @IBOutlet weak var backButton: UIButton!
    
    // This outlet represents the bottom of main view
    @IBOutlet weak var constraintsColorWidthBack: NSLayoutConstraint!
    
    private var framesManager = FramesManager()
    private(set) var framesData = [String]()

    var categoryList:[FrameCategoryModel]?

    var selectedFrame = String()
    var selectedFrameOpacity = CGFloat()
    weak var delegate: FrameViewDelegate?
    var isEdit: Bool?
    var imagePicker = UIImagePickerController()
    var framesSelection = Int()
    var selectedRatioWith: CGFloat?
    var isLandscape: Bool?

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
        self.initCollectionView()
    }

    func createFramesArray(isLandscape: Bool, selectedRatio: CGFloat, isEdit : Bool = false) {
        if isEdit == false {
            selectedCategoryDetail = nil
        }
        self.categoryList = self.framesManager.getEmoticonDataNew(isLandscape: isLandscape, selectedRatio: selectedRatio)
    }

    private func loadViewFromNib() -> UIView {
        let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = bundlePath != nil ? Bundle(path: bundlePath!) : nil

        let nib = UINib(nibName: FrameView.className, bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return nibView ?? UIView()
    }
    
    private func initCollectionView() {
        let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = bundlePath != nil ? Bundle(path: bundlePath!) : nil

        let nib = UINib(nibName: FrameCell.className, bundle: bundle)
        frameCollectionView.register(nib, forCellWithReuseIdentifier: FrameCell.className)
        frameCollectionView.dataSource = self
        frameCollectionView.delegate = self
    }
    
    @IBAction func actionSliderValue(_ sender: UISlider) {

    }
    
    @IBAction func actionChange(_ sender: UISlider) {
        self.frameCollectionView.isHidden = false
        self.opacityView.isHidden = true
        self.backButton.isHidden = true
    }

    @IBAction func actionBackButton(_ sender: UIButton) {
        // Reset to category selection
        self.backButton.isHidden = true
        self.constraintsColorWidthBack.constant = 0
        selectedCategoryDetail = nil
        frameCollectionView.reloadData()
        self.delegate?.backButtonSubCategory()
    }

}

extension FrameView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of cells in the table view
        if selectedCategoryDetail == nil {
            return self.categoryList?.count ?? 0
        } else {
            return selectedCategoryDetail?.frameList?.count ?? 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FrameCell.className, for: indexPath) as? FrameCell else {
            return FrameCell()
        }

        cell.dataSource = self
        cell.delegate = self

        if selectedCategoryDetail == nil {
            self.backButton.isHidden = true
            self.constraintsColorWidthBack.constant = 0

            // Configure category cells
            let data = self.categoryList?[indexPath.row]
            cell.configure(with: "",
                           subImage: data?.categoryIcon ?? "",
                           isSubSelected: false,
                           categoryName: data?.categoryName ?? "")
        } else {
            // Configure frame cells within a category
            let data = selectedCategoryDetail?.frameList?[indexPath.row]
            let frameImage = data?.frame as? String ?? ""
            if frameImage == selectedFrame {
                cell.isSelectedFrame = true//(selectedFrame == frameImage) // Maintain selection state
            } else {
                cell.isSelectedFrame = false
            }
            
            cell.configure(with: frameImage,
                           subImage: frameImage,
                           isSubSelected: false)
        }

        return cell
    }

}

extension FrameView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedCategoryDetail == nil {
            // Category selected
            self.backButton.isHidden = false
            self.constraintsColorWidthBack.constant = 30

            // Set selected category
            selectedCategoryDetail = categoryList?[indexPath.row]
            collectionView.reloadData()

            // Notify delegate
            let categoryName = selectedCategoryDetail?.categoryName ?? ""
            self.delegate?.selectedFramesCategory(with: categoryName)
        } else {
//            // Frame selected within the category
//            for index in 0..<collectionView.numberOfItems(inSection: indexPath.section) {
//                if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: indexPath.section)) as? FrameCell {
//                    // Update selection state
//                    cell.isSelectedFrame = index == indexPath.item
//                }
//            }

            // Notify delegate
            if let data = selectedCategoryDetail?.frameList?[indexPath.row] {
                let frameImage = data.frame as? String ?? ""
                selectedFrame = frameImage

                self.delegate?.selectedFramesImage(image: frameImage, isEdit: self.isEdit ?? false)
            }
            collectionView.reloadData()

            // Scroll to center
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }


}


extension FrameView: FrameCellDataSource, FrameCellDelegate {
    
    func getImage() -> [String] {
        // Return the image for the cell at the specified index path
        return self.framesData
    }
    
    func didSelectCellCategory(with data: String) {
        self.delegate?.selectedFramesCategory(with: data)
        frameCollectionView.reloadData()
    }

    func didSelectCellApi(with data: UIImage, isEdit: Bool) {
        self.delegate?.selectedFramesImageApi(image: data)
    }
    
    func didSelectCell(with data: String, isEdit:Bool) {
        // Handle cell selection
        self.delegate?.selectedFramesImage(image: data, isEdit: isEdit)
    }
}
