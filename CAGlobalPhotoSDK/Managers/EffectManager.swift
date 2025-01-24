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

class EffectManager: NSObject {
    // Storing options for edit imaae
    func getFilterData() -> [FilterModel] {
        let filters = EffectOption.allCases.map { options in
            let names = FilterModel.init(name: options.rawValue, image: options.rawValue)
            return names
        }
        return filters
    }
    
}
