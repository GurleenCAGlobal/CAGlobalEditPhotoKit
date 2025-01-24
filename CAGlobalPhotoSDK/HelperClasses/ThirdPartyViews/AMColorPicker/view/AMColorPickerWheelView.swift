//
//  AMColorPickerWheelView.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//


import UIKit

public class AMColorPickerWheelView: XibLioadView, AMColorPicker {
    
    weak public var delegate: AMColorPickerDelegate?
    public var isSelectedColorShown: Bool = true {
        didSet {
            headerView?.isHidden = !isSelectedColorShown
        }
    }
    public var selectedColor: UIColor = .white {
        didSet {
            displayColor(selectedColor)
        }
    }
    public var selectedOpacity: CGFloat = 1.0 {
        didSet {
            displayColor(selectedColor)
        }
    }
    @IBOutlet weak private var headerView: UIView!
    @IBOutlet weak private var opacityLabel: UILabel!
    @IBOutlet weak private var brightnessLabel: UILabel!
    @IBOutlet weak private var opacitySlider: UISlider!
    @IBOutlet weak private var colorView: UIView!
    @IBOutlet weak private var brightnessSlider: AMColorPickerSlider!
    @IBOutlet weak private var colorPickerImageView: UIImageView! {
        didSet {
            colorPickerImageView.isUserInteractionEnabled = true
            let pan = UIPanGestureRecognizer(target: self, action: #selector(self.gestureAction(gesture:)))
            colorPickerImageView.addGestureRecognizer(pan)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.gestureAction(gesture:)))
            colorPickerImageView.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak private var cursorImageView: UIImageView!
    
    private var radius: CGFloat {
        return colorPickerImageView.frame.width/2
    }
    private var pickerCenter: CGPoint {
        return colorPickerImageView.center
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        // Set the initial value of the opacity slider to the last selected opacity
        opacitySlider.value = Float(selectedOpacity * 100)
        displayColor(selectedColor)
    }

    
    // MARK: - Gesture Action
    @objc func gestureAction(gesture: UIGestureRecognizer) {
        let point = gesture.location(in: colorPickerImageView.superview)
        let path = UIBezierPath(ovalIn: colorPickerImageView.frame)
        if path.contains(point) {
            didSelect(color: calculateColor(point: point))
        }
    }
    
    // MARK: - IBAction
    @IBAction private func changedSlider(_ slider: UISlider) {
        if slider == opacitySlider {
            // Update selectedOpacity when opacity slider changes
            selectedOpacity = CGFloat(opacitySlider.value) / 100.0
            print("Opacity slider value: \(opacitySlider.value)")

            didSelect(color: selectedColor)
        } else if slider == brightnessSlider {
            // Handle brightness changes, using the existing selectedOpacity
            didSelect(color: calculateColor(point: cursorImageView.center))
        }
    }

    
    // MARK: - SetColor
    private func setSliderColor(color: UIColor) {
        let hsba = color.hsba
        brightnessSlider.setGradient(startColor: .clear,
                                     endColor: .init(hue: hsba.hue, saturation: hsba.saturation,
                                                     brightness: 1.0, alpha: CGFloat(opacitySlider.value)/100.0))
    }
    
//    private func didSelect(color: UIColor) {
//        selectedColor = color.withAlphaComponent(selectedOpacity)
//        delegate?.colorPicker(self, didSelect: color, opacity: selectedOpacity)
//    }
//    private func didSelect(color: UIColor) {
//        let colorWithOpacity = color.withAlphaComponent(selectedOpacity)
//
//        selectedColor = colorWithOpacity
//        print("Selected color: \(colorWithOpacity), Opacity: \(selectedOpacity)")
//
//        delegate?.colorPicker(self, didSelect: colorWithOpacity, opacity: selectedOpacity)
//    }
    private func didSelect(color: UIColor) {
        // Apply selectedOpacity to the selected color
        selectedColor = color.withAlphaComponent(selectedOpacity)

        // Notify the delegate (brush tool) with the updated color and opacity
        delegate?.colorPicker(self, didSelect: selectedColor, opacity: selectedOpacity)
    }



    private func displayColor(_ color: UIColor) {
        colorView.backgroundColor = color
        cursorImageView.center = calculatePoint(color: color)

        let hsba = color.hsba
        let alpha = selectedOpacity * 100 // Use selectedOpacity to reflect the current opacity
        let brightness = hsba.brightness * 100

        opacityLabel.text = alpha.colorFormatted
        brightnessLabel.text = brightness.colorFormatted
        opacitySlider.value = Float(alpha) // Ensure slider reflects the correct opacity
        brightnessSlider.value = Float(brightness)

        setSliderColor(color: color)
    }


    // MARK: - Calculate
//    private func calculateColor(point: CGPoint, opacity: inout CGFloat) -> UIColor {
//        // Since the upper side of the screen for obtaining the coordinate difference
//        // is set as the Y coordinate +, the sign of Y coordinate is replaced
//        let xPoint = point.x - pickerCenter.x
//        let yPoint = -(point.y - pickerCenter.y)
//        
//        // Find the radian angle
//        var radian = atan2f(Float(yPoint), Float(xPoint))
//        if radian < 0 {
//            radian += Float(Double.pi*2)
//        }
//
//        let distance = CGFloat(sqrtf(Float(pow(Double(xPoint), 2) + pow(Double(yPoint), 2))))
//        let saturation = (distance > radius) ? 1.0 : distance / radius
//        let brightness = CGFloat(brightnessSlider.value) / 100.0
//        let alpha = CGFloat(opacitySlider.value) / 100.0
//        opacity = alpha
//        let hue = CGFloat(radian / Float(Double.pi*2))
//        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
//    }
    private func calculateColor(point: CGPoint) -> UIColor {
        // Calculate the position of the point relative to the center
        let xPoint = point.x - pickerCenter.x
        let yPoint = -(point.y - pickerCenter.y)

        // Find the radian angle
        var radian = atan2f(Float(yPoint), Float(xPoint))
        if radian < 0 {
            radian += Float(Double.pi * 2)
        }

        let distance = CGFloat(sqrtf(Float(pow(Double(xPoint), 2) + pow(Double(yPoint), 2))))
        let saturation = (distance > radius) ? 1.0 : distance / radius
        let brightness = CGFloat(brightnessSlider.value) / 100.0
        let hue = CGFloat(radian / Float(Double.pi * 2))

        // Return color with preserved opacity
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: selectedOpacity)
    }


    private func calculatePoint(color: UIColor) -> CGPoint {
        let hsba = selectedColor.hsba
        let angle = Float(hsba.hue) * Float(Double.pi*2)
        let smallRadius = hsba.saturation * radius
        let point = CGPoint(x: pickerCenter.x + smallRadius * CGFloat(cosf(angle)),
                            y: pickerCenter.y + smallRadius * CGFloat(sinf(angle))*(-1))
        return point
    }
}
