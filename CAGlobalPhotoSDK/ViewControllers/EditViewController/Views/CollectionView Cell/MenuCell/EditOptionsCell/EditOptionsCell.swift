//
//  EditOptionsCell.swift
//  CAPhotoEditor
//
//  Created by Gurleen Singh on 22/03/23.
//

import UIKit

// Define a protocol for the cell's data source
protocol EditOptionsCellDataSource: AnyObject {
    func getFilterData() -> [FilterModel]
}

// Define a protocol for the cell's delegate
protocol EditOptionsCellDelegate: AnyObject {
    func didSelectCell(filterSelection: FilterSelection, currentFilterSelection: FilterSelection, editOptions: EditOptions)
    func didSelectCellAdjust(adjustSelection: AdjustSelection, currentAdjustSelection: AdjustSelection)
}

extension EditOptionsCellDelegate {
    func didSelectCell(filterSelection: FilterSelection, currentFilterSelection: FilterSelection, editOptions: EditOptions) {
        
    }
    
    func didSelectCellAdjust(adjustSelection: AdjustSelection, currentAdjustSelection: AdjustSelection) {
        
    }
}

class EditOptionsCell: UICollectionViewCell {
    // MARK: - Outlets
    // The image view displaying the edit option icon.
    @IBOutlet weak var editImageView: UIImageView!
    // The label displaying the name of the edit option.
    @IBOutlet weak var nameLabel: UILabel!
    // The label displaying the dot of the edit option.
    @IBOutlet weak var dotLabel: UILabel!
    // Declare data source and delegate properties
    weak var dataSource: EditOptionsCellDataSource?
    weak var delegate: EditOptionsCellDelegate?
    // Configure the cell with data from the data source
    func configure(with data: FilterModel, filterSelection: FilterSelection, editOptions: EditOptions, isSelect: Bool, isAutoSelect: Bool, isRedEyeSelect: Bool) {
        // Use the data source to retrieve the cell's data
        let options = data

        self.nameLabel.text = options.name
        if let bundlePath = Bundle(for: EditOptionsCell.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle"), let bundle = Bundle(path: bundlePath) {
            let imageName = options.image.lowercased().trimmingCharacters(in: .whitespaces)
            let image = UIImage(named: imageName, in: bundle, compatibleWith: nil)
            self.editImageView.image = image
        }
        
        
        if options.name == "Paper Length" {
            if let bundlePath = Bundle(for: EditOptionsCell.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle"), let bundle = Bundle(path: bundlePath) {
                let image = UIImage(named: "set length", in: bundle, compatibleWith: nil)
                self.editImageView.image = image
            }
        }
        if options.name == "Add Photo" {
            if let bundlePath = Bundle(for: EditOptionsCell.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle"), let bundle = Bundle(path: bundlePath) {
                let image = UIImage(named: "addphoto", in: bundle, compatibleWith: nil)
                self.editImageView.image = image
            }
        }
                
        if isAutoSelect {
            //self.dotLabel.isHidden = false
            self.editImageView.tintColor = (UIColor(named: .selectionColor, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!)
            self.nameLabel.textColor = (UIColor(named: .selectionColor, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!)
            let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
            let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)!

            self.editImageView.image = UIImage.init(named: "autoFill", in: bundle, compatibleWith: nil)!
        } else if isRedEyeSelect {
            //self.dotLabel.isHidden = true
            self.editImageView.tintColor = (UIColor(named: .selectionColor, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!)
            self.nameLabel.textColor = (UIColor(named: .selectionColor, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!)
        } else {
            if options.name == "Auto" {
                if let bundlePath = Bundle(for: EditOptionsCell.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle"), let bundle = Bundle(path: bundlePath) {
                    let image = UIImage(named: "auto", in: bundle, compatibleWith: nil)
                    self.editImageView.image = image
                }
            }
            //self.dotLabel.isHidden = true
            self.editImageView.tintColor = .white
            self.nameLabel.textColor = .white
        }
    }
    
    // Configure the cell with data from the data source
    func configureAdjust(with data: FilterModel, isSelect: Bool) {
        // Use the data source to retrieve the cell's data
        let options = data
        self.nameLabel.text = options.name
        let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)!

        let imageName = options.image.lowercased().trimmingCharacters(in: .whitespaces)
        let image = UIImage(named: imageName, in: bundle, compatibleWith: nil)
        self.editImageView.image = image

        self.editImageView.tintColor = (isSelect) ? .white : .lightGray
        self.nameLabel.textColor = (isSelect) ? .white : .lightGray
    }
    
    // Handle user interaction
    func handleSelection(filterSelection: FilterSelection, currentFilterSelection: FilterSelection, editOptions: EditOptions) {
        delegate?.didSelectCell(filterSelection: filterSelection,currentFilterSelection: currentFilterSelection, editOptions: editOptions)
    }
    
    func handleSelectionAdjust(adjustSelection: AdjustSelection, currentAdjustSelection: AdjustSelection) {
        delegate?.didSelectCellAdjust(adjustSelection: adjustSelection, currentAdjustSelection: currentAdjustSelection)
    }
}
