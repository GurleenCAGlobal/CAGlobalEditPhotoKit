//
//  Flipable.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//

import UIKit

public protocol Flipable {
    func flip(directionHorizontal: Bool)
}

extension Flipable where Self: CropperViewController {
    internal func flip(directionHorizontal: Bool = true) {
        let size: CGSize = scrollView.contentSize
        let contentOffset = scrollView.contentOffset
        let bounds: CGSize = scrollView.bounds.size

        scrollView.contentOffset = CGPoint(x: size.width - bounds.width - contentOffset.x, y: contentOffset.y)

        let image = imageView.image
        let fliped: Bool = (image?.imageOrientation == .upMirrored)

        if directionHorizontal {
            flipAngle += -2.0 * totalAngle // Make sum equal to -self.totalAngle
        } else {
            flipAngle += CGFloat.pi - 2.0 * totalAngle //  Make sum equal to pi - self.totalAngle
        }

        imageView.image = image?.withOrientation(fliped ? .up : .upMirrored)

        scrollView.transform = CGAffineTransform(rotationAngle: totalAngle)
        updateButtons()
    }
}


extension Flipable where Self: CAEditViewController {
    internal func flip(directionHorizontal: Bool = true) {
        let image = mainImageView.image
        fliped = (image?.imageOrientation == .upMirrored)

        if directionHorizontal {
            flipAngle += -2.0 * totalAngle // Make sum equal to -self.totalAngle
        } else {
            flipAngle += CGFloat.pi - 2.0 * totalAngle //  Make sum equal to pi - self.totalAngle
        }

        mainImageView.image = image?.withOrientation(fliped ? .up : .upMirrored)
        scrollView.transform = CGAffineTransform(rotationAngle: totalAngle)
        updateButtons()
    }
}
