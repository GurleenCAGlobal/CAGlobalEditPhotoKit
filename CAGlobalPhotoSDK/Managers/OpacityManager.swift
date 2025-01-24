//
//  OpacityManager.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 22/05/23.
//

import UIKit

enum Opacity: String, CaseIterable {
    case none
    case golden
    case lightleak1
    case mosaic
    case paper
    case rain
    case vintage
}

class OpacityManager: NSObject {
    func getOpacityData() -> [String] {
        let color = Opacity.allCases.map { options in
            return options.rawValue
        }
        return color
    }
}
