//
//  UIView+Helper.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//

import UIKit

extension UIView {

    private func standardizeRect(_ rect: CGRect) -> CGRect {
        return CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height)
    }

    var left: CGFloat {
        get {
            return frame.minX
        }
        set(xAxis) {
            var frame = standardizeRect(self.frame)

            frame.origin.x = xAxis
            self.frame = frame
        }
    }

    var top: CGFloat {
        get {
            return frame.minY
        }
        set(yAxis) {
            var frame = standardizeRect(self.frame)

            frame.origin.y = yAxis
            self.frame = frame
        }
    }

    var right: CGFloat {
        get {
            return frame.maxX
        }
        set(right) {
            var frame = standardizeRect(self.frame)

            frame.origin.x = right - frame.size.width
            self.frame = frame
        }
    }

    var bottom: CGFloat {
        get {
            return frame.maxY
        }
        set(bottom) {
            var frame = standardizeRect(self.frame)

            frame.origin.y = bottom - frame.size.height
            self.frame = frame
        }
    }

    var width: CGFloat {
        get {
            return frame.width
        }
        set(width) {
            var frame = standardizeRect(self.frame)

            frame.size.width = width
            self.frame = frame
        }
    }

    var height: CGFloat {
        get {
            return frame.height
        }
        set(height) {
            var frame = standardizeRect(self.frame)

            frame.size.height = height
            self.frame = frame
        }
    }

    var centerX: CGFloat {
        get {
            return frame.midX
        }
        set(centerX) {
            center = CGPoint(x: centerX, y: center.y)
        }
    }

    var centerY: CGFloat {
        get {
            return center.y
        }
        set(centerY) {
            center = CGPoint(x: center.x, y: centerY)
        }
    }

    var size: CGSize {
        get {
            return standardizeRect(frame).size
        }
        set(size) {
            var frame = standardizeRect(self.frame)

            frame.size = size
            self.frame = frame
        }
    }
}
