//
//  PaperLengthCell.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/05/23.
//


protocol PaperLengthDelegate {
    func selectedSizeOfPaperlength(_ tag: Int)
}

import UIKit

class PaperLengthCell: UITableViewCell {
    
    @IBOutlet weak var buttonPaperLengthSize: UIButton!
    @IBOutlet weak var buttonPaperLength: UIButton!
    var delegate: PaperLengthDelegate?
    
    func initButtonWithText(text: String, size: String, tag: Int) {
        buttonPaperLength.setTitle(text, for: .normal)
        buttonPaperLengthSize.setTitle(size, for: .normal)
        buttonPaperLength.titleLabel?.font = FontManager.normalRegular
        buttonPaperLengthSize.titleLabel?.font = FontManager.normalLight
        buttonPaperLength.setImage(UIImage(named: "paper_length_size_notselected_radio"), for: .normal)
        buttonPaperLength.tag = tag
    }
  
    func actionChangeCanvasSize() {
        buttonPaperLength.titleLabel?.font = FontManager.normalBold
        buttonPaperLength.setImage(UIImage(named: "paper_length_size_selected_radio"), for: .normal)
        buttonPaperLengthSize.titleLabel?.font = FontManager.normalBold
    }
    
    @IBAction func actionChangeCanvasSize(_ sender: Any) {
        delegate?.selectedSizeOfPaperlength((sender as AnyObject).tag)
    }
}
