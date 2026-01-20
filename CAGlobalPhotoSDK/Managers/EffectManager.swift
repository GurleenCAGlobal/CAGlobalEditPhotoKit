//
//  EffectOption.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/05/23.
//

import UIKit

enum EffectOption: String, CaseIterable {
    case autoFix = "Auto"
    case adjust = "Adjust"
    case filter = "Filters"
    case frame = "Frames"
    case stickers = "Stickers"
    case text = "Text"
    case brush = "Brush"
    case gallery = "Add Photo"
    case transform = "Transform"
}

enum EffectOption500: String, CaseIterable {
    case gallery = "Add Photo"
    case stickers = "Stickers"
    case text = "Text"
    case frame = "Frame"
    case brush = "Brush"
    case transform = "Transform"
}

class EffectManager: NSObject {
    // Storing options for edit imaae
    func getFilterData() -> [FilterModel] {
        let bundleID = Bundle.main.bundleIdentifier
        if bundleID == "com.sprocket.panoramas" {
            return getFilterData500()
        } else {
            return getFilterDataDefault()
        }
    }
    
    private func getFilterDataDefault() -> [FilterModel] {
        let filters = EffectOption.allCases.map { options in
            let names = FilterModel.init(name: options.rawValue, image: options.rawValue)
            return names
        }
        return filters
    }
    
    private func getFilterData500() -> [FilterModel] {
        let filters = EffectOption500.allCases.map { options in
            let names = FilterModel.init(name: options.rawValue, image: options.rawValue)
            return names
        }
        return filters
    }
}
