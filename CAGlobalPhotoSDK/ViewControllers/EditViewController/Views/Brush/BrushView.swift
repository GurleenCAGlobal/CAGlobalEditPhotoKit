//
//  BrushView.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 12/07/23.
//

import UIKit

// Define a protocol for the cell's data source
protocol BrushViewDelegate: AnyObject {
    /*
     Called when the user select any size
     */
    func setSize(sliderValue: CGFloat)
    
    /*
     Called when the user select opacity
     */
    func setOpacity(sliderValue: CGFloat)
    
    /*
     Called when the user reset
     */
    func setReset()
    
    /*
     Called when the user to apply colors
     */
    func applyColor(_: BrushView, colorModel: ColorModel)
    
    /*
     Called when the user wants further colors
     */
    func setFurtherColor()
    
    /*
     Called when the user stops changing the opacity of the text
     */
    func opacityDidEnd(sliderValue: CGFloat)
    
    /*
     Called when the user to select pick color
     */
    func pickColorForBrush(callBack: ColorCompletion)
    
    /*
     Called when the user to remove pick color
     */
    func removePickColorForBrush()
    /*
     Called when we have to show tick and cross
     */
    func tickAndCrossForSubOptionsBrush(name: String)

    // method for sharpness
    func setSharpness(sliderValue: CGFloat)
    
    func backButtonBrushSubCategory()
}

class BrushView: UIView {
    // This outlet represents to the main view in the interface builder
    @IBOutlet weak var mainView: UIView!
    
    // This outlet represents to the container view for displaying color options
    @IBOutlet weak var colorContainerView: UIView!

    // This outlet represents to the container view for displaying opacity options
    @IBOutlet weak var opacityContainerView: UIView!
    
    @IBOutlet weak var sharpnessContainerView: UIView!

    // This outlet represents to the container view for displaying size options
    @IBOutlet weak var sizeContainerView: UIView!

    // This outlet represents to the container view for displaying general options
    @IBOutlet weak var optionContainerView: UIView!
    
    @IBOutlet weak var heightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var widthConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var colorButton: UIButton!
    
    @IBOutlet weak var brushSizeLabel: UILabel!
    
    @IBOutlet weak var brushTransparencyLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var widthSlider: UISlider!
    
    @IBOutlet weak var opacitySlider: UISlider!
    
    @IBOutlet weak var sharpnessSlider: UISlider!

    @IBOutlet weak var sharpnessColorLbl: UILabel!
    // This outlet represents to the container view for picker color
    @IBOutlet weak var colorPickerView: UIView!
    
    // This outlet represents to the button used for color options selection
    @IBOutlet weak var colorOptionButton: UIButton!
    
    private var colorManager = ColorManager()
    private(set) var colorData = [UIColor]()
    let strokesArray = [#imageLiteral(resourceName: "line 1"), #imageLiteral(resourceName: "line 2"), #imageLiteral(resourceName: "line 3"), #imageLiteral(resourceName: "line 4"), #imageLiteral(resourceName: "line 5")]
    var drawingView: DrawingView?

    weak var delegate: BrushViewDelegate?
    var colorModel = ColorModel()
    var isWidth: Bool? = true 

    var selectedIndexPath: IndexPath? // Track the selected index path
    private var originalSharpness: CGFloat = 1.0

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
        colorData = colorManager.getColorsData()
        colorData.swapAt(0, colorData.count - 1)
        selectedIndexPath = IndexPath(row: 20, section: 0)
       // self.colorButton.backgroundColor = colorData[0]
        initCollectionView()
        
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: BrushView.self)
        let nib = UINib(nibName: BrushView.className, bundle: bundle)
        guard let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Failed to load TextView from nib.")
        }
        return nibView
    }
    
    private func initCollectionView() {
        let nib = UINib(nibName: TextColorCell.className, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: TextColorCell.className)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupUI() {
        originalSharpness = CGFloat(sharpnessSlider.value)

        self.brushSizeLabel.layer.cornerRadius = CGFloat(widthSlider.value)
        self.sharpnessColorLbl.layer.masksToBounds = true
        self.brushSizeLabel.layer.masksToBounds = true
        self.widthConstraints.constant = CGFloat(widthSlider.value * 2)
        self.heightConstraints.constant = CGFloat(widthSlider.value * 2)
        self.brushSizeLabel.backgroundColor = self.colorButton.backgroundColor

        self.brushTransparencyLabel.alpha = CGFloat(opacitySlider.value)
        self.sharpnessColorLbl.layer.cornerRadius = 12
        self.brushTransparencyLabel.backgroundColor = self.colorButton.backgroundColor
        self.sharpnessColorLbl.backgroundColor = self.colorButton.backgroundColor
        self.sharpnessSlider.semanticContentAttribute = .forceRightToLeft
        if self.colorButton.backgroundColor == UIColor(named: .blackColorName) {
            let indexPath1: IndexPath?
            indexPath1 = IndexPath.init(row: colorData.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath1!, at: .left, animated: true)
        }
        self.collectionView.reloadData()

    }



    @IBAction func colorpicker(_ sender: Any) {
        self.delegate?.pickColorForBrush(callBack: {[weak self] value in
            self?.selectedIndexPath = nil
            self?.colorPickerView.backgroundColor = value
            self?.sharpnessColorLbl.backgroundColor = value
            self?.brushTransparencyLabel.backgroundColor = value
            self?.brushSizeLabel.backgroundColor = value
            self?.colorOptionButton.showView()
            self?.colorModel.selectedColorIndex = 100
            self?.colorModel.isColor = true
            self?.updateFontColor(color: value)
            self?.collectionView.reloadData()
        })
    }
    
    func updateFontColor(color: UIColor) {
        self.colorButton.backgroundColor = color
        self.collectionView.reloadData()
    }
    
    func updateFontColorThroughPicker(color: UIColor) {
        self.updateFontColor(color: color)
        self.colorPickerView.backgroundColor = color
        self.colorOptionButton.showView()
        self.colorModel.selectedColorIndex = 100
        self.colorModel.isColor = true
        self.collectionView.reloadData()
    }
    
    func actionOnSubOptionTick() {
        self.sizeContainerView.isHidden = true
        self.colorContainerView.isHidden = true
        self.optionContainerView.isHidden = false
        self.opacityContainerView.isHidden = true
        self.sharpnessContainerView.isHidden = true
        self.delegate?.removePickColorForBrush()
    }
    
    @IBAction func actionColorClicked(_ sender: UISlider) {
        if colorModel.selectedColorIndex == 0 {
            self.colorButton.backgroundColor = (UIColor(named: .blackColorName)!)
        }
        if self.colorButton.backgroundColor == UIColor(named: .blackColorName) {
            let indexPath1: IndexPath?
            indexPath1 = IndexPath.init(row: colorData.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath1!, at: .left, animated: true)
        }
        self.selectedIndexPath = nil
        self.sizeContainerView.isHidden = true
        self.colorContainerView.isHidden = false
        self.optionContainerView.isHidden = true
        self.opacityContainerView.isHidden = true
        self.sharpnessContainerView.isHidden = true
        self.delegate?.tickAndCrossForSubOptionsBrush(name: "color")
        self.collectionView.reloadData()
    }
    
    @IBAction func actionBrushWidthClicked(_ sender: UISlider) {
        self.isWidth = true
        self.sizeContainerView.isHidden = false
        self.colorContainerView.isHidden = true
        self.optionContainerView.isHidden = true
        self.opacityContainerView.isHidden = true
        self.sharpnessContainerView.isHidden = true
        self.delegate?.tickAndCrossForSubOptionsBrush(name: "size")
    }
    
    @IBAction func actionBack(_ sender: UISlider) {
        
        self.sizeContainerView.isHidden = true
        self.colorContainerView.isHidden = true
        self.optionContainerView.isHidden = false
        self.opacityContainerView.isHidden = true
        self.sharpnessContainerView.isHidden = true
        self.delegate?.removePickColorForBrush()
        self.delegate?.backButtonBrushSubCategory()
    }
   
    @IBAction func actionBrushOpacityClicked(_ sender: Any) {
        self.isWidth = false
        self.sizeContainerView.isHidden = true
        self.colorContainerView.isHidden = true
        self.optionContainerView.isHidden = true
        self.opacityContainerView.isHidden = false
        self.sharpnessContainerView.isHidden = true
        self.delegate?.tickAndCrossForSubOptionsBrush(name: "transparency")
    }
    
    @IBAction func actionSharpnessClicked(_ sender: Any) {
        self.isWidth = true
        self.sizeContainerView.isHidden = true
        self.colorContainerView.isHidden = true
        self.optionContainerView.isHidden = true
        self.opacityContainerView.isHidden = true
        self.sharpnessContainerView.isHidden = false
        self.delegate?.tickAndCrossForSubOptionsBrush(name: "sharpness")
    }

    @IBAction func actionSliderValue(_ sender: UISlider, _ event: UIEvent) {
        guard let touch = event.allTouches?.first, touch.phase != .ended else {
            delegate?.opacityDidEnd(sliderValue: CGFloat(sender.value))
            return
        }

        if !sharpnessContainerView.isHidden {
            let sharpnessValue = CGFloat(sender.value)
            sharpnessColorLbl.layer.cornerRadius = CGFloat(sender.value)
            sharpnessColorLbl.backgroundColor = colorButton.backgroundColor
            sharpnessColorLbl.layer.masksToBounds = true
            sharpnessColorLbl.layer.cornerRadius = 12
            delegate?.setSharpness(sliderValue: sharpnessValue)
        } else if !sizeContainerView.isHidden {
            brushSizeLabel.layer.cornerRadius = CGFloat(sender.value)
            brushSizeLabel.layer.masksToBounds = true
            widthConstraints.constant = CGFloat(sender.value * 2)
            heightConstraints.constant = CGFloat(sender.value * 2)
            brushSizeLabel.backgroundColor = colorButton.backgroundColor
            delegate?.setSize(sliderValue: CGFloat(sender.value))
        } else if !opacityContainerView.isHidden {
            brushTransparencyLabel.alpha = CGFloat(sender.value)
            brushTransparencyLabel.backgroundColor = colorButton.backgroundColor
            delegate?.setOpacity(sliderValue: CGFloat(sender.value))
        }
    }


    func setUpPickerColor(views : [UIView], color : UIColor) {
        let subViews = views
        for subview in subViews {
            if subview is AddTextView {
                if let txtLbl = subview as? AddTextView {
                    if txtLbl.isSelected {
                        self.colorPickerView.backgroundColor = color
                        updateFontColor(color: color)
                    }
                }
            }
        }
    }
 

}

extension BrushView: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Dequeue the cell; guard clause fallback removed as it's unnecessary
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextColorCell.className, for: indexPath) as? TextColorCell else {
            fatalError("Could not dequeue TextColorCell")
        }

        cell.delegate = self
        let color = colorData[indexPath.row]
        cell.colorView.backgroundColor = color

//        // Simplified selection logic using selectedIndexPath
//        let isSelected = selectedIndexPath == indexPath
        
        var isSelect = false
        isSelect = colorData[indexPath.row] ==  self.colorButton.backgroundColor

        // Update the colorPickerView and colorOptionButton for the selected color
        if isSelect {
            self.colorPickerView.backgroundColor = .black
            self.colorOptionButton.hideView()
        }

        // Configure the cell with the color and selection state
        cell.configure(with: color, textModel: TextModel(), isSelect: isSelect, isPrevious: false)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Deselect the previously selected cell, if any
        

        // If the same cell is selected again, notify the delegate
        if selectedIndexPath?.row == indexPath.row {
            self.delegate?.setFurtherColor()
        } else {

            // Update selectedIndexPath to the new index and reload
            selectedIndexPath = indexPath
            self.colorModel.selectedColorIndex = indexPath.row

            // Notify the delegate about the brush selection
            let selectedColor = self.colorData[indexPath.row]
            if let cell = collectionView.cellForItem(at: indexPath) as? TextColorCell {
                cell.handleSelectionBrush(with: selectedColor, colorModel: self.colorModel)
            }

            // Hide the colorOptionButton after brush selection
            self.colorOptionButton.hideView()

//            // Reload the selected cell to update its appearance
//            collectionView.reloadItems(at: [indexPath])
        }
    }
}


extension BrushView: TextColorCellDelegate {
    func didSelectCellSticker(with data: UIColor, colorModel: ColorModel) {
        
    }
    
    func didSelectCell(with data: UIColor, textModel: TextModel) {
      //No Data
    }
    
    func didSelectCellBrush(with data: UIColor, colorModel: ColorModel) {
        colorModel.isColor = true
        colorModel.color = data
        colorModel.selectedColorIndex = self.colorModel.selectedColorIndex
        self.colorButton.backgroundColor = data
        self.brushSizeLabel.backgroundColor = self.colorButton.backgroundColor
        self.sharpnessColorLbl.backgroundColor = self.colorButton.backgroundColor
        self.brushTransparencyLabel.backgroundColor = self.colorButton.backgroundColor
        self.delegate?.applyColor(self, colorModel: colorModel)
        
        self.collectionView.reloadData()
    }
    func setSharpness(sliderValue: CGFloat) {
        print("Sharpness set to: \(sliderValue)")
        self.drawingView?.brushSharpness = sliderValue // Adjust sharpness value
        self.drawingView?.setNeedsDisplay() // Redraw with updated sharpness
    }

    // Ensure this method resets the sharpness when necessary
    func resetBrushSettings() {
        self.drawingView?.brushSharpness = 1.0 // Default value
        self.drawingView?.setNeedsDisplay()
    }
}
