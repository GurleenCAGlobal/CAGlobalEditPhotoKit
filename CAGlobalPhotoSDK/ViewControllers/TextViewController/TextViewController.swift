//
//  TextViewController.swift
//  CAPhotoEditor
//
//  Created by Gurleen Singh on 02/05/23.
//


import UIKit

enum TextViewSelection: Int {
    case text = 0
    case color = 1
    case opacity = 2
    case align = 3
    case none = -1
}

var textViewOpacity = 3.0

protocol TextViewControllerDelegate: AnyObject {
    
    /*
     Called when the user to apply colors and font name
     */
    func addTextToTextView(_: TextViewController, object: [String:Any])
    
    /*
     Called when the user click on back
     */
    func backToEdit(_: TextViewController)
}

class TextViewController: BaseViewController, UITextViewDelegate, AMColorPickerDelegate {
    
    

    // MARK: - Outlets
    // Outlet for the text view to enter text
    @IBOutlet weak var textToEnterTexView: UITextView!
    // Outlet for the Done button
    @IBOutlet weak var doneButton: UIButton!
    // This outlet represents the bottom view where we are using sub view of edit options
    @IBOutlet weak var bottomView: UIView!
    // This outlet represents the width of text view
    @IBOutlet weak var constraintsBottomViewHeight: NSLayoutConstraint!
    // This outlet represents the width of text view
    @IBOutlet weak var constraintTextViewHeight: NSLayoutConstraint!
    // This outlet represents the width of text view
    @IBOutlet weak var constraintTextViewWidth: NSLayoutConstraint!
    // This outlet represents the bottom of text view
    @IBOutlet weak var constraintsBottomViewBottom: NSLayoutConstraint!
    // This outlet represents the bottom view where we are using sub view of edit options
    @IBOutlet weak var viewCrossTickerSubOptions: UIView!
    
    // MARK: - Properties
    weak var delegate: TextViewControllerDelegate?
    var textModel = TextModel()
    var savedTextModel = TextModel()
    var backupTextModel = TextModel()
    private var colorManager = ColorManager()
    private var fontManager = FontManager()
    var textViewViewModel = TextViewViewModel()
    var textViewSelection = TextViewSelection(rawValue: -1)

    private(set) var colorData = [UIColor]()
    private(set) var fontData = [String]()
    
    var editText = ""
    var textAlignment = "center"
    var isBtnCrossShowing: Bool? = false
    var newText: Bool? = true
    var btnCross = UIButton()
    var textView = TextView()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if isBtnCrossShowing == true {
            btnCross.isHidden = true
        }
        
        self.textViewViewModel = TextViewViewModel()
        self.addBlurBackgroundEffect(view: self.view)
        UITextView.appearance().tintColor = UIColor.white
        self.textToEnterTexView.delegate = self
        self.textToEnterTexView.becomeFirstResponder()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        self.backupTextModel = self.textModel
        self.savedTextModel = self.textModel
        self.colorManager = ColorManager()
        self.fontManager = FontManager()
        self.colorData = self.colorManager.getColorsData()
        self.fontData = self.fontManager.getFontsData()
        
        if self.textModel.selectedColorIndex == 100 {
            self.textToEnterTexView.textColor = self.textModel.color
            self.textToEnterTexView.tintColor = self.textModel.color
            
        } else if self.textModel.selectedColorIndex == 101 {
            self.textToEnterTexView.textColor = self.textModel.color
            self.textToEnterTexView.tintColor = self.textModel.color
        } else {
            let color = self.colorData[textModel.selectedColorIndex]
            self.textToEnterTexView.textColor = self.textModel.color
            self.textToEnterTexView.tintColor = color
        }
        
        if self.textModel.selectedBackGrounfColorIndex == 100 {
            self.textToEnterTexView.backgroundColor = self.textModel.backgroungColor
            
        } else if self.textModel.selectedBackGrounfColorIndex == 101 {
            self.textToEnterTexView.backgroundColor = self.textModel.backgroungColor
        } else {
            self.textToEnterTexView.backgroundColor = self.textModel.backgroungColor
        }

        self.textToEnterTexView.text = self.editText
        _ = self.fontData[textModel.selectedFontIndex]
        
        self.textToEnterTexView.font = UIFont(name: self.textModel.fontCustom, size: 36)
        if self.textModel.alignment == .center {
            textAlignment = "center"
        } else if self.textModel.alignment == .right {
            textAlignment = "right"
        } else if self.textModel.alignment == .left {
            textAlignment = "left"
        }
        self.textToEnterTexView.textAlignment = self.textModel.alignment
        self.textToEnterTexView.alpha = self.textModel.opacity
        textViewOpacity = self.textModel.opacity
        for (i, text) in self.fontData.enumerated() {
            if self.textModel.fontCustom == text {
                self.textModel.selectedFontIndex = i
            }
        }
        self.textToEnterTexView.text = self.textModel.textString
        self.addTextBottomView()
        print("font name", self.textModel.fontCustom)
        self.textToEnterTexView.isScrollEnabled = false
        let size = textToEnterTexView.sizeThatFits(CGSize(width: textToEnterTexView.frame.width, height: .greatestFiniteMagnitude))
        self.constraintTextViewHeight.constant = size.height

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textToEnterTexView.becomeFirstResponder()
        adjustTextViewSize() // First to set the UI
        adjustTextViewSize() // Second to adjust text on view in number of lines
    }
    
    // MARK: - Private Methods
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            switch UIDevice.current.type {
            case .iPhoneSE, .iPhone5, .iPhone5S:
                self.constraintsBottomViewBottom.constant = keyboardHeight - 15
            case .iPhone6, .iPhone7, .iPhone8, .iPhone6S, .iPhoneX:
                self.constraintsBottomViewBottom.constant = keyboardHeight - 15
            default:
                self.constraintsBottomViewBottom.constant = keyboardHeight - 33
            }
        }
    }
    
    func addViewOnKeypad(frame:CGRect) {
        // Add a view on top of the keyboard
    }
    
    func removeFromSuperView() {
        // Remove self view from superview
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    func addLabelOnSuperView() {
        // Add a label on the superview
        let dict = [
            EditStaticStrings.color : (textModel.selectedColorIndex == 100 || textModel.selectedColorIndex == 101) ? textModel.color : textModel.color,
            EditStaticStrings.selectedColorIndex : textModel.selectedColorIndex,
            EditStaticStrings.previousColor : textModel.previousColor,
            EditStaticStrings.selectedPreviousColorIndex : textModel.previousSelectedColorIndex,
            EditStaticStrings.font : backupTextModel.fontCustom,
            EditStaticStrings.previousFont : textModel.previousFont,
            EditStaticStrings.selectedFontIndex : textModel.selectedFontIndex,
            EditStaticStrings.selectedPreviousFontIndex : textModel.previousSelectedFontIndex,
            EditStaticStrings.selectedOpacity : textModel.opacity,
            EditStaticStrings.selectedAlignment : textAlignment,
            EditStaticStrings.previousText : textModel.previousTextString,
            EditStaticStrings.text : textToEnterTexView.text ?? "",
            EditStaticStrings.newText : newText ?? true,
            EditStaticStrings.backgroundColor : (textModel.selectedBackGrounfColorIndex == 100 || textModel.selectedBackGrounfColorIndex == 101) ? textModel.backgroungColor : textModel.backgroungColor,
            EditStaticStrings.selectedBackgroundColorIndex : textModel.selectedBackGrounfColorIndex,
            EditStaticStrings.previousBackgroundColor : textModel.previousBackgroundColor,
            EditStaticStrings.selectedBackgroundPreviousColorIndex : textModel.previousSelectedBackgroundColorIndex,

        ] as [String : Any]
        self.delegate?.addTextToTextView(self, object: dict)
    }
    
    
    // MARK: - IBActions
    @IBAction func actionCrossSubOptions(_ sender: Any) {
        switch self.textViewSelection {
        case .text:
            self.textToEnterTexView.font = UIFont.init(name: self.backupTextModel.fontCustom , size: self.textToEnterTexView.font?.pointSize ?? 0.0)
            self.textModel.fontCustom = self.backupTextModel.fontCustom
            self.textModel.selectedFontIndex = self.backupTextModel.selectedFontIndex
        case .color:
            self.textToEnterTexView.textColor = self.backupTextModel.color
            self.textModel.color = self.backupTextModel.color
            self.textModel.selectedColorIndex = self.backupTextModel.selectedColorIndex
        case .opacity: break
        case .align: break
        default:
            break
        }
        self.addTextBottomView()
    }
    
    @IBAction func actionTickSubOptions(_ sender: Any) {
      //  selectedAddTextView?.handles.forEach { $0.isHidden = false }
        self.textModel.fontCustom = self.savedTextModel.fontCustom
        self.textModel.selectedFontIndex = self.savedTextModel.selectedFontIndex
        self.textModel.color = self.savedTextModel.color
        self.textModel.selectedColorIndex = self.savedTextModel.selectedColorIndex
        self.textModel.backgroungColor = self.savedTextModel.backgroungColor
        self.textModel.selectedBackGrounfColorIndex = self.savedTextModel.selectedBackGrounfColorIndex
        //self.addTextBottomView()
    }
    
    @IBAction func btnBackClicked(_ sender: Any) {
        if isBtnCrossShowing == true {
            btnCross.isHidden = false
        }
        removeFromSuperView()
        self.delegate?.backToEdit(self)
    }
    
    @IBAction func btnDoneClicked(_ sender: Any) {
        self.actionTickSubOptions(sender)
        if isBtnCrossShowing == true {
            btnCross.isHidden = false
        }
        if textToEnterTexView.text != "" {
            addLabelOnSuperView()
            removeFromSuperView()
        } else {
            removeFromSuperView()
            self.delegate?.backToEdit(self)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewSize()
    }
    
//    private func adjustTextViewSize() {
//        let size = textToEnterTexView.sizeThatFits(CGSize(width: textToEnterTexView.frame.width, height: .greatestFiniteMagnitude))
//        self.constraintTextViewHeight.constant = size.height
//        if size.height >= 200 {
//            self.constraintTextViewHeight.constant = 200
//            self.textToEnterTexView.isScrollEnabled = true
//        } else {
//            self.textToEnterTexView.isScrollEnabled = false
//        }
//    }
    
    func addTextBottomView() {
        for view in self.bottomView.subviews {
            view.removeFromSuperview()
            
        }
        self.bottomView.isHidden = false
        self.doneButton.isHidden = false
        self.textView = TextView()
        self.textView.delegate = self
        self.textView.isTextViewController = true
        self.textView.setUpColorPickerViews(iscolorpciker: false, isTextViewController: true)
        self.textView.setUpTextAndColorTextEdit(textModel: self.textModel, fontName: self.textToEnterTexView.font?.fontName ?? "")
        self.bottomView.addSubview(self.textView)
        self.bottomView.isHidden = false
        self.setupAutoLayoutForBottomView(newView: self.textView, bottomView: self.bottomView)
    }
    
    func setupAutoLayoutForBottomView(newView: UIView, bottomView: UIView) {
        newView.translatesAutoresizingMaskIntoConstraints = false
        let attribute = NSLayoutConstraint.Attribute.self
        let equal = NSLayoutConstraint.Relation.equal
        let top = self.constraintTop(item: newView, item2: bottomView)
        let bottom = self.constraintBottom(item: newView, item2: bottomView)
        let leading = NSLayoutConstraint(item: newView, attribute: attribute.leading, relatedBy: equal, toItem: bottomView, attribute: attribute.leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: newView, attribute: attribute.trailing, relatedBy: equal, toItem: bottomView, attribute: attribute.trailing, multiplier: 1, constant: 0)
        bottomView.addConstraints([top, bottom, leading, trailing])
    }
    
    func constraintTop(item: UIView, item2: UIView) -> NSLayoutConstraint {
        let top = NSLayoutConstraint.Attribute.top
        let equal = NSLayoutConstraint.Relation.equal
        return NSLayoutConstraint(item: item, attribute: top, relatedBy: equal, toItem: item2, attribute: top, multiplier: 1, constant: 0)
    }
    

    func constraintBottom(item: UIView, item2: UIView) -> NSLayoutConstraint {
        let bottom = NSLayoutConstraint.Attribute.bottom
        let equal = NSLayoutConstraint.Relation.equal
        return NSLayoutConstraint(item: item, attribute: bottom, relatedBy: equal, toItem: item2, attribute: bottom, multiplier: 1, constant: 0)
    }
}

extension TextViewController: TextViewDelegate {
    func pickColor(isBackground: Bool, callBack: (ColorModel) -> Void?) {
        
    }
    
    func pickColor(callBack: (ColorModel) -> Void?) {
        
    }
    
    func colorPicker() {
        
    }
    
    func opacityDidEnd(_: TextView, sliderValue: CGFloat) {

    }
    

    func backButtonColortext() {
//        magnifyingGlass.magnifiedView = nil
//        removeGesturesMainImageViewForMagnify()
    }

    func didChangeTextProperties(textModel: TextModel) {
        textToEnterTexView.text = textModel.textString
        textToEnterTexView.textColor = textModel.color
        textToEnterTexView.font = UIFont(name: textModel.fontCustom, size: 36)
        textToEnterTexView.textAlignment = textModel.alignment
        textToEnterTexView.alpha = textModel.opacity
    }
    
    func opacityWillStart(_ textView: TextView, isOpen: Bool) {
        self.textViewSelection = .opacity
        if isOpen {
            self.constraintsBottomViewHeight.constant = 80
        } else {
            self.constraintsBottomViewHeight.constant = 80
        }
    }
    
    func opacityDidStart(_ textView: TextView, sliderValue: CGFloat) {
        self.textViewSelection = .opacity
        self.textToEnterTexView.alpha = sliderValue
        self.savedTextModel.opacity = sliderValue
        self.textModel.opacity = sliderValue
        textViewOpacity = sliderValue
    }
    
    func selectColorAndText(_ textView: TextView, textModel: TextModel) {
        if textModel.isColor == true {
            self.textViewSelection = .color
            self.textToEnterTexView.textColor = textModel.color
            self.savedTextModel.color = textModel.color
            self.savedTextModel.selectedColorIndex = textModel.selectedColorIndex
        } else if textModel.isBackgroundColor == true {
            self.textToEnterTexView.backgroundColor = textModel.backgroungColor
            self.savedTextModel.backgroungColor = textModel.backgroungColor
            self.savedTextModel.selectedBackGrounfColorIndex = textModel.selectedBackGrounfColorIndex
        } else {
            self.textToEnterTexView.font = UIFont.init(name: textModel.fontCustom , size: self.textToEnterTexView.font?.pointSize ?? 0.0)
            self.textViewSelection = .text
            self.savedTextModel.fontCustom = textModel.fontCustom
            self.savedTextModel.selectedFontIndex = textModel.selectedFontIndex
        }
    }
    
    func alignLeft() {
        textAlignment = "left"
        self.textViewSelection = .align
        self.textToEnterTexView.textAlignment = .left
        self.savedTextModel.alignment = .left
        self.textModel.alignment = .left
    }
    
    func alignRight() {
        textAlignment = "right"
        self.textViewSelection = .align
        self.textToEnterTexView.textAlignment = .right
        self.savedTextModel.alignment = .right
        self.textModel.alignment = .right
    }
    
    func alignCenter() {
        textAlignment = "center"
        self.textViewSelection = .align
        self.textToEnterTexView.textAlignment = .center
        self.savedTextModel.alignment = .center
        self.textModel.alignment = .center
    }
    
    
    
    private func adjustTextViewSize() {
        // Padding for all sides
        let padding: CGFloat = 12
        
        // Define maximum width (screen width - margins)
        let maxWidth: CGFloat = UIScreen.main.bounds.width - 40

        // Calculate required size for the text content
        let size = textToEnterTexView.sizeThatFits(
            CGSize(width: maxWidth - padding * 2, // subtract padding when measuring text
                   height: CGFloat.greatestFiniteMagnitude)
        )
        
        // Apply constraints including padding
        constraintTextViewWidth.constant = min(size.width + padding * 2, maxWidth)
        constraintTextViewHeight.constant = size.height
        
        // Optional: apply textContainerInset to keep padding inside UITextView
        textToEnterTexView.textContainerInset = UIEdgeInsets(
            top: padding,
            left: padding,
            bottom: padding,
            right: padding
        )
        
        view.layoutIfNeeded()
    }
    
    func tickAndCrossForSubOptions(isAlign: Bool) {
        self.constraintsBottomViewHeight.constant = 80
    }
    
    func setFurtherColorText(color: UIColor, opacity: CGFloat, isBackground: Bool) {
        let colorPickerViewController = AMColorPickerViewController()
        colorPickerViewController.selectedColor = color
        colorPickerViewController.selectedOpacity = opacity
        colorPickerViewController.isBackground = isBackground
        colorPickerViewController.delegate = self
        colorPickerViewController.modalPresentationStyle = .fullScreen
        present(colorPickerViewController, animated: true, completion: nil)
    }
    
    func pickColor(callBack: (UIColor) -> Void?) {
        
    }
    
    func colorPicker(_ colorPicker: any AMColorPicker, didSelect color: UIColor, opacity: CGFloat, isBackground: Bool) {
        self.textToEnterTexView.becomeFirstResponder()

        let textModel = TextModel()
        let rgba = color.rgba
        let alpha = rgba.alpha
        
        if isBackground == true {
            textModel.backgroungColor = UIColor(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: alpha)
            textModel.selectedBackGrounfColorIndex = 101
            textModel.previousBackgroundColor = self.textModel.previousBackgroundColor
            textModel.previousSelectedBackgroundColorIndex = self.textModel.previousSelectedBackgroundColorIndex

        } else {
            textModel.color = UIColor(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: alpha)
            textModel.selectedColorIndex = 101
            textModel.previousColor = self.textModel.previousColor
            textModel.previousSelectedColorIndex = self.textModel.previousSelectedColorIndex
        }
        
        textModel.selectedFontIndex = self.textModel.selectedFontIndex
        textModel.previousSelectedFontIndex = self.textModel.previousSelectedFontIndex
        textModel.textString = self.textModel.textString
        textModel.previousTextString = self.textModel.previousTextString
        textModel.fontCustom = self.textModel.fontCustom
        textModel.previousFont = self.textModel.previousFont
        self.textModel = textModel
        
        let colorModel = ColorModel()
        colorModel.selectedColorIndex = 101
        colorModel.isColor = true
        colorModel.color = color

        self.textViewSelection = .color

        if isBackground == true {
            self.savedTextModel.backgroungColor = self.textModel.backgroungColor
            self.savedTextModel.selectedBackGrounfColorIndex = self.textModel.selectedBackGrounfColorIndex

            self.textToEnterTexView.backgroundColor = self.textModel.backgroungColor
            self.textView.setUpTextAndColorTextEditBackground(textModel: self.textModel, fontName: self.textToEnterTexView.font?.fontName ?? "")

            self.textView.colorBackWheelImage.image = UIImage(named: "Color Wheel - Selected")
            self.textView.colorBackWheelSelectedImage.backgroundColor = color

        } else {
            self.savedTextModel.color = self.textModel.color
            self.savedTextModel.selectedColorIndex = self.textModel.selectedColorIndex

            self.textToEnterTexView.textColor = self.textModel.color
            self.textView.setUpTextAndColorTextEditColor(textModel: self.textModel, fontName: self.textToEnterTexView.font?.fontName ?? "")

            self.textView.colorWheelImage.image = UIImage(named: "Color Wheel - Selected")
            self.textView.colorWheelSelectedImage.backgroundColor = color

        }
    }
    
//    func textViewDidChange(_ textView: UITextView) {
//        adjustTextViewSize(textView)  // or adjustTextViewHeight(textView)
//    }
//
//    func adjustTextViewSize(_ textView: UITextView) {
//        let newSize = textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude,
//                                                   height: CGFloat.greatestFiniteMagnitude))
//        var newFrame = textView.frame
//        newFrame.size = newSize
//        self.textToEnterTexView.frame = newFrame
//    }
}
