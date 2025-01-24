//
//  FramesManager.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 29/06/23.
//

import UIKit

struct SubFramesModel {
    var id : Int
    var eventId : Int
    var name : String
    var thumbnail : String
    var image : String
    var imagePath : String
    var isDownloaded : Bool
}

struct FramesModel {
    var id : Int
    var name : String
    var startDate : String
    var endDate : String
    var createdAt : String
    var updatedAt : String
    var deletedAll : String
    var version : String
}

var subFramesFromApi = [SubFramesModel]()
var framesFromApi = [FramesModel]()
class FramesManager: NSObject {
    
    func getFrameData() -> String {
        return "Frames"
    }
    
    func getFramesData(isLandscape: Bool, selectedRatio: CGFloat) -> String {
        let photoLength: CGFloat = selectedRatio
        var sizeType = ""
        // 9 7 4 1
        if photoLength <= 2 {
            sizeType = "1"
        } else if photoLength <= 5 {
            sizeType = "4"
        } else if photoLength <= 7 {
            sizeType = "7"
        } else if photoLength <= 9 {
            sizeType = "9"
        } else {
            sizeType = "9"
        }
        var imageString = String()
        var imageName = "HP500_App_\(1)_\(sizeType)"
        if isLandscape == true {
            imageName = "HP500_App_\(1)_\(sizeType)_L"
        }
        imageString = imageName
        return imageString
    }
    
    func getEmoticonData(isLandscape: Bool, selectedRatio: CGFloat) -> [String] {
        let photoLength: CGFloat = selectedRatio
        var sizeType = ""
        // 9 7 4 1
        if photoLength <= 2 {
            sizeType = "1"
        } else if photoLength <= 5 {
            sizeType = "4"
        } else if photoLength <= 7 {
            sizeType = "7"
        } else if photoLength <= 9 {
            sizeType = "9"
        } else {
            sizeType = "9"
        }
        var imageArray = [String]()
        for index in 1...30 {
            var imageName = "HP500_App_\(index)_\(sizeType)"
            if isLandscape == true {
                imageName = "HP500_App_\(index)_\(sizeType)_L"
            }
            imageArray.append(imageName)
        }
        return imageArray
    }
    
    func getEmoticonDataNew(isLandscape: Bool, selectedRatio: CGFloat) -> [FrameCategoryModel] {
        let photoLength: CGFloat = selectedRatio
        var sizeType = ""

        // Determine the sizeType based on photoLength
        if photoLength <= 2 {
            sizeType = "1"
        } else if photoLength <= 5 {
            sizeType = "4"
        } else if photoLength <= 7 {
            sizeType = "7"
        } else {
            sizeType = "9"
        }

        var frameCategoryList = [FrameCategoryModel]()

        // Function to add frame category details
        func addFrameCategory(name: String, frameCount: Int, format: String, insertNone: Bool = true) {
            let frameCategory = FrameCategoryModel()
            frameCategory.categoryName = name

            var frameList = [FrameModel]()
            var categoryIcon: String?

            for i in 1...frameCount {
                var imageName = String(format: format, i, sizeType)
                if isLandscape {
                    imageName += "_L"
                }

                let frameModel = FrameModel(frame: imageName, opacity: 1.0)
                frameList.append(frameModel)

                // Set the category icon as the first frame imageName
                if i == 1 {
                    categoryIcon = imageName
                }
            }

            if insertNone {
                frameList.insert(FrameModel(frame: "none", opacity: 1.0), at: 0)
            }

            frameCategory.frameList = frameList
            frameCategory.categoryIcon = categoryIcon // Assign the icon to the category
            frameCategoryList.append(frameCategory)
        }

        // Add Mother's Day frames
        addFrameCategory(name: "Mothers Day", frameCount: 20, format: "MothersDay_frame_%d_%@")

        // Add Kindness frames
        addFrameCategory(name: "Kindness", frameCount: 18, format: "kindness_frame_%d_%@")

        // Add Valentine frames
        addFrameCategory(name: "Valentine", frameCount: 18, format: "valentine_frame_%d_%@")

        // Add New Year frames
        addFrameCategory(name: "New Year", frameCount: 20, format: "New_year_frame_%d_%@")

        // Add Holiday frames
        addFrameCategory(name: "Holiday", frameCount: 16, format: "HP500_App_%d_%@")

        // Add Winter frames
        addFrameCategory(name: "Winter", frameCount: 9, format: "HP500_App_%d_%@")

        // Add Thanksgiving frames
        addFrameCategory(name: "Thanks Giving", frameCount: 23, format: "HP500_App_%d_%@")

        // Add Solid frames
        addFrameCategory(name: "Solid", frameCount: 30, format: "HP500_App_%d_%@")

        return frameCategoryList
    }


//    func getEmoticonDataNew(isLandscape: Bool, selectedRatio: CGFloat) -> [FrameCategoryModel] {
//        let photoLength: CGFloat = selectedRatio
//        var sizeType = ""
//        // 9 7 4 1
//        if photoLength <= 2 {
//            sizeType = "1"
//        } else if photoLength <= 5 {
//            sizeType = "4"
//        } else if photoLength <= 7 {
//            sizeType = "7"
//        } else if photoLength <= 9 {
//            sizeType = "9"
//        } else {
//            sizeType = "9"
//        }
//
//        var frameCategotyDetail = FrameCategoryModel()
//        var frameCategoryList = [FrameCategoryModel]()
//
//
//        for i in 1...20 {
//            var imageName = String(format: "MothersDay_frame_%d_\(sizeType)", i)
//            if isLandscape == true {
//                imageName = String(format: "MothersDay_frame_%d_\(sizeType)_L", i)
//            }
//            frameCategotyDetail.categoryName = "Mothers Day"
//            frameCategotyDetail.categoryIcon = imageName
//
//            var frameList = frameCategotyDetail.frameList
//            frameList = frameList == nil ? [String]() : frameList
//            frameList?.append(imageName)
//            frameCategotyDetail.frameList = frameList
//        }
//
//        frameCategotyDetail.frameList?.insert("none", at: 0)
//        frameCategoryList.append(frameCategotyDetail)
//        frameCategotyDetail = FrameCategoryModel()
//
//        for i in 1...18 {
//            var imageName = String(format: "kindness_frame_%d_\(sizeType)", i)
//            if isLandscape == true {
//                imageName = String(format: "kindness_frame_%d_\(sizeType)_L", i)
//            }
//            frameCategotyDetail.categoryName = "Kindness"
//            frameCategotyDetail.categoryIcon = imageName
//
//            var frameList = frameCategotyDetail.frameList
//            frameList = frameList == nil ? [String]() : frameList
//            frameList?.append(imageName)
//            frameCategotyDetail.frameList = frameList
//        }
//
//        frameCategotyDetail.frameList?.insert("none", at: 0)
//        frameCategoryList.append(frameCategotyDetail)
//        frameCategotyDetail = FrameCategoryModel()
//
//
//        for i in 1...18 {
//            var imageName = String(format: "valentine_frame_%d_\(sizeType)", i)
//            if isLandscape == true {
//                imageName = String(format: "valentine_frame_%d_\(sizeType)_L", i)
//            }
//            frameCategotyDetail.categoryName = "Valentine"
//            frameCategotyDetail.categoryIcon = imageName
//
//            var frameList = frameCategotyDetail.frameList
//            frameList = frameList == nil ? [String]() : frameList
//            frameList?.append(imageName)
//            frameCategotyDetail.frameList = frameList
//        }
//
//        frameCategotyDetail.frameList?.insert("none", at: 0)
//        frameCategoryList.append(frameCategotyDetail)
//        frameCategotyDetail = FrameCategoryModel()
//
//        for i in 1...20 {
//            var imageName = String(format: "New_year_frame_%d_\(sizeType)", i)
//            if isLandscape == true {
//                imageName = String(format: "New_year_frame_%d_\(sizeType)_L", i)
//            }
//            frameCategotyDetail.categoryName = "New Year"
//            frameCategotyDetail.categoryIcon = imageName
//
//            var frameList = frameCategotyDetail.frameList
//            frameList = frameList == nil ? [String]() : frameList
//            frameList?.append(imageName)
//            frameCategotyDetail.frameList = frameList
//        }
//
//        frameCategotyDetail.frameList?.insert("none", at: 0)
//        frameCategoryList.append(frameCategotyDetail)
//        frameCategotyDetail = FrameCategoryModel()
//
//        for i in 0...15 {
//            let index = 54 + i
//            var imageName = String(format: "HP500_App_%d_\(sizeType)", index)
//            if isLandscape == true {
//                imageName = String(format: "HP500_App_%d_\(sizeType)_L", index)
//            }
//            frameCategotyDetail.categoryName = "Holiday"
//            frameCategotyDetail.categoryIcon = imageName
//
//            var frameList = frameCategotyDetail.frameList
//            frameList = frameList == nil ? [String]() : frameList
//            frameList?.append(imageName)
//            frameCategotyDetail.frameList = frameList
//        }
//
//        frameCategotyDetail.frameList?.insert("none", at: 0)
//        frameCategoryList.append(frameCategotyDetail)
//        frameCategotyDetail = FrameCategoryModel()
//
//        for i in 0...8 {
//            let index = 70 + i
//            var imageName = String(format: "HP500_App_%d_\(sizeType)", index)
//            if isLandscape == true {
//                imageName = String(format: "HP500_App_%d_\(sizeType)_L", index)
//            }
//            frameCategotyDetail.categoryName = "Winter"
//            frameCategotyDetail.categoryIcon = imageName
//
//            var frameList = frameCategotyDetail.frameList
//            frameList = frameList == nil ? [String]() : frameList
//            frameList?.append(imageName)
//            frameCategotyDetail.frameList = frameList
//        }
//
//        frameCategotyDetail.frameList?.insert("none", at: 0)
//        frameCategoryList.append(frameCategotyDetail)
//        frameCategotyDetail = FrameCategoryModel()
//
//        for i in 1...23 {
//            let index = 30 + i
//            var imageName = String(format: "HP500_App_%d_\(sizeType)", index)
//            if isLandscape == true {
//                imageName = String(format: "HP500_App_%d_\(sizeType)_L", index)
//            }
//            frameCategotyDetail.categoryName = "Thanks Giving"
//            frameCategotyDetail.categoryIcon = imageName
//
//            var frameList = frameCategotyDetail.frameList
//            frameList = frameList == nil ? [String]() : frameList
//            frameList?.append(imageName)
//            frameCategotyDetail.frameList = frameList
//        }
//
//        frameCategotyDetail.frameList?.insert("none", at: 0)
//        frameCategoryList.append(frameCategotyDetail)
//        frameCategotyDetail = FrameCategoryModel()
//
//        for i in 1...30 {
//            var imageName = String(format: "HP500_App_%d_\(sizeType)", i)
//            if isLandscape == true {
//                imageName = String(format: "HP500_App_%d_\(sizeType)_L", i)
//            }
//            print(imageName)
//            frameCategotyDetail.categoryName = "Solid"
//            frameCategotyDetail.categoryIcon = imageName
//
//            var frameList = frameCategotyDetail.frameList
//            frameList = frameList == nil ? [String]() : frameList
//            frameList?.append(imageName)
//            frameCategotyDetail.frameList = frameList
//        }
//
//        frameCategotyDetail.frameList?.insert("none", at: 0)
//        frameCategoryList.append(frameCategotyDetail)
//        frameCategotyDetail = FrameCategoryModel()
//
//        return frameCategoryList
//    }
}

/*
 
 **/
