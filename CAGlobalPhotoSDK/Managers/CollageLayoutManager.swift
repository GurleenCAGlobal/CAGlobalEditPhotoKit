//
//  CollageLayoutManager.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/05/23.
//

import UIKit

enum CollageLayoutOption: String, CaseIterable {
    case horizontalTwo
    case verticalTwo
    case horizontalThree
    case verticalThree
    case horizontalFour
    case verticalFour
}

enum SelectedCollageLayoutOption: String, CaseIterable {
    case horizontalTwo = "layoutH2Active"
    case verticalTwo = "layoutV2Active"
    case horizontalThree = "layoutV3Active"
    case verticalThree = "layoutH3Active"
    case horizontalFour = "layoutH4Active"
    case verticalFour = "layoutV4Active"
}

class CollageLayoutManager: NSObject {
    
    // Storing options for collage layout
    func getCollageLayoutData() -> [String] {
        let layout = CollageLayoutOption.allCases.map { options in
            return options.rawValue
        }
        return layout
    }
    
    // Storing options for selected collage layout
    func getSelectedCollageLayoutData() -> [String] {
        let layout = SelectedCollageLayoutOption.allCases.map { options in
            return options.rawValue
        }
        return layout
    }
}
