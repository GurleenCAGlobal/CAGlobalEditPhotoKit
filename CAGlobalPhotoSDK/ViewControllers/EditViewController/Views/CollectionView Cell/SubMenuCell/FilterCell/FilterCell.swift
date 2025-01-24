//
//  FilterCell.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 21/06/23.
//

import UIKit

// Define a protocol for the cell's data source
protocol FilterCellDataSource: AnyObject {
    func getImage() -> [String]
}

// Define a protocol for the cell's delegate
protocol FilterCellDelegate: AnyObject {
    func didSelectCell(with data: String, isEmpty:Bool)
}

class FilterCell: UICollectionViewCell {
    // MARK: - Outlets
    
    // The view representing the filter image view.
    @IBOutlet weak var filterImageView: UIImageView!
    
    // The view representing the no filter view.
    @IBOutlet weak var filterLabel: UILabel!
    
    // Declare data source and delegate properties
    weak var dataSource: FilterCellDataSource?
    weak var delegate: FilterCellDelegate?
    
    // Configure the cell with data from the data source
    func configure(with data: String, selectedOverlay: String, image: UIImage) {
        // Use the data source to retrieve the cell's data
        if data == selectedOverlay {
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.white.cgColor
        } else {
            self.layer.borderWidth = 0
            self.layer.borderColor = UIColor.clear.cgColor
        }
        
        if data == "" {
            self.filterImageView.image = nil
            self.filterLabel.isHidden = false
        } else {
            self.filterImageView.image = image
            self.filterLabel.isHidden = true
        }
    }
    
    // Handle user interaction
    func handleSelection(with data: String, isEmpty:Bool) {
        delegate?.didSelectCell(with: data, isEmpty: isEmpty)
    }
    
    // ...rest of the cell implementation
}
