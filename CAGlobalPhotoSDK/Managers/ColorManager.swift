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

struct ColorManager {
    static let customColorsList: [UIColor] = [
        (UIColor(named: .blackColorName)!),
        (UIColor(named: .stickerColor)!),
        (UIColor(named: .yellow2ColorName)!),
        (UIColor(named: .yellowColorName)!),
        (UIColor(named: .skyColorName)!),
        (UIColor(named: .redColorName)!),
        (UIColor(named: .purpleColorName)!),
        (UIColor(named: .pinkColorName)!),
        (UIColor(named: .parrotColorName)!),
        (UIColor(named: .orangeColorName)!),
        (UIColor(named: .lightYellowColorName)!),
        (UIColor(named: .lightPinkColorName)!),
        (UIColor(named: .lightGreenColorName)!),
        (UIColor(named: .lightGrayColorName)!),
        (UIColor(named: .greenColorName)!),
        (UIColor(named: .darkPurpleColorName)!),
        (UIColor(named: .darkOrangeColorName)!),
        (UIColor(named: .darkGrayColorName)!),
        (UIColor(named: .darkBlueColorName)!),
        (UIColor(named: .cyanColorName)!),
        (UIColor(named: .blueColorName)!),
        (UIColor(named: .white)!)

    ]
    // Storing colors for text option
    func getColorsData() -> [UIColor] {
        let color = ColorManager.customColorsList.map { options in
            return options
        }
        return color
    }
}
