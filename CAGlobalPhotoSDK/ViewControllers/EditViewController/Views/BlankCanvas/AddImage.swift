//
//  AddImage.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 07/09/23.
//

import UIKit
protocol AddImageViewDelegate: AnyObject {
    /*
     Add remove button on tap on Sticker
     */
    func addRemoveButtonFromImage(_ addTextView: AddImage, tag: Int)
}

class AddImage: UIImageView, UIGestureRecognizerDelegate {
    var isSelected = false
    weak var delegate: AddImageViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initCommon()
    }
    
    func initCommon() {
        self.isUserInteractionEnabled = true
        self.contentMode = .scaleAspectFit
        self.isSelected = false

        let button = self.addDeleteButtonWithFrame(frame: CGRect(x: frame.size.width - 40, y: 0, width: 36, height: 36))
        button.tag = 1
        //self.addSubview(button)
        
        /**
         UIRotationGestureRecognizer - Rotating Objects
         */
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(recognizer:)))
        rotate.delegate = self
        self.addGestureRecognizer(rotate)
        
        /**
         UIPanGestureRecognizer - Moving Objects
         Selecting transparent parts of the imageview won't move the object
         */
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        self.addGestureRecognizer(pan)
        
        /**
         UIPinchGestureRecognizer - Pinching Objects
         If it's a UITextView will make the font bigger so it doen't look pixlated
         */
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(pinchRecognized(pinch:)))
        pinchGesture.delegate = self
        self.addGestureRecognizer(pinchGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        //self.addGestureRecognizer(tapGesture)

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
        self.delegate?.addRemoveButtonFromImage(self, tag: self.tag)
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.showCrossOnTap(gestureView: gestureRecognizer.view ?? self)
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        self.showCrossOnTap(gestureView: gestureRecognizer.view ?? self)
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let point = gestureRecognizer.location(in: self.superview)
            if let superview = self.superview {
                let restrictByPoint: CGFloat = 30.0
                let superViewX = superview.bounds.origin.x + restrictByPoint
                let superViewY = superview.bounds.origin.y + restrictByPoint
                let width = superview.bounds.size.width - 2*restrictByPoint
                let height = superview.bounds.size.height - 2*restrictByPoint
                let superBounds = CGRect(x: superViewX, y: superViewY, width: width, height: height)
                if superBounds.contains(point) {
                    let translation = gestureRecognizer.translation(in: self.superview)
                    gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
                    gestureRecognizer.setTranslation(CGPoint.zero, in: self.superview)
                }
            }
        }
    }
    
    @objc func pinchRecognized(pinch: UIPinchGestureRecognizer) {
        if let view = pinch.view {
            view.transform = view.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            pinch.scale = 1
        }
    }
    
    @objc func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate Methods
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        self.superview?.bringSubviewToFront(self)
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

