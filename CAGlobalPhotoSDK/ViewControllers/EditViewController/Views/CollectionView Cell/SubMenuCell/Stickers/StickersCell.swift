//
//  StickersCell.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 29/05/23.
//

import UIKit
// Define a protocol for the cell's data source
protocol StickersCellDataSource: AnyObject {
    func getImage() -> [String]
}

// Define a protocol for the cell's delegate
protocol StickersCellDelegate: AnyObject {
    func didSelectCell(with data: UIImage, isEdit:Bool, isCustomSticker:Bool, urlString: String, isImageDepth: Bool?)
}

class StickersCell: UICollectionViewCell {
    // MARK: - Outlets
    
    /// The view representing the sticker image view.
    @IBOutlet weak var stickerImageView: UIImageView!
    
    /// The view representing the no sticker view.
    @IBOutlet weak var addPhoto: UIButton!
    
    /// The view representing the name label
    @IBOutlet weak var nameLabel: UILabel!
    
    /// The view representing the height of name label
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    // Declare data source and delegate properties
    weak var dataSource: StickersCellDataSource?
    weak var delegate: StickersCellDelegate?
    
    // Configure the cell with data from the data source
    func configure(with data: String, subImage: UIImage, isSubSelected: Bool) {
        if isSubSelected {
            stickerImageView.image = subImage
            addPhoto.isHidden = true
            nameLabel.text = ""
        } else {
            if data == "none" {
                stickerImageView.image = nil
                addPhoto.isHidden = false
                nameLabel.text = ""
            } else {
                stickerImageView.image = subImage
                addPhoto.isHidden = true
                var sentence = data
                let wordsToRemove = ["sticker", "1", "Shapes", "65", "_", "stickers", "Stickers"]
                for wordToRemove in wordsToRemove {
                    sentence = sentence.replacingOccurrences(of: wordToRemove, with: "")
                }
                nameLabel.text = sentence.capitalized
            }
        }
    }
    
    func configureCustomStickers(with subImage: UIImage, isSubSelected: Bool) {
        stickerImageView.image = subImage
        addPhoto.isHidden = true
        nameLabel.text = "Custom"
    }
    
    func configureApiData(with data: StickerModel, subImage: SubStickerModel, isSubSelected: Bool) {
        // Use the data source to retrieve the cell's data
        if isSubSelected {
            self.addPhoto.isHidden = true
        } else {
            if data.name == "none" {
                self.stickerImageView.image = nil
                self.addPhoto.isHidden = false
            } else {
                self.addPhoto.isHidden = true
                self.nameLabel.text = data.name
            }
        }
    }
    
    // Handle user interaction
    func handleSelection(with data: UIImage, isEdit:Bool, isCustomSticker:Bool, urlString: String, isImageDepth: Bool? = false) {
        delegate?.didSelectCell(with: data, isEdit: isEdit, isCustomSticker: isCustomSticker, urlString: urlString, isImageDepth: isImageDepth)
    }
    
    // ...rest of the cell implementation
}
