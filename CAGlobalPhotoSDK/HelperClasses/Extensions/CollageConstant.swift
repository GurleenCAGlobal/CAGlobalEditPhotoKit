//
//  AppConstant.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 11/8/23.
//

import UIKit

class AppConstant: NSObject {}
let layoutSelectedColor = UIColor(red:0.21, green:0.24, blue:0.78, alpha:1)
let layoutUnSelectedColor = UIColor(red:0.2, green:0.2, blue:0.24, alpha:1)
var totalImagesInCurrentlayout = Int()
struct SelectedLayouts {
    var verticalLayoutTwo = "verticalTwo"
    var horizontalLayoutTwo = "horizontalTwo"
    var verticalLayoutThree = "verticalThree"
    var horizontalLayoutThree = "horizontalThree"
    var verticalLayoutFour = "verticalFour"
    var horizontalLayoutFour = "horizontalFour"
}
let selectedLayouts = SelectedLayouts()
var selectedNotificationKey = selectedLayouts.verticalLayoutTwo
var reloadCollectionKey = "ReloadColelctionView"
var selectedImageIndex = 11
var previousSelectImageIndex = 11
var isForReplacePhoto = false
var selectedImagesData = [[String:Any]]()
var tempImageArray = [UIImage]()
var socialPhotoArray = [String]()
var imageLocalIdentifier = String()
//Save imageScrollView in collage
var imageScrollViewArray = [ZoomImageView]()

func checkImageForButtonCountLable(image:UIImage?,imageButton:UIButton,imageIndex:String) {
    let imageIndexs = Int(imageIndex)!
    if image != nil {
        imageButton.setTitle("", for: .normal)
    } else {
        imageButton.setTitle(imageIndex, for: .normal)
    }
    let imageDictionary : [String : Any] = ["image": image!,"index": imageIndexs]
    // If image of current image index is present in dict then remove else add it in array
    if let index = selectedImagesData.firstIndex(where: {$0["index"] as? Int == imageIndexs}) {
        selectedImagesData.remove(at: index)
        if image != nil {
            selectedImagesData.append(imageDictionary)
        }
    } else {
        if selectedImagesData.count <= totalImagesInCurrentlayout {
            selectedImagesData.append(imageDictionary)
        }
    }
}

func roundedCorner(image:UIImageView){
    image.layer.cornerRadius = 6
    image.clipsToBounds = true
    image.contentMode = .scaleAspectFill
}

func setSelecetdBorder(image:UIImageView, isSet:Bool){
    if isSet{
        image.layer.borderWidth = 2
        image.layer.borderColor = layoutSelectedColor.cgColor
        image.backgroundColor = layoutSelectedColor
    } else {
        image.backgroundColor = layoutUnSelectedColor
        image.layer.borderWidth = 0
    }
}
