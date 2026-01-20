//
//  AddSticker.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/06/23.
//

import UIKit

// Typealias for alignment completion handler
typealias AlignCompletion = (CGFloat) -> Void?

// Protocol for sticker view delegate
protocol AddStickerViewDelegate: AnyObject {
    
    // Adds a remove button on tap on a sticker
    func addRemoveButtonFromSticker(sticker: AddSticker, tag: Int, stickerSelection: String)
    
    // Uncomment if needed
    func handleGestureSticker(_ gestureRecognizer: UIPanGestureRecognizer)
}

// Class representing a sticker with gesture handling and resizing
class AddSticker: UIImageView, UIGestureRecognizerDelegate {
    // MARK: - Properties
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
    var handles: [LShapeHandle] = [] // Resize handles

    var selectedColorIndex = 0
    var selectedColor = UIColor()
    var previousColor = UIColor()
    var previousSelectedColorIndex = 0

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        initCommon()
        addResizeHandles()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCommon()
        addResizeHandles()
    }

    // MARK: - Initialization
    /// Common initialization for the sticker
    func initCommon() {
        self.isUserInteractionEnabled = true
        self.contentMode = .scaleAspectFit
        self.tintColor = .white
        self.isSelected = false

        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)

        // Uncomment if pan gesture is needed
         let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
         pan.delegate = self
         self.addGestureRecognizer(pan)
    }

    // MARK: - Resize Handles
    /// Adds resize handles to the sticker
    private func addResizeHandles() {
        let cornerHandleSize: CGFloat = 16

        // Remove existing handles
        handles.forEach { $0.removeFromSuperview() }
        handles.removeAll()

        // Define positions for the handles
        let positions: [CGPoint] = [
            CGPoint(x: -cornerHandleSize / 2, y: -cornerHandleSize / 2), // Top Left
            CGPoint(x: bounds.width - cornerHandleSize / 2, y: -cornerHandleSize / 2), // Top Right
            CGPoint(x: bounds.width - cornerHandleSize / 2, y: bounds.height - cornerHandleSize / 2), // Bottom Right
            CGPoint(x: -cornerHandleSize / 2, y: bounds.height - cornerHandleSize / 2) // Bottom Left
        ]

        // Assign handle classes
        let handleClasses: [LShapeHandle.Type] = [
            BottomRightLShapeHandle.self,
            BottomLeftLShapeHandle.self,
            TopLeftLShapeHandle.self,
            TopRightLShapeHandle.self
        ]

        // Create and add handles
        for (index, pos) in positions.enumerated() {
            let handle = handleClasses[index].init(frame: CGRect(x: pos.x, y: pos.y, width: cornerHandleSize, height: cornerHandleSize))
            handle.isUserInteractionEnabled = true
            addSubview(handle)
            handles.append(handle)
        }
    }

    /// Updates the positions of resize handles
    private func updateResizeHandles() {
        let cornerHandleSize: CGFloat = 16
        let positions: [CGPoint] = [
            CGPoint(x: 0, y: 0), // Top Left
            CGPoint(x: bounds.width - cornerHandleSize, y: 0), // Top Right
            CGPoint(x: bounds.width - cornerHandleSize, y: bounds.height - cornerHandleSize), // Bottom Right
            CGPoint(x: 0, y: bounds.height - cornerHandleSize) // Bottom Left
        ]

        for (index, handle) in handles.enumerated() {
            handle.frame = CGRect(x: positions[index].x, y: positions[index].y, width: cornerHandleSize, height: cornerHandleSize)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateResizeHandles()
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if isSelected == true{
            self.delegate?.handleGestureSticker(gestureRecognizer)
        }
    }

    // MARK: - Gesture Handling
    /// Handles tap gesture on the sticker
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let gestureView = gestureRecognizer.view else { return }

        if gestureView is UILabel || gestureView == self {
            // Show delete button and handles
            showDeleteButton()
            //handles.forEach { $0.isHidden = false }
        } else {
            // Hide delete button and handles
            hideDeleteButton()
            //handles.forEach { $0.isHidden = true }
        }
        self.showCrossOnTap(gestureView: gestureRecognizer.view ?? self)
    }

    /// Brings the sticker to the front
    func bringSubviewToFront(view: AddSticker) {
        view.superview?.bringSubviewToFront(view)
    }

    /// Shows the cross button on tap
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

    // MARK: - Delete Button
    /// Adds a delete button to the sticker
    func addDeleteButtonWithFrame(frame: CGRect) -> UIButton {
        let button = UIButton(frame: frame)
        button.setImage(#imageLiteral(resourceName: "clear"), for: .normal)
        button.addTarget(self, action: #selector(self.deleteBtnClicked), for: .touchUpInside)
        return button
    }

    /// Hides the delete button
    func hideDeleteButton() {
        let buttonView = self.viewWithTag(1)
        if ((buttonView?.isKind(of: UIButton.self)) != nil) {
            buttonView?.isHidden = true
        }
        self.isSelected = false
    }

    /// Shows the delete button
    func showDeleteButton() {
        let buttonView = self.viewWithTag(1)
        if ((buttonView?.isKind(of: UIButton.self)) != nil) {
            buttonView?.isHidden = false
        }
        self.isSelected = true
    }

    /// Deletes the sticker
    @objc func deleteBtnClicked() {
        self.removeFromSuperview()
    }

    // MARK: - Rotation
    /// Rotates the sticker by a given angle
    func rotateSticker(rotateAngle: CGFloat) {
        var rotate = rotateAngle
        rotate += CGFloat.pi / 2.0
        rotate = self.standardizeAngleSticker(rotate)
        let total = autoHorizontalOrVerticalAngleSticker(self.straightenAngle + rotate + self.flipAngle)
        self.transform = CGAffineTransform(rotationAngle: total)
    }

    /// Standardizes the angle to a range of 0 to 2π
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

    /// Adjusts the angle to snap to horizontal or vertical
    func autoHorizontalOrVerticalAngleSticker(_ angle: CGFloat) -> CGFloat {
        var angle = angle
        angle = standardizeAngleSticker(angle)
        let deviation: CGFloat = 0.017444444 // 1 degree in radians
        if abs(angle - 0) < deviation {
            angle = 0
        } else if abs(angle - CGFloat.pi / 2.0) < deviation {
            angle = CGFloat.pi / 2.0
        } else if abs(angle - CGFloat.pi) < deviation {
            angle = CGFloat.pi - 0.001 // Fix for iOS rotation bug
        } else if abs(angle - CGFloat.pi / 2.0 * 3) < deviation {
            angle = CGFloat.pi / 2.0 * 3
        } else if abs(angle - CGFloat.pi * 2) < deviation {
            angle = CGFloat.pi * 2
        }
        return angle
    }

    // MARK: - Gesture Recognizer Delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}

// MARK: - Direction Enum
public enum Direction: Int {
    case up, down, left, right

    public var isX: Bool { return self == .left || self == .right }
    public var isY: Bool { return !isX }
}

// MARK: - UIPanGestureRecognizer Extension
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
