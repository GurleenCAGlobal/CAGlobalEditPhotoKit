//
//  ViewWithDiagonalLine.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/05/23.
//

import UIKit
import Foundation

class ViewWithDiagonalLine: UIView {

    private let line: UIView

    private var lengthConstraint: NSLayoutConstraint!

    init() {
        // Initialize line view
        line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor.red

        super.init(frame: CGRectZero)

        clipsToBounds = true // Cut off everything outside the view

        // Add and layout the line view

        addSubview(line)

        // Define line width
        line.addConstraint(NSLayoutConstraint(item: line, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 10))

        // Set up line length constraint
        lengthConstraint = NSLayoutConstraint(item: line, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        addConstraint(lengthConstraint)

        // Center line in view
        addConstraint(NSLayoutConstraint(item: line, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: line, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Update length constraint and rotation angle
        lengthConstraint.constant = sqrt(pow(frame.size.width, 2) + pow(frame.size.height, 2))
        line.transform = CGAffineTransformMakeRotation(atan2(frame.size.height, frame.size.width))
    }

}

extension UILabel {
    func addSlantLine(slantLineColor: UIColor, slantLineWidth:CGFloat, startPoint: CGPoint, endPoint: CGPoint) {
        let slantLinePath = UIBezierPath()
        slantLinePath.move(to: startPoint)
        slantLinePath.addLine(to: endPoint)

        let slantLineLayer = CAShapeLayer()
        slantLineLayer.path = slantLinePath.cgPath
        slantLineLayer.lineWidth = slantLineWidth
        slantLineLayer.strokeColor = slantLineColor.cgColor
        layer.addSublayer(slantLineLayer)
    }
}
