//
//  TransformView.swift
//  CAPhotoEditor
//
//  Created by Gurleen Singh on 17/03/23.
//

import UIKit

protocol TransformViewDelegate {
    func resetTransform()
    func presentRatioCropView()
    func notPresentRatioCropView()
    func cropViewControllerDidCrop(cropped: UIImage)
    func cropViewControllerDidCancel()
    
    func didSelectHorizontallyFlip()
    func didSelectVerticallyFlip()
    func didSelectClockwiseRotate()
}

class TransformView: UIView {
    
    // MARK: - Outlets
    // Outlet for the base view of the Transform view
    @IBOutlet weak var baseView: UIView!
    
    // Outlets for the aspect ratio views
    @IBOutlet weak var aspectRatioView1: UIView!
    @IBOutlet weak var aspectRatioView2: UIView!
    
    // Outlets for the base aspect ratio views
    @IBOutlet weak var baseAspectRatioView1: UIView!
    @IBOutlet weak var baseAspectRatioView2: UIView!
    
    // Outlets for the aspect ratio labels
    @IBOutlet weak var labelAspectRatio1: UILabel?
    @IBOutlet weak var labelAspectRatio2: UILabel?
    
    // MARK: - Properties
    var transformDelegate: TransformViewDelegate?
    private var fixedRatioSettingButton: UIButton?
    private var portraitRatioButton: UIButton?
    private var landscapeRatioButton: UIButton?
    private var cropButton: UIButton?
    private var cancelButton: UIButton?
    private var stackView: UIStackView?
    var adjustImage = UIImage()
    var orignalImage = UIImage()
    
    var custom: ((Double) -> Void)?
    
    // MARK: - Initialization
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
        let bundle = Bundle(for: TransformView.self)
        let nib = UINib(nibName: TransformView.className, bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return nibView ?? UIView()
    }
    
    func handleFixedRatioUnSetted() {
        
    }
    
    func handleFixedRatioSetted(ratio: Double) {
        switch ratio {
        case 2.0 / (self.selectedRatioWith ?? 0.0):
            portraitRatioButton?.setTitleColor(.blue, for: .normal)
            landscapeRatioButton?.setTitleColor(.white, for: .normal)
        case (self.selectedRatioWith ?? 0.0) / 2.0:
            landscapeRatioButton?.setTitleColor(.blue, for: .normal)
            portraitRatioButton?.setTitleColor(.white, for: .normal)
        default:
            landscapeRatioButton?.setTitleColor(.white, for: .normal)
            portraitRatioButton?.setTitleColor(.white, for: .normal)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func actionMirror(_ sender: Any) {
        self.transformDelegate?.didSelectHorizontallyFlip()
    }
    
    @IBAction func actionFlip(_ sender: Any) {
        self.transformDelegate?.didSelectVerticallyFlip()
    }
    
    @IBAction func action90Degree(_ sender: Any) {
        self.transformDelegate?.didSelectClockwiseRotate()
    }
    
    @IBAction func actionRatioSelection(_ sender: Any) {
        self.transformDelegate?.presentRatioCropView()
    }
    
    @IBAction func actionTick(_ sender: Any) {
        self.transformDelegate?.notPresentRatioCropView()
    }
    
    @IBAction func actionReset(_ sender: Any) {
        self.transformDelegate?.resetTransform()
    }
    
    // MARK: - Other Methods

    var selectedRatioWith: CGFloat? {
        didSet {
            self.labelAspectRatio1?.text = "2:\(Double(self.selectedRatioWith ?? 0.0).rounded(toPlaces: 1))"
            self.labelAspectRatio2?.text = "\(Double(self.selectedRatioWith ?? 0.0).rounded(toPlaces: 1)):2"
        }
    }
}

