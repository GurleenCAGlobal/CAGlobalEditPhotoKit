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

class AddTextView: UILabel, UIGestureRecognizerDelegate {

    var isSelected = false
    var selectedColorIndex = 0
    var selectedColor = UIColor()
    var previousColor = UIColor()
    var previousSelectedColorIndex = 0

    var selectedFont = ""
    var selectedPreviousFont = ""
    var selectedFontIndex = 0
    var selectedPreviousFontIndex = 0
    var selectedText = ""
    var previousText = ""

    var button = UIButton()
    let gutterSize : CGFloat = 30.0 // This will increase label width to avoid clipping.
    weak var delegate: AddTextViewDelegate?




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
        // Set initial values
        self.isSelected = false
        // Add gestures
        self.addGesture() 
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
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubletapRecognised(tap:)))
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
    
    func showCrossOnTap(gestureView: UIView) {
        if gestureView is UILabel {
            if gestureView.tag == textTempTags {
                gestureView.tag = textMoveTempTags
            }
            if gestureView.tag == textSavedTags {
                gestureView.tag = textMoveSavedTags
            }
        }
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
    
    @objc func doubletapRecognised(tap: UITapGestureRecognizer) {
        self.editOnTap(gestureView: tap.view ?? self)
        self.delegate?.editTextLabel(self)
    }
    @objc func tapRecognised(tap: UITapGestureRecognizer) {
        self.showCrossOnTap(gestureView: tap.view ?? self)
    }



    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        self.delegate?.handleGestureText(gestureRecognizer)
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
}
