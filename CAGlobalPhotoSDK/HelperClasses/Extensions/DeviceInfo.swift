//
//  DeviceInfo.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/05/23.
//

import UIKit

class DeviceInfo: NSObject {
    
}
public enum Model : String {
    
    //Simulator
    case simulator     = "simulator/sandbox",
         
         //iPod
         iPod1              = "iPod 1",
         iPod2              = "iPod 2",
         iPod3              = "iPod 3",
         iPod4              = "iPod 4",
         iPod5              = "iPod 5",
         iPod6              = "iPod 6",
         iPod7              = "iPod 7",
         
         //iPad
         iPad2              = "iPad 2",
         iPad3              = "iPad 3",
         iPad4              = "iPad 4",
         iPadAir            = "iPad Air ",
         iPadAir2           = "iPad Air 2",
         iPadAir3           = "iPad Air 3",
         iPadAir4           = "iPad Air 4",
         iPadAir5           = "iPad Air 5",
         iPad5              = "iPad 5", //iPad 2017
         iPad6              = "iPad 6", //iPad 2018
         iPad7              = "iPad 7", //iPad 2019
         iPad8              = "iPad 8", //iPad 2020
         iPad9              = "iPad 9", //iPad 2021
         iPad10             = "iPad 10", //iPad 2022
         
         //iPad Mini
         iPadMini           = "iPad Mini",
         iPadMini2          = "iPad Mini 2",
         iPadMini3          = "iPad Mini 3",
         iPadMini4          = "iPad Mini 4",
         iPadMini5          = "iPad Mini 5",
         iPadMini6          = "iPad Mini 6",
         
         //iPad Pro
         iPadPro97         = "iPad Pro 9.7\"",
         iPadPro105        = "iPad Pro 10.5\"",
         iPadPro11          = "iPad Pro 11\"",
         iPadPro211        = "iPad Pro 11\" 2nd gen",
         iPadPro311        = "iPad Pro 11\" 3rd gen",
         iPadPro129        = "iPad Pro 12.9\"",
         iPadPro2129      = "iPad Pro 2 12.9\"",
         iPadPro3129      = "iPad Pro 3 12.9\"",
         iPadPro4129      = "iPad Pro 4 12.9\"",
         iPadPro5129      = "iPad Pro 5 12.9\"",
         
         //iPhone
         iPhone4            = "iPhone 4",
         iPhone4S           = "iPhone 4S",
         iPhone5            = "iPhone 5",
         iPhone5S           = "iPhone 5S",
         iPhone5C           = "iPhone 5C",
         iPhone6            = "iPhone 6",
         iPhone6Plus        = "iPhone 6 Plus",
         iPhone6S           = "iPhone 6S",
         iPhone6SPlus       = "iPhone 6S Plus",
         iPhoneSE           = "iPhone SE",
         iPhone7            = "iPhone 7",
         iPhone7Plus        = "iPhone 7 Plus",
         iPhone8            = "iPhone 8",
         iPhone8Plus        = "iPhone 8 Plus",
         iPhoneX            = "iPhone X",
         iPhoneXS           = "iPhone XS",
         iPhoneXSMax        = "iPhone XS Max",
         iPhoneXR           = "iPhone XR",
         iPhone11           = "iPhone 11",
         iPhone11Pro        = "iPhone 11 Pro",
         iPhone11ProMax     = "iPhone 11 Pro Max",
         iPhoneSE2          = "iPhone SE 2nd gen",
         iPhone12Mini       = "iPhone 12 Mini",
         iPhone12           = "iPhone 12",
         iPhone12Pro        = "iPhone 12 Pro",
         iPhone12ProMax     = "iPhone 12 Pro Max",
         iPhone13Mini       = "iPhone 13 Mini",
         iPhone13           = "iPhone 13",
         iPhone13Pro        = "iPhone 13 Pro",
         iPhone13ProMax     = "iPhone 13 Pro Max",
         iPhoneSE3          = "iPhone SE 3nd gen",
         iPhone14           = "iPhone 14",
         iPhone14Plus       = "iPhone 14 Plus",
         iPhone14Pro        = "iPhone 14 Pro",
         iPhone14ProMax     = "iPhone 14 Pro Max",
         iPhone15           = "iPhone 15",
         iPhone15Plus       = "iPhone 15 Plus",
         iPhone15Pro        = "iPhone 15 Pro",
         iPhone15ProMax     = "iPhone 15 Pro Max",
         
         // Apple Watch
         appleWatch1         = "Apple Watch 1gen",
         appleWatchS1        = "Apple Watch Series 1",
         appleWatchS2        = "Apple Watch Series 2",
         appleWatchS3        = "Apple Watch Series 3",
         appleWatchS4        = "Apple Watch Series 4",
         appleWatchS5        = "Apple Watch Series 5",
         appleWatchSE        = "Apple Watch Special Edition",
         appleWatchS6        = "Apple Watch Series 6",
         appleWatchS7        = "Apple Watch Series 7",
         
         //Apple TV
         appleTV1           = "Apple TV 1gen",
         appleTV2           = "Apple TV 2gen",
         appleTV3           = "Apple TV 3gen",
         appleTV4           = "Apple TV 4gen",
         appleTV4K         = "Apple TV 4K",
         appleTV24K        = "Apple TV 4K 2gen",
         
         unrecognized       = "?unrecognized?"
}

// #-#-#-#-#-#-#-#-#-#-#-#-#
// MARK: UIDevice extensions
// #-#-#-#-#-#-#-#-#-#-#-#-#

public extension UIDevice {
    
    var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        
        let modelMap : [String: Model] = [
            
            //Simulator
            "i386"      : .simulator,
            "x86_64"    : .simulator,
            
            //iPod
            "iPod1,1"   : .iPod1,
            "iPod2,1"   : .iPod2,
            "iPod3,1"   : .iPod3,
            "iPod4,1"   : .iPod4,
            "iPod5,1"   : .iPod5,
            "iPod7,1"   : .iPod6,
            "iPod9,1"   : .iPod7,
            
            //iPad
            "iPad2,1"   : .iPad2,
            "iPad2,2"   : .iPad2,
            "iPad2,3"   : .iPad2,
            "iPad2,4"   : .iPad2,
            "iPad3,1"   : .iPad3,
            "iPad3,2"   : .iPad3,
            "iPad3,3"   : .iPad3,
            "iPad3,4"   : .iPad4,
            "iPad3,5"   : .iPad4,
            "iPad3,6"   : .iPad4,
            "iPad6,11"  : .iPad5, //iPad 2017
            "iPad6,12"  : .iPad5,
            "iPad7,5"   : .iPad6, //iPad 2018
            "iPad7,6"   : .iPad6,
            "iPad7,11"  : .iPad7, //iPad 2019
            "iPad7,12"  : .iPad7,
            "iPad11,6"  : .iPad8, //iPad 2020
            "iPad11,7"  : .iPad8,
            "iPad12,1"  : .iPad9, //iPad 2021
            "iPad12,2"  : .iPad9,
            "iPad13,18" : .iPad10,
            "iPad13,19" : .iPad10,
            
            //iPad Mini
            "iPad2,5"   : .iPadMini,
            "iPad2,6"   : .iPadMini,
            "iPad2,7"   : .iPadMini,
            "iPad4,4"   : .iPadMini2,
            "iPad4,5"   : .iPadMini2,
            "iPad4,6"   : .iPadMini2,
            "iPad4,7"   : .iPadMini3,
            "iPad4,8"   : .iPadMini3,
            "iPad4,9"   : .iPadMini3,
            "iPad5,1"   : .iPadMini4,
            "iPad5,2"   : .iPadMini4,
            "iPad11,1"  : .iPadMini5,
            "iPad11,2"  : .iPadMini5,
            "iPad14,1"  : .iPadMini6,
            "iPad14,2"  : .iPadMini6,
            
            //iPad Pro
            "iPad6,3"   : .iPadPro97,
            "iPad6,4"   : .iPadPro97,
            "iPad7,3"   : .iPadPro105,
            "iPad7,4"   : .iPadPro105,
            "iPad6,7"   : .iPadPro129,
            "iPad6,8"   : .iPadPro129,
            "iPad7,1"   : .iPadPro2129,
            "iPad7,2"   : .iPadPro2129,
            "iPad8,1"   : .iPadPro11,
            "iPad8,2"   : .iPadPro11,
            "iPad8,3"   : .iPadPro11,
            "iPad8,4"   : .iPadPro11,
            "iPad8,9"   : .iPadPro211,
            "iPad8,10"  : .iPadPro211,
            "iPad13,4"  : .iPadPro311,
            "iPad13,5"  : .iPadPro311,
            "iPad13,6"  : .iPadPro311,
            "iPad13,7"  : .iPadPro311,
            "iPad8,5"   : .iPadPro3129,
            "iPad8,6"   : .iPadPro3129,
            "iPad8,7"   : .iPadPro3129,
            "iPad8,8"   : .iPadPro3129,
            "iPad8,11"  : .iPadPro4129,
            "iPad8,12"  : .iPadPro4129,
            "iPad13,8"  : .iPadPro5129,
            "iPad13,9"  : .iPadPro5129,
            "iPad13,10" : .iPadPro5129,
            "iPad13,11" : .iPadPro5129,
            
            //iPad Air
            "iPad4,1"   : .iPadAir,
            "iPad4,2"   : .iPadAir,
            "iPad4,3"   : .iPadAir,
            "iPad5,3"   : .iPadAir2,
            "iPad5,4"   : .iPadAir2,
            "iPad11,3"  : .iPadAir3,
            "iPad11,4"  : .iPadAir3,
            "iPad13,1"  : .iPadAir4,
            "iPad13,2"  : .iPadAir4,
            "iPad13,16" : .iPadAir5,
            "iPad13,17" : .iPadAir5,
            
            //iPhone
            "iPhone3,1" : .iPhone4,
            "iPhone3,2" : .iPhone4,
            "iPhone3,3" : .iPhone4,
            "iPhone4,1" : .iPhone4S,
            "iPhone5,1" : .iPhone5,
            "iPhone5,2" : .iPhone5,
            "iPhone5,3" : .iPhone5C,
            "iPhone5,4" : .iPhone5C,
            "iPhone6,1" : .iPhone5S,
            "iPhone6,2" : .iPhone5S,
            "iPhone7,1" : .iPhone6Plus,
            "iPhone7,2" : .iPhone6,
            "iPhone8,1" : .iPhone6S,
            "iPhone8,2" : .iPhone6SPlus,
            "iPhone8,4" : .iPhoneSE,
            "iPhone9,1" : .iPhone7,
            "iPhone9,3" : .iPhone7,
            "iPhone9,2" : .iPhone7Plus,
            "iPhone9,4" : .iPhone7Plus,
            "iPhone10,1" : .iPhone8,
            "iPhone10,4" : .iPhone8,
            "iPhone10,2" : .iPhone8Plus,
            "iPhone10,5" : .iPhone8Plus,
            "iPhone10,3" : .iPhoneX,
            "iPhone10,6" : .iPhoneX,
            "iPhone11,2" : .iPhoneXS,
            "iPhone11,4" : .iPhoneXSMax,
            "iPhone11,6" : .iPhoneXSMax,
            "iPhone11,8" : .iPhoneXR,
            "iPhone12,1" : .iPhone11,
            "iPhone12,3" : .iPhone11Pro,
            "iPhone12,5" : .iPhone11ProMax,
            "iPhone12,8" : .iPhoneSE2,
            "iPhone13,1" : .iPhone12Mini,
            "iPhone13,2" : .iPhone12,
            "iPhone13,3" : .iPhone12Pro,
            "iPhone13,4" : .iPhone12ProMax,
            "iPhone14,4" : .iPhone13Mini,
            "iPhone14,5" : .iPhone13,
            "iPhone14,2" : .iPhone13Pro,
            "iPhone14,3" : .iPhone13ProMax,
            "iPhone14,6" : .iPhoneSE3,
            "iPhone14,7" : .iPhone14,
            "iPhone14,8" : .iPhone14Plus,
            "iPhone15,2" : .iPhone14Pro,
            "iPhone15,3" : .iPhone14ProMax,
            "iPhone15,4" : .iPhone15,
            "iPhone15,5" : .iPhone15Plus,
            "iPhone16,1" : .iPhone15Pro,
            "iPhone16,2" : .iPhone15ProMax,
            
            // Apple Watch
            "Watch1,1" : .appleWatch1,
            "Watch1,2" : .appleWatch1,
            "Watch2,6" : .appleWatchS1,
            "Watch2,7" : .appleWatchS1,
            "Watch2,3" : .appleWatchS2,
            "Watch2,4" : .appleWatchS2,
            "Watch3,1" : .appleWatchS3,
            "Watch3,2" : .appleWatchS3,
            "Watch3,3" : .appleWatchS3,
            "Watch3,4" : .appleWatchS3,
            "Watch4,1" : .appleWatchS4,
            "Watch4,2" : .appleWatchS4,
            "Watch4,3" : .appleWatchS4,
            "Watch4,4" : .appleWatchS4,
            "Watch5,1" : .appleWatchS5,
            "Watch5,2" : .appleWatchS5,
            "Watch5,3" : .appleWatchS5,
            "Watch5,4" : .appleWatchS5,
            "Watch5,9" : .appleWatchSE,
            "Watch5,10" : .appleWatchSE,
            "Watch5,11" : .appleWatchSE,
            "Watch5,12" : .appleWatchSE,
            "Watch6,1" : .appleWatchS6,
            "Watch6,2" : .appleWatchS6,
            "Watch6,3" : .appleWatchS6,
            "Watch6,4" : .appleWatchS6,
            "Watch6,6" : .appleWatchS7,
            "Watch6,7" : .appleWatchS7,
            "Watch6,8" : .appleWatchS7,
            "Watch6,9" : .appleWatchS7,
            
            //Apple TV
            "AppleTV1,1" : .appleTV1,
            "AppleTV2,1" : .appleTV2,
            "AppleTV3,1" : .appleTV3,
            "AppleTV3,2" : .appleTV3,
            "AppleTV5,3" : .appleTV4,
            "AppleTV6,2" : .appleTV4K,
            "AppleTV11,1" : .appleTV24K
        ]
        
        guard let map = modelCode, let model = modelMap[map] else { return Model.unrecognized }
        if model == .simulator {
            if let simMap = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                if let simModel = modelMap[simMap] {
                    return simModel
                }
            }
        }
        return model
    }
}
