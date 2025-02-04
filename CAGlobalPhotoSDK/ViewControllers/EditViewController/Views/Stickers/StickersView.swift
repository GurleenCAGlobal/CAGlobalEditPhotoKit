//
//  StickersView.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 19/05/23.
//

import UIKit

// Define a protocol for the cell's data source
protocol StickersViewDelegate: AnyObject {
    func selectedStickerImage(image: UIImage, stickerSelection: String, stickerUrl: String,isImageDepth:Bool?)
    func editStickerImage(oldImage: UIImage, oldImageTintColor: UIColor, image: UIImage, stickerSelection: String, isImageDepth:Bool?,isBackgroundRemoved:Bool?,isGallery:Bool?)
    func openCameraForCustomSticker(isEdit:Bool)
}

class StickersView: UIView, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    
    // MARK: - Outlets
    
    // Outlet for the base view of the stickers view
    @IBOutlet weak var baseView: UIView!
    
    // Outlets for the Collection View
    @IBOutlet weak var stickerCollectionView: UICollectionView!
    @IBOutlet weak var subStickerCollectionView: UICollectionView!
    
    private var stickerManager = StickerManager()
    var stickerData = [String]()
    var stickerURLData = [String]()
    var stickerNameURLData = [[String:Any]]()
    private(set) var customSticker = [UIImage]()
    private(set) var subStickerData = [UIImage]()
    private(set) var subStickerDataToDisplay = [UIImage]()
    //private(set) var subCloudsStickerData = [PGCloudAssetImage]()
    private(set) var subStickersDataApi = [SubStickerModel]()
    //var stickerCategories = [PGCloudAssetCategory]()
    
    weak var delegate: StickersViewDelegate?
    var isEdit: Bool?
    var imagePicker = UIImagePickerController()
    var stickerSelection = Int()
    var stickerSelectionString = String()
    var oldImage = UIImage()
    var oldImageTintColor = UIColor()
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
        
        self.stickerData = self.stickerManager.getStickerData()
        self.stickerURLData = self.stickerManager.getStickerData()
        self.configureCustomStickerArray()
        //self.subStickerData = self.stickerManager.getShapesData()
        self.stickerSelection = 1
        self.stickerSelectionString = "cloud"
//        DispatchQueue.main.async {
            self.stickersAll()
//        }
        // Usage
        NotificationCenter.default.addObserver(self, selector: #selector(handleAdditionalStickersDownloadedNotification), name: Notification.Name("kPGImglyManagerStickersUpdatedNotification"), object: nil)
        
        self.initCollectionView()
    }
    
    @objc func handleAdditionalStickersDownloadedNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let progress = userInfo["progress"] as? CGFloat else { return }
        if progress >= 1.0 {
            NotificationCenter.default.post(name: Notification.Name("StickerDownloadingNotification"), object: nil, userInfo: userInfo)
        } else {
            NotificationCenter.default.post(name: Notification.Name("StickerDownloadingNotification"), object: nil, userInfo: userInfo)
        }
            self.stickersAll()
    }
    
    private func loadViewFromNib() -> UIView {
        let bundlePath = Bundle(for: StickersView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = bundlePath != nil ? Bundle(path: bundlePath!) : nil
        let nib = UINib(nibName: StickersView.className, bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return nibView ?? UIView()
    }
    
    @objc func stickersAll() {
        /*
         DispatchQueue.global(qos: .background).async { [weak self] in
             let cac = PGCloudAssetClient.sharedInstance()
             var catalog = PGCloudAssetCatalog()
             if let catalog = cac?.currentCatalog() {
                 let activePrinterType = PGQueueController.shared().activePrinterType
                 
                 var stickerCategories = [PGCloudAssetCategory]()
                 stickerCategories = catalog.categories(forAssetType: PGCloudAssetCategoryTypeSticker, andDeviceType: activePrinterType) ?? []
                 var stickerURLData = [[String: Any]]()
                 for category in stickerCategories {
                     var stickerThumnailURL = [UIImage]()
                     var stickerAssestsURL = [UIImage]()
                     let cloudsAssets = category.sortedImageAssets()
                     if let cloudAssests = cloudsAssets {
                         for sticker in cloudAssests {
                             if sticker.supportsDeviceType(activePrinterType) {
                                 let localURL = URL(fileURLWithPath: PGCloudAssetClient.sharedInstance().storage.localUrl(forAsset: sticker))
                                 let localThumbnailURL = URL(fileURLWithPath: PGCloudAssetClient.sharedInstance().storage.localThumbnailUrl(forAsset: sticker))
                                 _ = sticker.name
                                 if sticker.name.hasSuffix("_color.png") || sticker.name.hasSuffix("_color") {
                                 }
                                 if let image_Data = try? Data(contentsOf: localURL) {
                                     let imagephoto = UIImage.init(data: image_Data)!
                                     stickerAssestsURL.append(imagephoto)
                                 }
                                 
                                 if let image_Data = try? Data(contentsOf: localThumbnailURL) {
                                     let imagephoto = UIImage.init(data: image_Data)!
                                     switch UIDevice().type {
                                     case .iPhoneSE, .iPhone5, .iPhone5S:
                                         stickerThumnailURL.append(imagephoto.resizeSticker(to: CGSize(width: (imagephoto.size.width)/10, height: (imagephoto.size.height)/10))!)
                                     case .iPhone6, .iPhone6S:
                                         stickerThumnailURL.append(imagephoto.resizeSticker(to: CGSize(width: (imagephoto.size.width)/10, height: (imagephoto.size.height)/10))!)
                                     default:
                                         stickerThumnailURL.append(imagephoto)
                                     }
                                 }
                             }
                         }
                     }
                     
                     if stickerAssestsURL.count > 0 {
                         var dictionary = [String: Any]()
                         dictionary["title"] = category.title
                         dictionary["stickerAssestsURL"] = stickerAssestsURL
                         dictionary["stickerThumbnailURL"] = stickerThumnailURL
                         stickerURLData.append(dictionary)
                     }
                 }
                 
                 DispatchQueue.main.async {
                     self?.stickerNameURLData = stickerURLData
                     self?.stickerData = stickerURLData.compactMap { $0["title"] as? String }
                     let data2 = self?.stickerNameURLData[0]
                     let dictionary2 = data2
                     let assestUrl = dictionary2?["stickerThumbnailURL"] as? [UIImage]
                     self?.subStickerData = assestUrl ?? []
                     let stickerAssestsURL = dictionary2?["stickerAssestsURL"] as? [UIImage]
                     self?.subStickerDataToDisplay = stickerAssestsURL ?? []
                     self?.stickerCollectionView.reloadData()
                 }
             } else {
                 // handle the case where catalog is nil
             }
         }
         **/
//        DispatchQueue.global(qos: .background).async { [weak self] in
//            
//            let cac = PGCloudAssetClient.sharedInstance()
//            var catalog = PGCloudAssetCatalog()
//            if let catalog = cac?.currentCatalog() {
//                let activePrinterType = PGQueueController.shared().activePrinterType
//                
//                self?.stickerCategories = catalog.categories(forAssetType: PGCloudAssetCategoryTypeSticker, andDeviceType: activePrinterType) ?? []
//                if let stickerCategories = self?.stickerCategories {
//                    for category in stickerCategories {
//                        self?.stickerURLData.append(category.thumbnailURL)
//                        var cloudAssets = [PGCloudAssetImage]()
//                        cloudAssets = category.sortedImageAssets()
//                        var stickerThumnailURL = [UIImage]()
//                        var stickerAssestsURL = [UIImage]()
//                        for sticker in cloudAssets {
//                            if sticker.supportsDeviceType(activePrinterType) {
//                                let localURL = URL(fileURLWithPath: PGCloudAssetClient.sharedInstance().storage.localUrl(forAsset: sticker))
//                                let localThumbnailURL = URL(fileURLWithPath: PGCloudAssetClient.sharedInstance().storage.localThumbnailUrl(forAsset: sticker))
//                                _ = sticker.name
//                                if sticker.name.hasSuffix("_color.png") || sticker.name.hasSuffix("_color") {
//                                }
//                                if let image_Data = try? Data(contentsOf: localURL) {
//                                    let imagephoto = UIImage.init(data: image_Data)!
//                                    stickerAssestsURL.append(imagephoto)
//                                }
//                                
//                                if let image_Data = try? Data(contentsOf: localThumbnailURL) {
//                                    let imagephoto = UIImage.init(data: image_Data)!
//                                    switch UIDevice().type {
//                                    case .iPhoneSE, .iPhone5, .iPhone5S:
//                                        stickerThumnailURL.append(imagephoto.resizeSticker(to: CGSize(width: (imagephoto.size.width)/10, height: (imagephoto.size.height)/10))!)
//                                    case .iPhone6, .iPhone6S:
//                                        stickerThumnailURL.append(imagephoto.resizeSticker(to: CGSize(width: (imagephoto.size.width)/10, height: (imagephoto.size.height)/10))!)
//                                    default:
//                                        stickerThumnailURL.append(imagephoto)
//                                    }
//                                }
//                            }
//                        }
//                        if stickerAssestsURL.count > 0 {
//                            var dictionary = [String: Any]()
//                            dictionary["title"] = category.title
//                            dictionary["stickerAssestsURL"] = stickerAssestsURL
//                            dictionary["stickerThumbnailURL"] = stickerThumnailURL
//                            self?.stickerNameURLData.append(dictionary)
//                            self?.stickerData.append(category.title)
//                            let data2 = self?.stickerNameURLData[0]
//                            let dictionary2 = data2
//                            let assestUrl = dictionary2?["stickerThumbnailURL"] as? [UIImage]
//                            self?.subStickerData = assestUrl ?? []
//                            let stickerAssestsURL = dictionary2?["stickerAssestsURL"] as? [UIImage]
//                            self?.subStickerDataToDisplay = stickerAssestsURL ?? []
//                        }
//                        DispatchQueue.main.async {
//                            self?.stickerCollectionView.reloadData()
//                        }
//                    }
//                }
//            } else {
//                // handle the case where catalog is nil
//            }
//        }
    }
    
    private func initCollectionView() {
        let bundlePath = Bundle(for: StickersCell.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = bundlePath != nil ? Bundle(path: bundlePath!) : nil

        let nib = UINib(nibName: StickersCell.className, bundle: bundle)
        stickerCollectionView.register(nib, forCellWithReuseIdentifier: StickersCell.className)
        stickerCollectionView.dataSource = self
        stickerCollectionView.delegate = self
        
        let subNib = UINib(nibName: StickersCell.className, bundle: bundle)
        subStickerCollectionView.register(subNib, forCellWithReuseIdentifier: StickersCell.className)
        subStickerCollectionView.dataSource = self
        subStickerCollectionView.delegate = self
    }
    
    func configureCustomStickerArray() {
        if let outData = UserDefaults.standard.data(forKey: "kUserData") {
            // customStickerArray = NSKeyedUnarchiver.unarchiveObject(with: outData) as! [UIImage]
        }
        if customStickerArray.count > 0 {
            if stickerData[1] != "Custom" {
                self.stickerData.insert("Custom", at: 1)
            }
            self.customSticker = customStickerArray
            if self.stickerSelection == 0 {
                self.stickerSelection = 1
                self.subStickerData = customSticker
                self.subStickerDataToDisplay = customSticker
                self.stickerSelectionString = "customSticker"
            } else if self.stickerSelection == 1 {
                self.stickerSelection = 1
                self.subStickerData = customSticker
                self.subStickerDataToDisplay = customSticker
                self.stickerSelectionString = "customSticker"
            }
        } else {
            if stickerData.count > 1, stickerData[1] == "Custom" {
                self.stickerData.remove(at: 1)
                self.customSticker.removeAll()
            }
        }
        let isContain = self.stickerData.contains(where: { value in
            if value == "Sports" {
                return true
            }
            return false //Change to false if wants to add these three stickers
        })
        if isContain == false {
            self.stickerData.insert("Sports", at: self.stickerData.count)
            self.stickerData.insert("Nature", at: self.stickerData.count)
            self.stickerData.insert("Get Well", at: self.stickerData.count)

        }
    }
    
    func toRefreshSelection() {
        self.stickerSelection = 1
        self.stickerSelectionString = "cloud"
        self.stickerCollectionView.reloadData()
        self.subStickerCollectionView.reloadData()

    }
    
    func setSelectionOnCancelAddPhoto() {
        self.stickerSelection = 1
        self.stickerCollectionView.reloadData()
        self.subStickerCollectionView.reloadData()
    }
}

extension StickersView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of cells in the table view
        switch collectionView {
        case self.stickerCollectionView:
            if stickersFromApi.count > 0 {
                return self.stickerData.count + stickersFromApi.count
            }
            return self.stickerData.count
        case self.subStickerCollectionView:
            if self.stickerSelection == 1 && self.customSticker.count > 0 {
                return self.customSticker.count
            }
            if self.stickerData.count == stickerSelection {
                if subStickersFromApi.count > 0 {
                    return subStickersFromApi.count
                }
            }
            return self.subStickerData.count
        default:
            break;
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickersCell.className, for: indexPath) as? StickersCell else {
            let cell = StickersCell()
            return cell
        }
        cell.dataSource = self
        cell.delegate = self
        switch collectionView {
        case self.stickerCollectionView:
            if self.stickerData.count <= indexPath.row {
                if stickersFromApi.count > 0 {
                    let data = stickersFromApi[indexPath.row - self.stickerData.count]
                    var subSticker : SubStickerModel!
                    for item in subStickersFromApi {
                        if item.eventId == data.id {
                            subSticker = item
                            break
                        }
                    }
                    cell.configureApiData(with: data, subImage: subSticker, isSubSelected: false)
                    if self.stickerSelection == indexPath.row {
                        cell.layer.borderWidth = 1
                        cell.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
                    } else {
                        cell.layer.borderWidth = 0
                    }
                }
            } else {
                let data = self.stickerData[indexPath.row]
                let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
                let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)!

                cell.configure(with: data, subImage:UIImage.init(named: "customSticker", in: bundle, compatibleWith: nil)! , isSubSelected: false)

                if indexPath.row>0 && self.customSticker.count == 0 {
                    if self.stickerNameURLData.count > indexPath.row - 1 {
                        let data2 = self.stickerNameURLData[indexPath.row - 1]
                        let dictionary = data2
                        let assestUrl = dictionary["stickerThumbnailURL"] as? [UIImage]
                        let title = dictionary["title"] as? String ?? ""
                        if assestUrl?.count ?? 0 > 0 {
                            cell.configure(with: title, subImage: (assestUrl?[0])!, isSubSelected: false)
                        } else {
                            let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
                            let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)!

                            cell.configure(with: title, subImage: UIImage.init(named: "load.png", in: bundle, compatibleWith: nil)!, isSubSelected: false)
                        }
                    }
                } else if indexPath.row > 1 && self.customSticker.count > 0 {
                    if self.stickerNameURLData.count > indexPath.row - 2 {
                        let data2 = self.stickerNameURLData[indexPath.row - 2]
                        let dictionary = data2
                        let assestUrl = dictionary["stickerThumbnailURL"] as? [UIImage]
                        let title = dictionary["title"] as? String ?? ""
                        if assestUrl?.count ?? 0 > 0 {
                            cell.configure(with: title, subImage: (assestUrl?[0])!, isSubSelected: false)
                        } else {
                            cell.configure(with: title, subImage: UIImage.init(named: "load.png", in: bundle, compatibleWith: nil)!, isSubSelected: false)
                        }
                    }
                }
                
                if indexPath.row == self.stickerData.count - 3 {
                    let data = self.stickerData[indexPath.row]
                    cell.configure(with: data, subImage:self.stickerManager.sportsCategoryStickers().first! , isSubSelected: false)
                } else if indexPath.row == self.stickerData.count - 2 {
                    let data = self.stickerData[indexPath.row]
                    cell.configure(with: data, subImage:self.stickerManager.natureCategoryStickers().first! , isSubSelected: false)
                } else if indexPath.row == self.stickerData.count - 1 {
                    let data = self.stickerData[indexPath.row]
                    cell.configure(with: data, subImage:self.stickerManager.getWellCategoryStickers().first! , isSubSelected: false)
                }
            
                if data == "Custom" {
                    cell.stickerImageView.image = customSticker.first
                }
                if self.stickerSelection == indexPath.row {
                    cell.layer.borderWidth = 1
                    cell.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
                } else {
                    cell.layer.borderWidth = 0
                }
            }
        case self.subStickerCollectionView:
            cell.heightConstraint.constant = 0
            
            if self.stickerData.count == stickerSelection {
                if subStickersDataApi.count > 0 {
                    let data = subStickersDataApi[indexPath.row]
                    let sticker = stickersFromApi[0]
                    cell.configureApiData(with: sticker, subImage: data, isSubSelected: true)
                }
            } else {
                let data = self.subStickerData[indexPath.row]
                cell.configure(with: "", subImage: data, isSubSelected: true)
//                if self.stickerSelection == 1 && self.customSticker.count > 0 {
//                    cell.stickerImageView.tintColor = UIColor(named: .stickerColor, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!
//                }
//                if self.stickerSelection == 0 && self.customSticker.count == 0 {
//                    cell.stickerImageView.tintColor = UIColor(named: .stickerColor, in: Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? ""), compatibleWith: nil)!
//                }
            }
            
            if self.stickerSelection == 0 && self.customSticker.count > 0 {
                cell.configureCustomStickers(with: self.customSticker[indexPath.row], isSubSelected: false)
            }
            stickerCollectionView.reloadData()

        default:
            break;
        }
        
        return cell
    }
}

extension StickersView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? StickersCell
        switch collectionView {
        case self.stickerCollectionView:
            if self.customSticker.count > 0 {
                if indexPath.row == 0 {
                    self.delegate?.openCameraForCustomSticker(isEdit: self.isEdit ?? false)
                    self.stickerSelectionString = "customSticker"
                } else if indexPath.row == 1 {
                    self.subStickerData = customSticker
                    self.subStickerDataToDisplay = customSticker
                    self.stickerSelectionString = "customSticker"
//                } else if indexPath.row == 2 {
//                    self.subStickerData = self.stickerManager.getShapesData()
//                    self.stickerSelectionString = "shapes"
                } else if indexPath.row > 1 && self.stickerNameURLData.count > indexPath.row - 2 {
                    let data2 = self.stickerNameURLData[indexPath.row - 2]
                    let dictionary = data2
                    let assestUrl = dictionary["stickerThumbnailURL"] as? [UIImage]
                    self.subStickerData = assestUrl ?? []
                    
                    let stickerAssestsURL = dictionary["stickerAssestsURL"] as? [UIImage]
                    self.subStickerDataToDisplay = stickerAssestsURL ?? []
                    
                    self.stickerSelectionString = "cloud"
                } else if indexPath.row == self.stickerData.count - 3 {
                    self.subStickerData = self.stickerManager.sportsCategoryStickers()
                    self.subStickerDataToDisplay = self.stickerManager.sportsCategoryStickers()
                } else if indexPath.row == self.stickerData.count - 2 {
                    self.subStickerData = self.stickerManager.natureCategoryStickers()
                    self.subStickerDataToDisplay = self.stickerManager.natureCategoryStickers()
                } else if indexPath.row == self.stickerData.count - 1 {
                    self.subStickerData = self.stickerManager.getWellCategoryStickers()
                    self.subStickerDataToDisplay = self.stickerManager.getWellCategoryStickers()
                }
            } else {
                if indexPath.row == 0 {
                    self.delegate?.openCameraForCustomSticker(isEdit: self.isEdit ?? false)
                    self.stickerSelectionString = "customSticker"
//                } else if indexPath.row == 1 {
//                    self.subStickerData = self.stickerManager.getShapesData()
//                    self.stickerSelectionString = "shapes"
                } else if indexPath.row > 0 && self.stickerNameURLData.count > indexPath.row - 1 {
                    let data2 = self.stickerNameURLData[indexPath.row - 1]
                    let dictionary = data2
                    let assestUrl = dictionary["stickerThumbnailURL"] as? [UIImage]
                    self.subStickerData = assestUrl ?? []
                    
                    let stickerAssestsURL = dictionary["stickerAssestsURL"] as? [UIImage]
                    self.subStickerDataToDisplay = stickerAssestsURL ?? []

                    self.stickerSelectionString = "cloud"
                } else if indexPath.row == self.stickerData.count - 3 {
                    self.subStickerData = self.stickerManager.sportsCategoryStickers()
                    self.subStickerDataToDisplay = self.stickerManager.sportsCategoryStickers()
                } else if indexPath.row == self.stickerData.count - 2 {
                    self.subStickerData = self.stickerManager.natureCategoryStickers()
                    self.subStickerDataToDisplay = self.stickerManager.natureCategoryStickers()
                } else if indexPath.row == self.stickerData.count - 1 {
                    self.subStickerData = self.stickerManager.getWellCategoryStickers()
                    self.subStickerDataToDisplay = self.stickerManager.getWellCategoryStickers()
                }
            }
            self.subStickerCollectionView.isHidden = false
            if self.stickerData.count == stickerSelection {
                let data = stickersFromApi[self.stickerData.count - indexPath.row]
                for (_, item) in subStickersFromApi.enumerated() {
                    if item.eventId == data.id {
                        subStickersDataApi.append(item)
                    }
                }
                self.stickerSelectionString = "api"
            }
            self.stickerSelection = indexPath.row
            self.subStickerCollectionView.reloadData()
        case self.subStickerCollectionView:

            if self.stickerData.count != stickerSelection {
                let data = self.subStickerData[indexPath.row]
                if customStickerArray.count > 0 {
                    cell?.handleSelection(with: data, isEdit: self.isEdit ?? false, isCustomSticker: true, urlString: "")
                } else {
                    cell?.handleSelection(with: data, isEdit: self.isEdit ?? false, isCustomSticker: false, urlString: "")
                }
            }
        default:
            break;
        }
    }
    
    func saveImageInDocumentDirectory(image: UIImage, fileName: String) -> URL? {
        
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        if let imageData = image.pngData() {
            try? imageData.write(to: fileURL, options: .atomic)
            return fileURL
        }
        return nil
    }
}

extension StickersView: StickersCellDataSource {
    func getImage() -> [String] {
        // Return the image for the cell at the specified index path
        return self.stickerData
    }
}

extension StickersView: StickersCellDelegate {
    
    func didSelectCell(with data: UIImage, isEdit: Bool, isCustomSticker: Bool, urlString: String, isImageDepth: Bool? = false) {
        // Handle cell selection
        if !isEdit {
            if isCustomSticker == true {
                self.stickerSelection = 0
            }
            self.delegate?.selectedStickerImage(image: data, stickerSelection: self.stickerSelectionString, stickerUrl: urlString, isImageDepth: isImageDepth)
        } else {
            if isCustomSticker == true {
                self.stickerSelection = 0
            }
            self.delegate?.editStickerImage(oldImage: self.oldImage, oldImageTintColor: self.oldImageTintColor, image: data, stickerSelection: self.stickerSelectionString, isImageDepth: isImageDepth,isBackgroundRemoved: false, isGallery: false)
        }
    }
}
