//
//  TextModel.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 17/03/23.
//
enum PropertyType {
    case text, font, color, alignment
}

struct UndoAction {
    let property: PropertyType
    let oldValue: Any
}

import UIKit

class TextModel: NSObject {

    var selectedColorIndex = 0
    var selectedBackGrounfColorIndex = 0
    var previousSelectedColorIndex = 0
    var previousSelectedBackgroundColorIndex = 0
    var isColor = false
    var isBackgroundColor = false
    var color = UIColor.black
    var backgroungColor = UIColor.clear
    var colorPicker = UIColor.black
    var previousColor = UIColor.black
    var previousBackgroundColor = UIColor.black
    var selectedFontIndex = 0
    var previousSelectedFontIndex = 0
    var textString = ""
    var previousTextString = ""
    var fontCustom = "AbrilFatface-Regular"
    var previousFont = "AbrilFatface-Regular"
    var alignment = NSTextAlignment.center
    var opacity = 3.0

    // Apply the properties from a given state
    func applyState(_ state: TextModel) {
        self.selectedColorIndex = state.selectedColorIndex
        self.previousSelectedColorIndex = state.previousSelectedColorIndex
        self.color = state.color
        self.previousColor = state.previousColor
        self.selectedFontIndex = state.selectedFontIndex
        self.previousSelectedFontIndex = state.previousSelectedFontIndex
        self.textString = state.textString
        self.previousTextString = state.previousTextString
        self.fontCustom = state.fontCustom
        self.previousFont = state.previousFont
        self.alignment = state.alignment
        self.opacity = state.opacity 
    }

    func copyState() -> TextModel {
        let copy = TextModel()
        copy.selectedColorIndex = self.selectedColorIndex
        copy.previousSelectedColorIndex = self.previousSelectedColorIndex
        copy.color = self.color
        copy.previousColor = self.previousColor
        copy.selectedFontIndex = self.selectedFontIndex
        copy.previousSelectedFontIndex = self.previousSelectedFontIndex
        copy.textString = self.textString
        copy.previousTextString = self.previousTextString
        copy.fontCustom = self.fontCustom
        copy.previousFont = self.previousFont
        copy.alignment = self.alignment
        copy.opacity = self.opacity
        return copy
    }
}
