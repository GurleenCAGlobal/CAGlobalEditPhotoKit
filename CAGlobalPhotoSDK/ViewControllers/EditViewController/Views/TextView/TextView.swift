//
//  TextView.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 17/03/23.
//

import UIKit
typealias ColorCompletion = (UIColor) -> Void?
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
     Called when the user to apply colors and font name
     */
    func selectColorAndText(_: TextView, textModel: TextModel)
    
    /*
     Called when the user to select pick color
     */
    func pickColor(callBack: ColorCompletion)

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
     Called when the user wants further colors
     */
    func setFurtherColorText(color: UIColor, opacity: CGFloat)

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

    // This outlet represents to the container view for picker color
    @IBOutlet weak var colorPickerView: UIView!
    
    // This outlet represents to the button used for color selection
    @IBOutlet weak var colorButton: UIButton!

    // This outlet represents to the button used for color options selection
    @IBOutlet weak var colorOptionButton: UIButton!

    // This outlet represents to the button used for font selection
    @IBOutlet weak var fontButton: UIButton!

    // This outlet represents to the button used for font selection
    @IBOutlet weak var colorBackButton: UIButton!
    
    // This outlet represents to the button used for font selection
    @IBOutlet weak var alignmentButton: UIButton!
    
    // This outlet represents to the slider used for text opacity
    @IBOutlet weak var opacitySlider: UISlider!

    // This outlet represents the pick image view
    @IBOutlet weak var pickImageView: UIImageView!

    // This outlet represents the bottom of main view
    @IBOutlet weak var constraintsWidthColorPicker: NSLayoutConstraint!

    // This outlet represents the bottom of main view
    @IBOutlet weak var constraintsWidthBack: NSLayoutConstraint!
    
    // This outlet represents the bottom of main view
    @IBOutlet weak var constraintsLeading: NSLayoutConstraint!
    
    // This outlet represents the bottom of main view
    @IBOutlet weak var constraintsColorWidthBack: NSLayoutConstraint!
    
    // MARK: Properties
    var undoMng = UndoManager()
    weak var delegate: TextViewDelegate?
    var textModel = TextModel()
    private var editViewModel = CAEditViewModel()
    private var colorManager = ColorManager()
    private var fontManager = FontManager()
    private(set) var colorData = [UIColor]()
    private(set) var fontData = [String]()
    var isColorPicker = true
    var isTextViewController = false
    var indexSelection = Int()

    // Call this method when you want to update the text properties
    func updateTextProperties() {
        // Notify the delegate (TextViewController) of the changes
        delegate?.didChangeTextProperties(textModel: textModel)
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
    }
    
    // MARK: Setup Methods
    func setUpViews() {
        if self.isColorPicker == false {
            self.constraintsWidthColorPicker.constant = 0
        }
        self.colorContainerView.hideView()
        self.fontContainerView.hideView()
        self.opacityContainerView.hideView()
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

        if iscolorpciker == false {
            self.constraintsWidthColorPicker.constant = 0
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
        self.fontButton.titleLabel?.font = UIFont(name: fontName, size: 16)
        if textModel.selectedColorIndex == 100 {
            self.colorOptionButton.showView()
            self.colorButton.backgroundColor = textModel.color
            self.colorPickerView.backgroundColor = textModel.color
            self.colorPickerView.backgroundColor = textModel.color
        } else {
            self.colorButton.backgroundColor = textModel.color
        }
        if textModel.alignment == .center {
            self.alignmentButton.setImage(UIImage.init(named: "alignCenter"), for: .normal)
            self.delegate?.alignCenter()
        } else if textModel.alignment == .right {
            self.alignmentButton.setImage(UIImage.init(named: "alignRight"), for: .normal)
            self.delegate?.alignRight()
        } else if textModel.alignment == .left {
            self.alignmentButton.setImage(UIImage.init(named: "alignLeft"), for: .normal)
            self.delegate?.alignLeft()
        }
        self.opacitySlider.value = Float(textModel.opacity)
        self.textCollectionView.reloadData()
    }
//    func updateTextProperties(_ textView: AddTextView) {
//        // Register the undo action
//        let oldState = self.textModel.copyState()
//        undoMng.registerUndo(withTarget: self) { targetSelf in
//            targetSelf.restoreState(oldState)
//        }
//
//        // Update the text properties
//        self.textModel.selectedColorIndex = textView.selectedColorIndex
//        self.textModel.color = textView.selectedColor
//        // Continue updating other properties as needed
//
//        // Clear redo stack after new changes
//        undoMng.removeAllActions(withTarget: self)
//    }
//
//    func restoreState(_ previousState: TextModel) {
//        // Register the redo action
//        let currentState = self.textModel.copyState()
//        undoMng.registerUndo(withTarget: self) { targetSelf in
//            targetSelf.restoreState(currentState)
//        }
//
//        // Restore previous state
//        self.textModel = previousState
//
//        // Update the UI based on the restored state
//        updateUIWithModel(self.textModel)
//    }

    func updateTextProperties(_ textView: AddTextView) {
        // Capture the current state before changing
        let oldState = self.textModel.copyState()

        // Register the undo action
        undoMng.registerUndo(withTarget: self) { targetSelf in
            targetSelf.restoreState(oldState)
        }

        // Update the text properties
        self.textModel.selectedColorIndex = textView.selectedColorIndex
        self.textModel.color = textView.selectedColor
        self.textModel.fontCustom = textView.selectedFont
        self.textModel.textString = textView.text ?? ""
        self.textModel.alignment = textView.textAlignment
        self.textModel.opacity = textView.alpha

        // Clear redo stack after new changes
        undoMng.removeAllActions(withTarget: self)
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
//    func updateUIWithModel(_ model: TextModel) {
//        self.colorButton.backgroundColor = model.color
//        self.fontButton.titleLabel?.font = UIFont(name: model.fontCustom, size: 16)
//        textToEnterTexView.text = textModel.textString
//        textToEnterTexView.textColor = textModel.color
//        textToEnterTexView.font = UIFont(name: textModel.fontCustom, size: 24)
//        textToEnterTexView.textAlignment = textModel.alignment
//        textToEnterTexView.alpha = textModel.opacity
//    }
    func batchUpdateTextProperties(textViews: [AddTextView]) {
        // Start grouping the undoable actions
        undoMng.beginUndoGrouping()

        // Make multiple changes here (e.g., updating multiple text views)
        for textView in textViews {
            updateTextProperties(textView)
        }

        // End the undo grouping so these changes are treated as one undo step
        undoMng.endUndoGrouping()
    }


    func setUpTextAndColor(views: [UIView]) {
        undoMng.beginUndoGrouping()
        var addTextViews: [AddTextView] = []


            // Now, perform the batch update using the collected text views
            if !addTextViews.isEmpty {
                batchUpdateTextProperties(textViews: addTextViews)
            }

        for subview in views {
            if let txtLbl = subview as? AddTextView {
                // Only perform the updates if the text view is selected
                if txtLbl.isSelected {
                    // Capture the current state for undo functionality
                    let oldTextModel = textModel
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
                    self.fontButton.titleLabel?.font = UIFont(name: txtLbl.font.fontName, size: 16)
                    if txtLbl.selectedColorIndex == 100 {
                        self.colorOptionButton.showView()
                        self.colorButton.backgroundColor = txtLbl.textColor
                        self.colorPickerView.backgroundColor = txtLbl.textColor
                    } else {
                        self.colorButton.backgroundColor = txtLbl.textColor
                    }

                    // Update alignment buttons and notify the delegate
                    if txtLbl.textAlignment == .center {
                        self.alignmentButton.setImage(UIImage(named: "alignCenter"), for: .normal)
                        self.delegate?.alignCenter()
                    } else if txtLbl.textAlignment == .right {
                        self.alignmentButton.setImage(UIImage(named: "alignRight"), for: .normal)
                        self.delegate?.alignRight()
                    } else if txtLbl.textAlignment == .left {
                        self.alignmentButton.setImage(UIImage(named: "alignLeft"), for: .normal)
                        self.delegate?.alignLeft()
                    }

                    // Register undo for the changes made to this text view's properties
                    undoMng.registerUndo(withTarget: self) { [oldTextModel] target in
                        target.restoreTextModel(oldTextModel)
                    }
                }
                if !addTextViews.isEmpty {
                    batchUpdateTextProperties(textViews: addTextViews)
                }
            }
        }

        undoMng.endUndoGrouping()
    }

    // Helper function to restore the previous text model state
    func restoreTextModel(_ oldModel: TextModel) {
        self.textModel = oldModel

        // Here you can also restore the actual UI (if needed)
        // For example, update the text views again based on the restored text model.
    }

    
    func setUpPickerColor(views : [UIView], color : UIColor) {
        undoMng.beginUndoGrouping()
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
        undoMng.endUndoGrouping()
    }
    
    func setUpOpacity(views : [UIView]) {
        self.constraintsLeading.constant = 0
        self.constraintsWidthBack.constant = 0
//        self.constraintsColorWidthBack.constant = 0
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
        
        let nib2 = UINib(nibName: TextFontCell.className, bundle: nil)
        textCollectionView.register(nib2, forCellWithReuseIdentifier: TextFontCell.className)
        textCollectionView.dataSource = self
        textCollectionView.delegate = self
    }
    
    func updateFont(index: Int) {
        self.fontButton.titleLabel?.font = UIFont(name: fontData[index], size: 16)
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
        self.delegate?.backButtonColortext()
    }
    
    @IBAction func actionFontClicked(_ sender: Any) {
        fontContainerView.showView()
        colorContainerView.hideView()
        opacityContainerView.hideView()
        optionContainerView.hideView()
        self.delegate?.tickAndCrossForSubOptions(isAlign: false)
    }
    
    @IBAction func actionColorClicked(_ sender: Any) { 
        if textModel.selectedColorIndex == 0 {
            self.colorButton.backgroundColor = (UIColor(named: .blackColorName)!)
        }
        self.indexSelection = -1
        if self.isTextViewController == true {
            self.constraintsColorWidthBack.constant = 30
            self.colorBackButton.isHidden = false
            self.colorPickerView.isHidden = true
        } else {
            self.colorBackButton.isHidden = false
            self.colorPickerView.isHidden = false
        }
        fontContainerView.hideView()
        colorContainerView.showView()
        opacityContainerView.hideView()
        optionContainerView.hideView()
        self.delegate?.tickAndCrossForSubOptions(isAlign: false)
        self.colorCollectionView.reloadData()
    }

    @IBAction func actionOpacityClicked(_ sender: Any) {
        if opacityContainerView.isHidden {
            fontContainerView.hideView()
            colorContainerView.hideView()
            opacityContainerView.showView()
            optionContainerView.showView()
            self.delegate?.opacityWillStart(self, isOpen: true)
        } else {
            fontContainerView.hideView()
            colorContainerView.hideView()
            opacityContainerView.hideView()
            optionContainerView.showView()
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
    
    @IBAction func actionColorPicker(_ sender: UISlider) {
        self.indexSelection = -1

        self.delegate?.pickColor(callBack: {[weak self] value in
            self?.updateFontColor(color: value)
            self?.colorPickerView.backgroundColor = value
            self?.colorOptionButton.showView()
            self?.textModel.selectedColorIndex = 100
            self?.textModel.isColor = true
            self?.colorCollectionView.reloadData()
        })
        
    }
    
    func actionCrossForText() {
        fontContainerView.hideView()
        colorContainerView.hideView()
        opacityContainerView.hideView()
        optionContainerView.showView()
        
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
    func didSelectCell(with data: UIColor, textModel: TextModel) {
        textModel.isColor = true
        self.updateFontColor(color: textModel.color)
        self.delegate?.selectColorAndText(self, textModel: textModel)
    }
}

extension TextView: TextFontCellDelegate {
    func didSelectFontCell(with data: String, textModel: TextModel) {
        textModel.isColor = false

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
        case textCollectionView:
            return fontData.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case colorCollectionView:
            return CGSize(width: 46, height: 56)
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
            let data = self.colorData[indexPath.row]
            var isSelect = false
            if self.textModel.selectedColorIndex == 100 {
                isSelect = false
            } else {
                self.colorOptionButton.hideView()
                isSelect = colorData[indexPath.row] ==  self.colorButton.backgroundColor
            }
            cell.configure(with: data, textModel: self.textModel, isSelect: isSelect, isPrevious: indexPath.row == self.colorData.count - 1)

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
        switch collectionView {
        case colorCollectionView:
            if self.indexSelection == indexPath.row {
                self.delegate?.setFurtherColorText(color: self.textModel.color, opacity: self.textModel.opacity)
            } else {
                let cell = collectionView.cellForItem(at: indexPath) as? TextColorCell
                self.colorOptionButton.hideView()
                let data = self.colorData[indexPath.row]
                self.indexSelection = indexPath.row
                self.textModel.selectedColorIndex = indexPath.row
                self.textModel.color = self.colorData[self.textModel.selectedColorIndex]
                cell?.handleSelection(with: data, textModel: self.textModel)
                self.colorPickerView.backgroundColor = .clear
            }
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
