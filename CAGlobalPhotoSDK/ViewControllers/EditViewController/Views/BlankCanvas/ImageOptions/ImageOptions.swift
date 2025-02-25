//
//  ImageOptions.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 08/06/23.
//

import UIKit

protocol ImageOptionsDelegate: AnyObject {
    /*
     Called when the user starts changing the opacity of the text
     */
    func opacityDidStartForImage(sliderValue: CGFloat)
    
    /*
     Called when the user to replace Image
     */
    func replaceImage()
}

class ImageOptions: UIView {

    // MARK: Outlets
    
    // This outlet represents to the main view in the interface builder
    @IBOutlet weak var mainView: UIView!

    // This outlet represents to the collection view for selecting colors
    @IBOutlet weak var colorCollectionView: UICollectionView!

    // This outlet represents to the collection view for selecting text options
    @IBOutlet weak var textCollectionView: UICollectionView!

    // This outlet represents to the container view for displaying font options
    @IBOutlet weak var fontContainerView: UIView!

    // This outlet represents to the container view for displaying color options
    @IBOutlet weak var colorContainerView: UIView!

    // This outlet represents to the container view for displaying opacity options
    @IBOutlet weak var opacityContainerView: UIView!

    // This outlet represents to the container view for displaying general options
    @IBOutlet weak var optionContainerView: UIView!

    // This outlet represents to the button used for color selection
    @IBOutlet weak var colorButton: UIButton!

    // This outlet represents to the button used for font selection
    @IBOutlet weak var fontButton: UIButton!

    // This outlet represents to the slider used for Images opacity
    @IBOutlet weak var opacitySlider: UISlider!
    
    // MARK: Initialization
    weak var delegate: ImageOptionsDelegate?

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
    }
    
    // MARK: Setup Methods
    
    func setUpViews() {
        colorContainerView.isHidden = true
        fontContainerView.isHidden = true
        opacityContainerView.isHidden = true
    }
    
    func setUpData(view : UIView) {
        self.opacitySlider.value = Float(view.alpha)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: ImageOptions.self)
        let nib = UINib(nibName: ImageOptions.className, bundle: bundle)
        guard let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Failed to load TextView from nib.")
        }
        return nibView
    }
    
    // MARK: Actions
    
    @IBAction func actionReplaceImage(_ sender: Any) {
        self.delegate?.replaceImage()
    }
    
    @IBAction func actionColorClicked(_ sender: Any) {
        fontContainerView.isHidden = true
        colorContainerView.isHidden = false
        opacityContainerView.isHidden = true
        optionContainerView.isHidden = true
    }
    
    @IBAction func actionOpacityClicked(_ sender: Any) {
        if opacityContainerView.isHidden {
            fontContainerView.isHidden = true
            colorContainerView.isHidden = true
            opacityContainerView.isHidden = false
            optionContainerView.isHidden = true
        } else {
            fontContainerView.isHidden = true
            colorContainerView.isHidden = true
            opacityContainerView.isHidden = true
            optionContainerView.isHidden = false
        }
    }
    
    @IBAction func actionSliderValue(_ sender: UISlider) {
        delegate?.opacityDidStartForImage(sliderValue: CGFloat(sender.value))
    }
    
    @IBAction func actionCrossContainer(_ sender: UISlider) {
        fontContainerView.isHidden = true
        colorContainerView.isHidden = true
        opacityContainerView.isHidden = true
        optionContainerView.isHidden = false
    }
}
