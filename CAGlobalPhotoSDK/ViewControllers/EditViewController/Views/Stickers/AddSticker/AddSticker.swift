//
//  AddSticker.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/06/23.
//

import UIKit
typealias AlignCompletion = (CGFloat) -> Void?
protocol AddStickerViewDelegate: AnyObject {
    /*
     Add remove button on tap on Sticker
     */
    func addRemoveButtonFromSticker(sticker: AddSticker, tag: Int, stickerSelection: String)
    
    /*
     Add pan gesture sticker
     */
    func handleGestureSticker(_ gestureRecognizer: UIPanGestureRecognizer)
 
}

class AddSticker: UIImageView, UIGestureRecognizerDelegate {
    var flipAngleSticker = ""
    var isSelected = false
    var isBlank = false
    var isStickers = true
    var stickerSelection = String()
    var stickerApiSelection = Int()
    var isDepthImage = Bool()
    var straightenAngle: CGFloat = 0.0
    var rotationAngle: CGFloat = 0.0
    var flipAngle: CGFloat = 0.0
    var orignalImage: UIImage?
    var backgroundRemovedImage: UIImage?
    weak var delegate: AddStickerViewDelegate?
    var isBackgroundRemoved = Bool()
    override init(frame: CGRect) {
        super.init(frame: frame)
        initCommon()
    }

    func initCommon() {
        self.isUserInteractionEnabled = true
        self.contentMode = .scaleAspectFit
        self.tintColor = .white
        self.isSelected = false

        let tapGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)

        /**
         UIPanGestureRecognizer - Moving Objects
         Selecting transparent parts of the imageview won't move the object
         */

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        self.addGestureRecognizer(pan)


    }

    func bringSubviewToFront(view : AddSticker) {
        view.superview?.bringSubviewToFront(view)
    }

    func showCrossOnTap(gestureView: UIView) {
        if gestureView is UIImageView {
            if gestureView.tag == stickerTempTags {
                gestureView.tag = stickerMoveTempTags
            }
            if gestureView.tag == stickerSavedTags {
                gestureView.tag = stickerMoveSavedTags
            }
        }
        self.delegate?.addRemoveButtonFromSticker(sticker: self, tag: self.tag, stickerSelection: self.stickerSelection)
    }

    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.showCrossOnTap(gestureView: gestureRecognizer.view ?? self)
    }

    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        self.delegate?.handleGestureSticker(gestureRecognizer)
    }

    // MARK: - UIGestureRecognizerDelegate Methods
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }

    func addDeleteButtonWithFrame(frame : CGRect) -> UIButton {
        let button = UIButton.init(frame: frame)
        button.setImage( #imageLiteral(resourceName: "clear"), for: .normal)
        button.addTarget(self, action: #selector(self.deleteBtnClicked), for: .touchUpInside)
        return button
    }

    func hideDeleteButton() {
        let buttonView = self.viewWithTag(1)
        if ((buttonView?.isKind(of: UIButton.self)) != nil) {
            buttonView?.isHidden = true
        }
        self.isSelected = false
    }

    func rotateSticker(rotateAngle: CGFloat){
        var rotate = rotateAngle
        rotate += CGFloat.pi / 2.0
        rotate = self.standardizeAngleSticker(rotate)
        let total = autoHorizontalOrVerticalAngleSticker(self.straightenAngle + rotate + self.flipAngle)
        self.transform = CGAffineTransform(rotationAngle: total)
    }

    func standardizeAngleSticker(_ angle: CGFloat) -> CGFloat {
        var angle = angle
        if angle >= 0, angle <= 2 * CGFloat.pi {
            return angle
        } else if angle < 0 {
            angle += 2 * CGFloat.pi

            return standardizeAngleSticker(angle)
        } else {
            angle -= 2 * CGFloat.pi

            return standardizeAngleSticker(angle)
        }
    }

    func autoHorizontalOrVerticalAngleSticker(_ angle: CGFloat) -> CGFloat {
        var angle = angle
        angle = standardizeAngleSticker(angle)

        let deviation: CGFloat = 0.017444444 // 1 * 3.14 / 180, sync with AngleRuler
        if abs(angle - 0) < deviation {
            angle = 0
        } else if abs(angle - CGFloat.pi / 2.0) < deviation {
            angle = CGFloat.pi / 2.0
        } else if abs(angle - CGFloat.pi) < deviation {
            angle = CGFloat.pi - 0.001 // Handling a iOS bug that causes problems with rotation animations
        } else if abs(angle - CGFloat.pi / 2.0 * 3) < deviation {
            angle = CGFloat.pi / 2.0 * 3
        } else if abs(angle - CGFloat.pi * 2) < deviation {
            angle = CGFloat.pi * 2
        }

        return angle
    }

    func showDeleteButton() {
        let buttonView = self.viewWithTag(1)
        if ((buttonView?.isKind(of: UIButton.self)) != nil) {
            buttonView?.isHidden = false
        }
        self.isSelected = true
    }

    @objc func deleteBtnClicked() {
        if let parent = self.superview {
            let subViews = parent.subviews
            if subViews.count == 1 {
            }
        }
        self.removeFromSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCommon()
    }
}

public enum Direction: Int {
    case up
    case down
    case left
    case right

    public var isX: Bool { return self == .left || self == .right }
    public var isY: Bool { return !isX }
}

public extension UIPanGestureRecognizer {

    var direction: Direction? {
        let velocity = velocity(in: view)
        let vertical = abs(velocity.y) > abs(velocity.x)
        switch (vertical, velocity.x, velocity.y) {
        case (true, _, let ySide) where ySide < 0: return .up
        case (true, _, let ySide) where ySide > 0: return .down
        case (false, let xSide, _) where xSide > 0: return .right
        case (false, let xSide, _) where xSide < 0: return .left
        default: return nil
        }
    }
}
