//
//  StickerManager.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 30/05/23.
//

import UIKit
enum Sticker: String, CaseIterable {
    case none = "none"
    
}

struct SubStickerModel {
    var id : Int
    var eventId : Int
    var name : String
    var thumbnail : String
    var image : String
    var imagePath : String
    var isDownloaded : Bool
}

class StickerModel: NSObject {
    var id : Int = 0
    var name : String = ""
    var startDate : String = ""
    var endDate : String = ""
    var createdAt : String = ""
    var updatedAt : String = ""
    var deletedAll : String = ""
    var version : String = ""
}

var subStickersFromApi = [SubStickerModel]()
var stickersFromApi = [StickerModel]()
class StickerManager: NSObject {
    
    func getStickerData() -> [String] {
        let color = Sticker.allCases.map { options in
            return options.rawValue
        }
        return color
    }
    
    func getShapesData() -> [UIImage] {
        let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)!

        let stickers = (1...64).compactMap { UIImage(named: "shape\($0)", in: bundle, compatibleWith: nil) }
        return stickers
    }
    
    func getEmoticonData() -> [UIImage] {
        let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)!

        let stickers = (1...58).compactMap { UIImage(named: "stickerEmoticons\($0)", in: bundle, compatibleWith: nil) }
        return stickers
    }
    
    func getBadgesData() -> [UIImage] {
        let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)!

        let stickers = (1...15).compactMap { UIImage(named: "stickerShapesBadge\($0)", in: bundle, compatibleWith: nil) }
        return stickers
    }
    
    func getArrowData() -> [UIImage] {
        let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)!

        let stickers = (1...2).compactMap { UIImage(named: "stickerShapesArrow\($0)", in: bundle, compatibleWith: nil) }
        return stickers
    }
    
    func getSprayData() -> [UIImage] {
        let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)!

        let stickers = (1...3).compactMap { UIImage(named: "stickerShapesSpray\($0)", in: bundle, compatibleWith: nil) }
        return stickers
    }
    
    func natureCategoryStickers() -> [UIImage] {
        let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)!

        return [
            UIImage(named: "sun", in: bundle, compatibleWith: nil)!,
            UIImage(named: "sun_hearts", in: bundle, compatibleWith: nil)!,
            UIImage(named: "sun_rays_face", in: bundle, compatibleWith: nil)!,
            UIImage(named: "star_yellow", in: bundle, compatibleWith: nil)!,
            UIImage(named: "flower", in: bundle, compatibleWith: nil)!,
            UIImage(named: "flowers_daisies", in: bundle, compatibleWith: nil)!,
            UIImage(named: "flowers_left", in: bundle, compatibleWith: nil)!,
            UIImage(named: "flowers_right", in: bundle, compatibleWith: nil)!,
            UIImage(named: "wedding_bouquet", in: bundle, compatibleWith: nil)!,
            UIImage(named: "banner_2", in: bundle, compatibleWith: nil)!,
            UIImage(named: "banner-copy", in: bundle, compatibleWith: nil)!,
            UIImage(named: "hibiscus", in: bundle, compatibleWith: nil)!,
            UIImage(named: "plum-blossom", in: bundle, compatibleWith: nil)!,
            UIImage(named: "rosebud", in: bundle, compatibleWith: nil)!,
            UIImage(named: "bouquet", in: bundle, compatibleWith: nil)!,
            UIImage(named: "poppy_leaves-2", in: bundle, compatibleWith: nil)!,
            UIImage(named: "anzac_poppy-2", in: bundle, compatibleWith: nil)!,
            UIImage(named: "Flowers", in: bundle, compatibleWith: nil)!,
            UIImage(named: "cactus_family", in: bundle, compatibleWith: nil)!,
            UIImage(named: "rose", in: bundle, compatibleWith: nil)!,
            UIImage(named: "Flowers2", in: bundle, compatibleWith: nil)!,
            UIImage(named: "heart_bouquet", in: bundle, compatibleWith: nil)!,
            UIImage(named: "Mushrooms-b", in: bundle, compatibleWith: nil)!,
            UIImage(named: "leaves", in: bundle, compatibleWith: nil)!,
            UIImage(named: "palm-tree-2", in: bundle, compatibleWith: nil)!,
            UIImage(named: "rainbow_2", in: bundle, compatibleWith: nil)!,
            UIImage(named: "feather_blue", in: bundle, compatibleWith: nil)!,
            UIImage(named: "feather", in: bundle, compatibleWith: nil)!,
            UIImage(named: "feather2", in: bundle, compatibleWith: nil)!,
            UIImage(named: "starhp", in: bundle, compatibleWith: nil)!,
            UIImage(named: "stars", in: bundle, compatibleWith: nil)!,
            UIImage(named: "wave", in: bundle, compatibleWith: nil)!,
            UIImage(named: "sun_face", in: bundle, compatibleWith: nil)!,
            UIImage(named: "palmtree", in: bundle, compatibleWith: nil)!,
            UIImage(named: "cloud-sun", in: bundle, compatibleWith: nil)!,
            UIImage(named: "cloud_angry", in: bundle, compatibleWith: nil)!,
            UIImage(named: "cloud_sad", in: bundle, compatibleWith: nil)!,
            UIImage(named: "moon", in: bundle, compatibleWith: nil)!,
            UIImage(named: "flower_leaves_element", in: bundle, compatibleWith: nil)!,
            UIImage(named: "hanging_lillies", in: bundle, compatibleWith: nil)!,
            UIImage(named: "lilly", in: bundle, compatibleWith: nil)!,
            UIImage(named: "aster_flower", in: bundle, compatibleWith: nil)!,
            UIImage(named: "rosebud_leaves", in: bundle, compatibleWith: nil)!,
            UIImage(named: "three_daisies", in: bundle, compatibleWith: nil)!,
            UIImage(named: "three_flower_bunch", in: bundle, compatibleWith: nil)!,
            UIImage(named: "three_rosebuds", in: bundle, compatibleWith: nil)!,
            UIImage(named: "tulips", in: bundle, compatibleWith: nil)!,
            UIImage(named: "wedding_bouquet_color", in: bundle, compatibleWith: nil)!,
            UIImage(named: "flower_ring", in: bundle, compatibleWith: nil)!
        ]
    }
    
    func sportsCategoryStickers() -> [UIImage] {
        let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)!

        return [
            UIImage(named: "Football", in: bundle, compatibleWith: nil)!,
            UIImage(named: "foam_finger_px", in: bundle, compatibleWith: nil)!,
            UIImage(named: "flag_px", in: bundle, compatibleWith: nil)!,
            UIImage(named: "glasses_px", in: bundle, compatibleWith: nil)!,
            UIImage(named: "jersey", in: bundle, compatibleWith: nil)!,
            UIImage(named: "spirit_week_1", in: bundle, compatibleWith: nil)!,
            UIImage(named: "spirit_week_2", in: bundle, compatibleWith: nil)!,
            UIImage(named: "glasses_2_px", in: bundle, compatibleWith: nil)!,
            UIImage(named: "game_day", in: bundle, compatibleWith: nil)!,
            UIImage(named: "go_team_banner_homecoming", in: bundle, compatibleWith: nil)!,
            UIImage(named: "were_no1_homecoming", in: bundle, compatibleWith: nil)!,
            UIImage(named: "football_character_homecoming", in: bundle, compatibleWith: nil)!,
            UIImage(named: "football_flames_px", in: bundle, compatibleWith: nil)!,
            UIImage(named: "football_helmet_homecoming", in: bundle, compatibleWith: nil)!,
            UIImage(named: "helmet_px", in: bundle, compatibleWith: nil)!,
            UIImage(named: "heart_football_px", in: bundle, compatibleWith: nil)!,
            UIImage(named: "stars_n_balls_px", in: bundle, compatibleWith: nil)!,
            UIImage(named: "skateboard_px", in: bundle, compatibleWith: nil)!,
            UIImage(named: "heart_football3_px", in: bundle, compatibleWith: nil)!,
            UIImage(named: "i_heart_football_2_px", in: bundle, compatibleWith: nil)!
        ]
    }
    
    func getWellCategoryStickers() -> [UIImage] {
        let bundlePath = Bundle(for: FrameView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = (bundlePath != nil ? Bundle(path: bundlePath!) : nil)!

        return [
            UIImage(named: "band-aid2", in: bundle, compatibleWith: nil)!,
            UIImage(named: "kleenex", in: bundle, compatibleWith: nil)!,
            UIImage(named: "measles", in: bundle, compatibleWith: nil)!,
            UIImage(named: "medicine", in: bundle, compatibleWith: nil)!,
            UIImage(named: "germs", in: bundle, compatibleWith: nil)!,
            UIImage(named: "nauseous_emoji", in: bundle, compatibleWith: nil)!,
            UIImage(named: "sick_mask_emoji", in: bundle, compatibleWith: nil)!,
            UIImage(named: "soup_bowl", in: bundle, compatibleWith: nil)!,
            UIImage(named: "tea_honey", in: bundle, compatibleWith: nil)!,
            UIImage(named: "thermometer_fire", in: bundle, compatibleWith: nil)!,
            UIImage(named: "tissue_box", in: bundle, compatibleWith: nil)!,
            UIImage(named: "love_monster", in: bundle, compatibleWith: nil)!,
            UIImage(named: "letter", in: bundle, compatibleWith: nil)!
        ]
    }
    
    func addSticker(delegate: UIViewController, frame: CGRect, image: UIImage, isTransform: Bool, transform: CGAffineTransform, tag: Int, sticker: String, isSticker: Bool, color: UIColor) -> AddSticker {
        var indexcount = 0
        let customView = AddSticker(frame: frame)
        customView.delegate = delegate as? any AddStickerViewDelegate
        customView.stickerSelection = sticker
        customView.isStickers = isSticker
        customView.image = image
        if sticker == "shapes" || sticker == "badges"  || sticker == "arrow" || sticker == "spray" {
            customView.tintColor = color
        }
        
        for i in 0...stickersFromApi.count {
            print(i)
            if sticker == "api" {
                customView.tintColor = .clear
            }
        }
        if isTransform {
            customView.transform = CGAffineTransformIdentity
            customView.transform = transform
        }
        customView.tag = tag
        return customView
    }
    
    func addImage(delegate: UIViewController, frame: CGRect, image: UIImage, isTransform: Bool, transform: CGAffineTransform, tag: Int) -> AddSticker {
        let customView = AddSticker(frame: frame)
        customView.delegate = delegate as? any AddStickerViewDelegate
        customView.image = image
        customView.isBlank = true
        if isTransform {
            customView.transform = CGAffineTransformIdentity
            customView.transform = transform
        }
        customView.tag = tag
        return customView
    }
}
