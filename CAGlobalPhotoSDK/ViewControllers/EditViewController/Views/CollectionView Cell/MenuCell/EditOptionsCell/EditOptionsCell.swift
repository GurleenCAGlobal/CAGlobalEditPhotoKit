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
        self.editImageView.image = UIImage.init(named:(options.image.lowercased().trimmingCharacters(in: .whitespaces)))
        
        if options.name == "Paper Length" {
            self.editImageView.image = UIImage.init(named:"set length".lowercased())
        }
        if options.name == "Add Photo" {
            self.editImageView.image = UIImage.init(named:"addphoto".lowercased())
        }
                
        if isAutoSelect {
            self.dotLabel.isHidden = false
            self.editImageView.tintColor = (UIColor(named: .selectionColor)!)
            self.nameLabel.textColor = (UIColor(named: .selectionColor)!)
            self.editImageView.image = UIImage.init(named: "autoFill")
        } else if isRedEyeSelect {
            self.dotLabel.isHidden = true
            self.editImageView.tintColor = (UIColor(named: .selectionColor)!)
            self.nameLabel.textColor = (UIColor(named: .selectionColor)!)
        } else {
            if options.name == "Auto" {
                self.editImageView.image = UIImage.init(named: "auto")
            }
            self.dotLabel.isHidden = true
            self.editImageView.tintColor = .white
            self.nameLabel.textColor = .white
        }
    }
    
    // Configure the cell with data from the data source
    func configureAdjust(with data: FilterModel, isSelect: Bool) {
        // Use the data source to retrieve the cell's data
        let options = data
        self.nameLabel.text = options.name
        self.editImageView.image = UIImage.init(named:(options.image.lowercased().trimmingCharacters(in: .whitespaces)))
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
