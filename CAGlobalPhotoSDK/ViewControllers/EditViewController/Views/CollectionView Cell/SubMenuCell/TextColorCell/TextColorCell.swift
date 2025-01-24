//
//  TextColorCell.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 22/03/23.
//

import UIKit

// Define a protocol for the cell's data source
protocol TextColorCellDataSource: AnyObject {
    func getColor() -> [UIColor]
}

// Define a protocol for the cell's delegate
protocol TextColorCellDelegate: AnyObject {
    func didSelectCell(with data: UIColor, textModel: TextModel)
    func didSelectCellBrush(with data: UIColor, colorModel: ColorModel)
    func didSelectCellSticker(with data: UIColor, colorModel: ColorModel)
}

extension TextColorCellDelegate {
    func didSelectCell(with data: UIColor, textModel: TextModel) {
        
    }
    
    func didSelectCellBrush(with data: UIColor, colorModel: ColorModel) {
        
    }
    
    func didSelectCellSticker(with data: UIColor, colorModel: ColorModel) {
        
    }

}

class TextColorCell: UICollectionViewCell {
    
    // MARK: - Outlets
    
    /// The view representing the color.
    @IBOutlet weak var colorView: UIView!
    
    /// The button used to select the color.
    @IBOutlet weak var selectedButton: UIButton!
    
    // Declare data source and delegate properties
    weak var dataSource: TextColorCellDataSource?
    weak var delegate: TextColorCellDelegate?
      
    func configure(with data: UIColor, textModel: TextModel, isSelect: Bool, isPrevious: Bool) {
        // Set the background color of the colorView
        self.colorView.backgroundColor = data
        self.selectedButton.isHidden = true
        if isSelect {
            // Set the border color and width for the selected cell
            self.colorView.layer.borderWidth = 3
            self.selectedButton.isHidden = false
        } else {
            // Set default border color and width for unselected cells
            self.colorView.layer.borderWidth = 0.5
            self.selectedButton.isHidden = true
        }
    }

    // Handle user interaction
    func handleSelection(with data: UIColor, textModel: TextModel) {
        delegate?.didSelectCell(with: data, textModel: textModel)
    }
    
    func handleSelectionBrush(with data: UIColor, colorModel: ColorModel) {
        // Notify the delegate about the color selection
        delegate?.didSelectCellBrush(with: data, colorModel: colorModel)

        // Update the appearance of the selected cell
        self.colorView.layer.borderWidth = 3
        self.selectedButton.isHidden = false
    }

    
    // Handle user interaction
    func handleSelectionSticker(with data: UIColor, colorModel: ColorModel) {
        delegate?.didSelectCellSticker(with: data, colorModel: colorModel)
    }
}
