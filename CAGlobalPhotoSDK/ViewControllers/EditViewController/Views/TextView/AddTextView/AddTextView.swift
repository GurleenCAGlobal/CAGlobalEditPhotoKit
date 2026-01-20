//
//  AddTextView.swift
//  CAPhotoEditor
//
//  Created by Gurleen Singh on 19/03/23.
//


import UIKit

protocol AddTextViewDelegate: AnyObject {
    /*
     Add remove button on tap on text label
     */
    func addRemoveButtonFromText(_: AddTextView, tag: Int)
    
    /*
     Called when the user starts editing existing text
     */
    
    func editTextLabel(_: AddTextView)
    
    /*
     To check alignemnt on text
     */
    func alignmentText()
    
    /*
     Add pan gesture sticker
     */
    func handleGestureText(_ gestureRecognizer: UIPanGestureRecognizer)
}
var doubleTapRecognizedRecently = false

class AddTextView: UILabel, UIGestureRecognizerDelegate {
    var textPadding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 40)
    var outlineLayer: CAShapeLayer?
    
    let cornerHandleSize: CGFloat = 16
    let sideHandleWidth: CGFloat = 6
    let sideHandleHeight: CGFloat = 20
    
    let wideSideHandleWidth: CGFloat = 20
    let wideSideHandleHeight: CGFloat = 40
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textPadding)
        super.drawText(in: insetRect)
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textPadding.left + textPadding.right,
            height: size.height + textPadding.top + textPadding.bottom
        )
    }
    
    override var text: String? {
        didSet {
            resizeToFitText()
        }
    }
    
    var isSelected = false
    var selectedColorIndex = 0
    var selectedBackGrounfColorIndex = 0
    var selectedColor = UIColor()
    var previousColor = UIColor()
    var previousSelectedColorIndex = 0
    
    var selectedBackgroundColor = UIColor()
    var previousBackgroundColor = UIColor()
    var previousSelectedBackgroundColorIndex = 0
    
    var selectedFont = ""
    var selectedPreviousFont = ""
    var selectedFontIndex = 0
    var selectedPreviousFontIndex = 0
    var selectedText = ""
    var previousText = ""
    var selectedOpacity = 1.0
    var button = UIButton()
    let gutterSize : CGFloat = 30.0 // This will increase label width to avoid clipping.
    weak var delegate: AddTextViewDelegate?
    var doubleTap = UITapGestureRecognizer()
    var handles: [LShapeHandle] = []
    // Set limits for the text box size
    let minWidth: CGFloat = 50
    let minHeight: CGFloat = 55
    let maxWidth: CGFloat = UIScreen.main.bounds.width - 40
    let maxHeight: CGFloat = UIScreen.main.bounds.height - 45
    var isResizing = false // Track whether the user is resizing the text box
    var transformText = CGAffineTransform ()
    let borderView = UIView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initCommon()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCommon()
    }
    
    func initCommon() {
        // Enable user interaction
        self.isUserInteractionEnabled = true
        // Set content mode to scale aspect fit
        self.contentMode = .scaleAspectFit
        // Set text alignment to center
        self.textAlignment = .center
        // Enable word wrapping
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        
        borderView.isUserInteractionEnabled = false
        borderView.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 0.6).cgColor
        borderView.layer.borderWidth = 2.0
        borderView.frame = CGRect(x: self.bounds.origin.x + 0, y: self.bounds.origin.y + 0, width: self.bounds.size.width - 0, height: self.bounds.size.height - 0)
        borderView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(borderView)
        borderView.isHidden = true
        // Set initial values
        self.isSelected = false
        // Add gestures
        self.addGesture()
        // Add handlers
        //self.addResizeHandles()
       // toggleOutline(show: false)
        self.addDottedOutline()
    }


    func addCrossButton() {
        button = self.addDeleteButtonWithFrame(frame: CGRect(x: (frame.size.width - 36), y: 0, width: 36, height: 36))
        button.tag = 1
        self.addSubview(button)
    }
    
    func addGesture() {
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        self.addGestureRecognizer(pan)
        
        // UITapGestureRecognizer - Double Tap
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubletapRecognised(tap:)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        
        // UITapGestureRecognizer - Single Tap
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(tapRecognised(tap:)))
        //        tap.numberOfTapsRequired = 1
        //        self.addGestureRecognizer(tap)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapRecognised(tap:)))
        tap.numberOfTapsRequired = 1
        tap.require(toFail: doubleTap) // Ensure single tap waits for double tap recognition
        self.addGestureRecognizer(tap)
        
        
        
        /**
         UIPanGestureRecognizer - Moving Objects
         Selecting transparent parts of the imageview won't move the object
         */
        
        
    }
    
    private func addResizeHandles() {

        // Remove existing handles if any
        handles.forEach { $0.removeFromSuperview() }
        handles.removeAll()
        
        // Define positions for the handles at the corners and middle sides of the text box
        let positions: [CGPoint] = [
            CGPoint(x: -cornerHandleSize / 2, y: -cornerHandleSize / 2), // Top Left
            CGPoint(x: bounds.width - cornerHandleSize / 2, y: -cornerHandleSize / 2), // Top Right
            CGPoint(x: bounds.width - cornerHandleSize / 2, y: bounds.height - cornerHandleSize / 2), // Bottom Right
            CGPoint(x: -cornerHandleSize / 2, y: bounds.height - cornerHandleSize / 2), // Bottom Left
            
            CGPoint(x: 0, y: bounds.height / 2 - sideHandleHeight / 2), // Left Middle
            CGPoint(x: bounds.width - sideHandleWidth, y: bounds.height / 2 - sideHandleHeight / 2), // Right Middle
            
            CGPoint(x: 0, y: bounds.height / 2 - wideSideHandleHeight / 2), // Left Wide Middle
            CGPoint(x: bounds.width - wideSideHandleWidth, y: bounds.height / 2 - wideSideHandleHeight / 2) // Right wide Middle

        ]
        
        // Handle class assignments
        let handleClasses: [LShapeHandle.Type] = [
            BottomRightLShapeHandle.self,  // Top Left becomes Bottom Right
            BottomLeftLShapeHandle.self,   // Top Right becomes Bottom Left
            TopLeftLShapeHandle.self,      // Bottom Right becomes Top Left
            TopRightLShapeHandle.self,     // Bottom Left becomes Top Right
            LeftMiddleResizeHandle.self,   // Left Middle
            RightMiddleResizeHandle.self,   // Right Middl
            WideLeftMiddleResizeHandle.self,   // Left Wide Middle
            WideRightMiddleResizeHandle.self   // Right Wide Middle
        ]
        
        // Loop through the positions and create the handles
        for (index, pos) in positions.enumerated() {
            let handle: LShapeHandle

            if index == 4 || index == 5 { // Left and Right Middle handles (side handles)
                handle = handleClasses[index].init(frame: CGRect(x: pos.x, y: pos.y, width: sideHandleWidth, height: sideHandleHeight))
            } else if index == 6 || index == 7 { // Left and Right Middle handles (side handles)
                handle = handleClasses[index].init(frame: CGRect(x: pos.x, y: pos.y, width: wideSideHandleWidth, height: wideSideHandleHeight))
            } else { // Corner handles
                handle = handleClasses[index].init(frame: CGRect(x: pos.x, y: pos.y, width: cornerHandleSize, height: cornerHandleSize))
            }
            
            handle.isUserInteractionEnabled = true
            
            addSubview(handle)
            self.bringSubviewToFront(handle)
            // Add pan gesture recognizer for each handle
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDragged(_:)))
            handle.addGestureRecognizer(panGesture)
            
            handles.append(handle)
            
        }
    }
    
    func updatingTransformOfTextView(transform: CGAffineTransform) {
        transformText = transform
    }
    
    func resizeToFitText() {
        guard let text = self.text, let font = self.font else { return }
        
        let maxSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let textSize = text.boundingRect(
            with: maxSize,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        ).size
        
        // Add text padding to both width and height
        let totalWidth = textSize.width + textPadding.left + textPadding.right
        let totalHeight = textSize.height + textPadding.top + textPadding.bottom
        
        // Constrain within min/max sizes
        let finalWidth = max(minWidth, totalWidth)
        let finalHeight = max(minHeight, totalHeight)
        
        self.frame.size = CGSize(width: finalWidth, height: finalHeight)
        
        // Update handles and outline after resizing
        layoutSubviews()
    }
    
    @objc func doubletapRecognised(tap: UITapGestureRecognizer) {
        doubleTapRecognizedRecently = true

        self.editOnTap(gestureView: tap.view ?? self)
        self.delegate?.editTextLabel(self)
        // Reset the flag after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                doubleTapRecognizedRecently = false
            }
//        // Resize after editing
//        resizeToFitText()
    }
    
    private func updateResizeHandles() {
        

        // Define positions for the handles at the corners and middle sides of the text box
        let positions: [CGPoint] = [
            CGPoint(x: 0, y: 0), // Top Left
            CGPoint(x: bounds.width - cornerHandleSize, y: 0), // Top Right
            CGPoint(x: bounds.width - cornerHandleSize, y: bounds.height - cornerHandleSize), // Bottom Right
            CGPoint(x: 0, y: bounds.height - cornerHandleSize), // Bottom Left
            
            
            CGPoint(x: 0, y: bounds.height / 2 - sideHandleHeight / 2), // Left Middle
            CGPoint(x: bounds.width - sideHandleWidth, y: bounds.height / 2 - sideHandleHeight / 2), // Right Middle
            
            CGPoint(x: 0, y: bounds.height / 2 - wideSideHandleHeight / 2), // Left Wide Middle
            CGPoint(x: bounds.width - wideSideHandleWidth, y: bounds.height / 2 - wideSideHandleHeight / 2) // Right wide Middle

        ]
        
        for (index, handle) in handles.enumerated() {
            if index < positions.count {
                // Correctly position each handle at the corner or side of the text box
                if index == 4 || index == 5 { // Left/Right middle handles
                    handle.frame = CGRect(x: positions[index].x, y: positions[index].y, width: sideHandleWidth, height: sideHandleHeight)
                } else if index == 6 || index == 7 { // Left and Right Middle handles (side handles)
                    handle.frame = CGRect(x: positions[index].x, y: positions[index].y, width: wideSideHandleWidth, height: wideSideHandleHeight)
                } else { // Corner handles
                    handle.frame = CGRect(x: positions[index].x, y: positions[index].y, width: cornerHandleSize, height: cornerHandleSize)
                }
            }
        }
    }
    
//    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
//            guard let handle = gesture.view else { return }
//            let translation = gesture.translation(in: self)
//
//            if gesture.state == .began {
//                // Determine which handle is being dragged
//                isResizingLeft = (handle == leftHandle)
//                isResizingRight = (handle == rightHandle)
//            } else if gesture.state == .changed {
//                var newFrame = textView.frame
//                
//                if isResizingLeft {
//                    newFrame.origin.x += translation.x
//                    newFrame.size.width -= translation.x
//                } else if isResizingRight {
//                    newFrame.size.width += translation.x
//                }
//
//                // Constrain minimum size
//                newFrame.size.width = max(50, newFrame.size.width)
//
//                // Apply changes
//                textView.frame = newFrame
//                
//                // Update handles
//                leftHandle.center = CGPoint(x: textView.frame.minX, y: textView.center.y)
//                rightHandle.center = CGPoint(x: textView.frame.maxX, y: textView.center.y)
//                
//                // Reset translation
//                gesture.setTranslation(.zero, in: self)
//            }
//        }
    
    @objc func handleDragged(_ gesture: UIPanGestureRecognizer) {
        
        
        guard let handle = gesture.view as? LShapeHandle else { return }
        
        let translation = gesture.translation(in: self)
        var newFrame = self.frame
        
        switch gesture.state {
        case .began:
            isResizing = true
            NotificationCenter.default.post(name: NSNotification.Name("disabelPanGesture"), object: nil, userInfo: ["isEnable": false])
        case .changed:
            let rotation = atan2(transform.b, transform.a) // Get current rotation angle
            let rotatedTranslation = rotateTranslation(translation, by: -rotation)
            
            if handle is WideLeftMiddleResizeHandle {
                
                newFrame.origin.x += translation.x
                newFrame.size.width = max(minWidth, newFrame.width - translation.x)
                newFrame.size.height = max(minHeight, newFrame.height + translation.y)
            } else if handle is WideRightMiddleResizeHandle {
                newFrame.size.width = max(minWidth, newFrame.width + translation.x)
                newFrame.size.height = max(minHeight, newFrame.height + translation.y)
            }
            adjustTextViewHeightToFit(newFrame: &newFrame)
            self.frame = newFrame
            layoutSubviews()
            gesture.setTranslation(.zero, in: superview)
        case .ended, .cancelled:
            isResizing = false
            NotificationCenter.default.post(name: NSNotification.Name("disabelPanGesture"), object: nil, userInfo: ["isEnable": true])
            NotificationCenter.default.post(name: NSNotification.Name("updatedFrames"), object: nil, userInfo: ["frames": self.frame,"fontSize": self.font?.pointSize ?? 0,"fontName": self.font.fontName])
        default:
            break
        }
    }
    
    // MARK: - Adjust Height Dynamically
    func adjustTextViewHeightToFit(newFrame: inout CGRect) {
        guard let text = self.text else { return }
        self.numberOfLines = 0 // Allow multiline text

        let maxWidth: CGFloat = UIScreen.main.bounds.width - 16
        let padding: CGFloat = 16

        // Calculate the bounding size with the new width
        let boundingSize = CGSize(width: newFrame.width - 2 * padding, height: CGFloat.greatestFiniteMagnitude)
        let textSize = text.boundingRect(
            with: boundingSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [NSAttributedString.Key.font: self.font!],
            context: nil
        ).size

        // Set the height based on calculated text size and padding
        newFrame.size.height = max(textSize.height + 2 * padding, 55)

        // Adjust center position to maintain consistency
        let originalCenter = self.center
        self.bounds.size = CGSize(width: newFrame.width, height: newFrame.size.height)
        self.center = originalCenter
    }
    
    
    private func adjustFontSizeToFitText(in frame: CGRect) {
        guard let label = self as? UILabel else { return }
        
        let maxFontSize: CGFloat = 100 // Set a maximum font size
        let minFontSize: CGFloat = 10   // Set a minimum font size
        
        // Calculate the new font size based on the frame size
        let widthRatio = frame.width / label.intrinsicContentSize.width
        let heightRatio = frame.height / label.intrinsicContentSize.height
        let newFontSize = min(maxFontSize, max(minFontSize, min(widthRatio, heightRatio) * label.font.pointSize))
        
        label.font = label.font.withSize(newFontSize)
    }
    
    func rotateTranslation(_ translation: CGPoint, by angle: CGFloat) -> CGPoint {
        let rotatedX = translation.x * cos(angle) - translation.y * sin(angle)
        let rotatedY = translation.x * sin(angle) + translation.y * cos(angle)
        return CGPoint(x: rotatedX, y: rotatedY)
    }
    
    
    
    func adjustHeightToFitText(_ frame: inout CGRect) {
        guard let text = self.text, let font = self.font else { return }

        // Calculate the number of lines based on the text and current width
        let maxSize = CGSize(width: frame.width, height: .greatestFiniteMagnitude)
        
        let textSize = text.boundingRect(
            with: maxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        ).size
        
        // Calculate the number of lines based on the text height and font line height
        let numberOfLines = max(1, Int(ceil(textSize.height / font.lineHeight)))

        // Calculate the final height
        let calculatedHeight = CGFloat(numberOfLines) * font.lineHeight + textPadding.top + textPadding.bottom + 50
        frame.size.height = calculatedHeight
    }
    func showCrossOnTap(gestureView: UIView) {
        if gestureView is UILabel {
            if gestureView.tag == textTempTags {
                gestureView.tag = textMoveTempTags
            }
            if gestureView.tag == textSavedTags {
                gestureView.tag = textMoveSavedTags
            }
        }
        handles.forEach { $0.isHidden = false }
        self.delegate?.addRemoveButtonFromText(self, tag: self.tag)
    }
    
    func editOnTap(gestureView: UIView) {
        if gestureView is UILabel {
            if gestureView.tag == textTempTags {
                gestureView.tag = textTempEditTags
            }
            if gestureView.tag == textSavedTags {
                gestureView.tag = textEditTags
            }
        }
    }

    @objc func tapRecognised(tap: UITapGestureRecognizer) {
        guard let gestureView = tap.view else { return }
        
        if gestureView is UILabel || gestureView == self {
            // Tapped on the text → Show delete button & handlers
            showDeleteButton()
            handles.forEach { $0.isHidden = false } // Show handles
        } else {
            // Tapped outside → Hide everything
            hideDeleteButton()
            handles.forEach { $0.isHidden = true } // Hide handles
        }
        self.showCrossOnTap(gestureView: tap.view ?? self)
    }
    
    
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        //self.delegate?.handleGestureText(gestureRecognizer)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        self.superview?.bringSubviewToFront(self)
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    func shouldRespondToGesture(_ gesture: UIGestureRecognizer, in frame: CGRect) -> Bool {
        return gesture.state == .began && frame.contains(gesture.location(in: self.superview))
    }
    func addDeleteButtonWithFrame(frame : CGRect) -> UIButton {
        let button = UIButton.init(frame: frame)
        button.setImage( #imageLiteral(resourceName: "clear"), for: .normal)
        button.addTarget(self, action: #selector(self.deleteBtnClicked), for: .touchUpInside)
        return button
    }
    func hideDeleteButton() {
        let buttonView = self.viewWithTag(1)
        if (buttonView?.isKind(of: UIButton.self)) != nil {
            buttonView?.isHidden = true
        }
        self.isSelected = false
    }
    func showDeleteButton() {
        let buttonView = self.viewWithTag(1)
        if (buttonView?.isKind(of: UIButton.self)) != nil {
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
    
    /// Toggle Outline Visibility
    func toggleOutline(show: Bool) {
        if show {
            removeOutline()
        } else {
            removeOutline()
        }
    }
    /// Add Pink Dotted Outline Around Text
    private func updateDottedOutline() {
        outlineLayer?.isHidden = false // Show the outline layer
        let padding: CGFloat = 12 // Adjust to match text padding
        let insetBounds = bounds.insetBy(dx: padding, dy: padding) // Shrink by padding
        
        let path = UIBezierPath(rect: insetBounds)
        
        
        outlineLayer?.path = path.cgPath
        outlineLayer?.strokeColor = UIColor(hex: "#FF22E9").cgColor
        outlineLayer?.fillColor = UIColor.clear.cgColor
        outlineLayer?.lineWidth = 2.0
        outlineLayer?.lineDashPattern = [4, 4] // Dotted effect

    }
    
    
    private func addDottedOutline() {
        removeOutlineDottedOutline() // Remove existing outline if any
        
        let padding: CGFloat = 12 // Adjust to match text padding
        let insetBounds = bounds.insetBy(dx: padding, dy: padding) // Shrink by padding
        
        let path = UIBezierPath(rect: insetBounds)
        
        outlineLayer = CAShapeLayer()
        outlineLayer?.path = path.cgPath
        outlineLayer?.strokeColor = UIColor(hex: "#FF22E9").cgColor
        outlineLayer?.fillColor = UIColor.clear.cgColor
        outlineLayer?.lineWidth = 2.0
        outlineLayer?.lineDashPattern = [4, 4] // Dotted effect
        
        outlineLayer?.name = "dottedOutline" // Assign a name to identify the layer

        layer.addSublayer(outlineLayer!)
    }
    
    /// Remove the existing outline from the layer
    private func removeOutlineDottedOutline() {
        layer.sublayers?.removeAll(where: { $0.name == "dottedOutline" })
    }
    
    /// Remove Outline
    func removeOutline() {
        outlineLayer?.isHidden = true
    }
    
//    /// Update Outline Position on Resizing
//    private func updateOutline() {
//        if outlineLayer != nil {
//            addDottedOutline()
//        }
//    }
}

// Extension to Invert UIEdgeInsets
extension UIEdgeInsets {
    func inverted() -> UIEdgeInsets {
        return UIEdgeInsets(top: -self.top, left: -self.left, bottom: -self.bottom, right: -self.right)
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
