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

//class TextModel: NSObject {
//
//    var textString = ""
//    var fontCustom = "AbrilFatface-Regular"
//    var color = UIColor.black
//    var alignment = NSTextAlignment.left
//
//    var selectedColorIndex = 0
//    var previousSelectedColorIndex = 0
//    var isColor = false
//    var colorPicker = UIColor.black
//    var previousColor = UIColor.black
//    var selectedFontIndex = 0
//    var previousSelectedFontIndex = 0
//    var previousTextString = ""
//    var previousFont = "AbrilFatface-Regular"
//    var opacity = 3.0
//
//    // Undo and Redo Stacks
//    var undoStack: [UndoAction] = []
//    var redoStack: [UndoAction] = []
//
//    // Save an action for undo
//    func saveUndoAction(_ action: UndoAction) {
//        undoStack.append(action)
//        redoStack.removeAll() // Clear redo stack after a new action
//    }
//
//    // Save a text change for undo
//    func saveTextChange(_ oldText: String) {
//        saveUndoAction(UndoAction(property: .text, oldValue: oldText))
//    }
//
//    // Save a font change for undo
//    func saveFontChange(_ oldFont: String) {
//        saveUndoAction(UndoAction(property: .font, oldValue: oldFont))
//    }
//
//    // Save a color change for undo
//    func saveColorChange(_ oldColor: UIColor) {
//        saveUndoAction(UndoAction(property: .color, oldValue: oldColor))
//    }
//
//    // Save an alignment change for undo
//    func saveAlignmentChange(_ oldAlignment: NSTextAlignment) {
//        saveUndoAction(UndoAction(property: .alignment, oldValue: oldAlignment))
//    }
//
//    // Undo the last action
//    func undo() {
//        guard let lastAction = undoStack.popLast() else { return }
//
//        // Save the current state for redo
//        switch lastAction.property {
//        case .text:
//            let currentText = self.textString
//            self.textString = lastAction.oldValue as! String
//            redoStack.append(UndoAction(property: .text, oldValue: currentText))
//
//        case .font:
//            let currentFont = self.fontCustom
//            self.fontCustom = lastAction.oldValue as! String
//            redoStack.append(UndoAction(property: .font, oldValue: currentFont))
//
//        case .color:
//            let currentColor = self.color
//            self.color = lastAction.oldValue as! UIColor
//            redoStack.append(UndoAction(property: .color, oldValue: currentColor))
//
//        case .alignment:
//            let currentAlignment = self.alignment
//            self.alignment = lastAction.oldValue as! NSTextAlignment
//            redoStack.append(UndoAction(property: .alignment, oldValue: currentAlignment))
//        }
//
//        // Update the view to reflect the undone change
//        updateFramesText()
//    }
//
//    // Redo the last undone action
//    func redo() {
//        guard let lastRedoAction = redoStack.popLast() else { return }
//
//        // Save the current state for undo
//        switch lastRedoAction.property {
//        case .text:
//            let currentText = self.textString
//            self.textString = lastRedoAction.oldValue as! String
//            undoStack.append(UndoAction(property: .text, oldValue: currentText))
//
//        case .font:
//            let currentFont = self.fontCustom
//            self.fontCustom = lastRedoAction.oldValue as! String
//            undoStack.append(UndoAction(property: .font, oldValue: currentFont))
//
//        case .color:
//            let currentColor = self.color
//            self.color = lastRedoAction.oldValue as! UIColor
//            undoStack.append(UndoAction(property: .color, oldValue: currentColor))
//
//        case .alignment:
//            let currentAlignment = self.alignment
//            self.alignment = lastRedoAction.oldValue as! NSTextAlignment
//            undoStack.append(UndoAction(property: .alignment, oldValue: currentAlignment))
//        }
//
//        // Update the view to reflect the redone change
//        updateFramesText()
//    }
//
//    func updateFramesText() {
//        // Update the text view or UI elements
//    }
//}

//import UIKit
//
//class TextModel: NSObject {
//    
//    // Index of the selected color in the color options
//    var selectedColorIndex = 0
//    // Index of the selected color in the color options
//    var previousSelectedColorIndex = 0
//    // Flag indicating whether the selection is for color or font
//    var isColor = false
//    // The selected color for the text
//    var color = UIColor.black
//    // The selected color for the color picker
//    var colorPicker = UIColor.black
//    // The selected color for the text
//    var previousColor = UIColor.black
//
//    
//    // Index of the selected font in the font options
//    var selectedFontIndex = 0
//    // Index of the selected font in the font options
//    var previousselectedFontIndex = 0
//    // The text string to be displayed
//    var textString = ""
//    // The text string to be displayed
//    var previousTextString = ""
//    // The selected font for the text
//    var fontCustom = "AbrilFatface-Regular"
//    // The selected font for the text
//    var previousfont = "AbrilFatface-Regular"
//    
//    var alignment = NSTextAlignment.left
//    
//    var opacity = 3.0
//
//    var undoStack: [TextModel] = []
//    var redoStack: [TextModel] = []
//
//    func copyState() -> TextModel {
//        let copy = TextModel()
//        copy.selectedColorIndex = self.selectedColorIndex
//        copy.previousSelectedColorIndex = self.previousSelectedColorIndex
//        copy.color = self.color
//        copy.previousColor = self.previousColor
//        copy.selectedFontIndex = self.selectedFontIndex
//        copy.previousselectedFontIndex = self.previousselectedFontIndex
//        copy.textString = self.textString
//        copy.previousTextString = self.previousTextString
//        copy.fontCustom = self.fontCustom
//        copy.previousfont = self.previousfont
//        copy.alignment = self.alignment
//        copy.opacity = self.opacity
//        return copy
//    }
//}



//    class TextModel {
//        var text: String
//        var font: UIFont
//        var color: UIColor
//        var alignment: NSTextAlignment
//
//        // Undo and Redo stacks
//        var undoStack: [TextState] = []
//        var redoStack: [TextState] = []
//
//        init(text: String, font: UIFont, color: UIColor, alignment: NSTextAlignment) {
//            self.text = text
//            self.font = font
//            self.color = color
//            self.alignment = alignment
//        }
//
//        // Other methods and properties of your TextModel
//    }

class TextModel: NSObject {

    var selectedColorIndex = 0
    var previousSelectedColorIndex = 0
    var isColor = false
    var color = UIColor.black
    var colorPicker = UIColor.black
    var previousColor = UIColor.black
    var selectedFontIndex = 0
    var previousSelectedFontIndex = 0
    var textString = ""
    var previousTextString = ""
    var fontCustom = "AbrilFatface-Regular"
    var previousFont = "AbrilFatface-Regular"
    var alignment = NSTextAlignment.left
    var opacity = 3.0

    // Undo and Redo Stacks
    var undoStack: [TextModel] = []
    var redoStack: [TextModel] = []


    func saveStateForUndo() {
        undoStack.append(self.copyState())
        redoStack.removeAll() // Clear redo stack after any new change
    }
  
    func undo() {
        guard !undoStack.isEmpty else { return }

        // Pop the latest change from undoStack
        let lastChange = undoStack.removeLast()

        // Push it to the redoStack, in case you want to redo it later
        redoStack.append(lastChange)

        // Restore the state from the last change
        applyState(lastChange)
    }

//    func undo() {
//        // Check if there are states to undo
//        guard !textModel.undoStack.isEmpty else { return }
//
//        // Pop the last state from the undo stack
//        let lastState = textModel.undoStack.removeLast()
//
//        // Store the current state in the redo stack in case we redo later
//        let currentState = TextState(
//            text: self.textModel.text,
//            font: self.textModel.font,
//            color: self.textModel.color,
//            alignment: self.textModel.alignment
//        )
//        textModel.redoStack.append(currentState)
//
//        // Restore the previous state
//        self.textModel.text = lastState.text
//        self.textModel.font = lastState.font
//        self.textModel.color = lastState.color
//        self.textModel.alignment = lastState.alignment
//
//        // Apply the changes visually
//        updateFramesText()
//
//        // Optional: print undoStack and redoStack count for debugging
//        print("Undo Stack Count after undo: \(textModel.undoStack.count)")
//        print("Redo Stack Count after undo: \(textModel.redoStack.count)")
//    }


    func redo() {
        guard let nextState = redoStack.popLast() else { return }

        // Save the current state to the undoStack before redoing
        undoStack.append(self.copyState())

        // Debug: Check the redo state values
        print("Redo State: Text: \(nextState.textString), Color: \(nextState.color), Font: \(nextState.fontCustom), Alignment: \(nextState.alignment)")

        // Apply only the changed properties
        if nextState.textString != self.textString {
            self.textString = nextState.textString
        }

        if nextState.color != self.color {
            self.color = nextState.color
        }

        if nextState.fontCustom != self.fontCustom {
            self.fontCustom = nextState.fontCustom
        }

        if nextState.alignment != self.alignment {
            self.alignment = nextState.alignment
        }

        // Update the view after redo
     //   updateFramesText()

        // Debug: Check undo and redo stack count
        print("Undo Stack Count after redo: \(undoStack.count)")
        print("Redo Stack Count after redo: \(redoStack.count)")
    }



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
//
//
