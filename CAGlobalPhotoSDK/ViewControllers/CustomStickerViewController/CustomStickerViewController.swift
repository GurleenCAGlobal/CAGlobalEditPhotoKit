//
//  CustomStickerViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by iOS Developer on 16/10/23.
//

import UIKit
import AVFoundation
import MetalPerformanceShaders
import MetalKit
import AVKit


var globalGpuFilter:GPUImageFilter?

let kPGCustomStickerCameraCornerMargin: CGFloat = 8.0
let kPGCustomerStickerThreshold: Float = 0.42
let kPGCustomStickerClosingRadius: Int = 1
let kPGCustomStickerErosionRadius: Int = 4
let kPGCustomStickerErosionCount: Int = 1
let kPGCustomStickerCameraInset: CGFloat = 60.0
let kPGCustomStickerCameraOpacity: Float = 0.61803398875
let kPGCustomStickerCameraCornerLength: CGFloat = 30.0
let kPGCustomStickerCameraCornerInset: CGFloat = 52.0
let kPGCustomStickerCameraCornerWidth: Int = 3
let kPGCustomStickerAnimationDuration: TimeInterval = 0.61803398875
let kPGCustomStickerVideoPlayedKey = "kPGCustomStickerVideoPlayedKey"
let kStickerSize: CGSize = CGSize(width: 750, height: 750)
let kThumbnailSize: CGSize = CGSize(width: 100, height: 100)

protocol PGCustomStickerDelegate: AnyObject {
    func getCustomSticker(stickerImage: UIImage, thumbnailImage: UIImage)
    func getCrossButton()
}

class CustomStickerViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var gpuCleanImageView: GPUImageView!
    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var captureLabel: UILabel!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var infoButton: UIImageView!
    @IBOutlet weak var closeButton: UIImageView!
    @IBOutlet weak var videoView: UIView!
    var camera: GPUImageStillCamera?
    var filters: [GPUImageOutput] = []
    lazy var cropFilter: GPUImageCropFilter = {
        cropFilter = GPUImageCropFilter(cropRegion: croppingRect())
        return cropFilter
    }()
    
    lazy var thresholdFilter: GPUImageLuminanceThresholdFilter = {
        thresholdFilter = GPUImageLuminanceThresholdFilter()
        thresholdFilter.threshold = CGFloat(kPGCustomerStickerThreshold)
        
        if !hasCamera() {
            thresholdFilter.useNextFrameForImageCapture()
        }
        return thresholdFilter
    }()
    
    lazy var closingFilter: GPUImageClosingFilter = {
        closingFilter = GPUImageClosingFilter(radius: UInt(kPGCustomStickerClosingRadius))
        if !hasCamera() {
            closingFilter.useNextFrameForImageCapture()
        }
        return closingFilter
    }()
    
    lazy var erosionFilters: [GPUImageErosionFilter] = {
        var filters = [GPUImageErosionFilter]()
        for _ in 0..<kPGCustomStickerErosionCount {
            let filter = GPUImageErosionFilter(radius: UInt(kPGCustomStickerErosionRadius))
            if !hasCamera() {
                filter?.useNextFrameForImageCapture()
            }
            filters.append(filter!)
        }
        erosionFilters = filters
        return erosionFilters
    }()
    
    lazy var invertFilter: GPUImageColorInvertFilter = {
        invertFilter = GPUImageColorInvertFilter()
        if !hasCamera() {
            invertFilter.useNextFrameForImageCapture()
        }
        return invertFilter
    }()
    
    lazy var rgbFilter: GPUImageRGBFilter = {
        rgbFilter = GPUImageRGBFilter()
        //rgbFilter.setRed(0, green: 0, blue: 1)
        if !hasCamera() {
            rgbFilter.useNextFrameForImageCapture()
        }
        return rgbFilter
    }()
    
    lazy var chromaKeyFilter: GPUImageChromaKeyFilter = {
        chromaKeyFilter = GPUImageChromaKeyFilter()
        chromaKeyFilter.setColorToReplaceRed(0, green: 0, blue: 0)
        if !hasCamera() {
            chromaKeyFilter.useNextFrameForImageCapture()
        }
        return chromaKeyFilter
    }()
    
    lazy var monochromeFilter: GPUImageMonochromeFilter = {
        monochromeFilter = GPUImageMonochromeFilter()
        //monochromeFilter.color = GPUVector4
        if !hasCamera() {
            monochromeFilter.useNextFrameForImageCapture()
        }
        return monochromeFilter
    }()
    
    var resultData: Data?
    var cornerLayer = CAShapeLayer()
    var stickerImage: UIImage?
    var thumbnailImage: UIImage?
    var saveMode: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.resultImageView.image = self.stickerImage
                if self.saveMode {
                    self.setupSaveLabel()
                    UIView.animate(withDuration: kPGCustomStickerAnimationDuration) {
                        self.resultImageView.alpha = 1.0
                        self.captureLabel.alpha = 0.0
                        self.saveLabel.alpha = 1.0
                        self.cornerLayer.opacity = 0.0
                        self.closeButton.alpha = 0.0
                        self.closeButton.superview?.isUserInteractionEnabled = false
                        self.infoButton.alpha = 0.0
                        self.infoButton.superview?.isUserInteractionEnabled = false
                        self.noButton.alpha = 1.0
                        self.noButton.isEnabled = true
                        self.yesButton.alpha = 1.0
                        self.yesButton.isEnabled = true
                    }
                } else {
                    UIView.animate(withDuration: kPGCustomStickerAnimationDuration) {
                        self.resultImageView.alpha = 0.0
                        self.captureLabel.alpha = 1.0
                        self.saveLabel.alpha = 0.0
                        self.cornerLayer.opacity = 1.0
                        self.closeButton.alpha = 1.0
                        self.closeButton.superview?.isUserInteractionEnabled = true
                        self.infoButton.alpha = 1.0
                        self.infoButton.superview?.isUserInteractionEnabled = true
                        self.noButton.alpha = 0.0
                        self.noButton.isEnabled = false
                        self.yesButton.alpha = 0.0
                        self.yesButton.isEnabled = false
                    }
                }
            }
        }
    }
    var isCapturing: Bool = false
    var player: AVPlayer?
    weak var delegate: PGCustomStickerDelegate?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        thresholdFilter.threshold = CGFloat(kPGCustomerStickerThreshold)
        if !hasCamera() {
            thresholdFilter.useNextFrameForImageCapture()
        }
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupPlayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCamera()
        setupPlayerUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        camera?.stopCapture()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func hasCamera() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    // MARK: - Events
    @IBAction func cancelButtonTapped(_ sender: Any) {
        saveMode = false
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveSticker()
    }
    
    @objc func cameraTapped() {
        if !saveMode {
            captureSticker()
        }
    }
    
    @objc func videoTapped(_ recognizer: UIGestureRecognizer) {
        hideVideo()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        if videoView.isHidden {
            camera?.stopCapture()
            self.delegate?.getCrossButton()
            navigationController?.popViewController(animated: true)
        } else {
            hideVideo()
        }
    }
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        playVideo()
    }
    
    // MARK: - Stickers
    func processResult(_ image: UIImage) {
        stickerImage = image.resizeSticker(to: kStickerSize)
        thumbnailImage = image.resizeSticker(to: kThumbnailSize)
    }
    
    func captureSticker() {
        
        guard !isCapturing else {
            return
        }
        
        isCapturing = true
        
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
            
        switch cameraAuthorizationStatus {
        case .denied:
            self.presentCameraSettings()
        case .authorized:
            self.camera?.capturePhotoAsImageProcessedUp(toFilter: self.lastFilter()) { processedImage, _ in
                globalGpuFilter = self.lastFilter()
                self.processResult(processedImage!)
                self.saveMode = true
                self.isCapturing = false
            }
        case .restricted: break
            
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                if granted {
                    
                } else {
                    print("Denied access to \(cameraMediaType)")
                }
            }
        @unknown default: 
            break
        }
    }
    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Alert",
                                      message: "Camera access is denied",
                                      preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })

        present(alertController, animated: true)
    }
    
    @IBAction func touchedDownInButton(_ sender: Any) {
        if let button = sender as? UIButton {
            button.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func touchedUpButton(_ sender: Any) {
        if let button = sender as? UIButton {
            button.backgroundColor = UIColor.clear
        }
    }
    
    func saveSticker() {
        UIView.animate(withDuration: kPGCustomStickerAnimationDuration, animations: {
            self.saveLabel.alpha = 0.0
            self.yesButton.alpha = 0.0
            self.noButton.alpha = 0.0
            self.yesButton.isEnabled = false
            self.noButton.isEnabled = false
        }) { _ in
            self.navigationController?.popViewController(animated: true)
//            UIImage *filteredPhoto = [filterOutput imageFromCurrentlyProcessedOutput];
//            self.saveSticker(sticker: self.stickerImage!, thumbnail: self.thumbnailImage!)
            self.delegate?.getCustomSticker(stickerImage: self.stickerImage!, thumbnailImage: self.thumbnailImage!)
        }
        camera?.stopCapture()
    }
    
    // Captures the image from a given view
    func captureImageInView(inView: UIView) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: inView.bounds.size)
        let image = renderer.image { _ in
            inView.drawHierarchy(in: inView.bounds, afterScreenUpdates: true)
        }
        
        let data = image.highestQualityJPEGNSData
        let iageHigh = UIImage(data: data)
        return iageHigh
    }
    
    // MARK: - UI
    func setupSaveLabel() {
        let randomTextLines = [
            NSLocalizedString("Check out your custom sticker!", comment: ""),
            NSLocalizedString("Nice drawing!", comment: ""),
            NSLocalizedString("Looks good.", comment: ""),
            NSLocalizedString("You must be an artist.", comment: ""),
            NSLocalizedString("Perfect!", comment: "")
        ]
        
        let rnd = Int.random(in: 0..<randomTextLines.count)

        let firstLine = randomTextLines[rnd]
        let secondLine = NSLocalizedString("Add to your sticker collection?", comment: "")
        
        saveLabel.text = "\(firstLine)\n\(secondLine)"
    }
    
    // MARK: - Mask and Corners
    func addMask(to view: UIView, color: UIColor) {
        let overlayPath = UIBezierPath(rect: view.bounds)
        let width = view.bounds.size.width - 2.0 * kPGCustomStickerCameraInset
        let top = self.resultImageView.frame.origin.y// + 50
        let transparentPath = UIBezierPath(rect: CGRect(x: kPGCustomStickerCameraInset, y: top, width: width, height: width))
        overlayPath.append(transparentPath)
        overlayPath.usesEvenOddFillRule = true
        let fillLayer = CAShapeLayer()
        fillLayer.path = overlayPath.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = color.cgColor
        view.layer.addSublayer(fillLayer)
    }
    
    func addMaskCoverAll(to view: UIView, color: UIColor) {
        self.gpuCleanImageView.layer.removeFromSuperlayer()
        let overlayPath = UIBezierPath(rect: view.bounds)
        let transparentPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 0, height: 0))
        overlayPath.append(transparentPath)
        overlayPath.usesEvenOddFillRule = true
        let fillLayer = CAShapeLayer()
        fillLayer.path = overlayPath.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = color.cgColor
        view.layer.addSublayer(fillLayer)
    }
    
    func addCorners(to view: UIView) {
        let width = view.bounds.size.width - 2.0 * kPGCustomStickerCameraCornerInset
        let top = self.resultImageView.frame.origin.y /*+ 50*/ - kPGCustomStickerCameraCornerMargin
        let path = UIBezierPath()
        // top left
        path.move(to: CGPoint(x: kPGCustomStickerCameraCornerInset + kPGCustomStickerCameraCornerLength, y: top))
        path.addLine(to: CGPoint(x: kPGCustomStickerCameraCornerInset, y: top))
        path.addLine(to: CGPoint(x: kPGCustomStickerCameraCornerInset, y: top + kPGCustomStickerCameraCornerLength))
        // bottom left
        path.move(to: CGPoint(x: kPGCustomStickerCameraCornerInset, y: top + width - kPGCustomStickerCameraCornerLength))
        path.addLine(to: CGPoint(x: kPGCustomStickerCameraCornerInset, y: top + width))
        path.addLine(to: CGPoint(x: kPGCustomStickerCameraCornerInset + kPGCustomStickerCameraCornerLength, y: top + width))
        // bottom right
        path.move(to: CGPoint(x: kPGCustomStickerCameraCornerInset + width - kPGCustomStickerCameraCornerLength, y: top + width))
        path.addLine(to: CGPoint(x: kPGCustomStickerCameraCornerInset + width, y: top + width))
        path.addLine(to: CGPoint(x: kPGCustomStickerCameraCornerInset + width, y: top + width - kPGCustomStickerCameraCornerLength))
        // top right
        path.move(to: CGPoint(x: kPGCustomStickerCameraCornerInset + width, y: top + kPGCustomStickerCameraCornerLength))
        path.addLine(to: CGPoint(x: kPGCustomStickerCameraCornerInset + width, y: top))
        path.addLine(to: CGPoint(x: kPGCustomStickerCameraCornerInset + width - kPGCustomStickerCameraCornerLength, y: top))
        self.cornerLayer.path = path.cgPath
        self.cornerLayer.lineWidth = CGFloat(kPGCustomStickerCameraCornerWidth)
        self.cornerLayer.lineCap = .square
        self.cornerLayer.fillColor = UIColor.clear.cgColor
        self.cornerLayer.strokeColor = UIColor.white.cgColor
        view.layer.addSublayer(self.cornerLayer)
    }
    
    // MARK: - UI Setup
    func setupUI() {
        // Apply 3pt border to buttons
        yesButton.layer.borderWidth = 3.0
        yesButton.layer.borderColor = UIColor.white.cgColor
        yesButton.layer.masksToBounds = true
        noButton.layer.borderWidth = 3.0
        noButton.layer.borderColor = UIColor.white.cgColor
        noButton.layer.masksToBounds = true
    }
    
    // MARK: - GPUImage
    func lastFilter() -> GPUImageFilter? {
        return filters.last as? GPUImageFilter
    }
    
    func setupCamera() {
        gpuCleanImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        addMask(to: gpuCleanImageView, color: UIColor(red: 0, green: 0, blue: 0, alpha: CGFloat(kPGCustomStickerCameraOpacity)))
        addCorners(to: gpuCleanImageView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(cameraTapped))
        gpuCleanImageView.addGestureRecognizer(tap)
        resultImageView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: CGFloat(kPGCustomStickerCameraOpacity))
        if !hasCamera() {
            gpuCleanImageView.backgroundColor = UIColor.magenta
            return
        }
        DispatchQueue.main.async {
            self.camera = GPUImageStillCamera()
            if let camera = self.camera {
                camera.outputImageOrientation = .portrait
                self.setupFilters()
                self.applyFilterChain(self.filters, start: camera)
                camera.addTarget(self.gpuCleanImageView)
                camera.startCapture()
            }
        }
    }
    
    func setupFilters() {
        var filters = [GPUImageOutput]()
        filters.append(cropFilter)
        filters.append(self.thresholdFilter)
        filters.append(self.closingFilter)
        filters.append(contentsOf: self.erosionFilters)
        filters.append(self.invertFilter)
        filters.append(self.rgbFilter)
        filters.append(self.chromaKeyFilter)
        filters.append(self.monochromeFilter)
        self.filters = filters
    }
    
    func applyFilterChain(_ filters: [GPUImageOutput], start: GPUImageOutput) {
        var targets = filters
        targets.insert(start, at: 0)
        for idx in 0..<targets.count - 1 {
            let output = targets[idx]
            let input = targets[idx + 1]
            output.addTarget(input as? GPUImageInput)
        }
    }
    
    func croppingRect() -> CGRect {
        guard let videoOutput = self.camera?.captureSession.outputs.first as? AVCaptureVideoDataOutput,
              let settings = videoOutput.videoSettings,
              let cameraWidth = settings["Width"] as? NSNumber,
              let cameraHeight = settings["Height"] as? NSNumber else {
            return CGRect.zero
        }
        
        let cameraAspectRatio = min(CGFloat(cameraWidth.floatValue), CGFloat(cameraHeight.floatValue)) / max(CGFloat(cameraWidth.floatValue), CGFloat(cameraHeight.floatValue))
        let containerWidth = gpuCleanImageView.bounds.size.width
        let containerHeight = gpuCleanImageView.bounds.size.height
        let targetSize = containerWidth - 2.0 * CGFloat(kPGCustomStickerCameraInset)
        let viewAspectRatio = containerWidth / containerHeight
        var xAxis, yAxis, width, height: CGFloat
        if cameraAspectRatio < viewAspectRatio {
            let adjustedCameraHeight = containerWidth / cameraAspectRatio
            xAxis = CGFloat(kPGCustomStickerCameraInset) / containerWidth
            yAxis = resultImageView.frame.origin.y / adjustedCameraHeight
            width = targetSize / containerWidth
            height = targetSize / adjustedCameraHeight
        } else {
            let adjustedCameraWidth = containerHeight * cameraAspectRatio
            xAxis = (adjustedCameraWidth - targetSize) / 2.0 / adjustedCameraWidth
            yAxis = resultImageView.frame.origin.y / containerHeight
            width = targetSize / adjustedCameraWidth
            height = targetSize / containerHeight
        }
        return CGRect(x: xAxis, y: yAxis, width: width, height: height)
    }
    
    // MARK: - Video
    func setupPlayer() {
        guard let url = Bundle.main.url(forResource: "stickers", withExtension: "mp4") else {
            return
        }
        player = AVPlayer(url: url)
        player?.actionAtItemEnd = .none
        player?.isMuted = true
        NotificationCenter.default.addObserver(self, selector: #selector(videoFinished(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func setupPlayerUI() {
        guard let player = player else {
            return
        }
        let layer = AVPlayerLayer(player: player)
        layer.frame = videoView.bounds
        layer.videoGravity = .resizeAspect
        videoView.layer.addSublayer(layer)
        let tap = UITapGestureRecognizer(target: self, action: #selector(videoTapped(_:)))
        videoView.addGestureRecognizer(tap)
    }
    
    @objc func videoFinished(_ notification: Notification) {
        player?.seek(to: CMTime.zero)
    }
    
    func playVideo() {
        player?.seek(to: CMTime.zero)
        player?.play()
        videoView.alpha = 0.0
        videoView.isHidden = false
        infoButton.superview?.isUserInteractionEnabled = false
        UIView.animate(withDuration: kPGCustomStickerAnimationDuration) {
            self.videoView.alpha = 1.0
        } completion: { _ in
            self.infoButton.superview?.isUserInteractionEnabled = true
        }
    }
    
    func hideVideo() {
        player?.pause()
        UIView.animate(withDuration: kPGCustomStickerAnimationDuration) {
            self.videoView.alpha = 0.0
        } completion: { _ in
            self.videoView.isHidden = true
        }
    }
    
    func nextStickerNumber() -> Int {
        let lastStickerNumber = UserDefaults.standard.integer(forKey: kPGCSMLastStickerNumberKey)
        return lastStickerNumber + 1
    }
    
    func stickerDirectoryURL() -> URL {
        let manager = FileManager.default
        guard let documentsDirectory = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Unable to access documents directory")
        }
        
        let stickerDirectory = documentsDirectory.appendingPathComponent(kPGCustomStickerManagerDirectory)
        
        do {
            try manager.createDirectory(at: stickerDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating sticker directory: \(error)")
        }
        
        return stickerDirectory
    }
    
    func saveSticker(sticker: UIImage, thumbnail: UIImage) {
        let number = nextStickerNumber()
        // Appending a random suffix to prevent caching by imgly
        let image = self.thresholdFilter.imageFromCurrentFramebuffer()

        let data = image?.withTintColor(.white).pngData()
        let url = self.stickerDirectoryURL().appendingPathComponent("fileName.png")

        do {
            try data?.write(to: url, options: .atomic)
        } catch {
            print("Error writing thumbnail image: \(error)")
        }
        
        let dataThumb = thumbnail.pngData()
        let urlThumb = self.stickerDirectoryURL().appendingPathComponent("fileNameurlThumb.png")

        do {
            try dataThumb?.write(to: urlThumb, options: .atomic)
        } catch {
            print("Error writing thumbnail image: \(error)")
        }

        UserDefaults.standard.set(number, forKey: kPGCSMLastStickerNumberKey)
        UserDefaults.standard.synchronize()
    }

}
