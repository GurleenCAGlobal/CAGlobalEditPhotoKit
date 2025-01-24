//
//  TextFontCell.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 22/03/23.
//

import UIKit

// Define a protocol for the cell's data source
protocol TextFontCellDataSource: AnyObject {
    func getFont() -> [String]
}

// Define a protocol for the cell's delegate
protocol TextFontCellDelegate: AnyObject {
    func didSelectFontCell(with data: String, textModel: TextModel)
}

class TextFontCell: UICollectionViewCell {
    
    // MARK: - Outlets
    
    /// The label displaying the font preview.
    @IBOutlet weak var fontPreviewLabel: UILabel!
    
    /// The button used to select the font.
    @IBOutlet weak var selectedButton: UIButton!
    
    // Declare data source and delegate properties
    weak var dataSource: TextFontCellDataSource?
    weak var delegate: TextFontCellDelegate?
    
    

    // Configure the cell with data from the data source
    func configure(with data: String, textModel: TextModel, isSelect: Bool) {
        // Use the data source to retrieve the cell's data
        self.fontPreviewLabel.font = UIFont(name: data, size: 16)
        if isSelect {
            self.selectedButton.isHidden = false
            self.selectedButton.backgroundColor = #colorLiteral(red: 0.465190351, green: 0.9172363877, blue: 0.9757485986, alpha: 1)
            self.fontPreviewLabel.textColor = .black
            self.selectedButton.layer.cornerRadius = 25

        } else {
            self.selectedButton.isHidden = true
            self.fontPreviewLabel.textColor = .white
            self.selectedButton.backgroundColor = .clear
            self.selectedButton.layer.cornerRadius = 0
        }
    }
    
    // Handle user interaction
    func handleSelection(with data: String, textModel: TextModel) {
        delegate?.didSelectFontCell(with: data, textModel: textModel)
    }
}
