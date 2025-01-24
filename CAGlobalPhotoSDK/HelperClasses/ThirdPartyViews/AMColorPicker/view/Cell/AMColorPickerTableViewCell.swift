//
//  AMColorPickerTableViewCell.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//

import UIKit

public struct AMCPCellInfo {
    var title: String
    var color: UIColor

    public init(title: String, color: UIColor) {
        self.title = title
        self.color = color
    }

}

class AMColorPickerTableViewCell: UITableViewCell {

    @IBOutlet weak private var blackView: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var colorView: UIView!
    var info: AMCPCellInfo! {
        didSet {
            titleLabel.text = info.title
            if #available(iOS 11.0, *) {
                titleLabel.textColor = UIColor(named: "textColor")
            }
            colorView.backgroundColor = info.color
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            blackView.backgroundColor = .black
            colorView.backgroundColor = info.color
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            blackView.backgroundColor = .black
            colorView.backgroundColor = info.color
        }
    }
}
