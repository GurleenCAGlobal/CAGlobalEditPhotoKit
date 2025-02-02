//
//  StateRestorable.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//

import UIKit

public protocol StateRestorable {
    func isCurrentlyInState(_ state: CropperState?) -> Bool
    func saveState() -> CropperState
    func restoreState(_ state: CropperState, animated: Bool)
}

extension StateRestorable where Self: CropperViewController {
    internal func isCurrentlyInState(_ state: CropperState?) -> Bool {
        guard let state = state else { return false }
        let epsilon: CGFloat = 0.0001

        if state.viewFrame.isEqual(to: self.mainView.frame, accuracy: epsilon),
            state.angle.isEqual(to: totalAngle, accuracy: epsilon),
            state.rotationAngle.isEqual(to: rotationAngle, accuracy: epsilon),
            state.straightenAngle.isEqual(to: straightenAngle, accuracy: epsilon),
            state.flipAngle.isEqual(to: flipAngle, accuracy: epsilon),
            state.imageOrientationRawValue == imageView.image?.imageOrientation.rawValue ?? 0,
            state.scrollViewTransform.isEqual(to: scrollView.transform, accuracy: epsilon),
            state.scrollViewCenter.isEqual(to: scrollView.center, accuracy: epsilon),
            state.scrollViewBounds.isEqual(to: scrollView.bounds, accuracy: epsilon),
            state.scrollViewContentOffset.isEqual(to: scrollView.contentOffset, accuracy: epsilon),
            state.scrollViewMinimumZoomScale.isEqual(to: scrollView.minimumZoomScale, accuracy: epsilon),
            state.scrollViewMaximumZoomScale.isEqual(to: scrollView.maximumZoomScale, accuracy: epsilon),
            state.scrollViewZoomScale.isEqual(to: scrollView.zoomScale, accuracy: epsilon),
            state.cropBoxFrame.isEqual(to: overlay.cropBoxFrame, accuracy: epsilon),
            state.isFlip == false,
            state.isMirror == false {
            return true
        }

        return false
    }

    internal func saveState() -> CropperState {
        let cs = CropperState(viewFrame: self.mainView.bounds,
                              angle: totalAngle,
                              rotationAngle: rotationAngle,
                              straightenAngle: straightenAngle,
                              flipAngle: flipAngle,
                              imageOrientationRawValue: imageView.image?.imageOrientation.rawValue ?? 0,
                              scrollViewTransform: scrollView.transform,
                              scrollViewCenter: scrollView.center,
                              scrollViewBounds: scrollView.bounds,
                              scrollViewContentOffset: scrollView.contentOffset,
                              scrollViewMinimumZoomScale: scrollView.minimumZoomScale,
                              scrollViewMaximumZoomScale: scrollView.maximumZoomScale,
                              scrollViewZoomScale: scrollView.zoomScale,
                              cropBoxFrame: overlay.cropBoxFrame,
                              photoTranslation: photoTranslation(),
                              imageViewTransform: imageView.transform,
                              imageViewBoundsSize: imageView.bounds, imageCenter: imageView.center,
                              isFlip: false,
                              isMirror: false)
        return cs
    }

    internal func restoreState(_ state: CropperState, animated: Bool = false) {
        let animationsBlock = { () -> Void in
            self.rotationAngle = state.rotationAngle
            self.straightenAngle = state.straightenAngle
            self.flipAngle = state.flipAngle
            let orientation = UIImage.Orientation(rawValue: state.imageOrientationRawValue) ?? .up
            self.imageView.image = self.imageView.image?.withOrientation(orientation)
            self.scrollView.minimumZoomScale = state.scrollViewMinimumZoomScale
            self.scrollView.maximumZoomScale = state.scrollViewMaximumZoomScale
            self.scrollView.zoomScale = state.scrollViewZoomScale
            self.scrollView.transform = state.scrollViewTransform
            self.scrollView.bounds = state.scrollViewBounds
            self.scrollView.contentOffset = state.scrollViewContentOffset
            self.scrollView.center = state.scrollViewCenter
            self.overlay.cropBoxFrame = state.cropBoxFrame
            if self.overlay.cropBoxFrame.size.width > self.overlay.cropBoxFrame.size.height {
                self.aspectRatioPicker.aspectRatios = self.verticalAspectRatios
            } else {
                self.aspectRatioPicker.aspectRatios = self.verticalAspectRatios.map { $0.rotated }
            }
            self.aspectRatioPicker.rotated = false
            self.angleRuler.value = state.straightenAngle * 180 / CGFloat.pi 
        }

        if animated {
            UIView.animate(withDuration: 0.25, animations: animationsBlock)
        } else {
            animationsBlock()
        }
    }
}

extension StateRestorable where Self: CAEditViewController {
    public func isCurrentlyInState(_ state: CropperState?) -> Bool {
        guard let state = state else { return false }
        let epsilon: CGFloat = 0.0001

        if state.viewFrame.isEqual(to: self.transformMainView.frame, accuracy: epsilon),
            state.angle.isEqual(to: totalAngle, accuracy: epsilon),
            state.rotationAngle.isEqual(to: rotationAngle, accuracy: epsilon),
            state.straightenAngle.isEqual(to: straightenAngle, accuracy: epsilon),
            state.flipAngle.isEqual(to: flipAngle, accuracy: epsilon),
            state.imageOrientationRawValue == mainImageView.image?.imageOrientation.rawValue ?? 0,
            state.scrollViewTransform.isEqual(to: scrollView.transform, accuracy: epsilon),
            state.scrollViewCenter.isEqual(to: scrollView.center, accuracy: epsilon),
            state.scrollViewBounds.isEqual(to: scrollView.bounds, accuracy: epsilon),
            state.scrollViewContentOffset.isEqual(to: scrollView.contentOffset, accuracy: epsilon),
            state.scrollViewMinimumZoomScale.isEqual(to: scrollView.minimumZoomScale, accuracy: epsilon),
            state.scrollViewMaximumZoomScale.isEqual(to: scrollView.maximumZoomScale, accuracy: epsilon),
            state.scrollViewZoomScale.isEqual(to: scrollView.zoomScale, accuracy: epsilon),
            state.cropBoxFrame.isEqual(to: overlay.cropBoxFrame, accuracy: epsilon),
           state.isFlip == false,
            state.isMirror == false {
            return true
        }

        return false
    }

    public func saveState() -> CropperState {
        let cs = CropperState(viewFrame: self.transformMainView.bounds,
                              angle: totalAngle,
                              rotationAngle: rotationAngle,
                              straightenAngle: straightenAngle,
                              flipAngle: flipAngle,
                              imageOrientationRawValue: mainImageView.image?.imageOrientation.rawValue ?? 0,
                              scrollViewTransform: scrollView.transform,
                              scrollViewCenter: scrollView.center,
                              scrollViewBounds: scrollView.bounds,
                              scrollViewContentOffset: scrollView.contentOffset,
                              scrollViewMinimumZoomScale: scrollView.minimumZoomScale,
                              scrollViewMaximumZoomScale: scrollView.maximumZoomScale,
                              scrollViewZoomScale: scrollView.zoomScale,
                              cropBoxFrame: overlay.cropBoxFrame,
                              photoTranslation: photoTranslation(),
                              imageViewTransform: mainImageView.transform,
                              imageViewBoundsSize: mainImageView.frame,
                              imageCenter: mainImageView.center,
                              isFlip: isFlippedSelected,
                              isMirror: isMirroredSelected)
        return cs
    }

    public func restoreState(_ state: CropperState, animated: Bool = false) {
        let animationsBlock = { () -> Void in
            self.rotationAngle = state.rotationAngle
            self.straightenAngle = state.straightenAngle
            self.flipAngle = state.flipAngle
            let orientation = UIImage.Orientation(rawValue: state.imageOrientationRawValue) ?? .up
            self.mainImageView.image = self.mainImageView.image?.withOrientation(orientation)
            self.scrollView.minimumZoomScale = state.scrollViewMinimumZoomScale
            self.scrollView.maximumZoomScale = state.scrollViewMaximumZoomScale
            self.scrollView.zoomScale = state.scrollViewZoomScale
            self.scrollView.transform = state.scrollViewTransform
            self.scrollView.bounds = state.scrollViewBounds
            self.scrollView.contentOffset = state.scrollViewContentOffset
            self.scrollView.center = state.scrollViewCenter
            _ = CGRectMake(state.cropBoxFrame.origin.x, state.cropBoxFrame.origin.y + 0, state.cropBoxFrame.size.width, self.overlay.cropBoxFrame.size.height)
            self.overlay.cropBoxFrame = state.cropBoxFrame
            self.aspectRatioPicker.rotated = false
            self.angleRuler.value = state.straightenAngle * 180 / CGFloat.pi
            self.mainImageView.transform = state.imageViewTransform
            self.mainImageView.frame = state.imageViewBoundsSize
            _ = CGRect(x: 0, y: 0, width: self.overlay.cropBox.bounds.width, height: self.overlay.cropBox.bounds.height)
            self.framesImageViewAngleRatio.transform = CGAffineTransform(rotationAngle: self.rotationAngle)
            self.framesImageViewAngleRatio.frame.size = self.overlay.cropBox.bounds.size
            self.framesImageViewAngleRatio.center = self.scrollViewContainer.center
            self.scrollViewContainer.transform = CGAffineTransformIdentity

            if self.isMirroredSelected && self.isFlippedSelected {
                self.scrollViewContainer.transform = CGAffineTransform(scaleX: -1, y: -1)
            } else if self.isFlippedSelected {
                self.scrollViewContainer.transform = CGAffineTransform(scaleX: -1, y: 1)
            } else if self.isMirroredSelected {
                self.scrollViewContainer.transform = CGAffineTransform(scaleX: 1, y: -1)
            } else {
                self.scrollViewContainer.transform = CGAffineTransformIdentity
            }
        }

        if animated {
            UIView.animate(withDuration: 0.25, animations: animationsBlock)
        } else {
            animationsBlock()
        }
    }
}
