//
//  GalleryViewModel.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 13/9/23.
//

import Photos

var isPhotoPermissionAccess = Bool()
var isPhotoPermissionDenied = Bool()
var singletonFetchResult: PHFetchResult<PHAsset>!
var thumbnailSize: CGSize!
let imageManager = PHCachingImageManager()
var previousPreheatRect = CGRect.zero

class GalleryViewModel: NSObject {
    
    func checkingPhotoLibraryPermissions() -> String {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            if isPhotoPermissionAccess == false{
                isPhotoPermissionAccess = true
            }
            return "true"
        case .denied, .restricted:
            isPhotoPermissionAccess = false
            
            if isPhotoPermissionDenied == false{
                isPhotoPermissionDenied = true
            }
            return "denied"
        case .notDetermined:
            return "false"
        case .limited:
            return "true"
        @unknown default:
            return "false"
        }
    }
    
    func getPhotoAssetsAlbumWise(completion: @escaping ([PHAsset]) -> Void) {
        guard self.checkingPhotoLibraryPermissions() == "true" else {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    DispatchQueue.main.async {
                        self.getPhotoAssetsAlbumWise(completion: completion)
                    }
                }
            }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            var allAssets = [PHAsset]()
            let seenIdentifiersQueue = DispatchQueue(label: "com.yourapp.seenIdentifiers")
            var seenIdentifiers = Set<String>()

            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            fetchOptions.fetchLimit = 500 // Process in smaller batches to reduce memory usage

            let fetchAlbumCollections = { (fetchResult: PHFetchResult<PHAssetCollection>) in
                fetchResult.enumerateObjects { collection, _, _ in
                    // Skip collections with no assets
                    guard collection.estimatedAssetCount > 0 else { return }

                    let assets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
                    assets.enumerateObjects { asset, _, _ in
                        guard !asset.localIdentifier.isEmpty else { return }
                        seenIdentifiersQueue.sync {
                            if seenIdentifiers.insert(asset.localIdentifier).inserted {
                                allAssets.append(asset)
                            }
                        }
                    }
                }
            }

            let topLevelUserCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)

            fetchAlbumCollections(topLevelUserCollections)
            fetchAlbumCollections(smartAlbums)

            // Sort assets by creation date
            allAssets.sort { (asset1, asset2) -> Bool in
                guard let date1 = asset1.creationDate, let date2 = asset2.creationDate else { return false }
                return date1 > date2
            }

            // Return to the main thread with the result
            DispatchQueue.main.async {
                completion(allAssets)
            }
        }
    }






}
