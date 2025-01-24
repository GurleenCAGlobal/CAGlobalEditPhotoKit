//
//  CAEditBlurViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 08/04/24.
//

import UIKit

// MARK: - Blur Option -

extension CAEditViewController {
    func setUpBlurView() {
        self.option.isBlur = false
        self.imageBlur = self.applyingAllFilters(true, false, false) //removed gaussBlur
        self.removeBottomSubViews()
        self.bottomView.isHidden = false
    }
    
    
    func setup() {
        blurType = .blurTypeCircle
        thumbnailImage = self.imageBlur.resize(mainImageScaledSize) ?? self.imageBlur
        circleView.removeFromSuperview()
        handlerView = UIView(frame: mainImageView.frame)
        handlerView.center = mainImageView.center
        mainImageView.superview?.addSubview(handlerView)
        setHandlerView()
        setDefaultParams()
        self.blurImage = self.thumbnailImage.gaussBlur(blurLevel: 1) ?? self.self.imageBlur
        self.buildThumbnailImage()
    }
    
    func cleanup() {
        blurSlider?.superview?.removeFromSuperview()
        handlerView.removeFromSuperview()
    }
    
    func setDefaultParams() {
        var width = CGFloat()
        width = 100
        circleView = CircularBlurView(frame: CGRect(x: handlerView.frame.width / 2 - width / 2, y: handlerView.frame.height / 2 - width / 2, width: width, height: width))
        circleView.backgroundColor = .clear
        circleView.color = .white
    }
    
    func setHandlerView() {
        
    }
    
    @objc func tappedBlurMenu(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        view.alpha = 0.2
        UIView.animate(withDuration: kCLImageToolAnimationDuration) {
            view.alpha = 1
        }
        circleView.removeFromSuperview()
        switch blurType {
        case .blurTypeNormal:
            break
        case .blurTypeCircle:
            handlerView.addSubview(circleView)
            circleView.setNeedsDisplay()
        default:
            break
        }
        buildThumbnailImage()
    }
    
    @objc func tapHandlerView(_ sender: UITapGestureRecognizer) {
        switch blurType {
        case .blurTypeCircle:
            let point = sender.location(in: handlerView)
            circleView.center = point
            buildThumbnailImage()
        default:
            break
        }
    }
    
    @objc func panHandlerView(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let point = gestureRecognizer.location(in: self.mainImageView)
            let restrictByPoint: CGFloat = 30.0
            let superViewX = self.mainImageView.bounds.origin.x + restrictByPoint
            let superViewY = self.mainImageView.bounds.origin.y + restrictByPoint
            let width = self.mainImageView.bounds.size.width - 2*restrictByPoint
            let height = self.mainImageView.bounds.size.height - 2*restrictByPoint
            let superBounds = CGRect(x: superViewX, y: superViewY, width: width, height: height)
            
            if superBounds.contains(point) {
                circleView.removeFromSuperview()
                switch blurType {
                case .blurTypeCircle:
                    handlerView.addSubview(circleView)
                    circleView.center = point
                    circleView.setNeedsDisplay()
                    circleView.setNeedsLayout()
                    buildThumbnailImage()
                    circleView.setNeedsDisplay()
                    circleView.setNeedsLayout()
                default:
                    break
                }
            }
        }
    }
    
    @objc func pinchHandlerView(_ sender: UIPinchGestureRecognizer) {
        switch blurType {
        case .blurTypeCircle:
            if sender.state == .began {
                initialFrame = circleView.frame
            }
            let scale = sender.scale
            var rct = CGRect()
            rct.size.width = max(
                min(initialFrame.size.width * scale, 3 * max(handlerView.frame.size.width , handlerView.frame.size.height )),
                0.3 * min(handlerView.frame.size.width , handlerView.frame.size.height )
            )
            rct.size.height = rct.size.width
            rct.origin.x = initialFrame.origin.x + (initialFrame.size.width - rct.size.width) / 2
            rct.origin.y = initialFrame.origin.y + (initialFrame.size.height - rct.size.height) / 2
            circleView.frame = rct
            buildThumbnailImage()
        default:
            break
        }
    }
    
    func applyBlur() {
        if self.option.isBlurActual == false {
            self.handlerView.removeFromSuperview()
            self.mainImageView.image = self.applyingAllFilters(false,false,false)
        } else {
            self.handlerView.removeFromSuperview()
            self.option.isBlur = true
            self.option.appliedBlurDetails.append(self.circleView.frame)
            self.mainImageView.image = self.applyingAllFilters(false,false,false)
        }
    }
    
    func buildThumbnailImage() {
        var inProgress = false
        if inProgress {
            return
        }
        inProgress = true
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                self.blurManager.mainImageView = self.mainImageView.frame
                self.blurManager.circleView = self.circleView.frame
                self.blurManager.optionalmage = self.imageBlur
                let image = self.blurManager.buildResultImage(self.thumbnailImage, withBlurImage: self.blurImage)
                self.mainImageView.image = image
                inProgress = false
            }
        }
    }
}
