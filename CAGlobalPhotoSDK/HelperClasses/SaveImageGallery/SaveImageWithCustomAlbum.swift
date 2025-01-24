//
//  SaveImageWithCustomAlbum.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/05/23.
//

import UIKit
import Photos

struct SaveImageStaticStrings {
    static let albumName = "PhotoEditSDK"
    static let albumEditName = "PhotoEditSDK Edit"
    static let savePhotoTitle = "Save Photo Permission"
    static let savePhotoMessage = "Please change Photos settings to All Photos in order to save Zip images."
    static let setting = "Settings"
    static let okay = "Okay"
}

class SaveImageWithCustomAlbum: NSObject {
    
    var assetCollection = PHAssetCollection()
    
    override init() {
        super.init()
        createPhotoLibraryAlbum(name: SaveImageStaticStrings.albumName)
        createPhotoLibraryAlbum(name: SaveImageStaticStrings.albumEditName)
    }
    
    func saveImageInAlbum(name: String, withImage image: UIImage) {
        if let assetCollection = fetchAssetCollectionForAlbum(name: name) {
            self.assetCollection = assetCollection
            save(image: image)
            return
        }
    }
    
    // Fetch album from PHAssetCollection
    func fetchAssetCollectionForAlbum(name: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let collection = collection.firstObject {
            return collection
        } else {
            let cameraUnavailableAlertController = UIAlertController(title: SaveImageStaticStrings.savePhotoTitle, message: SaveImageStaticStrings.savePhotoMessage, preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: SaveImageStaticStrings.setting, style: .destructive) { (_) -> Void in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                }
            }
            
            let cancelAction = UIAlertAction(title: SaveImageStaticStrings.okay, style: .default, handler: nil)
            cameraUnavailableAlertController.addAction(settingsAction)
            cameraUnavailableAlertController.addAction(cancelAction)
            
            if let topController = UIApplication.shared.windows.first?.rootViewController {
                topController.present(cameraUnavailableAlertController, animated: true, completion: nil)
            }
        }
        
        return nil
    }
    
    func isAlbumPresent(name: String) -> Bool {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let firstObject = collection.firstObject {
            self.assetCollection = firstObject
            return true
        } else {
            return false
        }
    }
    
    // Create custom album in photo gallery
    func createPhotoLibraryAlbum(name: String) {
        PHPhotoLibrary.shared().performChanges({
            if !self.isAlbumPresent(name: name) {
                _ = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            }
        }, completionHandler: { success, error in
            if success {
                // Album created successfully
            } else if error != nil {
                // Error occurred while creating the album
            } else {
                // Unknown error occurred
            }
        })
    }
    
    // Save image in custom photo album
    func save(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest?.addAssets(enumeration)
        }, completionHandler: { _, error in
            if error == nil {
            }
        })
    }
}
