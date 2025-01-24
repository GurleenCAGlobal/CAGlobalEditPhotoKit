//
//  AdjustManager.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 06/07/23.
//

import Foundation

enum AdjustOption: String, CaseIterable {
    case brightness = "Brightness"
    case contrast = "Contrast"
    case saturation = "Saturation"
}

class AdjustManager: NSObject {
    // Storing options for edit imaae
    func getAdjustsData() -> [FilterModel] {
        let filters = AdjustOption.allCases.map { options in
            let filter = FilterModel.init(name: options.rawValue, image: options.rawValue)
            return filter
        }
        return filters
    }
}
