//
//  ColorManager.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 09/05/23.
//

import UIKit

extension String {
    static let blueColorName = "Blue"
    static let blackColorName = "Black"
    static let cyanColorName = "Cyan"
    static let darkBlueColorName = "DarkBlue"
    static let darkGrayColorName = "DarkGray"
    static let darkOrangeColorName = "DarkOrange"
    static let darkPurpleColorName = "DarkPurple"
    static let greenColorName = "Green"
    static let lightGrayColorName = "Lightgray"
    static let lightGreenColorName = "LightGreen"
    static let lightPinkColorName = "LightPink"
    static let lightYellowColorName = "LightYellow"
    static let orangeColorName = "Orange"
    static let parrotColorName = "Parrot"
    static let pinkColorName = "Pink"
    static let purpleColorName = "Purple"
    static let redColorName = "Red"
    static let skyColorName = "Skyblue"
    static let yellowColorName = "Yellow"
    static let yellow2ColorName = "Yellow2"
    static let white = "White"
    static let stickerColor = "StickerColor"
    static let selectionColor = "selectionColor"
}
//let color = UIColor(named: "YourColorName", in: Bundle(path: Bundle(for: YourCustomView.self).path(forResource: "YourLibraryNameResources", ofType: "bundle") ?? ""), compatibleWith: nil)
struct ColorManager {
    static let bundle = Bundle(path: Bundle(for: CAEditViewModel.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle") ?? "")

        static let customColorsList: [UIColor] = [
            UIColor(named: .blackColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .stickerColor, in: bundle, compatibleWith: nil)!,
            UIColor(named: .yellow2ColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .yellowColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .skyColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .redColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .purpleColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .pinkColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .parrotColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .orangeColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .lightYellowColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .lightPinkColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .lightGreenColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .lightGrayColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .greenColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .darkPurpleColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .darkOrangeColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .darkGrayColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .darkBlueColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .cyanColorName, in: bundle, compatibleWith: nil)!,
            UIColor(named: .blueColorName, in: bundle, compatibleWith: nil)!,
            UIColor.white
        ]
    
    // Storing colors for text option
    func getColorsData() -> [UIColor] {
        let color = ColorManager.customColorsList.map { options in
            return options
        }
        return color
    }
}
