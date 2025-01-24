//
//  StickerOptions.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 08/06/23.
//

import UIKit

protocol StickerOptionsDelegate: AnyObject {
    /*
     Called when the user starts changing the opacity of the text
     */
    func opacityWillStart(_: StickerOptions, isOpen: Bool)

    /*
     Called when the user starts changing the opacity of the text
     */
    func opacityDidStart(_: StickerOptions, sliderValue: CGFloat)

    /*
     Called when the user starts the opacity of the text
     */
    func opacityClicked(isOpacity: Bool)

    /*
     Called when the user to replace Sticker
     */
    func replaceSticker(_: StickerOptions)
    /*
     Called when the user to mirror Sticker
     */
    func mirrorSticker(_: StickerOptions)
    
    /*
     Called when the user to on top Sticker
     */
    func onTopSticker(_: StickerOptions)
    
    /*
     Called when the user to apply colors
     */
    func applyColor(_: StickerOptions, colorModel: ColorModel)

    /*
     Called when the user wants further colors
     */
    func setFurtherColorSticker(color: UIColor)
    
    /*
     Called when the user to select pick color
     */
    func pickColorFromStickers(callBack: ColorCompletion)
    
    /*
     Called when the user to remove pick color
     */
    func removePickColorForColor()
    
    /*
     Called when the user to remove background color
     */
    func removeBackgroundFromImage()

    /*
     Called when the user to unremove background color
     */
    func unremoveBackgroundFromImage()
    
    /*
     Called when the user to remove pick color
     */
    func backButtonColor()
}

class StickerOptions: UIView {
    

    // MARK: Outlets
    
    // This outlet represents to the main view in the interface builder
    @IBOutlet weak var mainView: UIView!

    // This outlet represents to the collection view for selecting colors
    @IBOutlet weak var colorCollectionView: UICollectionView!

    // This outlet represents to the container view for displaying color options
    @IBOutlet weak var colorContainerView: UIView!

    // This outlet represents to the container view for displaying opacity options
    @IBOutlet weak var opacityContainerView: UIView!

    // This outlet represents to the container view for displaying general options
    @IBOutlet weak var optionContainerView: UIView!

    // This outlet represents to the container view for displaying general options
    @IBOutlet weak var colorView: UIView!
    
    // This outlet represents to the button used for color selection
    @IBOutlet weak var colorButton: UIButton!

    // This outlet represents to the button used for font selection
    @IBOutlet weak var fontButton: UIButton!

    // This outlet represents to the slider used for stickers opacity
    @IBOutlet weak var opacitySlider: UISlider!
    
    // This outlet represents the height of Opacity
    @IBOutlet weak var constraintsOpacityHeight: NSLayoutConstraint!

    // This outlet represents to the container view for picker color
    @IBOutlet weak var colorPickerView: UIView!
    
    // This outlet represents to the button used for color options selection
    @IBOutlet weak var colorOptionButton: UIButton!

    // This outlet represents to the container view for background remover
    @IBOutlet weak var removeBackgroundButton: UIButton!

    // MARK: Initialization
    weak var delegate: StickerOptionsDelegate?
    private var colorManager = ColorManager()
    private(set) var colorData = [UIColor]()
    var colorModel = ColorModel()
    var indexSelection = Int()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibSetup()
    }
    
    private func nibSetup() {
        backgroundColor = .clear
        self.mainView = loadViewFromNib()
        self.mainView.frame = bounds
        self.mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mainView.translatesAutoresizingMaskIntoConstraints = true
        addSubview(mainView)
        self.setUpViews()
        self.colorData = colorManager.getColorsData()
        let nib = UINib(nibName: TextColorCell.className, bundle: nil)
        self.colorCollectionView.register(nib, forCellWithReuseIdentifier: TextColorCell.className)
        self.colorCollectionView.dataSource = self
        self.colorCollectionView.delegate = self
        self.constraintsOpacityHeight.constant = 0
    }
    
    // MARK: Setup Methods
    
    func setUpViews() {
        self.colorContainerView.isHidden = true
        self.opacityContainerView.isHidden = true
        self.optionContainerView.isHidden = false
    }
    
    func setUpData(views : [UIView], stickerSelection: String, isFromGallery:Bool?=false,isImageDepth:Bool?=false,isBackgroundRemoved:Bool?=false) {
        self.opacityContainerView.isHidden = true
        self.colorContainerView.isHidden = true
        self.optionContainerView.isHidden = false
        self.colorView.isHidden = false
        self.removeBackgroundButton.isHidden = true
        if isFromGallery == true {
            self.colorView.isHidden = true
            if isBackgroundRemoved ?? false {
                self.removeBackgroundButton.setImage(UIImage.init(named: "removeBackground"), for: .normal)
            } else {
                self.removeBackgroundButton.setImage(UIImage.init(named: "unremoveBackground"), for: .normal)
            }
            if isImageDepth! {
                self.removeBackgroundButton.isHidden = false
            } else {
                self.removeBackgroundButton.isHidden = true
            }
        } else {
            if stickerSelection == "customSticker" || stickerSelection == "emo" || stickerSelection == "cloud" {
                self.colorView.isHidden = true
                self.removeBackgroundButton.isHidden = true
            }
            
            for _ in stickersFromApi {
                if stickerSelection == "api" {
                    self.colorView.isHidden = true
                    self.removeBackgroundButton.isHidden = true
                }
            }
        }
        
        let subViews = views
        for subview in subViews {
            if subview is AddSticker {
                if let addSticker = subview as? AddSticker {
                    if addSticker.isSelected {
                        self.opacitySlider.value = Float(addSticker.alpha)
                        self.colorButton.backgroundColor = addSticker.tintColor
                        if self.colorOptionButton.isHidden == false {
                            self.colorPickerView.backgroundColor = addSticker.tintColor
                        }
                    }
                }
            }
        }

    }
    
    func updatingColor(views : [UIView]) {
        let subViews = views
        for subview in subViews {
            if subview is AddSticker {
                if let addSticker = subview as? AddSticker {
                    if addSticker.isSelected {
                        self.opacitySlider.value = Float(addSticker.alpha)
                        self.colorButton.backgroundColor = addSticker.tintColor
                        print(addSticker.tintColor ?? UIColor.white)
                    }
                }
            }
        }
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: StickerOptions.self)
        let nib = UINib(nibName: StickerOptions.className, bundle: bundle)
        guard let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Failed to load TextView from nib.")
        }
        return nibView
    }
    
    // MARK: Actions
    
    @IBAction func actionReplaceSticker(_ sender: Any) {
        self.delegate?.replaceSticker(self)
    }
    
    @IBAction func actionMirrorSticker(_ sender: Any) {
        self.delegate?.mirrorSticker(self)
    }
    
    @IBAction func actionOnTopSticker(_ sender: Any) {
        self.delegate?.onTopSticker(self)

    }

    @IBAction func actionOnRemoveBackground(_ sender: Any) {
        if isButtonImageEqual(to: "unremoveBackground") {
            self.removeBackgroundButton.setImage(UIImage.init(named: "removeBackground"), for: .normal)
            self.delegate?.removeBackgroundFromImage()
        } else {
            self.removeBackgroundButton.setImage(UIImage.init(named: "unremoveBackground"), for: .normal)
            self.delegate?.unremoveBackgroundFromImage()
        }
    }

    func isButtonImageEqual(to imageName: String) -> Bool {
        // Get the current image of the button
        guard let currentImage = removeBackgroundButton.image(for: .normal) else {
            return false
        }
        
        // Get the image to compare
        guard let comparisonImage = UIImage(named: imageName) else {
            return false
        }
        
        // Compare the images
        return currentImage.isEqual(comparisonImage)
    }

    @IBAction func actionColorClicked(_ sender: Any) {
        self.indexSelection = -1
        self.colorContainerView.isHidden = false
        self.opacityContainerView.isHidden = true
        self.optionContainerView.isHidden = true
        self.delegate?.removePickColorForColor()
    }
    
    @IBAction func actionOpacityClicked(_ sender: Any) {
        if self.opacityContainerView.isHidden {
            self.colorContainerView.isHidden = true
            self.opacityContainerView.isHidden = false
            self.optionContainerView.isHidden = false
            self.delegate?.opacityWillStart(self, isOpen: true)
        } else {
            self.colorContainerView.isHidden = true
            self.opacityContainerView.isHidden = true
            self.optionContainerView.isHidden = false
            self.delegate?.opacityWillStart(self, isOpen: false)
        }
        self.constraintsOpacityHeight.constant = 60
        self.delegate?.opacityClicked(isOpacity: self.opacityContainerView.isHidden)
    }
    
    @IBAction func actionSliderValue(_ sender: UISlider) {
        self.delegate?.opacityDidStart(self, sliderValue: CGFloat(sender.value))
    }
    
    @IBAction func actionCrossContainer(_ sender: UISlider) {
        self.delegate?.backButtonColor()
        self.colorContainerView.isHidden = true
        self.opacityContainerView.isHidden = true
        self.optionContainerView.isHidden = false
    }
    
    @IBAction func colorpicker(_ sender: Any) {
        self.indexSelection = -1
        self.delegate?.pickColorFromStickers(callBack: {[weak self] value in
            self?.updateFontColor(color: value)
            self?.colorPickerView.backgroundColor = value
            self?.colorOptionButton.showView()
            self?.colorModel.selectedColorIndex = 100
            self?.colorModel.isColor = true
            self?.colorCollectionView.reloadData()
        })
    }
    
    func updateFontColor(color: UIColor) {
        self.colorButton.backgroundColor = color
        self.colorCollectionView.reloadData()
    }
    
    func updateFontColorPickColor(color: UIColor) {
        self.updateFontColor(color: color)
        self.colorPickerView.backgroundColor = color
        self.colorOptionButton.showView()
        self.colorModel.selectedColorIndex = 100
        self.colorModel.isColor = true
        self.colorCollectionView.reloadData()
    }
}

extension StickerOptions: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colorData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextColorCell.className, for: indexPath) as? TextColorCell else {
            let cell = TextColorCell()
            return cell
        }
        cell.delegate = self
        if colorData[indexPath.row] ==  self.colorButton.backgroundColor || colorData[indexPath.row] ==  self.colorButton.tintColor {
            cell.colorView.layer.borderWidth = 3
            cell.selectedButton.isHidden = false
            self.colorPickerView.backgroundColor = .black
            self.colorOptionButton.hideView()
        } else {
            cell.colorView.layer.borderWidth = 0.5
            cell.selectedButton.isHidden = true
        }
        cell.colorView.backgroundColor = colorData[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.indexSelection == indexPath.row {
            self.delegate?.setFurtherColorSticker(color: self.colorButton.backgroundColor!)
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as? TextColorCell
            let data = self.colorData[indexPath.row]
            self.indexSelection = indexPath.row
            cell?.handleSelectionSticker(with: data, colorModel: colorModel)
            self.colorOptionButton.hideView()
        }
    }
}

extension StickerOptions: TextColorCellDelegate {
    func didSelectCellSticker(with data: UIColor, colorModel: ColorModel) {
        colorModel.isColor = true
        colorModel.color = data
        colorModel.selectedColorIndex = self.colorModel.selectedColorIndex
        self.colorButton.backgroundColor = data
        self.colorCollectionView.reloadData()
        self.delegate?.applyColor(self, colorModel: colorModel)
    }
}
