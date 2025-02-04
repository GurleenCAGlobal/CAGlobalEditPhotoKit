//
//  OverlayCell.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 19/05/23.
//

import UIKit

// Define a protocol for the cell's data source
protocol OverlayCellDataSource: AnyObject {
    func getImage() -> [String]
}

// Define a protocol for the cell's delegate
protocol OverlayCellDelegate: AnyObject {
    func didSelectCell(with data: String)
}

class OverlayCell: UICollectionViewCell {
    // MARK: - Outlets
    
    /// The view representing the overlay image view.
    @IBOutlet weak var overlayImageView: UIImageView!
    
    /// The view representing the no overlay view.
    @IBOutlet weak var overlayLabel: UILabel!
    
    // Declare data source and delegate properties
    weak var dataSource: OverlayCellDataSource?
    weak var delegate: OverlayCellDelegate?
    
    // Configure the cell with data from the data source
    func configure(with data: String, selectedOverlay: String) {
        // Use the data source to retrieve the cell's data
        if data == selectedOverlay {
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.white.cgColor
        } else {
            self.layer.borderWidth = 0
        }
        
        if data == "none" {
            self.overlayImageView.image = nil
            self.overlayLabel.isHidden = false
        } else {
            let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
            let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)!

            self.overlayImageView.image = UIImage.init(named: data, in: bundle, compatibleWith: nil)!
            self.overlayLabel.isHidden = true
        }
    }
    
    // Handle user interaction
    func handleSelection(with data: String) {
        delegate?.didSelectCell(with: data)
    }
    
    // ...rest of the cell implementation
}
