//
//  CAGGallery.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 27/04/23.
//

import UIKit
import Photos

class CAGalleryViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, LiquidLayoutDelegate {
    
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    var allPhotos: [PHAsset]!
    var allAlbumArray: [PHAsset]!
    var imageIndex = Int()
    var selectedFolderIndex = Int()
    let imageRequest = PHImageRequestOptions()
    var numberOfColumnsInGrid : CGFloat = 2
    var filterTimer : Timer?
    var galleryViewModel = GalleryViewModel()
    var isLandscape = true

    override func viewDidLoad() {
        self.selectedFolderIndex = 0
        self.imageRequest.isNetworkAccessAllowed = true
        self.initialiseCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        filterTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.updateFilterTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateFilterTimer() {
        self.fetchingImagesFromGallery()
        filterTimer?.invalidate()
    }
    
    func initialiseCollectionView() {
        self.galleryCollectionView.collectionViewLayout.invalidateLayout()
        let mosaicLayout = LiquidCollectionViewLayout()
        mosaicLayout.delegate = self
        mosaicLayout.numberOfColumns = numberOfColumnsInGrid
        mosaicLayout.cellWidth = UIScreen.main.bounds.width / numberOfColumnsInGrid - CGFloat(8)
        self.galleryCollectionView.collectionViewLayout = mosaicLayout
    }
    
    // MARK: - Init methods
    @objc static func presentCustomRulerBlankCanvas(currentViewController:UIViewController){
            
            let rulerViewController = CustomRulerCanvasViewController(nibName: CustomRulerCanvasViewController.className, bundle: nil)
            rulerViewController.image = UIImage(named: "blank_canvas")
            rulerViewController.isBlankCanvasRuler = true
            rulerViewController.selectedColor = .white
            rulerViewController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            rulerViewController.modalPresentationCapturesStatusBarAppearance = true
            GlobalHelper.sharedManager.navigationController.pushViewController(rulerViewController, animated: true)
    }
    
    // MARK: - Fetching photos from gallery to show it on Collection View
    func fetchingImagesFromGallery() {
        if self.galleryViewModel.checkingPhotoLibraryPermissions() == "false" {
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    DispatchQueue.main.async(execute: {
                        self.getAssetsCollection()
                    })
                }
            }
        }
        
        if self.galleryViewModel.checkingPhotoLibraryPermissions() == "true" {
            self.getAssetsCollection()
        }
        
        if self.galleryViewModel.checkingPhotoLibraryPermissions() == "denied" {
            self.showPhotosAccessFromSettingsPopup()
        }
    }
    
    func showPhotosAccessFromSettingsPopup() {
        let title = "Unable to access the Photos"
        let message = "To enable access, go to Settings > Privacy > Photos and turn on Photos access for this app."
        let dialog = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(settingsUrl)
        }
        
        dialog.addAction(okAction)
        self.present(dialog, animated:true, completion:nil)
    }
    
    func getAssetsCollection() {
        if self.galleryViewModel.checkingPhotoLibraryPermissions() == "true" {
            PHPhotoLibrary.shared().register(self)
            resetCachedAssets()
            self.galleryViewModel.getPhotoAssetsAlbumWise() { albumArray in
                self.allPhotos = albumArray
                DispatchQueue.main.async {
                    self.galleryCollectionView.reloadData()
                }
            }
            // If we get here without a segue, it's because we're visible at app launch,
            // so match the behavior of segue from the default "All Photos" view.
//            if allPhotos == nil {
//                if selectedFolderIndex < self.allAlbumArray.count {
//                    let collectionItem = self.allAlbumArray[selectedFolderIndex]
//                    let options = PHFetchOptions()
//                    options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
//                    allPhotos = PHAsset.fetchAssets(in: collectionItem, options: options)
//                }
//            }
//            singletonFetchResult = allPhotos
            // Determine the size of the thumbnails to request from the PHCachingImageManager
            thumbnailSize = CGSize(width:200, height: 200)
        }
    }
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
}

// MARK: - UICollectionViewDataSource and UICollectionViewDelegate  -
extension CAGalleryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if allPhotos == nil {
            return 0
        } else {
            print(allPhotos.count)
            return allPhotos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCell.className, for: indexPath) as? GalleryCell else {
            let cell = GalleryCell()
            return cell
        }
        let asset = allPhotos[indexPath.item]
        autoreleasepool {
            cell.representedAssetIdentifier = asset.localIdentifier
            imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: imageRequest, resultHandler: { image, _ in
                // The cell may have been recycled by the time this handler gets called;
                // set the cell's thumbnail image only if it's still showing the same asset.
                if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                    cell.imageView.image = image
                }
            })
        }
        return cell
    }
//    func getSelectedImageAssetBySelectedOrder(index : Int) -> PHAsset {
//        //this condition for oldest and newest first function
//        var asset = PHAsset()
//        isSortByOldestFirst = false
//        if isSortByOldestFirst {
//            asset = allPhotos.object(at: index)
//        } else {
//            asset = allPhotos.object(at: allPhotos.count - (index + 1))
//        }
//        
//        return asset
//    }
    
    func getImageFromAsset(asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true

        PHImageManager.default().requestImage(for: asset,
                                              targetSize: PHImageManagerMaximumSize,
                                              contentMode: .aspectFit,
                                              options: options) { (image, info) in
            if let dict = info, let isCloudImage = dict[PHImageResultIsInCloudKey] as? Int, isCloudImage == 1 {
                DispatchQueue.main.async {
                    let dialog = UIAlertController(title: "Cloud Error", message: "This photo could not be downloaded from iCloud. Please connect to the internet.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    dialog.addAction(okAction)
                    // Present the alert on the appropriate view controller
                    completion(nil)
                }
            } else {
                completion(image)
            }
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = allPhotos[indexPath.item]
        self.getImageFromAsset(asset: asset, completion: { image in
            let isHp500 = true
            if isHp500 {
                if image != nil {
                    let viewController = CAEditViewController(nibName: CAEditViewController.className, bundle: nil)
                    if let newImage = image {
                        viewController.imageOrignal = newImage
                        viewController.imageOrignalBackUp = newImage
                        //viewController.isImageAlreadyEdited = self.isImageEdited(newImage)
                        let imageHeigth = newImage.size.height
                        let imageWidth = newImage.size.width
                        var bestFitRatioValue: CGFloat?
                        var isLandscape = true

                        if imageHeigth > imageWidth {
                            //-- Portrait
                            isLandscape = false
                            bestFitRatioValue = round(((imageHeigth/imageWidth) * 2) * 10) / 10.0
                        } else {
                            //-- landscape
                            isLandscape = true
                            bestFitRatioValue = round(((imageWidth/imageHeigth) * 2) * 10) / 10.0
                        }
                        viewController.selectedRatioWith = bestFitRatioValue ?? 0.0
                        viewController.isLandscape = isLandscape
                        
                    }
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
        })
    }
    
    // MARK: - CollectionView Layout Delegate
    func collectionView(collectionView: UICollectionView, customHeightForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
        if isShowingSocialPhotos == false {
            var height = 0.0
            let indexOfImage = indexPath.item  
            
            if numberOfColumnsInGrid != 4 {
                let asset = allPhotos[indexPath.item]
                var isPortrait = true
                if asset.pixelWidth > asset.pixelHeight {
                    isPortrait = false
                }
                
                if numberOfColumnsInGrid == 2 {
                    height = isPortrait ? 248.0 : 124.0
                } else if numberOfColumnsInGrid == 3 {
                    height = isPortrait ? 162.0 : 81.49
                }
            } else if numberOfColumnsInGrid == 4 {
                height = Double(UIScreen.main.bounds.width / numberOfColumnsInGrid - CGFloat(10))
            }
            return CGFloat(height)
        } else {
            return 125.0
        }
    }
}

extension CAGalleryViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized && allPhotos != nil {
            self.galleryViewModel.getPhotoAssetsAlbumWise() { albumArray in
                self.allPhotos = albumArray
                DispatchQueue.main.async {
                    self.galleryCollectionView.reloadData()
                }
            }
            
            // Change notifications may be made on a background queue. Re-dispatch to the
            // main queue before acting on the change as we'll be updating the UI.
            DispatchQueue.main.sync {
                // Hang on to the new fetch result.
                selectedFolderIndex = 0
                galleryCollectionView!.reloadData()
                resetCachedAssets()
            }
        }
    }
}
