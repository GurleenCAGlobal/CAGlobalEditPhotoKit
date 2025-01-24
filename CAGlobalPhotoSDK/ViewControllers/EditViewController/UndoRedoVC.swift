//
//  UndoRedoVC.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 29/10/24.
//

import Foundation
import UIKit

enum EditActionType {
    case add
    case opacity
    case mirror
    case color
    case font
    case alignment
    case pan
    case pinch
    case rotate
    case orientation
    case brushSize
    case sharpness
}

struct EditAction {
    let type: EditActionType
    let filterSelection: FilterSelection
    let data: Any
}

var globalUndoStack: [EditAction] = []
var globalRedoStack: [EditAction] = []

class Editor {
    static let shared = Editor()
    
    // Store a reference to the stickerTextView
    weak var stickerTextView: UIView?
    
    private init() {} // Private initializer to enforce singleton usage
    
    // Static function to access stickerTextView
    static func getStickerTextView() -> UIView? {
        return shared.stickerTextView
    }
    
    static var currentFilterSelection: FilterSelection = .none
    
//    // Global undo method
//    static func globalUndo() {
//        guard let lastAction = undoStack.last else { return }
//
//        undoStack.removeLast()
//        redoStack.append(lastAction)
//        reverseAction(lastAction)
//    }
//
//    // Global redo method
//    static func globalRedo() {
//        guard let lastUndo = redoStack.last else { return }
//        redoStack.removeLast()
//        undoStack.append(lastUndo)
//        applyAction(lastUndo)
//    }

    // Perform an action and add it to the undo stack
    static func performAction(type: EditActionType, data: Any) {
        let action = EditAction(type: type, filterSelection: currentFilterSelection, data: data)
        globalUndoStack.append(action)
        print(globalUndoStack)
        //redoStack.removeAll() // Clear redo stack when a new action is performed
        //applyAction(action)
    }

    // Static undo method
    static func undo() {
        guard let lastAction = globalUndoStack.last else { return }

        // Remove the last action from the undo stack
        //undoStack.removeLast()

        // Add the action to the redo stack
        globalRedoStack.append(lastAction)

        // Reverse the action
        reverseAction(lastAction)

//        // Restore properties for the last action
//        if let previousState = lastAction.data as? [String: Any],
//           let textView = previousState["view"] as? UILabel {
//
//            // Restore properties
//            textView.text = previousState["text"] as? String
//            textView.font = previousState["font"] as? UIFont
//            textView.textColor = previousState["color"] as? UIColor
//            textView.textAlignment = previousState["alignment"] as? NSTextAlignment ?? .left // Default to left if nil
//            textView.alpha = previousState["opacity"] as? CGFloat ?? 1.0 // Default to fully opaque if nil
//            textView.frame = previousState["frame"] as? CGRect ?? .zero
//            textView.transform = previousState["transform"] as? CGAffineTransform ?? .identity
//
//            // Optionally, handle any additional UI updates or state changes
//        } else {
//            print("Error: Invalid action structure for undo.")
//        }
    }

    // Static redo method
    static func redo() {
        guard let lastUndo = globalRedoStack.last else { return }
        globalRedoStack.removeLast()
        globalUndoStack.append(lastUndo)
        //applyAction(lastUndo)
        applyFilterAction(lastUndo)

    }
    
    // Apply the action (based on type and data)
    private static func applyAction(_ action: EditAction) {
        switch action.type {
        case .add:
            switch currentFilterSelection {
            case .gallery:
                applyStickerAction(action)
            case .sticker:
                applyStickerAction(action)
            case .text:
                applyTextAction(action)
            case .frame:
                applyFrameAction(action)
            case .brush:
                applyBrushAction(action)
            case .transform:
                applyTransformAction(action)
            case .filter:
                applyFilterAction(action)
            case .none:
                print("No filter selected; action not applied.")
            case .auto: break
                
            case .adjust: break
                
            }
        case .opacity:
            applyOpacityAction(action)
        case .mirror:
            print("Applying mirror action")
        case .color:
            applyColorAction(action)
        case .font:
            print("Applying font action")
        case .alignment:
            print("Applying alignment action")
        case .pan:
            applyPanAction(action)
        case .pinch:
            print("Applying pinch action")
        case .rotate:
            print("Applying rotate action")
        case .orientation:
            print("Applying orientation action")
        case .brushSize:
            print("Applying brush size action")
        case .sharpness:
            print("Applying sharpness action")
        }
    }
    
    // Reverse the action effect
    private static func reverseAction(_ action: EditAction) {
        if let stickerView = (action.data as? [String: Any])?["view"] as? UIView {
            stickerView.removeFromSuperview()
        }
//        if let filterView = (action.data as? [String: Any])?["view"] as? UIImageView {
//            if let data = action.data as? [String: Any] {
//                let previousFrame = data["previousImage"] as? UIImage
//                filterView.image = previousFrame
//            }
//        }
//        switch action.type {
//        case .add:
//            // Revert "add" action based on the current filter selection
//            switch currentFilterSelection {
//            case .gallery:
//                if let stickerView = (action.data as? [String: Any])?["view"] as? UIView {
//                    stickerView.removeFromSuperview()
//                }
//            case .sticker:
//                if let stickerView = (action.data as? [String: Any])?["view"] as? UIView {
//                    stickerView.removeFromSuperview()
//                }
//            case .text:
//                if let data = action.data as? [String: Any],
//                   let textView = data["view"] as? UIView {
//                    textView.removeFromSuperview()
//                }
//            case .frame:
//                if let frameView = (action.data as? [String: Any])?["view"] as? UIImageView {
//                    if let data = action.data as? [String: Any] {
//                        let previousFrame = data["previousImage"] as? UIImage
//                        if previousFrame == nil{
//                            frameView.isHidden = true
//                        }else {
//                            frameView.image = previousFrame
//                        }
//                    }
//                }
//
//            case .brush:
//                print("brush")
//            case .transform:
//                print("Reverting transform addition")
//            case .filter:
//                if let filterView = (action.data as? [String: Any])?["view"] as? UIImageView {
//                    if let data = action.data as? [String: Any] {
//                        let previousFrame = data["previousImage"] as? UIImage
//                        filterView.image = previousFrame
//                    }
//                }
//            case .none:
//                print("No filter selected; nothing to revert.")
//            case .auto:
//                break
//            case .adjust:
//                break
//            }
//        case .opacity:
//            if let data = action.data as? [String: Any], let view = data["view"] as? UIView,
//               let previousOpacity = data["previousOpacity"] as? CGFloat {
//                view.alpha = previousOpacity // Restore previous opacity
//            }
//        case .mirror:
//            print("Reverting mirror action")
//        case .color:
//               if let data = action.data as? [String: Any], let view = data["view"] as? UIView,
//               let previousColor = data["previousColor"] as? UIColor {
//                if let label = view as? UILabel {
//                    label.textColor = previousColor // Restore previous color
//                } else if let sticker = view as? UIImageView {
//                    sticker.tintColor = previousColor // Restore previous color for stickers
//                }
//            }
//        case .font:
//            if let data = action.data as? [String: Any],
//               let textView = data["view"] as? UILabel,
//               let previousFont = data["previousFont"] as? UIFont {
//                textView.font = previousFont // Restore previous font
//            }
//        case .alignment:
//            if let data = action.data as? [String: Any],
//               let textView = data["view"] as? UILabel,
//               let previousAlignment = data["previousAlignment"] as? NSTextAlignment {
//                textView.textAlignment = previousAlignment // Restore previous alignment
//            }
//
//        case .pan:
//            if let data = action.data as? [String: Any],
//               let view = data["view"] as? UIView,
//               let originalCenter = data["originalCenter"] as? CGPoint {
//                view.center = originalCenter // Restore original center position
//            }
//        case .pinch:
//            print("Reverting pinch action")
//        case .rotate:
//            print("Reverting rotate action")
//        case .orientation:
//            print("Reverting orientation change")
//        case .brushSize:
//            print("Reverting brush size change")
//        case .sharpness:
//            print("Reverting sharpness change")
//        }
    }
}

// Edit Functionality
extension Editor {
    // Functions for specific filter actions
    private static func applyStickerAction(_ action: EditAction) {
        if let data = action.data as? [String: Any],
           let stickerView = data["view"] as? UIView,
           let frame = data["frame"] as? CGRect,
           let color = data["color"] as? UIColor,
           let image = data["image"] as? UIImage,
           let sticker = data["name"] as? String {

            // Set up the sticker view
            stickerView.frame = frame
            stickerView.backgroundColor = .clear
            stickerView.tintColor = (sticker == "shapes" || sticker == "badges" || sticker == "arrow" || sticker == "spray") ? color : .clear

            // Add image to UIImageView inside the sticker view if it exists, otherwise create one
            if let imageView = stickerView.subviews.compactMap({ $0 as? UIImageView }).first {
                imageView.image = image
            } else {
                let imageView = UIImageView(image: image)
                imageView.frame = stickerView.bounds
                imageView.contentMode = .scaleAspectFit
                stickerView.addSubview(imageView)
            }

            // Add sticker view to stickerTextView if available
            if let stickerTextView = getStickerTextView() {
                stickerTextView.addSubview(stickerView)
            }
        }
    }

    private static func applyTextAction(_ action: EditAction) {
        // Check if action.data is a dictionary
        guard let data = action.data as? [String: Any] else {
            print("Error: Invalid action data structure.")
            return // You can keep this if you want to exit early
        }

        // Check for the textView
        if let textView = data["view"] as? UILabel {

            // Prepare previous state
            var previousText: String?
            var previousFont: UIFont?
            var previousColor: UIColor?
            var previousAlignment: NSTextAlignment?
            var previousOpacity: CGFloat?
            var previousFrame: CGRect?
            var previousTransform: CGAffineTransform?

            // Check for previousState
            if let previousState = data["previousState"] as? [String: Any] {
                // Extract properties if they exist
                previousText = previousState["text"] as? String
                previousFont = previousState["font"] as? UIFont
                previousColor = previousState["color"] as? UIColor
                previousAlignment = previousState["alignment"] as? NSTextAlignment
                previousOpacity = previousState["opacity"] as? CGFloat
                previousFrame = previousState["frame"] as? CGRect
                previousTransform = previousState["transform"] as? CGAffineTransform
            }

            // Save the current state before applying changes for undo functionality
            let currentState: [String: Any] = [
                "text": textView.text ?? "",
                "font": textView.font ?? UIFont.systemFont(ofSize: 12),
                "color": textView.textColor ?? UIColor.black,
                "alignment": textView.textAlignment,
                "opacity": textView.alpha,
                "frame": textView.frame,
                "transform": textView.transform
            ]

            // Apply properties to the text view if they exist
            if let text = previousText {
                textView.text = text
            }

            if let font = previousFont {
                textView.font = font
            }

            if let color = previousColor {
                textView.textColor = color
            }

            if let alignment = previousAlignment {
                textView.textAlignment = alignment
            }

            if let opacity = previousOpacity {
                textView.alpha = opacity
            }

            if let frame = previousFrame {
                textView.frame = frame
            }

            if let transform = previousTransform {
                textView.transform = transform
            }


            // Add the text view to the stickerTextView
            if let stickerTextView = getStickerTextView() {
                stickerTextView.addSubview(textView)
            }

            // Save the action to the undo stack
            let actionToUndo = EditAction(type: .add, filterSelection: currentFilterSelection, data: ["view": textView, "previousState": currentState])
            globalUndoStack.append(actionToUndo)
        } else {
            print("Error: data['view'] is not a UILabel")
        }
    }

    private static func applyFrameAction(_ action: EditAction) {
        if let frameView = (action.data as? [String: Any])?["view"] as? UIImageView {
            // Save the current frame state for undo
            let currentFrameImage = frameView.image
            let previousState = ["image": currentFrameImage as Any]

            if let data = action.data as? [String: Any] {
                // Retrieve the new frame image
                let frame = data["image"] as? UIImage

                // Check if the frame is valid (not "none")
                if frame != nil {
                    frameView.image = frame // Set the new frame image
                    frameView.isHidden = false // Make sure the frame view is visible
                } else {
                    // If the frame is "none", clear the image
                    frameView.image = nil
                    frameView.isHidden = true // Optionally hide the frame view
                }

                // Save the action for undo
                let action = EditAction(type: .add, filterSelection: currentFilterSelection, data: ["view": frameView, "previousState": previousState])
                globalUndoStack.append(action)
            }
        }
    }
    private static func applyBrushAction(_ action: EditAction) {
        
    }
    
    private static func applyTransformAction(_ action: EditAction) {}
    
    private static func applyFilterAction(_ action: EditAction) {
        if let filterView = (action.data as? [String: Any])?["view"] as? UIImageView {
            if let data = action.data as? [String: Any] {
                let frame = data["image"] as? UIImage
                filterView.image = frame
            }
        }
    }
    
    // Unified function for color actions
    private static func applyColorAction(_ action: EditAction) {
        if let data = action.data as? [String: Any],
           let color = data["color"] as? UIColor,
           let viewType = data["viewType"] as? String,
           let view = data["view"] as? UIView {
            if viewType == "sticker", let sticker = view as? UIImageView {
                sticker.tintColor = color
            } else if viewType == "text", let label = view as? UILabel {
                label.textColor = color
            }
        }
    }
    
    // Unified function for opacity actions
    private static func applyOpacityAction(_ action: EditAction) {
        if let data = action.data as? [String: Any],
           let view = data["view"] as? UIView,
           let newOpacity = data["opacity"] as? CGFloat {
            view.alpha = newOpacity
        }
    }
    
    // Unified function for pan actions
    private static func applyPanAction(_ action: EditAction) {
        if let data = action.data as? [String: Any],
           let view = data["view"] as? UIView,
           let newCenter = data["newCenter"] as? CGPoint {
            // Move the sticker to the new center position
            view.center = newCenter
        }
    }
}
