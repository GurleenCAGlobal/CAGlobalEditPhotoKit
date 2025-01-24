import UIKit
// MARK: AspectRatioPickerDelegate

extension CAEditViewController: AspectRatioPickerDelegate {
    
    func aspectRatioPickerDidSelectedAspectRatio(_ aspectRatio: AspectRatio) {
        setAspectRatio(aspectRatio)
    }
}
extension CAEditViewController {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == cropBoxPanGesture {
            guard isCropBoxPanEnabled else {
                return false
            }
            let tapPoint = gestureRecognizer.location(in: self.transformMainView)
            
            let frame = overlay.cropBoxFrame
            
            let direction = cropBoxHotArea / 2.0
            let innerFrame = frame.insetBy(dx: direction, dy: direction)
            let outerFrame = frame.insetBy(dx: -direction, dy: -direction)
            
            if innerFrame.contains(tapPoint) || !outerFrame.contains(tapPoint) {
                return false
            }
        }
        
        return true
    }
}

extension CAEditViewController {
    @objc func cropBoxPan(_ pan: UIPanGestureRecognizer) {
        guard isCropBoxPanEnabled else {
            return
        }
        let point = pan.location(in: self.transformMainView)
        
        if pan.state == .began {
            cancelUniqueActivity()
            panBeginningPoint = point
            panBeginningCropBoxFrame = overlay.cropBoxFrame
            panBeginningCropBoxEdge = nearestCropBoxEdgeForPoint(point: panBeginningPoint)
            overlay.blur = false
            overlay.gridLinesAlpha = 1
            bottomView.isUserInteractionEnabled = false
        }
        
        if pan.state == .ended || pan.state == .cancelled {
            self.matchScrollViewAndCropView(animated: true, targetCropBoxFrame: self.overlay.cropBoxFrame, extraZoomScale: 1, blurLayerAnimated: true, animations: {
                self.overlay.gridLinesAlpha = 0
                self.overlay.blur = true
            }, completion: {
                self.bottomView.isUserInteractionEnabled = true
            })
        } else {
            updateCropBoxFrameWithPanGesturePoint(point)
        }
    }
}

// MARK: UIScrollViewDelegate

extension CAEditViewController: UIScrollViewDelegate {
    
    public func viewForZooming(in scroll: UIScrollView) -> UIView? {
        if scroll == self.scrollView && self.option.isTransformActual == true {
            if self.option.isTransformActual == false {
                return nil
            }
            return self.mainImageView
        }
        return nil
    }
    
    public func scrollViewWillBeginZooming(_ scroll: UIScrollView, with _: UIView?) {
        if scroll == self.scrollView && self.option.isTransformActual == true {
            cancelUniqueActivity()
            bottomView.isUserInteractionEnabled = false
        }
    }
    
    public func scrollViewDidEndZooming(_ scroll: UIScrollView, with _: UIView?, atScale _: CGFloat) {
        if scroll == self.scrollView && self.option.isTransformActual == true {
            matchScrollViewAndCropView(animated: true, completion: {
                self.uniqueActivityAndThenRun {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.overlay.gridLinesAlpha = 0
                        self.overlay.blur = true
                    }, completion: { _ in
                        self.bottomView.isUserInteractionEnabled = true
                    })
                    
                    self.manualZoomed = true
                }
            })
        }
    }
    
    public func scrollViewWillBeginDragging(_ scroll: UIScrollView) {
        if scroll == self.scrollView && self.option.isTransformActual == true {
            cancelUniqueActivity()
            bottomView.isUserInteractionEnabled = false
        }
    }
    
    public func scrollViewDidEndDragging(_ scroll: UIScrollView, willDecelerate decelerate: Bool) {
        if scroll == self.scrollView && self.option.isTransformActual == true {
            if !decelerate {
                matchScrollViewAndCropView(animated: true, completion: {
                    self.uniqueActivityAndThenRun {
                        UIView.animate(withDuration: 0.25, animations: {
                            self.overlay.gridLinesAlpha = 0
                            self.overlay.blur = true
                        }, completion: { _ in
                            self.bottomView.isUserInteractionEnabled = true
                        })
                    }
                })
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scroll: UIScrollView) {
        if scroll == self.scrollView && self.option.isTransformActual == true {
            matchScrollViewAndCropView(animated: true, completion: {
                self.uniqueActivityAndThenRun {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.overlay.gridLinesAlpha = 0
                        self.overlay.blur = true
                    }, completion: { _ in
                        self.bottomView.isUserInteractionEnabled = true
                    })
                }
            })
        }
    }
    
    public static let overlayCropBoxFramePlaceholder: CGRect = .zero
    public func matchScrollViewAndCropView(animated: Bool = false,
                                           targetCropBoxFrame: CGRect = overlayCropBoxFramePlaceholder,
                                           extraZoomScale: CGFloat = 1.0,
                                           blurLayerAnimated: Bool = false,
                                           animations: (() -> Void)? = nil,
                                           completion: (() -> Void)? = nil) {
        var targetCropBoxFrame = targetCropBoxFrame
        if targetCropBoxFrame.equalTo(CAEditViewController.overlayCropBoxFramePlaceholder) {
            targetCropBoxFrame = overlay.cropBoxFrame
        }
        
        let scaleX = maxCropRegion.size.width / targetCropBoxFrame.size.width
        let scaleY = maxCropRegion.size.height / targetCropBoxFrame.size.height
        
        let scale = min(scaleX, scaleY)
        
        // calculate the new bounds of crop view
        let newCropBounds = CGRect(x: 0, y: 0, width: scale * targetCropBoxFrame.size.width, height: scale * targetCropBoxFrame.size.height)
        
        // calculate the new bounds of scroll view
        let rotatedRect = newCropBounds.applying(CGAffineTransform(rotationAngle: totalAngle))
        let width = rotatedRect.size.width
        let height = rotatedRect.size.height
        
        let cropBoxFrameBeforeZoom = targetCropBoxFrame
        
        let zoomRect = transformMainView.convert(cropBoxFrameBeforeZoom, to: self.mainImageView) // zoomRect is base on imageView when scrollView.zoomScale = 1
        let center = CGPoint(x: zoomRect.origin.x + zoomRect.size.width / 2, y: zoomRect.origin.y + zoomRect.size.height / 2)
        let normalizedCenter = CGPoint(x: center.x / (self.mainImageView.width / scrollView.zoomScale), y: center.y / (self.mainImageView.height / scrollView.zoomScale))
        
        UIView.animate(withDuration: animated ? 0.25 : 0, animations: {
            self.overlay.setCropBoxFrame(CGRect(center: self.defaultCropBoxCenter, size: newCropBounds.size), blurLayerAnimated: blurLayerAnimated)
            animations?()
            self.scrollView.bounds = CGRect(x: 0, y: 0, width: width, height: height)
            
            var zoomScale = scale * self.scrollView.zoomScale * extraZoomScale
            let scrollViewZoomScaleToBounds = self.scrollViewZoomScaleToBounds()
            if zoomScale < scrollViewZoomScaleToBounds { // Some area not fill image in the cropbox area
                zoomScale = scrollViewZoomScaleToBounds
            }
            
            if zoomScale > self.scrollView.maximumZoomScale { // Only rotate can make maximumZoomScale to get bigger
                zoomScale = self.scrollView.maximumZoomScale
            }
            
            self.willSetScrollViewZoomScale(zoomScale)
            
            self.scrollView.zoomScale = zoomScale
            
            let contentOffset = CGPoint(x: normalizedCenter.x * self.mainImageView.width - self.scrollView.bounds.size.width * 0.5,
                                        y: normalizedCenter.y * self.mainImageView.height - self.scrollView.bounds.size.height * 0.5)
            self.scrollView.contentOffset = self.safeContentOffsetForScrollView(contentOffset)
        }, completion: { _ in
            completion?()
        })
        
        manualZoomed = true
    }
    
    func scrollViewZoomScaleToBounds() -> CGFloat {
        let scaleW = scrollView.bounds.size.width / self.mainImageView.bounds.size.width
        let scaleH = scrollView.bounds.size.height / self.mainImageView.bounds.size.height
        return max(scaleW, scaleH)
    }
    
    func willSetScrollViewZoomScale(_ zoomScale: CGFloat) {
        if zoomScale > scrollView.maximumZoomScale {
            scrollView.maximumZoomScale = zoomScale
        }
        if zoomScale < scrollView.minimumZoomScale {
            scrollView.minimumZoomScale = zoomScale
        }
    }
    
    func safeContentOffsetForScrollView(_ contentOffset: CGPoint) -> CGPoint {
        var contentOffset = contentOffset
        contentOffset.x = max(contentOffset.x, 0)
        contentOffset.y = max(contentOffset.y, 0)
        
        if scrollView.contentSize.height - contentOffset.y <= scrollView.bounds.size.height {
            contentOffset.y = scrollView.contentSize.height - scrollView.bounds.size.height
        }
        
        if scrollView.contentSize.width - contentOffset.x <= scrollView.bounds.size.width {
            contentOffset.x = scrollView.contentSize.width - scrollView.bounds.size.width
        }
        
        return contentOffset
    }
    
    func safeCropBoxFrame(_ cropBoxFrame: CGRect) -> CGRect {
        var cropBoxFrame = cropBoxFrame
        // Upon init, sometimes the box size is still 0, which can result in CALayer issues
        if cropBoxFrame.size.width < .ulpOfOne || cropBoxFrame.size.height < .ulpOfOne {
            return CGRect(center: defaultCropBoxCenter, size: defaultCropBoxSize)
        }
        
        // clamp the cropping region to the inset boundaries of the screen
        let contentFrame = maxCropRegion
        let xOrigin = contentFrame.origin.x
        let xDelta = cropBoxFrame.origin.x - xOrigin
        cropBoxFrame.origin.x = max(cropBoxFrame.origin.x, xOrigin)
        if xDelta < -.ulpOfOne { // If we clamp the x value, ensure we compensate for the subsequent delta generated in the width (Or else, the box will keep growing)
            cropBoxFrame.size.width += xDelta
        }
        
        let yOrigin = contentFrame.origin.y
        let yDelta = cropBoxFrame.origin.y - yOrigin
        cropBoxFrame.origin.y = max(cropBoxFrame.origin.y, yOrigin)
        if yDelta < -.ulpOfOne {
            cropBoxFrame.size.height += yDelta
        }
        
        // given the clamped X/Y values, make sure we can't extend the crop box beyond the edge of the screen in the current state
        let maxWidth = (contentFrame.size.width + contentFrame.origin.x) - cropBoxFrame.origin.x
        cropBoxFrame.size.width = min(cropBoxFrame.size.width, maxWidth)
        
        let maxHeight = (contentFrame.size.height + contentFrame.origin.y) - cropBoxFrame.origin.y
        cropBoxFrame.size.height = min(cropBoxFrame.size.height, maxHeight)
        
        // Make sure we can't make the crop box too small
        cropBoxFrame.size.width = max(cropBoxFrame.size.width, cropBoxMinSize)
        cropBoxFrame.size.height = max(cropBoxFrame.size.height, cropBoxMinSize)
        
        return cropBoxFrame
    }
}

