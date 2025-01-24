//
//  GlobalHelper.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 24/03/23.
//

import UIKit

@objcMembers public class GlobalHelper:NSObject {
    
    static let sharedManager = GlobalHelper()
    
    var stickerView =  UIView()
    var isRulerSliderChange = Bool(false)
    var isLandcape = Bool(false)
    var photoLength = CGFloat(0.0)
    var fromPhotobooth = Bool(false)
    var navigationController = UINavigationController()
    var isNavigateSignup = Bool(false)
    var isEditComplete = Bool(false)
    var hadChanges = Bool(false)
    var finalEditImage = UIImage()
    var selectedRatioWith = CGFloat(0.0)

    var isPhotoboothCapturing = Bool(false)
    var copilotTextFrameIds = [String]()

    var copilotFrameIds = [String]()
    var copilotStickerIds = [String]()
    var copilotFontIds = [String]()

    var copilotFrameNamesList = [String]()
    var originalFrameNamesList = [String]()

    var isFunFactScreen = Bool(false)

    func clearImglyCopilot() {
        copilotFrameIds.removeAll()
        copilotStickerIds.removeAll()
        copilotFontIds.removeAll()
    }
    
}


// Function to disable button
func disableBtnAnimated(_ sender:UIButton)
{
    sender.isEnabled = false
    UIView.animate(withDuration: 1, delay: 0.1, options: .beginFromCurrentState, animations: {
        sender.alpha = 0.30
    }, completion: nil)
}

// Function to enable button
func enableBtnAnimated(_ sender:UIButton)
{
    sender.isEnabled = true
    UIView.animate(withDuration: 1, delay: 0.1, options: .beginFromCurrentState, animations: {
        sender.alpha = 1
    }, completion: nil)
}

// Function to showHidePassword using button
func showHidePassword(_ sender: UIButton,_ txtFieldPassword: UITextField)
{
    if !sender.isSelected{
        sender.isSelected = true
        txtFieldPassword.isSecureTextEntry = false
    } else {
        sender.isSelected = false
        txtFieldPassword.isSecureTextEntry = true
    }
}
