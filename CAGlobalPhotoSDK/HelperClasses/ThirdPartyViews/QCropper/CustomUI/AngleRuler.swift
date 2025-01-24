//
//  AngleRuler.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//

import UIKit

/// Will send 2 actions: valueChanged and editingDidEnd
public class AngleRuler: UIControl {
    /// Should be an integer multiple of numberOfGroupedScales
    var numberOfTotalScales: Int = 40
    var numberOfGroupedScales: Int = 10
    var scaleSpacing: CGFloat = 10.0

    var minimumValue: CGFloat = -180.0
    var maximumValue: CGFloat = 180.0
    var valueObj: CGFloat = 0 {
        didSet {
            if abs(valueObj) < 0.01 {
                zeroDot.isHidden = true
            } else {
                zeroDot.isHidden = false
            }
        }
    }

    var value: CGFloat {
        get {
            return valueObj
        }
        set {
            setValue(newValue, sendEvent: false)
        }
    }

    func setValue(_ newValue: CGFloat, sendEvent: Bool) {
        valueObj = newValue
        valueLabel.text = String(format: "%.1f", newValue)
        let xPoint = CGFloat(numberOfTotalScales) * scaleSpacing * (newValue - minimumValue) / (maximumValue - minimumValue)
        if sendEvent {
            scrollView.contentOffset = CGPoint(x: xPoint, y: 0)
        } else {
            scrollView.delegate = nil
            scrollView.contentOffset = CGPoint(x: xPoint, y: 0)
            scrollView.delegate = self
        }
    }

    private let lineName = "line"
    private let margin: CGFloat = 0
    private let bottomMargin: CGFloat = 0
    // Make pixel alignment to avoid anti-aliasing, 0.5 = lineWidth / 2
    private lazy var pixelOffset = CGFloat(0.5.truncatingRemainder(dividingBy: Double(10)))
    private lazy var scrollViewContentInset = scrollView.frame.size.width / 2.0

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView(frame: self.frame.insetBy(dx: margin, dy: 0))
        sv.backgroundColor = .clear
        sv.decelerationRate = .fast
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.delegate = self
        return sv
    }()

    lazy var valueLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 52))
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.center = CGPoint(x: self.frame.size.width / 2.0 + pixelOffset, y: self.frame.size.height / 2)
        return label
    }()

    private lazy var midScaleLine: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 30))
        view.backgroundColor = .white
        view.center = CGPoint(x: self.frame.size.width / 2.0 + pixelOffset, y: self.frame.size.height / 2)
        return view
    }()

    private lazy var midScaleLineBorder: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1 + 2 * borderWidth, height: 30 + 2 * borderWidth))
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.center = self.midScaleLine.center
        return view
    }()

    private lazy var zeroDot: UIView = {
        let xPoint = (CGFloat(numberOfTotalScales) / 2) * scaleSpacing + pixelOffset + scrollViewContentInset - 3
        let view = UIView(frame: CGRect(x: xPoint, y: frame.size.height - bottomMargin - 29, width: 6, height: 6))
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()

    private lazy var maskLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        let clear = UIColor.clear.cgColor
        let black = UIColor.black.cgColor
        layer.colors = [clear, black, black, clear]
        layer.locations = [0, 0.08, 0.92, 1]
        layer.frame = self.bounds
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()

    private func setupScaleLayers() {
        layer.sublayers?.forEach { layer in
            if layer.name == lineName {
                layer.removeFromSuperlayer()
            }
        }

        func createShapeLayer() -> CAShapeLayer {
            let layer = CAShapeLayer()
            layer.name = lineName
            layer.lineWidth = 1
            layer.fillColor = UIColor.clear.cgColor
            return layer
        }

        let grayScales = createShapeLayer()
        grayScales.strokeColor = UIColor(white: 0.76, alpha: 1).cgColor
        let grayPath = CGMutablePath()

        let whiteScales = createShapeLayer()
        whiteScales.strokeColor = UIColor(white: 1, alpha: 1).cgColor
        let whitePath = CGMutablePath()

        let scaleBorders = createShapeLayer()
        scaleBorders.strokeColor = UIColor(white: 0, alpha: 0.2).cgColor
        scaleBorders.lineWidth = 1
        let borderPath = CGMutablePath()

        let lineHeight: CGFloat = 2
        let lineBottom: CGFloat = 26
        let lineTop = lineBottom - lineHeight

        for index in 0 ... numberOfTotalScales {
            let xAxis = CGFloat(index) * scaleSpacing + pixelOffset + scrollViewContentInset

            if index % numberOfGroupedScales == 0 {
                whitePath.move(to: CGPoint(x: xAxis, y: lineTop))
                whitePath.addLine(to: CGPoint(x: xAxis, y: lineBottom))
            } else {
                grayPath.move(to: CGPoint(x: xAxis, y: lineTop))
                grayPath.addLine(to: CGPoint(x: xAxis, y: lineBottom))
            }

            borderPath.move(to: CGPoint(x: xAxis, y: lineTop))
            borderPath.addLine(to: CGPoint(x: xAxis, y: lineBottom))
        }

        grayScales.path = grayPath
        whiteScales.path = whitePath
        scaleBorders.path = borderPath
        scrollView.layer.addSublayer(scaleBorders)
        scrollView.layer.addSublayer(whiteScales)
        scrollView.layer.addSublayer(grayScales)

        scrollView.contentSize = CGSize(width: CGFloat(numberOfTotalScales) * scaleSpacing + 2 * scrollViewContentInset, height: scrollView.bounds.size.height)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        setupScaleLayers()
        addSubview(scrollView)
        addSubview(valueLabel)
        layer.mask = maskLayer
        setValue(0, sendEvent: false)
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if view == self {
            return scrollView
        }

        return view
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func autoZeroValue() {
        if abs(value) < 1 {
            UIView.animate(withDuration: 0.15) {
                self.setValue(0, sendEvent: true)
            }
        }
    }

    private func scrollEnded() {
        midScaleLine.backgroundColor = .white
        autoZeroValue()
        sendActions(for: .editingDidEnd)
    }
}

extension AngleRuler: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var value = scrollView.contentOffset.x * (maximumValue - minimumValue) / (CGFloat(numberOfTotalScales) * scaleSpacing) + minimumValue
        if value < minimumValue {
            value = minimumValue
        }
        if value > maximumValue {
            value = maximumValue
        }
        valueObj = value
        valueLabel.text = String(format: "%.1f", value)
        midScaleLine.backgroundColor = QCropper.Config.highlightColor
        sendActions(for: .valueChanged)
    }

    public func scrollViewDidEndDragging(_: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollEnded()
        }
    }

    public func scrollViewDidEndDecelerating(_: UIScrollView) {
        scrollEnded()
    }

    public func scrollViewDidEndScrollingAnimation(_: UIScrollView) {
        scrollEnded()
    }
}
