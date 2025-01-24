import UIKit

class CircularBlurView: UIView {
    var color: UIColor?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        var rct = bounds
        rct.origin.x = 0.35 * rct.size.width
        rct.origin.y = 0.35 * rct.size.height
        rct.size.width *= 0.4
        rct.size.height *= 0.4
        
        if let color = color {
            context.setStrokeColor(color.cgColor)
        }
        context.strokeEllipse(in: rct)
        
        alpha = 1
        UIView.animate(withDuration: 0.2, delay: 1, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            self.alpha = 0
        }, completion: { _ in
            // Completion handler code
        })
    }
}
