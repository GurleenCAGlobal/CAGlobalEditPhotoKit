//
//  Config.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//

import UIKit

public enum QCropper {
    public enum Config {
        public static var croppingImageShortSideMaxSize: CGFloat = 1280
        public static var croppingImageLongSideMaxSize: CGFloat = 5120 // 1280 * 4

        public static var highlightColor = UIColor(red: 249 / 255.0, green: 214 / 255.0, blue: 74 / 255.0, alpha: 1)

        public static var resourceBundle = Bundle(for: CropperViewController.self)
    }
}
