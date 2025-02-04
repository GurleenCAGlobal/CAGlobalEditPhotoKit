//
//  FrameOptions.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 08/06/23.
//

import UIKit

protocol FrameOptionsDelegate: AnyObject {
    /*
     Called when the user starts changing the opacity of the text
     */
    func opacityDidStart(_: FrameOptions, sliderValue: CGFloat)
    
    /*
     Called when the user to replace Frames
     */
    func replaceFrames(_: FrameOptions)
    
    /*
     Called when the user to reset Frames
     */
    func resetFrames(_: FrameOptions)
    
    /*
     Called when the user starts the opacity of the text
     */
    func opacityClicked(isOpacity: Bool)

}

class FrameOptions: UIView {

    // MARK: Outlets
    
    // This outlet represents to the main view in the interface builder
    @IBOutlet weak var mainView: UIView!

    // This outlet represents to the container view for displaying opacity options
    @IBOutlet weak var opacityContainerView: UIView!

    // This outlet represents to the container view for displaying general options
    @IBOutlet weak var optionContainerView: UIView!

    // This outlet represents to the button used for color selection
    @IBOutlet weak var opacityButton: UIButton!

    // This outlet represents to the button used for font selection
    @IBOutlet weak var fontButton: UIButton!

    // This outlet represents to the slider used for frames opacity
    @IBOutlet weak var opacitySlider: UISlider!
    
    // This outlet represents the height of Opacity
    @IBOutlet weak var constraintsOpacityHeight: NSLayoutConstraint!

    // MARK: Initialization
    weak var delegate: FrameOptionsDelegate?

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
        mainView = loadViewFromNib()
        mainView.frame = bounds
        mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainView.translatesAutoresizingMaskIntoConstraints = true
        addSubview(mainView)
        setUpViews()
        self.constraintsOpacityHeight.constant = 0
    }
    
    // MARK: Setup Methods
    
    func setUpViews() {
        opacityContainerView.isHidden = true
    }
    
    func setUpData(alpha: CGFloat, isReset: Bool) {
        self.opacitySlider.value = Float(alpha)
        self.opacityButton.isUserInteractionEnabled = !isReset
    }
    
    private func loadViewFromNib() -> UIView {
        let bundlePath = Bundle(for: FrameOptions.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = bundlePath != nil ? Bundle(path: bundlePath!) : nil

        let nib = UINib(nibName: FrameOptions.className, bundle: bundle)
        guard let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Failed to load TextView from nib.")
        }
        return nibView
    }
    
    // MARK: Actions
    
    @IBAction func actionResetFrame(_ sender: Any) {
        self.opacityButton.isEnabled = false
        self.delegate?.resetFrames(self)
    }
    
    @IBAction func actionReplaceFrame(_ sender: Any) {
        self.delegate?.replaceFrames(self)
    }
    
    @IBAction func actionOpacityClicked(_ sender: Any) {
        if opacityContainerView.isHidden {
            self.constraintsOpacityHeight.constant = 60
            opacityContainerView.isHidden = false
            optionContainerView.isHidden = false
        } else {
            self.constraintsOpacityHeight.constant = 0
            opacityContainerView.isHidden = true
            optionContainerView.isHidden = false
        }
        self.delegate?.opacityClicked(isOpacity: self.opacityContainerView.isHidden)
    }
    
    @IBAction func actionSliderValue(_ sender: UISlider) {
        delegate?.opacityDidStart(self, sliderValue: CGFloat(sender.value))
    }
    
    @IBAction func actionCrossContainer(_ sender: UISlider) {
        opacityContainerView.isHidden = true
        optionContainerView.isHidden = false
    }
}
