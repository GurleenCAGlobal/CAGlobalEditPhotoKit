//
//  AspectRatioPicker.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//

import UIKit

enum Boxs {
    case none
    case vertical
    case horizontal
}

protocol AspectRatioPickerDelegate: AnyObject {
    func aspectRatioPickerDidSelectedAspectRatio(_ aspectRatio: AspectRatio)
}

let boxButtonShortSide: CGFloat = 21
let boxButtonLongSide: CGFloat = 31
let boxSelectedColor = UIColor(white: 0.56, alpha: 1)
let boxNormalColorImage = UIColor(white: 0.14, alpha: 1)
let boxButtonGap = 15
let boxButtonCenter = 16
let boxPadding = 9
let margin = 2
let buttonHeight = 20
let initialColor = UIColor(white: 0.6, alpha: 1)
let backgroundImageSize = 3
let backgroundImageHeighWidth = 10

public class AspectRatioPicker: UIView {

    weak var delegate: AspectRatioPickerDelegate?

    var selectedAspectRatio: AspectRatio = .freeForm {
        didSet {
            let buttonIndex = aspectRatios.firstIndex(of: selectedAspectRatio) ?? 0
            scrollView.subviews.forEach { view in
                if let button = view as? UIButton, button.tag == buttonIndex {
                    button.isSelected = true
                    scrollView.scrollRectToVisible(button.frame.insetBy(dx: -30, dy: 0), animated: true)
                }
            }
        }
    }

    var selectedBox: Boxs = .none {
        didSet {
            switch selectedBox {
            case .none:
                horizontalButton.isSelected = false
                verticalButton.isSelected = false
            case .vertical:
                horizontalButton.isSelected = false
                verticalButton.isSelected = true
            case .horizontal:
                horizontalButton.isSelected = true
                verticalButton.isSelected = false
            }
        }
    }

    var rotated: Bool = false

    var aspectRatios: [AspectRatio] = [
        .original,
        .square,
        .ratio(width: 9, height: 16),
        .ratio(width: 8, height: 10),
        .ratio(width: 5, height: 7),
        .ratio(width: 3, height: 4),
        .ratio(width: 3, height: 5),
        .ratio(width: 2, height: 3)
        ] {
        didSet {
            reloadScrollView()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(scrollView)
        addSubview(horizontalButton)
        addSubview(verticalButton)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    lazy var horizontalButton: UIButton = {
        let button = boxButton(size: CGSize(width: boxButtonLongSide, height: boxButtonShortSide))
        button.left = verticalButton.right + CGFloat(boxButtonGap)
        button.centerY = verticalButton.centerY
        button.addTarget(self, action: #selector(horizontalButtonPressed(_:)), for: .touchUpInside)
        return button
    }()

    lazy var verticalButton: UIButton = {
        let button = boxButton(size: CGSize(width: boxButtonShortSide, height: boxButtonLongSide))
        button.left = (width - boxButtonShortSide - boxButtonLongSide - CGFloat(boxButtonGap)) / 2
        button.centerY = CGFloat(boxButtonCenter)
        button.addTarget(self, action: #selector(verticalButtonPressed(_:)), for: .touchUpInside)
        return button
    }()

    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: self.bounds)
        sv.backgroundColor = .clear
        sv.decelerationRate = .fast
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    func reloadScrollView() {

        scrollView.subviews.forEach { button in
            if button is UIButton {
                button.removeFromSuperview()
            }
        }

        let buttonCount = aspectRatios.count
        let font = UIFont.systemFont(ofSize: 14)
        let margin = margin * boxPadding
        let colorImage = UIImage(color: UIColor(white: 0.5, alpha: 0.4),
                                 size: CGSize(width: backgroundImageHeighWidth, height: backgroundImageHeighWidth))
        let edgeInsets = UIEdgeInsets(top: CGFloat(backgroundImageSize), left: CGFloat(backgroundImageSize), bottom: CGFloat(backgroundImageSize), right: CGFloat(backgroundImageSize))
        let backgroundImage = colorImage.resizableImage(withCapInsets: edgeInsets)

        var xPoint: CGFloat = CGFloat(margin)
        for index in 0 ..< buttonCount {
            let button = UIButton(frame: CGRect.zero)
            button.tag = index
            button.backgroundColor = UIColor.clear
            button.setTitleColor(initialColor, for: .normal)
            button.setTitleColor(.white, for: .selected)
            button.setBackgroundImage(backgroundImage, for: .selected)
            button.layer.cornerRadius = CGFloat(buttonHeight / 2)
            button.layer.masksToBounds = true
            button.titleLabel?.font = font
            button.addTarget(self, action: #selector(aspectRatioButtonPressed(_:)), for: .touchUpInside)

            let ar = aspectRatios[index]
            let title = ar.description
            let width = title.width(withFont: font) + CGFloat(boxPadding) * 2
            button.setTitle(title, for: .normal)
            button.frame = CGRect(x: xPoint, y: 0, width: width, height: CGFloat(buttonHeight))
            xPoint += width + CGFloat(boxPadding)

            scrollView.addSubview(button)
        }

        scrollView.height = CGFloat(buttonHeight)
        scrollView.bottom = height - 8
        scrollView.contentSize = CGSize(width: Int(xPoint) + Int(CGFloat(boxPadding)), height: buttonHeight)
    }

    @objc
    func horizontalButtonPressed(_: UIButton) {
        if verticalButton.isSelected {
            horizontalButton.isSelected = true
            verticalButton.isSelected = false
            rotated = !rotated
            rotateAspectRatios()
        }
    }

    @objc
    func verticalButtonPressed(_: UIButton) {
        if horizontalButton.isSelected {
            horizontalButton.isSelected = false
            verticalButton.isSelected = true
            rotated = !rotated
            rotateAspectRatios()
        }
    }

    @objc
    func aspectRatioButtonPressed(_ sender: UIButton) {
        if !sender.isSelected {
            scrollView.subviews.forEach { view in
                if let button = view as? UIButton {
                    button.isSelected = false
                }
            }

            if sender.tag < aspectRatios.count {
                selectedAspectRatio = aspectRatios[sender.tag]
            } 

            delegate?.aspectRatioPickerDidSelectedAspectRatio(selectedAspectRatio)
        }
    }

    func rotateAspectRatios() {
        let selected = selectedAspectRatio
        aspectRatios = aspectRatios.map { $0.rotated }
        selectedAspectRatio = selected.rotated
        delegate?.aspectRatioPickerDidSelectedAspectRatio(selectedAspectRatio)
    }

    func boxButton(size: CGSize) -> UIButton {
        let button = UIButton(frame: CGRect(origin: .zero, size: size))

        let normalColorImage = UIImage(color: boxNormalColorImage,
                                       size: CGSize(width: backgroundImageHeighWidth, height: backgroundImageHeighWidth))
        let edgeInsets = UIEdgeInsets(top: CGFloat(backgroundImageSize), left: CGFloat(backgroundImageSize), bottom: CGFloat(backgroundImageSize), right: CGFloat(backgroundImageSize))
        let normalBackgroundImage = normalColorImage.resizableImage(withCapInsets: edgeInsets)

        let selectedColorImage = UIImage(color: boxSelectedColor,
                                         size: CGSize(width: backgroundImageHeighWidth, height: backgroundImageHeighWidth))
        let backgroundInsets = UIEdgeInsets(top: CGFloat(backgroundImageSize), left: CGFloat(backgroundImageSize), bottom: CGFloat(backgroundImageSize), right: CGFloat(backgroundImageSize))
        let selectedBackgroundImage = selectedColorImage.resizableImage(withCapInsets: backgroundInsets)
        let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)!

        let checkmark = UIImage(named: "QCropper.check.mark", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

        button.tintColor = .black
        button.layer.borderColor = boxSelectedColor.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = CGFloat(backgroundImageSize)
        button.layer.masksToBounds = true
        button.setBackgroundImage(normalBackgroundImage, for: .normal)
        button.setBackgroundImage(selectedBackgroundImage, for: .selected)
        button.setImage(checkmark, for: .selected)
        return button
    }
}
