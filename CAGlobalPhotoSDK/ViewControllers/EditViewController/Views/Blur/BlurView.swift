//
//  BlurViewDelegate.swift
//  CAPhotoEditor
//
//  Created by Gurleen Singh on 29/03/23.
//

import UIKit
import Accelerate

protocol BlurViewDelegate: AnyObject {
    /*
     Called when the user starts changing the opacity of the text
     */
    func noBlur(_: BlurView)
    
    /*
     Called when the user to replace Sticker
     */
    func blurImage(_: BlurView)
}

class BlurView: UIView {
    
    // MARK: - Outlets
    
    // Outlet for the base view of the blur view
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var noblurButton: UIButton!
    @IBOutlet weak var blurButton: UIButton!
    
    // MARK: - Initialization
    weak var delegate: BlurViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        backgroundColor = .clear
        baseView = loadViewFromNib()
        baseView.frame = bounds
        baseView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        baseView.translatesAutoresizingMaskIntoConstraints = true
        addSubview(baseView)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: BlurView.self)
        let nib = UINib(nibName: BlurView.className, bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return nibView ?? UIView()
    }
    
    @IBAction func actionNoFocus(_ sender: Any) {
        self.delegate?.noBlur(self)
        noblurButton.layer.borderWidth = 1
        noblurButton.layer.borderColor = UIColor.white.cgColor
        blurButton.layer.borderWidth = 0
        blurButton.layer.borderColor = UIColor.clear.cgColor
        noblurButton.isEnabled = false
    }
    
    @IBAction func actionBlur(_ sender: Any) {
        self.delegate?.blurImage(self)
        blurButton.layer.borderWidth = 1
        blurButton.layer.borderColor = UIColor.white.cgColor
        noblurButton.layer.borderWidth = 0
        noblurButton.layer.borderColor = UIColor.clear.cgColor
        noblurButton.isEnabled = true
    }
}
