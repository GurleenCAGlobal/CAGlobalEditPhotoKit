//
//  CAEditBlackCanvasViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 08/04/24.
//

import UIKit



// MARK: - Blank Canvas option -

extension CAEditViewController {
    
    func selectedImage(image: UIImage) {
        //-- Setting image to orignal UIImage class
        self.imageOrignal = image
        self.imageTransform = self.imageOrignal
        self.mainImageView.image = image
        self.mainImageView.isUserInteractionEnabled = true
        self.removeGesturesMainImageView()
        self.setUpImageOptionView()
        self.calculatingMainImageViewSize()
    }
    
    func setUpImageOptionView() {
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        switch self.filterSelection {
        case .transform:
            return true
        case .text:
            return true
        case .sticker:
            return true
        case .frame:
            return false
        case .brush:
            return true
        default:
            return true
        }
    }
    
    @objc func pinchRecognizedBlankImage(pinchGesture: UIPinchGestureRecognizer) {
        if self.isAnyOptionSelected() == false {
            self.setUpImageOptionView()
            view.transform = view.transform.scaledBy(x: pinchGesture.scale, y: pinchGesture.scale)
            pinchGesture.scale = 1
        }
    }
    
    @objc func handleRotateBlankImage(recognizer : UIRotationGestureRecognizer) {
        if self.isAnyOptionSelected() == false {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    func opacityDidStartForImage(sliderValue: CGFloat) {
        self.mainImageView.alpha = sliderValue
    }
    
    func replaceImage() {
        self.openPhotoLibrary(isEdit: false)
    }
    
    func removeGesturesScrollViewContainer() {
        for gestureRecognizer in scrollViewContainer.gestureRecognizers ?? [] {
            scrollViewContainer.removeGestureRecognizer(gestureRecognizer)
        }
    }
    
    func removeGesturesMainImageViewForMagnify() {
        for gestureRecognizer in mainImageView.gestureRecognizers ?? [] {
            mainImageView.removeGestureRecognizer(gestureRecognizer)
        }
    }
    
    func removeGesturesMainImageView() {
        for gestureRecognizer in mainImageView.gestureRecognizers ?? [] {
            mainImageView.removeGestureRecognizer(gestureRecognizer)
        }
        
        if let imageView = transformMainView {
            for gestureRecognizer in imageView.gestureRecognizers ?? [] {
                imageView.removeGestureRecognizer(gestureRecognizer)
            }
        }
    }
    
    func applyImageView() {
        let frame = self.mainImageView.frame
        let backgroundColor = self.transformMainView.backgroundColor
        self.option.imageDetail.append((self.mainImageView, frame: frame, color: backgroundColor, transform: self.mainImageView.transform, opacity: self.mainImageView.alpha))
        self.option.isBlank = false
        self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
    }
    
    func resetImageView() {
        if isBlankCanvasRuler == true, self.option.isBlank == true {
            if self.option.imageDetail.count > 0 {
                for imageView in self.option.imageDetail {
                    self.mainImageView = imageView.imageView
                    self.mainImageView.transform = CGAffineTransform(rotationAngle: self.rotation(from: imageView.transform!))
                    self.mainImageView.frame = imageView.frame!
                    self.transformMainView.backgroundColor = imageView.color!
                    self.mainImageView.alpha = imageView.opacity!
                    
                }
            } else {
                self.mainImageView.image = self.imageOrignalBackUp
                self.setupAddDeleteFlipAndOnTopButtons(isHidden: true)
                self.imageOrignal = self.imageOrignalBackUp
                self.imageTransform = self.imageOrignalBackUp
            }
        }
    }
}
