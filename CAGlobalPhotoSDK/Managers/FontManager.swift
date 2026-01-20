//
//  FontManager.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 09/05/23.
//

import UIKit

enum CustomFont: String, CaseIterable {
    case AbrilFatfaceRegular = "AbrilFatface-Regular"
    case AgbalumoRegular = "Agbalumo-Regular"
    case AlatsiRegular = "Alatsi-Regular"
    case AleoRegular = "Aleo-Medium"
    case BangersRegular = "Bangers-Regular" //5
    case Baskerville = "Baskerville"
    case BebasNeueRegular = "BebasNeue-Regular"
    case Bodoni72 = "BodoniSvtyTwoITCTT-Book"
    case BradleyHandBold = "BradleyHandITCTT-Bold" //9
    case BubblegumSansRegular = "BubblegumSans-Regular"
    case BungeeRegular = "Bungee-Regular"
    case CalistogaRegular = "Calistoga-Regular"
    case CaveatRegular = "Caveat-SemiBold" // 13
    case ComfortaaRegular = "Comfortaa-Medium"
    case Copperplate = "Copperplate"
    case Flama_11 = "Flama-Bold"
    case Futura = "Futura-Medium"
    case GaladaRegular = "Galada-Regular" // 18
    case Georgia = "Georgia"
    case GillSans = "GillSans"
    case GreatVibesRegular = "GreatVibes-Regular" //21
    case IndieFlowerRegular = "IndieFlower"
    case LiterataRegular = "Literata24pt-Black"
    case MarcellusRegular = "Marcellus-Regular"
    case Optima = "Optima-Regular"
    case OswaldRegular = "Oswald-Light"
}

struct FontManager {
    
    static var normalRegular: UIFont! {
        return UIFont(name: "HPSimplified-Regular", size: 17.0)
    }
    
    static var normalLight: UIFont! {
        return UIFont(name: "HPSimplified-Light", size: 17.0)
    }
    
    static var normalBold: UIFont! {
        return UIFont(name: "HP Simplified Bold", size: 17.0)
    }
    
    static var largeBold: UIFont! {
        return UIFont(name: "HP Simplified Bold", size: 25.0)
    }
    
    // Storing Font names for text option
    func getFontsData() -> [String] {
        let color = CustomFont.allCases.map { options in
            return options.rawValue
        }
        return color
    }
}
