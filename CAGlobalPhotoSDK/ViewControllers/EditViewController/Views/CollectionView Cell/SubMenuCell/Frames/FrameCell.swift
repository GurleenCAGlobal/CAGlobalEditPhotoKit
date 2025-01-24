//
//  FrameCell.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 29/05/23.
//

import UIKit

// Define a protocol for the cell's data source
protocol FrameCellDataSource: AnyObject {
    func getImage() -> [String]
}

// Define a protocol for the cell's delegate
protocol FrameCellDelegate: AnyObject {
    func didSelectCell(with data: String, isEdit:Bool)
    func didSelectCellCategory(with data: String)
    func didSelectCellApi(with data: UIImage, isEdit:Bool)
}

class FrameCell: UICollectionViewCell {
    // MARK: - Outlets
    
    /// The view representing the frame image view.
    @IBOutlet weak var frameImageView: UIImageView!
    
    /// The view representing the no frame view.
    @IBOutlet weak var frameLabel: UILabel!
    
    /// The view representing the name
    @IBOutlet weak var nameLabel: UILabel!
    
    /// The view representing the height of name label
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    /// The image representing the selection of frame view.
    @IBOutlet weak var frameSelectedImageView: UIImageView!

    // Declare data source and delegate properties
    weak var dataSource: FrameCellDataSource?
    weak var delegate: FrameCellDelegate?
    var isSelectedFrame: Bool = false {
        didSet {
            updateSelectionState()
        }
    }
    var selectedCategory: String?


    override func prepareForReuse() {
        super.prepareForReuse()
        isSelectedFrame = false
        frameImageView.image = nil
    }


//    func configure(with data: String, subImage: String, isSubSelected: Bool, categoryName: String? = nil) {
//        self.removeGradientLayer()
//        if subImage == "none" {
//            self.frameLabel.addSlantLine(slantLineColor: UIColor.red,
//                                         slantLineWidth: 2,
//                                         startPoint: CGPoint(x: 0, y: 0),
//                                         endPoint: CGPoint(x: self.frameLabel.bounds.width, y: self.frameLabel.bounds.height))
//            self.frameImageView.image = nil
//            self.frameLabel.isHidden = false
//            self.nameLabel.isHidden = true
//            self.heightConstraint.constant = 0
//            self.configureGradientLayer()
//        } else {
//            let image = UIImage(named: subImage)
//            self.frameImageView.image = image?.resizeSticker(to: CGSize(width: (image?.size.width ?? 0) / 10, height: (image?.size.height ?? 0) / 10))
//            self.frameLabel.isHidden = true
//
//            if let category = categoryName {
//                self.nameLabel.isHidden = false
//                self.nameLabel.text = category
//                self.heightConstraint.constant = 12
//            } else {
//                self.nameLabel.isHidden = true
//                self.heightConstraint.constant = 0
//            }
//
//            // Show/hide the image based on the selected category
//            self.frameImageView.isHidden = (categoryName != selectedCategory)
//            self.removeGradientLayer()
//        }
//    }
    func configure(with data: String, subImage: String, isSubSelected: Bool, categoryName: String? = nil) {
        removeGradientLayer()

        if subImage == "none" {
            self.frameLabel.addSlantLine(slantLineColor: UIColor.red,
                                         slantLineWidth: 2,
                                         startPoint: CGPoint(x: 0, y: 0),
                                         endPoint: CGPoint(x: self.frameLabel.bounds.width, y: self.frameLabel.bounds.height))
            frameLabel.isHidden = false
            frameImageView.image = nil
            nameLabel.isHidden = true
            heightConstraint.constant = 0
        } else {
            let image = UIImage(named: subImage)
            self.frameImageView.image = image?.resizeSticker(to: CGSize(width: (image?.size.width ?? 0) / 10, height: (image?.size.height ?? 0) / 10))
            frameLabel.isHidden = true
            nameLabel.isHidden = (categoryName == nil)
            nameLabel.text = categoryName ?? ""
            heightConstraint.constant = categoryName != nil ? 12 : 0
        }

        // Update selection state
        frameSelectedImageView.isHidden = !isSelectedFrame
    }

    
    func configureApiData(with data: FramesModel, subImage: SubFramesModel, isSubSelected: Bool) {
        // Use the data source to retrieve the cell's data
        if isSubSelected {
            self.frameLabel.isHidden = true
        } else {
            if data.name == "none" {
                self.frameImageView.image = nil
                self.frameLabel.isHidden = false
            } else {
                self.frameLabel.isHidden = true
                self.nameLabel.text = data.name
            }
        }
    }
    
    func configureGradientLayer() {
        self.layer.borderColor = self.backgroundColor?.cgColor
        self.layer.borderWidth = 3
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [self.backgroundColor!, UIColor.black.cgColor]
        gradient.locations = [0.0 , 2.0]
        gradient.startPoint = CGPoint(x: 1, y: 1)
        gradient.endPoint = CGPoint(x: 0, y: 0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        self.layer.insertSublayer(gradient, at: 0)

    }
    
    func removeGradientLayer() {
        self.layer.sublayers = self.layer.sublayers?.filter { theLayer in
            !theLayer.isKind(of: CAGradientLayer.classForCoder())
        }
    }
    
    func removeSublayer(_ view: UIView, layerIndex index: Int) {
        guard let sublayers = view.layer.sublayers else {
            print("The view does not have any sublayers.")
            return
        }
        if sublayers.count > index {
            view.layer.sublayers!.remove(at: index)
        } else {
            print("There are not enough sublayers to remove that index.")
        }
    }

    func handleSelection(with data: String, isEdit: Bool) {
        // Toggle selection state
        isSelectedFrame = isEdit
        self.frameImageView.image = UIImage(named: data)

        // Notify the delegate
        delegate?.didSelectCell(with: data, isEdit: isEdit)
    }

    private func updateSelectionState() {
        UIView.animate(withDuration: 0.3) {
            self.frameSelectedImageView.alpha = self.isSelectedFrame ? 1.0 : 0.0
        }
        self.frameSelectedImageView.isHidden = !isSelectedFrame
    }

    // Handle user interaction
    func handleSelectionForCategory(with data: String){
        delegate?.didSelectCellCategory(with: data)
    }
    
    // Handle user interaction with api
    func handleSelectionApi(with data: UIImage, isEdit:Bool) {
        delegate?.didSelectCellApi(with: data, isEdit: isEdit)
    }
    
    // ...rest of the cell implementation
}
