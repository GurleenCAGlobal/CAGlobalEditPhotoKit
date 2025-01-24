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
        let stickers = (1...64).compactMap { UIImage(named: "shape\($0)") }
        return stickers
    }
    
    func getEmoticonData() -> [UIImage] {
        let stickers = (1...58).compactMap { UIImage(named: "stickerEmoticons\($0)") }
        return stickers
    }
    
    func getBadgesData() -> [UIImage] {
        let stickers = (1...15).compactMap { UIImage(named: "stickerShapesBadge\($0)") }
        return stickers
    }
    
    func getArrowData() -> [UIImage] {
        let stickers = (1...2).compactMap { UIImage(named: "stickerShapesArrow\($0)") }
        return stickers
    }
    
    func getSprayData() -> [UIImage] {
        let stickers = (1...3).compactMap { UIImage(named: "stickerShapesSpray\($0)") }
        return stickers
    }
    
    func natureCategoryStickers() -> [UIImage] {
        return [
            UIImage(named: "sun")!,
            UIImage(named: "sun_hearts")!,
            UIImage(named: "sun_rays_face")!,
            UIImage(named: "star_yellow")!,
            UIImage(named: "flower")!,
            UIImage(named: "flowers_daisies")!,
            UIImage(named: "flowers_left")!,
            UIImage(named: "flowers_right")!,
            UIImage(named: "wedding_bouquet")!,
            UIImage(named: "banner_2")!,
            UIImage(named: "banner-copy")!,
            UIImage(named: "hibiscus")!,
            UIImage(named: "plum-blossom")!,
            UIImage(named: "rosebud")!,
            UIImage(named: "bouquet")!,
            UIImage(named: "poppy_leaves-2")!,
            UIImage(named: "anzac_poppy-2")!,
            UIImage(named: "Flowers")!,
            UIImage(named: "cactus_family")!,
            UIImage(named: "rose")!,
            UIImage(named: "Flowers2")!,
            UIImage(named: "heart_bouquet")!,
            UIImage(named: "Mushrooms-b")!,
            UIImage(named: "leaves")!,
            UIImage(named: "palm-tree-2")!,
            UIImage(named: "rainbow_2")!,
            UIImage(named: "feather_blue")!,
            UIImage(named: "feather")!,
            UIImage(named: "feather2")!,
            UIImage(named: "starhp")!,
            UIImage(named: "stars")!,
            UIImage(named: "wave")!,
            UIImage(named: "sun_face")!,
            UIImage(named: "palmtree")!,
            UIImage(named: "cloud-sun")!,
            UIImage(named: "cloud_angry")!,
            UIImage(named: "cloud_sad")!,
            UIImage(named: "moon")!,
            UIImage(named: "flower_leaves_element")!,
            UIImage(named: "hanging_lillies")!,
            UIImage(named: "lilly")!,
            UIImage(named: "aster_flower")!,
            UIImage(named: "rosebud_leaves")!,
            UIImage(named: "three_daisies")!,
            UIImage(named: "three_flower_bunch")!,
            UIImage(named: "three_rosebuds")!,
            UIImage(named: "tulips")!,
            UIImage(named: "wedding_bouquet_color")!,
            UIImage(named: "flower_ring")!
        ]
    }
    
    func sportsCategoryStickers() -> [UIImage] {
        return [
            UIImage(named: "Football")!,
            UIImage(named: "foam_finger_px")!,
            UIImage(named: "flag_px")!,
            UIImage(named: "glasses_px")!,
            UIImage(named: "jersey")!,
            UIImage(named: "spirit_week_1")!,
            UIImage(named: "spirit_week_2")!,
            UIImage(named: "glasses_2_px")!,
            UIImage(named: "game_day")!,
            UIImage(named: "go_team_banner_homecoming")!,
            UIImage(named: "were_no1_homecoming")!,
            UIImage(named: "football_character_homecoming")!,
            UIImage(named: "football_flames_px")!,
            UIImage(named: "football_helmet_homecoming")!,
            UIImage(named: "helmet_px")!,
            UIImage(named: "heart_football_px")!,
            UIImage(named: "stars_n_balls_px")!,
            UIImage(named: "skateboard_px")!,
            UIImage(named: "heart_football3_px")!,
            UIImage(named: "i_heart_football_2_px")!
        ]
    }
    
    func getWellCategoryStickers() -> [UIImage] {
        return [
            UIImage(named: "band-aid2")!,
            UIImage(named: "kleenex")!,
            UIImage(named: "measles")!,
            UIImage(named: "medicine")!,
            UIImage(named: "germs")!,
            UIImage(named: "nauseous_emoji")!,
            UIImage(named: "sick_mask_emoji")!,
            UIImage(named: "soup_bowl")!,
            UIImage(named: "tea_honey")!,
            UIImage(named: "thermometer_fire")!,
            UIImage(named: "tissue_box")!,
            UIImage(named: "love_monster")!,
            UIImage(named: "letter")!
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
