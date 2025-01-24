//
//  Toolbar.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//

import UIKit

let kCancel = "Cancel"
let kReset = "RESET"
let kDone = "Done"
let doneColor = UIColor(white: 0.4, alpha: 1)
let kFontSize = 17
let buttonNormalColor = UIColor(white: 1, alpha: 1.0)
let buttonHighlightColor = UIColor(white: 1, alpha: 1.0)
let width = 20
let height = 44
class Toolbar: UIView {
    lazy var cancelButton: UIButton = {
        let button = self.titleButton(kCancel)
        button.left = 0
        button.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
        return button
    }()

    lazy var resetButton: UIButton = {
        let button = self.titleButton(kReset, highlight: true)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.isHidden = true
        button.centerX = self.width / 2
        button.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
        return button
    }()

    lazy var doneButton: UIButton = {
        let button = self.titleButton(kDone, highlight: true)
        button.right = self.width
        button.setTitleColor(doneColor, for: .disabled)
        button.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
        return button
    }()

    lazy var blurBackgroundView: UIVisualEffectView = {
        let vev = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        vev.alpha = 0.3
        vev.backgroundColor = .clear
        vev.frame = self.bounds
        vev.isUserInteractionEnabled = false
        vev.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleHeight, .flexibleWidth]
        return vev
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(blurBackgroundView)
        addSubview(cancelButton)
        addSubview(resetButton)
        addSubview(doneButton)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func titleButton(_ title: String, highlight: Bool = false) -> UIButton {
        let font = UIFont.systemFont(ofSize: CGFloat(kFontSize))
        let button = UIButton(frame: CGRect(center: .zero,
                                            size: CGSize(width: title.width(withFont: font) + width, height: height)))
        if highlight {
            button.setTitleColor(QCropper.Config.highlightColor, for: .normal)
            button.setTitleColor(QCropper.Config.highlightColor.withAlphaComponent(0.7), for: .highlighted)
        } else {
            button.setTitleColor(buttonNormalColor, for: .normal)
            button.setTitleColor(buttonHighlightColor, for: .highlighted)
        }
        button.titleLabel?.font = font
        button.setTitle(title, for: .normal)
        button.top = 0

        button.autoresizingMask = [.flexibleRightMargin, .flexibleWidth]
        return button
    }
}
