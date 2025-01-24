//
//  TopBar.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//

import UIKit

let kMirror = "mirror"
let kFlip = "flip"
let kRotate = "rotate"
let kAspectRatio = "QCropper.aspectratio.fill"
let kRatio = "ratio"
let iconColor = UIColor(white: 0.725, alpha: 1)
let iconSelectedColor = UIColor(white: 0.725, alpha: 1)
let topBarWidth = 44
let topBarHeight = 44

class TopBar: UIView {
    lazy var mirrorButton: UIButton = {
        let button = self.iconButton(iconName: kMirror)
        button.left = 0
        button.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        return button
    }()
    
    lazy var flipButton: UIButton = {
        let button = self.iconButton(iconName: kFlip)
        button.left = self.mirrorButton.right
        button.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        return button
    }()

    lazy var rotateButton: UIButton = {
        let button = self.iconButton(iconName: kRotate)
        button.left = self.flipButton.right
        button.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
        return button
    }()

    lazy var aspectRationButton: UIButton = {
        let button = self.iconButton(iconName: kAspectRatio)
        button.right = self.width
        button.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
        return button
    }()
    
    lazy var rationButton: UIButton = {
        let button = self.iconButton(iconName: kRatio)
        button.right = self.aspectRationButton.left
        button.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
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
        addSubview(flipButton)
        addSubview(rotateButton)
        addSubview(aspectRationButton)
        addSubview(rationButton)
        addSubview(mirrorButton)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func iconButton(iconName: String) -> UIButton {
        let button = IconButton(iconName)
        button.bottom = height
        return button
    }
}

class IconButton: UIButton {
    init(_ iconName: String) {
        super.init(frame: CGRect(center: .zero, size: CGSize(width: topBarWidth, height: topBarHeight)))
        let image = UIImage(named: iconName, in: QCropper.Config.resourceBundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        setImage(image, for: .normal)
        tintColor = iconColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                tintColor = QCropper.Config.highlightColor
            } else {
                tintColor = iconSelectedColor
            }
        }
    }
}
