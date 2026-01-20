//
//  TextView.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 17/03/23.
//

import UIKit
typealias ColorCompletion = (ColorModel) -> Void?
protocol TextViewDelegate: AnyObject {
    /*
     Called when the user starts changing the opacity of the text
     */
    func opacityWillStart(_: TextView, isOpen: Bool)

    /*
     Called when the user starts changing the opacity of the text
     */
    func opacityDidStart(_: TextView, sliderValue: CGFloat)

    /*
     Called when the user starts changing the opacity of the text
     */
    func opacityDidEnd(_: TextView, sliderValue: CGFloat)
    
    /*
     Called when the user to apply colors and font name
     */
    func selectColorAndText(_: TextView, textModel: TextModel)

    /*
     Called when the user to select pick color
     */
    func pickColor(isBackground: Bool, callBack: ColorCompletion)

    /*
     Called when the user starts changing the opacity of the text
     */
    func alignLeft()

    /*
     Called when the user starts changing the opacity of the text
     */
    func alignRight()

    /*
     Called when the user starts changing the opacity of the text
     */
    func alignCenter()

    /*
     Called when we have to show tick and cross
     */
    func tickAndCrossForSubOptions(isAlign: Bool)
    /*
     Called when the user to remove pick color
     */
    func colorPicker()
    /*
     Called when the user wants further colors
     */
    func setFurtherColorText(color: UIColor, opacity: CGFloat, isBackground: Bool)

    /*
     Called when the user to remove pick color
     */
    func backButtonColortext()

    func didChangeTextProperties(textModel: TextModel)

}


class TextView: UIView {

    // MARK: Outlets
    // This outlet represents to the main view in the interface builder
    @IBOutlet weak var mainView: UIView!

    // This outlet represents to the collection view for selecting colors
    @IBOutlet weak var colorCollectionView: UICollectionView!

    // This outlet represents to the collection view for selecting colors
    @IBOutlet weak var colorBackgroundCollectionView: UICollectionView!
    
    // This outlet represents to the collection view for selecting text options
    @IBOutlet weak var textCollectionView: UICollectionView!

    // This outlet represents to the container view for displaying font options
    @IBOutlet weak var fontContainerView: UIView!

    // This outlet represents to the container view for displaying color options
    @IBOutlet weak var colorContainerView: UIView!

    // This outlet represents to the container view for displaying color options
    @IBOutlet weak var colorBackgroundContainerView: UIView!

    // This outlet represents to the container view for displaying opacity options
    @IBOutlet weak var opacityContainerView: UIView!

    // This outlet represents to the container view for displaying general options
    @IBOutlet weak var optionContainerView: UIView!

    // This outlet represents to the container view for picker color
    @IBOutlet weak var colorPickerView: UIView!

    // This outlet represents to the container view for picker color
    @IBOutlet weak var colorBackgroundPickerView: UIView!
    
    // This outlet represents to the container view for picker color Wheel view
    @IBOutlet weak var colorPickerWheelView: UIView!

    // This outlet represents to the button used for color selection
    @IBOutlet weak var colorButton: UIButton!

    // This outlet represents to the button used for color options selection
    @IBOutlet weak var colorOptionButton: UIButton!

    // This outlet represents to the button used for color options selection
    @IBOutlet weak var colorBackgroundOptionButton: UIButton!
    
    // This outlet represents to the button used for font selection
    @IBOutlet weak var fontButton: UIButton!

    // This outlet represents to the button used for color back button
    @IBOutlet weak var colorBackButton: UIButton!

    // This outlet represents to the button used for font back button
    @IBOutlet weak var fontBackButton: UIButton!

    // This outlet represents to the button used for font selection
    @IBOutlet weak var alignmentButton: UIButton!

    // This outlet represents to the slider used for text opacity
    @IBOutlet weak var opacitySlider: UISlider!

    // This outlet represents the pick image view
    @IBOutlet weak var pickImageView: UIImageView!

    // This outlet represents the bottom of main view
    @IBOutlet weak var constraintsWidthColorPicker: NSLayoutConstraint!

    // This outlet represents the bottom of main view
    @IBOutlet weak var constraintsWidthColorPickerBackground: NSLayoutConstraint!

    
    // This outlet represents the bottom of main view
    @IBOutlet weak var constraintsWidthBack: NSLayoutConstraint!

    // This outlet represents the bottom of main view
    @IBOutlet weak var constraintsLeading: NSLayoutConstraint!
    
    // This outlet represents the width of color
    @IBOutlet weak var constraintsColorWidthBack: NSLayoutConstraint!

    // This outlet represents the width of color picker button
    @IBOutlet weak var constraintsColorWheelWidthBack: NSLayoutConstraint!

    // This outlet represents the width of font back button
    @IBOutlet weak var backBtn: UIButton!

    // This outlet represents to the image used for color wheel selection
    @IBOutlet weak var colorWheelImage: UIImageView!

    // This outlet represents to the image used for color wheel selection
    @IBOutlet weak var colorWheelSelectedImage: UIImageView!
    
    // This outlet represents to the image used for color wheel selection
    @IBOutlet weak var colorBackWheelImage: UIImageView!

    // This outlet represents to the image used for color wheel selection
    @IBOutlet weak var colorBackWheelSelectedImage: UIImageView!

    // MARK: Properties
    weak var delegate: TextViewDelegate?
    var textModel = TextModel()
    private var editViewModel = CAEditViewModel()
    private var colorManager = ColorManager()
    private var fontManager = FontManager()
    private(set) var colorData = [UIColor]()
    private(set) var fontData = [String]()
    var isColorPicker = true
    var isTextViewController = false
    var isColorText = false
    var indexSelection = Int()
    var indexBackgroundSelection = Int()
    // Call this method when you want to update the text properties
    func updateTextProperties() {
        // Notify the delegate (TextViewController) of the changes
        delegate?.didChangeTextProperties(textModel: textModel)
    }


    @objc func handleFontColorUpdate(_ notification: Notification) {
        let color = (notification.userInfo?["color"] as? UIColor) ?? UIColor.black
        updateFontColor(color: color)
    }

    @objc func handleFontUpdate(_ notification: Notification) {
        let fontIndex = (notification.userInfo?["fontIndex"] as? Int)
        updateFont(index: fontIndex ?? 0)
    }

    @objc func handleOpacityUpdate(_ notification: Notification) {
        let fontOpacity = (notification.userInfo?["opacity"] as? CGFloat)
        self.opacitySlider.value = Float(fontOpacity ?? 1)
    }

    @objc func handlealignmentUpdate(_ notification: Notification) {
        let fontAlignment = (notification.userInfo?["alignment"] as? NSTextAlignment)
        switch fontAlignment {
        case .center:
            self.alignmentButton.setImage(UIImage(named: "alignCenter"), for: .normal)
        case .right:
            self.alignmentButton.setImage(UIImage(named: "alignRight"), for: .normal)
        case .left:
            self.alignmentButton.setImage(UIImage(named: "alignLeft"), for: .normal)
        default:
            break
        }
    }


    // MARK: Initialization

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
        initCollectionView()
        setUpViews()
        setUpData()
        NotificationCenter.default.addObserver(self, selector: #selector(handleFontColorUpdate(_:)), name: NSNotification.Name("FontColorUpdateNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFontUpdate(_:)), name: NSNotification.Name("FontUpdateNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpacityUpdate(_:)), name: NSNotification.Name("OpacityUpdateNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlealignmentUpdate(_:)), name: NSNotification.Name("alignmentUpdateNotification"), object: nil)


    }

    // MARK: Setup Methods
    func setUpViews() {
        if self.isColorPicker == false {
            self.constraintsWidthColorPicker.constant = 0
            self.constraintsWidthColorPickerBackground.constant = 0
            self.constraintsColorWheelWidthBack.constant = 0
        }
        self.colorContainerView.hideView()
        self.fontContainerView.hideView()
        self.opacityContainerView.hideView()
        self.colorBackgroundContainerView.hideView()
        self.pickImageView.layer.masksToBounds = true
        self.pickImageView.layer.shadowColor = UIColor.gray.cgColor
        self.pickImageView.layer.shadowOffset = CGSizeMake(0, 1)
        self.pickImageView.layer.shadowOpacity = 1
        self.pickImageView.layer.shadowRadius = 1.0
    }

    func setUpColorPickerViews(iscolorpciker: Bool,isTextViewController: Bool) {
        self.colorBackButton.isHidden = false
        self.constraintsLeading.constant = 20
        self.constraintsWidthBack.constant = 30
        self.constraintsColorWidthBack.constant = 30
        self.constraintsColorWheelWidthBack.constant = 40

        if iscolorpciker == false {
            self.constraintsWidthColorPicker.constant = 0
            self.constraintsWidthColorPickerBackground.constant = 0
            //self.constraintsColorWheelWidthBack.constant = 0
        }
    }

    func setUpData() {
        self.colorData = self.colorManager.getColorsData()
        self.fontData = self.fontManager.getFontsData()
    }

    func setUpTextAndColorTextEdit(textModel : TextModel, fontName: String) {
        self.textModel.selectedColorIndex = textModel.selectedColorIndex
        self.textModel.color = textModel.color
        self.textModel.previousColor = textModel.previousColor
        self.textModel.previousSelectedColorIndex = textModel.previousSelectedColorIndex
        self.textModel.selectedFontIndex = textModel.selectedFontIndex
        self.textModel.previousSelectedFontIndex = textModel.previousSelectedFontIndex
        self.textModel.fontCustom = textModel.fontCustom
        self.textModel.previousFont = textModel.previousFont
        self.textModel.textString = textModel.textString
        self.textModel.previousTextString = textModel.previousTextString
        self.fontButton.titleLabel?.font = UIFont(name: fontName, size: 36)
        
        self.textModel.selectedBackGrounfColorIndex = textModel.selectedBackGrounfColorIndex
        self.textModel.backgroungColor = textModel.backgroungColor
        self.textModel.previousBackgroundColor = textModel.previousBackgroundColor
        self.textModel.previousSelectedBackgroundColorIndex = textModel.previousSelectedBackgroundColorIndex

        
        if textModel.selectedColorIndex == 101 {
            self.colorOptionButton.showView()
            self.colorButton.backgroundColor = textModel.color
            self.colorPickerView.backgroundColor = textModel.color
        } else {
            self.colorButton.backgroundColor = textModel.color
        }
        
        if textModel.selectedBackGrounfColorIndex == 101 {
            self.colorBackgroundOptionButton.showView()
            self.colorBackWheelImage.image = UIImage(named: "Color Wheel - Selected")
            self.colorBackWheelSelectedImage.backgroundColor = textModel.backgroungColor

        } else {
            if textModel.color == .clear {
                self.textModel.selectedBackGrounfColorIndex = -1
            }
        }
        if textModel.alignment == .center {
            self.alignmentButton.setImage(UIImage.init(named: "alignCenter"), for: .normal)
            //self.delegate?.alignCenter()
        } else if textModel.alignment == .right {
            self.alignmentButton.setImage(UIImage.init(named: "alignRight"), for: .normal)
            //self.delegate?.alignRight()
        } else if textModel.alignment == .left {
            self.alignmentButton.setImage(UIImage.init(named: "alignLeft"), for: .normal)
            //self.delegate?.alignLeft()
        }
        self.opacitySlider.value = Float(textModel.opacity)
        self.textCollectionView.reloadData()
        self.colorCollectionView.reloadData()
    }
    
    func setUpTextAndColorTextEditColor(textModel : TextModel, fontName: String) {
        self.textModel.selectedColorIndex = textModel.selectedColorIndex
        self.textModel.color = textModel.color
        self.textModel.previousColor = textModel.previousColor
        self.textModel.previousSelectedColorIndex = textModel.previousSelectedColorIndex
        self.textModel.selectedFontIndex = textModel.selectedFontIndex
        self.textModel.previousSelectedFontIndex = textModel.previousSelectedFontIndex
        self.textModel.fontCustom = textModel.fontCustom
        self.textModel.previousFont = textModel.previousFont
        self.textModel.textString = textModel.textString
        self.textModel.previousTextString = textModel.previousTextString
        self.fontButton.titleLabel?.font = UIFont(name: fontName, size: 36)
        
        self.textModel.selectedBackGrounfColorIndex = textModel.selectedBackGrounfColorIndex
        self.textModel.backgroungColor = textModel.backgroungColor
        self.textModel.previousBackgroundColor = textModel.previousBackgroundColor
        self.textModel.previousSelectedBackgroundColorIndex = textModel.previousSelectedBackgroundColorIndex

        
        if textModel.selectedColorIndex == 101 {
            self.colorOptionButton.showView()
            self.colorButton.backgroundColor = textModel.color
            self.colorPickerView.backgroundColor = textModel.color
        } else {
            self.colorButton.backgroundColor = textModel.color
        }
        
        
        if textModel.alignment == .center {
            self.alignmentButton.setImage(UIImage.init(named: "alignCenter"), for: .normal)
            //self.delegate?.alignCenter()
        } else if textModel.alignment == .right {
            self.alignmentButton.setImage(UIImage.init(named: "alignRight"), for: .normal)
            //self.delegate?.alignRight()
        } else if textModel.alignment == .left {
            self.alignmentButton.setImage(UIImage.init(named: "alignLeft"), for: .normal)
            //self.delegate?.alignLeft()
        }
        self.opacitySlider.value = Float(textModel.opacity)
        self.textCollectionView.reloadData()
        self.colorCollectionView.reloadData()
    }
    
    func setUpTextAndColorTextEditBackground(textModel : TextModel, fontName: String) {
        self.textModel.selectedColorIndex = textModel.selectedColorIndex
        self.textModel.color = textModel.color
        self.textModel.previousColor = textModel.previousColor
        self.textModel.previousSelectedColorIndex = textModel.previousSelectedColorIndex
        self.textModel.selectedFontIndex = textModel.selectedFontIndex
        self.textModel.previousSelectedFontIndex = textModel.previousSelectedFontIndex
        self.textModel.fontCustom = textModel.fontCustom
        self.textModel.previousFont = textModel.previousFont
        self.textModel.textString = textModel.textString
        self.textModel.previousTextString = textModel.previousTextString
        self.fontButton.titleLabel?.font = UIFont(name: fontName, size: 36)
        
        self.textModel.selectedBackGrounfColorIndex = textModel.selectedBackGrounfColorIndex
        self.textModel.backgroungColor = textModel.backgroungColor
        self.textModel.previousBackgroundColor = textModel.previousBackgroundColor
        self.textModel.previousSelectedBackgroundColorIndex = textModel.previousSelectedBackgroundColorIndex
        
        if textModel.selectedBackGrounfColorIndex == 101 {
            self.colorBackgroundOptionButton.showView()
            self.colorBackWheelImage.image = UIImage(named: "Color Wheel - Selected")
            self.colorBackWheelSelectedImage.backgroundColor = textModel.backgroungColor

        } else {
            if textModel.color == .clear {
                self.textModel.selectedBackGrounfColorIndex = -1
            }
        }
        if textModel.alignment == .center {
            self.alignmentButton.setImage(UIImage.init(named: "alignCenter"), for: .normal)
            //self.delegate?.alignCenter()
        } else if textModel.alignment == .right {
            self.alignmentButton.setImage(UIImage.init(named: "alignRight"), for: .normal)
            //self.delegate?.alignRight()
        } else if textModel.alignment == .left {
            self.alignmentButton.setImage(UIImage.init(named: "alignLeft"), for: .normal)
            //self.delegate?.alignLeft()
        }
        self.opacitySlider.value = Float(textModel.opacity)
        self.textCollectionView.reloadData()
        self.colorCollectionView.reloadData()
    }

    func updateSubOptionsPropertiesUndoRedo(textModel: TextModel) {
        // Update Text Alignment
        switch textModel.alignment {
        case .center:
            self.alignmentButton.setImage(UIImage(named: "alignCenter"), for: .normal)
            self.delegate?.alignCenter()
        case .right:
            self.alignmentButton.setImage(UIImage(named: "alignRight"), for: .normal)
            self.delegate?.alignRight()
        case .left:
            self.alignmentButton.setImage(UIImage(named: "alignLeft"), for: .normal)
            self.delegate?.alignLeft()
        default:
            break
        }

        // Update Opacity
        self.opacitySlider.value = Float(textModel.opacity)

        // Example: Update Font (if applicable)
//        if let fontName = textModel.fontName {
//            self.textView.font = UIFont(name: fontName, size: CGFloat(textModel.fontSize))
//        }
//
//        // Example: Update Text Color (if applicable)
//        if let textColor = textModel.textColor {
//            self.textView.textColor = textColor
//        }

        // Refresh collection view (assuming this shows fonts or colors)
        self.textCollectionView.reloadData()
    }


    func updateTextProperties(_ textView: AddTextView) {
        // Capture the current state before changing
        let oldState = self.textModel.copyState()

        // Update the text properties
        self.textModel.selectedColorIndex = textView.selectedColorIndex
        self.textModel.color = textView.selectedColor
        self.textModel.fontCustom = textView.selectedFont
        self.textModel.textString = textView.text ?? ""
        self.textModel.alignment = textView.textAlignment
        self.textModel.opacity = textView.alpha

        // Clear redo stack after new changes
    }

    func restoreState(_ previousState: TextModel) {
        // Restore previous state
        self.textModel.textString = previousState.textString
        self.textModel.fontCustom = previousState.previousFont
        self.textModel.color = previousState.color
        self.textModel.alignment = previousState.alignment
        self.textModel.opacity = previousState.opacity

        // Update the UI based on the restored state
        updateUIWithModel(self.textModel)
    }

    func updateUIWithModel(_ model: TextModel) {
        self.colorButton.backgroundColor = model.color
        self.fontButton.titleLabel?.font = UIFont(name: model.fontCustom, size: 16)
        // Update other UI components
    }

    func setUpTextAndColor(views: [UIView]) {
        var addTextViews: [AddTextView] = []

        for subview in views {
            if let txtLbl = subview as? AddTextView {
                // Only perform the updates if the text view is selected
                if txtLbl.isSelected {
                    // Capture the current state for undo functionality
                    _ = textModel
                    addTextViews.append(txtLbl)
                    self.textModel.selectedColorIndex = txtLbl.selectedColorIndex
                    self.textModel.color = txtLbl.selectedColor
                    self.textModel.previousColor = txtLbl.previousColor
                    self.textModel.previousSelectedColorIndex = txtLbl.previousSelectedColorIndex
                    self.textModel.selectedFontIndex = txtLbl.selectedFontIndex
                    self.textModel.previousSelectedFontIndex = txtLbl.selectedPreviousFontIndex
                    self.textModel.fontCustom = txtLbl.selectedFont
                    self.textModel.previousFont = txtLbl.selectedPreviousFont
                    self.textModel.textString = txtLbl.selectedText
                    self.textModel.previousTextString = txtLbl.previousText

                    self.textModel.selectedBackGrounfColorIndex = txtLbl.selectedBackGrounfColorIndex
                    self.textModel.backgroungColor = txtLbl.selectedBackgroundColor
                    self.textModel.previousBackgroundColor = txtLbl.previousBackgroundColor
                    self.textModel.previousSelectedBackgroundColorIndex = txtLbl.previousSelectedBackgroundColorIndex

                    self.fontButton.titleLabel?.font = UIFont(name: txtLbl.font.fontName, size: 16)
                    self.colorWheelSelectedImage.backgroundColor = nil
                    self.colorWheelImage.image = UIImage(named: "colorWheel")
                    self.colorPickerView.backgroundColor = .clear
                    if txtLbl.selectedColorIndex == 100 {
                        self.colorOptionButton.showView()
                        self.colorButton.backgroundColor = txtLbl.textColor
                        self.colorPickerView.backgroundColor = txtLbl.textColor
                        self.colorBackgroundPickerView.backgroundColor = txtLbl.backgroundColor
                    } else if txtLbl.selectedColorIndex == 101 {
                        self.colorWheelImage.image = UIImage(named: "Color Wheel - Selected")
                        self.colorWheelSelectedImage.backgroundColor = txtLbl.textColor
                        self.colorOptionButton.hideView()
                        self.colorButton.backgroundColor = txtLbl.textColor
                    } else {
                        self.colorButton.backgroundColor = txtLbl.textColor
                    }
                    
                    if txtLbl.selectedBackGrounfColorIndex == 100 {
                        self.colorBackgroundOptionButton.showView()
                        self.colorBackgroundPickerView.backgroundColor = txtLbl.backgroundColor
                    } else if txtLbl.selectedBackGrounfColorIndex == 101 {
                        self.colorBackWheelImage.image = UIImage(named: "Color Wheel - Selected")
                        self.colorBackWheelSelectedImage.backgroundColor = txtLbl.backgroundColor
                        self.colorBackgroundOptionButton.hideView()
                    } else {
                        if txtLbl.backgroundColor == .clear {
                            txtLbl.selectedBackGrounfColorIndex = -1
                            self.textModel.selectedBackGrounfColorIndex = txtLbl.selectedBackGrounfColorIndex

                        }
                        //self.colorButton.backgroundColor = txtLbl.textColor
                    }
                    // Update alignment buttons and notify the delegate
                    if txtLbl.textAlignment == .center {
                        self.alignmentButton.setImage(UIImage(named: "alignCenter"), for: .normal)
                        //self.delegate?.alignCenter()
                    } else if txtLbl.textAlignment == .right {
                        self.alignmentButton.setImage(UIImage(named: "alignRight"), for: .normal)
                        //self.delegate?.alignRight()
                    } else if txtLbl.textAlignment == .left {
                        self.alignmentButton.setImage(UIImage(named: "alignLeft"), for: .normal)
                        //self.delegate?.alignLeft()
                    }
                }
            }
        }
        self.textCollectionView.reloadData()
        self.colorCollectionView.reloadData()
        self.colorBackgroundCollectionView.reloadData()
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
    
    func setUpPickerBackGroundColor(views : [UIView], color : UIColor) {
        let subViews = views
        for subview in subViews {
            if subview is AddTextView {
                if let txtLbl = subview as? AddTextView {
                    if txtLbl.isSelected {
                        self.colorBackgroundPickerView.backgroundColor = color
                        self.colorBackgroundCollectionView.reloadData()
                    }
                }
            }
        }
    }

    func setUpOpacity(views : [UIView]) {
        self.constraintsLeading.constant = 0
        self.colorBackButton.isHidden = false
        let subViews = views
        for subview in subViews {
            if subview is AddTextView {
                if let addText = subview as? AddTextView {
                    if addText.isSelected {
                        self.opacitySlider.value = Float(addText.alpha)
                    }
                }
            }
        }
    }
    
    func setUpAlignment(views : [UIView]) {
        let subViews = views
        for subview in subViews {
            if subview is AddTextView {
                if let addText = subview as? AddTextView {
                    if addText.isSelected {
                        if addText.textAlignment == .center {
                            self.alignmentButton.setImage(UIImage.init(named: "alignCenter"), for: .normal)
                        } else if addText.textAlignment == .right {
                            self.alignmentButton.setImage(UIImage.init(named: "alignRight"), for: .normal)
                        } else if addText.textAlignment == .left {
                            self.alignmentButton.setImage(UIImage.init(named: "alignLeft"), for: .normal)
                        }
                    }
                }
            }
        }
    }

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: TextView.self)
        let nib = UINib(nibName: TextView.className, bundle: bundle)
        guard let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Failed to load TextView from nib.")
        }
        return nibView
    }

    private func initCollectionView() {
        let nib = UINib(nibName: TextColorCell.className, bundle: nil)
        self.colorCollectionView.register(nib, forCellWithReuseIdentifier: TextColorCell.className)
        self.colorCollectionView.dataSource = self
        self.colorCollectionView.delegate = self

        let nibBackground = UINib(nibName: TextColorCell.className, bundle: nil)
        self.colorBackgroundCollectionView.register(nibBackground, forCellWithReuseIdentifier: TextColorCell.className)
        self.colorBackgroundCollectionView.dataSource = self
        self.colorBackgroundCollectionView.delegate = self
        
        let nib2 = UINib(nibName: TextFontCell.className, bundle: nil)
        textCollectionView.register(nib2, forCellWithReuseIdentifier: TextFontCell.className)
        textCollectionView.dataSource = self
        textCollectionView.delegate = self
    }

    func updateFont(index: Int) {
        self.fontButton.titleLabel?.font = UIFont(name: fontData[index], size: 36)
        self.textCollectionView.reloadData()
    }

    func updateFontColor(color: UIColor) {
        self.colorButton.backgroundColor = color
        self.colorCollectionView.reloadData()
    }

    // MARK: Actions
    @IBAction func actionDeleteClicked(_ sender: Any) {
        // for delete the text and any changes in text
    }

    @IBAction func actionBackClicked(_ sender: Any) {
        fontContainerView.hideView()
        colorContainerView.hideView()
        opacityContainerView.hideView()
        optionContainerView.showView()
        colorBackgroundContainerView.hideView()
        self.delegate?.backButtonColortext()
    }
    @IBAction func actionOpacityBackClicked(_ sender: Any) {
        fontContainerView.hideView()
        colorContainerView.hideView()
        opacityContainerView.hideView()
        optionContainerView.showView()
        self.delegate?.backButtonColortext()
    }

    @IBAction func actionFontClicked(_ sender: Any) {
        if self.isTextViewController == true {
            self.fontBackButton.isHidden = false
        } else {
            self.fontBackButton.isHidden = false
        }
        fontContainerView.showView()
        colorContainerView.hideView()
        opacityContainerView.hideView()
        optionContainerView.hideView()
        self.delegate?.tickAndCrossForSubOptions(isAlign: false)
    }

    @IBAction func actionColorClicked(_ sender: Any) {
        self.colorCollectionView.reloadData()
        self.isColorText = true
        if textModel.selectedColorIndex == 0 {
            self.colorButton.backgroundColor = (UIColor(named: .blackColorName)!)
        }
        self.indexSelection = -1
        if self.isTextViewController == true {
            //self.constraintsColorWidthBack.constant = 30
            self.colorBackButton.isHidden = false
            self.colorPickerView.isHidden = true
            self.colorPickerWheelView.isHidden = false
        } else {
            self.colorBackButton.isHidden = false
            self.colorPickerView.isHidden = false
            self.colorPickerWheelView.isHidden = false
        }
        
        fontContainerView.hideView()
        colorContainerView.showView()
        opacityContainerView.hideView()
        optionContainerView.hideView()
        self.delegate?.tickAndCrossForSubOptions(isAlign: false)
        self.colorCollectionView.reloadData()
    }

    @IBAction func actionBackgroundClicked(_ sender: Any) {
        self.colorBackgroundCollectionView.reloadData()
        self.isColorText = false
        self.indexBackgroundSelection = -1
        if self.isTextViewController == true {
            //self.constraintsColorWidthBack.constant = 30
            self.colorBackButton.isHidden = false
            self.colorBackgroundPickerView.isHidden = true
            self.colorPickerWheelView.isHidden = false
        } else {
            self.colorBackButton.isHidden = false
            self.colorBackgroundPickerView.isHidden = false
            self.colorPickerWheelView.isHidden = false
        }
        
        fontContainerView.hideView()
        colorContainerView.hideView()
        opacityContainerView.hideView()
        optionContainerView.hideView()
        colorBackgroundContainerView.showView()
        self.delegate?.tickAndCrossForSubOptions(isAlign: false)
        self.colorBackgroundCollectionView.reloadData()
    }
    
    @IBAction func actionOpacityClicked(_ sender: Any) {
        if opacityContainerView.isHidden {
            fontContainerView.hideView()
            colorContainerView.hideView()
            opacityContainerView.showView()
            optionContainerView.hideView()
            self.delegate?.opacityWillStart(self, isOpen: true)
        } else {
            fontContainerView.hideView()
            colorContainerView.hideView()
            opacityContainerView.hideView()
            optionContainerView.showView()
//            opacityContainerView.hideView()
//            optionContainerView.showView()
            self.delegate?.opacityWillStart(self, isOpen: false)
        }

    }

    @IBAction func actionAlignment(_ sender: UIButton) {
        opacityContainerView.hideView()
        if self.alignmentButton.currentImage?.description.contains("alignLeft") == true {
            self.alignmentButton.setImage(UIImage.init(named: "alignCenter"), for: .normal)
            self.delegate?.alignCenter()
        } else if self.alignmentButton.currentImage?.description.contains("alignCenter") == true {
            self.alignmentButton.setImage(UIImage.init(named: "alignRight"), for: .normal)
            self.delegate?.alignRight()
        } else if self.alignmentButton.currentImage?.description.contains("alignRight") == true {
            self.alignmentButton.setImage(UIImage.init(named: "alignLeft"), for: .normal)
            self.delegate?.alignLeft()
        }
        self.delegate?.tickAndCrossForSubOptions(isAlign: true)
    }

    @IBAction func actionSliderValue(_ sender: UISlider) {
        delegate?.opacityDidStart(self, sliderValue: CGFloat(sender.value))
    }
    
    @IBAction func actionSliderValueEnd(_ sender: UISlider) {
        delegate?.opacityDidEnd(self, sliderValue: CGFloat(sender.value))
    }
    
    @IBAction func actionColorPicker(_ sender: UISlider) {
        self.indexSelection = -1
        if self.isColorText == false {
            self.delegate?.pickColor(isBackground: true, callBack: {[weak self] value in
                //self?.updateFontColor(color: value.color)
                self?.colorPickerView.backgroundColor = value.color
                self?.colorOptionButton.showView()
                self?.textModel.selectedColorIndex = 100
                self?.textModel.isColor = true
                self?.colorWheelSelectedImage.backgroundColor = nil
                self?.colorWheelImage.image = UIImage(named: "colorWheel")
                self?.colorCollectionView.reloadData()
            })
        } else {
            self.delegate?.pickColor(isBackground: false, callBack: {[weak self] value in
                self?.updateFontColor(color: value.color)
                self?.colorPickerView.backgroundColor = value.color
                self?.colorOptionButton.showView()
                self?.textModel.selectedColorIndex = 100
                self?.textModel.isColor = true
                self?.colorWheelSelectedImage.backgroundColor = nil
                self?.colorWheelImage.image = UIImage(named: "colorWheel")
                self?.colorCollectionView.reloadData()
            })
        }
    }
    
    @IBAction func actionBackgroundColorPicker(_ sender: UISlider) {
        self.indexBackgroundSelection = -1
        self.delegate?.pickColor(isBackground: true, callBack: {[weak self] value in
            self?.colorBackgroundPickerView.backgroundColor = value.color
            self?.colorBackgroundOptionButton.showView()
            self?.textModel.selectedBackGrounfColorIndex = 100
            self?.textModel.isBackgroundColor = true
            self?.colorBackWheelSelectedImage.backgroundColor = nil
            self?.colorBackWheelImage.image = UIImage(named: "colorWheel")
            self?.colorBackgroundCollectionView.reloadData()
        })
    }

    @IBAction func wheelColorpicker(_ sender: Any) {
        self.indexSelection = -1
        
        if self.isColorText == false {
            self.delegate?.setFurtherColorText(color: self.textModel.color, opacity: self.textModel.opacity, isBackground: true)


            self.colorWheelImage.image = UIImage(named: "Color Wheel - Selected")
            self.colorWheelSelectedImage.backgroundColor = self.textModel.color
            //self.colorPickerView.backgroundColor = self.textModel.color
            self.colorOptionButton.hideView()
            self.textModel.selectedColorIndex = 101
            self.textModel.isColor = true
            self.colorBackgroundPickerView.backgroundColor = .clear
            self.delegate?.colorPicker()
            self.delegate?.selectColorAndText(self, textModel: textModel)
          //  self.colorWheelSelectedImage.backgroundColor = self.colorButton.backgroundColor
        } else {
            self.delegate?.setFurtherColorText(color: self.textModel.color, opacity: self.textModel.opacity, isBackground: false)


            self.colorWheelImage.image = UIImage(named: "Color Wheel - Selected")
            self.colorWheelSelectedImage.backgroundColor = self.textModel.color
            //self.colorPickerView.backgroundColor = self.textModel.color
            self.colorOptionButton.hideView()
            self.textModel.selectedColorIndex = 101
            self.textModel.isColor = true
            self.colorPickerView.backgroundColor = .clear
            self.delegate?.colorPicker()
            self.delegate?.selectColorAndText(self, textModel: textModel)
          //  self.colorWheelSelectedImage.backgroundColor = self.colorButton.backgroundColor
        }
    }
    
    @IBAction func wheelBackgroundColorpicker(_ sender: Any) {
        self.indexBackgroundSelection = -1
        
        self.delegate?.setFurtherColorText(color: self.textModel.backgroungColor, opacity: self.textModel.opacity, isBackground: true)
        
        self.colorBackWheelImage.image = UIImage(named: "Color Wheel - Selected")
        self.colorBackWheelSelectedImage.backgroundColor = self.textModel.backgroungColor
        self.colorBackgroundOptionButton.hideView()
        self.textModel.selectedBackGrounfColorIndex = 101
        self.textModel.isBackgroundColor = true
        self.colorBackgroundPickerView.backgroundColor = .clear
        self.delegate?.colorPicker()
        self.delegate?.selectColorAndText(self, textModel: textModel)
    }

    func actionCrossForText() {
        fontContainerView.hideView()
        colorContainerView.hideView()
        opacityContainerView.hideView()
        optionContainerView.showView()
        colorBackgroundContainerView.hideView()
    }

    func addText(delegate: UIViewController, frame: CGRect, text: String, font: UIFont, color: UIColor , isTransform: Bool, transform: CGAffineTransform, tag: Int) -> AddTextView {
        let customView = AddTextView(frame: frame)
        customView.delegate = delegate as? any AddTextViewDelegate
        customView.text = text
        customView.font = font
        customView.textColor = color
        if isTransform {
            customView.transform = CGAffineTransformIdentity
            customView.transform = transform
        }
        customView.tag = tag
        return customView
    }
}

extension TextView: TextColorCellDataSource {
    func getColor() -> [UIColor] {
        // Return the color for the cell at the specified index path
        return colorData
    }
}

extension TextView: TextColorCellDelegate {
    func didSelectCell(with data: UIColor, textModel: TextModel, isTextColor: Bool) {
        if isTextColor {
            textModel.isColor = true
            textModel.isBackgroundColor = false
            self.updateFontColor(color: textModel.color)
        } else {
            textModel.isColor = false
            textModel.isBackgroundColor = true
        }
        self.delegate?.selectColorAndText(self, textModel: textModel)
        
    }
}

extension TextView: TextFontCellDelegate {
    func didSelectFontCell(with data: String, textModel: TextModel) {
        textModel.isColor = false
        textModel.isBackgroundColor = false
        textModel.selectedColorIndex = self.textModel.selectedColorIndex
        textModel.previousSelectedColorIndex = self.textModel.previousSelectedColorIndex

        textModel.fontCustom = data
        textModel.selectedFontIndex = self.textModel.selectedFontIndex
        textModel.previousFont = self.textModel.previousFont
        textModel.previousSelectedFontIndex = self.textModel.previousSelectedFontIndex

        self.colorOptionButton.hideView()
        self.updateFont(index: self.textModel.selectedFontIndex)
        self.delegate?.selectColorAndText(self, textModel: textModel)
    }
}

extension TextView: TextFontCellDataSource {
    func getFont() -> [String] {
        // Return the font for the cell at the specified index path
        return fontData
    }
}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension TextView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case colorCollectionView:
            return colorData.count
        case colorBackgroundCollectionView:
            return colorData.count + 1
        case textCollectionView:
            return fontData.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case colorCollectionView:
            return CGSize(width: 38, height: 56)
        case colorBackgroundCollectionView:
            return CGSize(width: 38, height: 56)
        case textCollectionView:
            return CGSize(width: 50, height: 50)
        default:
            return CGSize(width: 0, height: 0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case colorCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextColorCell.className, for: indexPath) as? TextColorCell else {
                let cell = TextColorCell()
                return cell
            }
            
            cell.delegate = self
            cell.dataSource = self
            
                cell.noColorView.isHidden = true
                let data = self.colorData[indexPath.row]
                var isSelect = false
                if self.textModel.selectedColorIndex == 100 {
                    isSelect = false
                } else if self.textModel.selectedColorIndex == 101 {
                    isSelect = false
                } else {
                    self.colorOptionButton.hideView()
                    isSelect = colorData[indexPath.row] ==  self.colorButton.backgroundColor
                }
                cell.configure(with: data, textModel: self.textModel, isSelect: isSelect, isPrevious: indexPath.row == self.colorData.count - 1)
            
            return cell
        case colorBackgroundCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextColorCell.className, for: indexPath) as? TextColorCell else {
                let cell = TextColorCell()
                return cell
            }
            
            cell.delegate = self
            cell.dataSource = self
            if indexPath.row == 0 {
                cell.colorView.isHidden = true
                cell.noColorView.isHidden = false
                if self.textModel.selectedBackGrounfColorIndex == -1 {
                    cell.selectedButton.isHidden = false
                } else {
                    cell.selectedButton.isHidden = true
                }
            } else {
                cell.selectedButton.isHidden = true
                let data = self.colorData[indexPath.row - 1]
                var isSelect = false
                if self.textModel.selectedBackGrounfColorIndex == 100 {
                    isSelect = false
                } else if self.textModel.selectedBackGrounfColorIndex == 101 {
                    isSelect = false
                } else {
                    self.colorOptionButton.hideView()
                    if self.textModel.selectedBackGrounfColorIndex == -1 {
                        isSelect = false
                    } else {
                        isSelect = indexPath.row - 1 ==  self.textModel.selectedBackGrounfColorIndex
                    }
                }
                cell.configure(with: data, textModel: self.textModel, isSelect: isSelect, isPrevious: indexPath.row == self.colorData.count - 1)
                cell.noColorView.isHidden = true
                cell.colorView.isHidden = false
            }
            
            
            return cell
        case textCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextFontCell.className, for: indexPath) as? TextFontCell else {
                let cell = TextFontCell()
                return cell
            }
            cell.delegate = self
            cell.dataSource = self
            let data = self.fontData[indexPath.row]
            var isSelect = false
            print(self.fontButton.titleLabel?.font.fontName ?? "")
            if data == self.fontButton.titleLabel?.font.fontName {
                isSelect = true
                self.fontButton.setTitle("", for: .normal)
            }
            cell.configure(with: data, textModel: self.textModel, isSelect: isSelect)
            
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.colorWheelSelectedImage.backgroundColor = nil
        self.colorWheelImage.image = UIImage(named: "colorWheel")
        switch collectionView {
        case colorCollectionView:
            let cell = collectionView.cellForItem(at: indexPath) as? TextColorCell
            self.colorOptionButton.hideView()
            let data = self.colorData[indexPath.row]
            self.indexSelection = indexPath.row
            self.textModel.selectedColorIndex = indexPath.row
            self.textModel.color = self.colorData[self.textModel.selectedColorIndex]
            cell?.handleSelection(with: data, textModel: self.textModel)
            self.colorPickerView.backgroundColor = .clear
            
        case colorBackgroundCollectionView:
            let cell = collectionView.cellForItem(at: indexPath) as? TextColorCell
            self.colorBackgroundOptionButton.hideView()
            if indexPath.row == 0 {
                self.textModel.selectedBackGrounfColorIndex = -1
                self.textModel.backgroungColor = .clear
                cell?.handleSelection(with: .clear, textModel: self.textModel, isTextColor: self.isColorText)
                self.colorBackgroundPickerView.backgroundColor = .clear
                
            } else {
                let data = self.colorData[indexPath.row - 1]
                self.indexBackgroundSelection = indexPath.row - 1
                self.textModel.selectedBackGrounfColorIndex = indexPath.row - 1
                self.textModel.backgroungColor = self.colorData[self.textModel.selectedBackGrounfColorIndex]
                cell?.handleSelection(with: data, textModel: self.textModel, isTextColor: self.isColorText)
                self.colorBackgroundPickerView.backgroundColor = .clear
            }
            self.colorBackgroundCollectionView.reloadData()

        case textCollectionView:
            let cell = collectionView.cellForItem(at: indexPath) as? TextFontCell
            let data = self.fontData[indexPath.row]
            self.textModel.selectedFontIndex = indexPath.row
            self.textModel.fontCustom = data
            cell?.handleSelection(with: data, textModel: self.textModel)
        default:
            break
        }
    }
}
