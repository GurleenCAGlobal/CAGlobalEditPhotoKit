//
//  CanvasView.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/05/23.
//


import UIKit

struct BrushState {
    var color: UIColor
    var size: CGFloat
    var path: UIBezierPath
}

struct TouchPointsAndColor {
    var color: UIColor = UIColor(named: .blackColorName, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!
    var width: CGFloat?
    var opacity: CGFloat?
    var points: [CGPoint]?
    var sharpness: CGFloat = 1.0
    var isSaveLine: Bool? = false

    init(color: UIColor, points: [CGPoint]?, width: CGFloat? = nil, opacity: CGFloat? = nil, sharpness: CGFloat? = nil) {
        self.color = color
        self.points = points
        self.width = width
        self.opacity = opacity
        self.sharpness = sharpness ?? 1.0
    }
}




protocol DrawingViewDelegate: AnyObject {
    /*
     Called when the user select any size
     */
    func setLine()
}

class DrawingView: UIView {

    var lines = [TouchPointsAndColor]()
    var strokeWidth: CGFloat = 1.0
    var strokeColor: UIColor = UIColor(named: .blackColorName, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!
    var strokeOpacity: CGFloat = 1.0
    weak var delegate: DrawingViewDelegate?
    var brushSharpness: CGFloat = 1.0



    private var currentBrushSettings: (width: CGFloat, color: UIColor, opacity: CGFloat, sharpness: CGFloat)?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else { return }

        for line in lines {
            context.setLineCap(.round)

            // Base properties
            let strokeColor = line.color.withAlphaComponent(line.opacity ?? 0.0)
            let mainWidth: CGFloat = line.width ?? 0.0

            // Safely unwrap points
            guard let points = line.points, points.count > 1 else { continue }

            // Draw the border
//            context.setLineWidth(mainWidth)
//            context.setStrokeColor(strokeColor.cgColor)
//            context.setShadow(offset: CGSize(width: 0.1, height: -0.1), blur: line.sharpness ?? 0.0, color: line.color.cgColor)
//
//            context.beginPath()
//            context.move(to: points[0]) // Move to the first point
//            for point in points {
//                context.addLine(to: point)
//            }
//            context.strokePath()

            // Draw the main stroke on top
            context.setStrokeColor(strokeColor.cgColor)
            context.setLineWidth(mainWidth)
            context.setShadow(offset: CGSize(width: 0.1, height: -0.1), blur: line.sharpness, color: line.color.cgColor)
            context.beginPath()
            context.move(to: points[0]) // Move to the first point again
            for point in points {
                context.addLine(to: point)
            }
            context.strokePath()
        }
        
        /*
         // Shadows
         let shadow = UIColor.black
         let shadowOffset = CGSize(width: 0.1, height: -0.1)
         let shadowBlurRadius: CGFloat = 11
         let shadow2 = UIColor.black // Here you can adjust softness of inner shadow.
         let shadow2Offset = CGSize(width: 0.1, height: -0.1)
         let shadow2BlurRadius: CGFloat = 9

         // Rectangle Drawing
         let rectanglePath = UIBezierPath(roundedRect: CGRect(x: 59, y: 58, width: 439, height: 52), cornerRadius: 21)
         context.saveGState()
         context.setShadow(offset: shadowOffset, blur: shadowBlurRadius, color: shadow.cgColor)
         UIColor.black.setFill()
         rectanglePath.fill()

         // Rectangle Inner Shadow
         context.saveGState()
         rectanglePath.addClip()
         context.setShadow(offset: CGSize.zero, blur: 0, color: nil)

         context.setAlpha(shadow2.cgColor.alpha)
 //        context.beginTransparencyLayer(self: self, auxiliaryInfo: nil)
             let opaqueShadow = shadow2.withAlphaComponent(1)
             context.setShadow(offset: shadow2Offset, blur: shadow2BlurRadius, color: opaqueShadow.cgColor)
             context.setBlendMode(.sourceOut)
             context.beginTransparencyLayer(auxiliaryInfo: nil)

             opaqueShadow.setFill()
             rectanglePath.fill()

             context.endTransparencyLayer()
         context.endTransparencyLayer()
         context.restoreGState()

         context.restoreGState()
        */
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentBrushSettings = (width: strokeWidth, color: strokeColor, opacity: strokeOpacity, sharpness: brushSharpness)
        lines.append(TouchPointsAndColor(color: strokeColor, points: [CGPoint](), width: strokeWidth, opacity: strokeOpacity, sharpness: brushSharpness))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let point = touch?.location(in: self) {
            guard var lastLine = lines.popLast() else { return }
            lastLine.points?.append(point)
            lines.append(lastLine)
            setNeedsDisplay()
        }
    }





    func reDraw(lines : [TouchPointsAndColor]) {
        self.lines = lines
        setNeedsDisplay()
    }
    func clearCanvasView() {
        lines.removeAll()
        setNeedsDisplay()
    }

    func setPaint() {
        setNeedsDisplay()
    }

    func undoDraw() {
        if lines.count > 0 {
            lines.removeLast()
            setNeedsDisplay()
        }
    }

}
