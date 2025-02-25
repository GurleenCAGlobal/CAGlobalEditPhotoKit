import UIKit

enum SeparatorType {
    case horizontal
    case vertical
}

let kTotalSize: CGFloat = 18                            // the total height of the separator (including parts that are not visible)
let kVisibleSize: CGFloat = 3                           // the height of the visible portion of the separator
let kMargin: CGFloat = (kTotalSize - kVisibleSize) / 2  // the height of the non-visible portions of the separator (i.e. above and below the visible portion)
let kMinSize: CGFloat = 32                              // the minimum height allowed for views above and below the separator
let kIndicatorSize: CGFloat = 100//36                        // size of the indicator in the middle of the separator

let when = DispatchTime.now() + 0.001 // change 2 to desired number of seconds

let collageTilesBorderWidth : CGFloat = 3
let separatorIndicatorCornerRadius : CGFloat = 3.5

var separatorColor = UIColor.clear
var collageImage = UIImage()

 let collageTilesBorderColor = UIColor(red:0.21, green:0.24, blue:0.78, alpha:1).cgColor


protocol OnConstraintsUpdateProtocol {
    func updateConstraintOnBasisOfTouch(touch: UITouch)
}

class SeparatorView: UIView {
    var startConstraint: NSLayoutConstraint?    // the constraint that dictates the vertical position of the separator
    var primaryView: UIView                     // the view above the separator
    var secondaryView: UIView                   // the view below the separator
    // Some properties used for handling the touches
    var oldPosition: CGFloat = 0.0  // the position of the separator before the gesture started
    var firstTouch: CGPoint?        // the position where the drag gesture started
    var updateListener: OnConstraintsUpdateProtocol?
    @discardableResult
    internal static func addSeparatorBetweenViews(separatorType: SeparatorType, primaryView: UIView, secondaryView: UIView, parentView: UIView) -> SeparatorView {
        
        var separator: SeparatorView
        if separatorType == .horizontal {
            separator = HorizontalSeparatorView(primaryView: primaryView, secondaryView: secondaryView)
        } else {
            separator = VerticalSeparatorView(primaryView: primaryView, secondaryView: secondaryView)
        }
        separator.setupParentViewConstraints(parentView: parentView)
        parentView.addSubview(separator)
        separator.setupSeparatorConstraints()
        
        return separator
    }
    
    init(primaryView: UIView, secondaryView: UIView) {
        self.primaryView = primaryView
        self.secondaryView = secondaryView
        super.init(frame: CGRect.zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = true
        self.backgroundColor = .clear
    }
    
    func setupParentViewConstraints(parentView: UIView) {}
    
    func setupSeparatorConstraints() {}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.firstTouch = touches.first?.location(in: self.superview)
        self.startConstraint!.constant = self.oldPosition
        self.startConstraint!.isActive = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let event = event else { return }
        
        // for more responsive UX, use predicted touches, if possible
        let predictedTouch = event.predictedTouches(for: touch)?.last
        if predictedTouch != nil {
            updateListener?.updateConstraintOnBasisOfTouch(touch: predictedTouch!)
            return
        }
        
        // if no predicted touch found, just use the touch provided
        updateListener?.updateConstraintOnBasisOfTouch(touch: touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        updateListener?.updateConstraintOnBasisOfTouch(touch: touch)
    }
    
    func drawSeparator(_ rect: CGRect, with color: UIColor) {
        color.set()
        let path = UIBezierPath(rect: rect)
        path.stroke()
        path.fill()
    }
    
    func drawIndicator(_ rect: CGRect, with color: UIColor) {
        color.set()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 5.5)
        path.stroke()
        path.fill()
    }
    
    func drawDot(_ rect: CGRect, with color: UIColor) {
        color.set()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 2.5)
        path.stroke()
        path.fill()
    }
}

class HorizontalSeparatorView: SeparatorView, OnConstraintsUpdateProtocol {
    
    override init(primaryView: UIView, secondaryView: UIView) {
        super.init(primaryView: primaryView, secondaryView: secondaryView)
        updateListener = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSeparatorConstraints() {
        self.heightAnchor.constraint(equalToConstant: kTotalSize).isActive = true
        self.superview?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.superview?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        primaryView.bottomAnchor.constraint(equalTo: self.topAnchor, constant:  kMargin + kVisibleSize / 2).isActive = true
        secondaryView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: -(kMargin + kVisibleSize / 2)).isActive = true
        startConstraint = self.topAnchor.constraint(equalTo: self.superview!.topAnchor, constant: 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.oldPosition = self.frame.origin.y
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
    
    func updateConstraintOnBasisOfTouch(touch: UITouch) {
        // Calculate where separator should be moved to
        var yAxis: CGFloat = self.oldPosition + touch.location(in: self.superview).y - self.firstTouch!.y
        // Make sure the views above and below are not too small
        yAxis = max(yAxis, self.primaryView.frame.origin.y + kMinSize - kMargin)
        yAxis = min(yAxis, self.secondaryView.frame.origin.y + self.secondaryView.frame.size.height - (kMargin + kMinSize))
        // Set constraint
        self.startConstraint!.constant = yAxis
    }
    
    override func draw(_ rect: CGRect) {
        let separatorRect = CGRect(x: 0, y: kMargin, width: self.bounds.size.width, height: kVisibleSize)
        _ = CGRect(x: (self.bounds.size.width - kIndicatorSize) / 2, y: 2.5, width: kIndicatorSize, height: 13)
        _ = CGRect(x: (self.bounds.size.width - 5) / 2, y: (self.bounds.size.height - 5) / 2, width: 5, height: 5)
        super.drawSeparator(separatorRect, with: separatorColor)
    }
}

class VerticalSeparatorView: SeparatorView, OnConstraintsUpdateProtocol {
    
    override init(primaryView: UIView, secondaryView: UIView) {
        super.init(primaryView: primaryView, secondaryView: secondaryView)
        updateListener = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSeparatorConstraints() {
        self.widthAnchor.constraint(equalToConstant: kTotalSize).isActive = true
        self.superview?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.superview?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        primaryView.trailingAnchor.constraint(equalTo: self.leadingAnchor, constant:  kMargin + kVisibleSize / 2).isActive = true
        secondaryView.leadingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(kMargin + kVisibleSize / 2)).isActive = true
        startConstraint = self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor, constant: 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.oldPosition = self.frame.origin.x
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
    
    func updateConstraintOnBasisOfTouch(touch: UITouch) {
        // calculate where separator should be moved to
        var xAxis: CGFloat = self.oldPosition + touch.location(in: self.superview).x - self.firstTouch!.x
        // make sure the views above and below are not too small
        xAxis = max(xAxis, self.primaryView.frame.origin.x + kMinSize - kMargin)
        xAxis = min(xAxis, self.secondaryView.frame.origin.x + self.secondaryView.frame.size.width - (kMargin + kMinSize))
        // set constraint
        self.startConstraint!.constant = xAxis
    }
    
    override func draw(_ rect: CGRect) {
        let separatorRect = CGRect(x: kMargin, y: 0, width: kVisibleSize, height: self.bounds.size.height)
        super.drawSeparator(separatorRect, with: separatorColor)
    }
}
