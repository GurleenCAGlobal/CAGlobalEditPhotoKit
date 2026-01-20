//
//  TextBoxHandlers.swift
//  CAGlobalPhotoSDK
//
//  Created by Caglobal on 31/01/25.
//

import Foundation

class LShapeHandle: UIView {

    let lineWidth: CGFloat = 6
    let borderColors: UIColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1.0)

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHandle()
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        setupHandle()
    }

    func setupHandle() {
        // This method will be overridden in subclasses
    }
}
class TopLeftLShapeHandle: LShapeHandle {
    override func setupHandle() {
        let verticalLine = UIView(frame: CGRect(x: frame.width - lineWidth, y: 0, width: lineWidth, height: frame.height))
        verticalLine.backgroundColor = borderColors
        addSubview(verticalLine)

        let horizontalLine = UIView(frame: CGRect(x: 0, y: frame.height - lineWidth, width: frame.width, height: lineWidth))
        horizontalLine.backgroundColor = borderColors
        addSubview(horizontalLine)
    }
}

class TopRightLShapeHandle: LShapeHandle {
    override func setupHandle() {
        let verticalLine = UIView(frame: CGRect(x: 0, y: 0, width: lineWidth, height: frame.height))
        verticalLine.backgroundColor = borderColors
        addSubview(verticalLine)

        let horizontalLine = UIView(frame: CGRect(x: 0, y: frame.height - lineWidth, width: frame.width, height: lineWidth))
        horizontalLine.backgroundColor = borderColors
        addSubview(horizontalLine)
    }
}

class BottomRightLShapeHandle: LShapeHandle {
    override func setupHandle() {
        let verticalLine = UIView(frame: CGRect(x: 0, y: 0, width: lineWidth, height: frame.height))
        verticalLine.backgroundColor = borderColors
        addSubview(verticalLine)

        let horizontalLine = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: lineWidth))
        horizontalLine.backgroundColor = borderColors
        addSubview(horizontalLine)
    }
}

class BottomLeftLShapeHandle: LShapeHandle {
    override func setupHandle() {
        let verticalLine = UIView(frame: CGRect(x: frame.width - lineWidth, y: 0, width: lineWidth, height: frame.height))
        verticalLine.backgroundColor = borderColors
        addSubview(verticalLine)

        let horizontalLine = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: lineWidth))
        horizontalLine.backgroundColor = borderColors
        addSubview(horizontalLine)
    }
}
// Left middle resize handle
class LeftMiddleResizeHandle: LShapeHandle {
    required init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1.0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Right middle resize handle
class RightMiddleResizeHandle: LShapeHandle {
    required init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1.0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Left middle resize handle
class WideLeftMiddleResizeHandle: LShapeHandle {
    required init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Right middle resize handle
class WideRightMiddleResizeHandle: LShapeHandle {
    required init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
