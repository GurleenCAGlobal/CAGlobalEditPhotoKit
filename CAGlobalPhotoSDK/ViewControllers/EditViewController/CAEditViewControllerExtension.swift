//
//  CAEditViewControllerExtension.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 02/05/23.
//

import Foundation
import UIKit
import Photos
import Accelerate
import AudioToolbox

// MARK: - Options functionality
// MARK: Gallery Options (if we are using blank image) -
// MARK: - Auto Enhancement Option -

extension CAEditViewController: AMColorPickerDelegate {
    func colorPicker(_ colorPicker: AMColorPicker, didSelect color: UIColor, opacity: CGFloat)  {
        switch self.filterSelection {
        case .text:
            let textModel = TextModel()
            let rgba = color.rgba
            let alpha = rgba.alpha / 100.0
            textModel.color = UIColor(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: alpha)
            textModel.selectedColorIndex = 101
            textModel.previousColor = self.selectedTextModel.previousColor
            textModel.previousSelectedColorIndex = self.selectedTextModel.previousSelectedColorIndex
            textModel.selectedFontIndex = self.selectedTextModel.selectedFontIndex
            textModel.previousSelectedFontIndex = self.selectedTextModel.previousSelectedFontIndex
            textModel.textString = self.selectedTextModel.textString
            textModel.previousTextString = self.selectedTextModel.previousTextString
            textModel.fontCustom = self.selectedTextModel.fontCustom
            textModel.previousFont = self.selectedTextModel.previousFont
            self.selectedTextModel = textModel
            self.stickersText(text: .setColor,textModel: self.selectedTextModel, color: color, index: 101, isText: true)
            self.textView.setUpTextAndColor(views: self.stickerTextView.subviews)
        case .brush:
            self.drawingViewWillBeginDraw()
            self.option.selectedBrushColorIndex = 101
            self.viewPaintDrawing.strokeColor = color
            self.viewPaintDrawing.strokeOpacity = opacity
            self.brushView.colorButton.backgroundColor = self.viewPaintDrawing.strokeColor
            self.brushView.sharpnessColorLbl.backgroundColor = self.viewPaintDrawing.strokeColor
            self.brushView.brushTransparencyLabel.backgroundColor = self.viewPaintDrawing.strokeColor
            self.brushView.brushSizeLabel.backgroundColor = self.viewPaintDrawing.strokeColor
        case .sticker:
            self.selectedStickerColorModel = color
            self.stickersText(text: .setColor, color: color, isText: false)
        default:
            break
        }
    }
}


// MARK: - UICollectionViewDataSource and UICollectionViewDelegate  -

extension CAEditViewController: EditOptionsCellDataSource {
    func getFilterData() -> [FilterModel] {
        return self.editViewModel.filterData
    }
}

extension CAEditViewController: UICollectionViewDataSource, UICollectionViewDelegate, EditOptionsCellDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.editViewModel.filterData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditOptionsCell.className, for: indexPath) as? EditOptionsCell else {
            let cell = EditOptionsCell()
            return cell
        }
        cell.delegate = self
        cell.dataSource = self
        let indesPath = 0
        let data = self.editViewModel.filterData[indexPath.row]
        var isAuto = false
        if indexPath.row == 0 + indesPath && self.option.isAuto {
            isAuto = true
        }

        let isSelect = self.filterSelection?.rawValue == indexPath.row
        cell.configure(with: data, filterSelection: self.filterSelection ?? .none, editOptions: self.option, isSelect: isSelect, isAutoSelect: isAuto, isRedEyeSelect: false)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.option.isTransformActual = false
        let cell = collectionView.cellForItem(at: indexPath) as? EditOptionsCell
        let currentFilterSelection = FilterSelection(rawValue: indexPath.row) ?? .none
        cell?.handleSelection(filterSelection: self.filterSelection ?? .none,currentFilterSelection: currentFilterSelection, editOptions: self.option)
    }

    // MARK: Cell Delegates
    func didSelectCell(filterSelection: FilterSelection, currentFilterSelection: FilterSelection, editOptions: EditOptions) {
        self.removeGesturesMainImageViewForMagnify()
        self.resetImageView()
        self.unsavedOptions()
        self.filterSelection = currentFilterSelection
        self.stickerTextView.isUserInteractionEnabled = true
        self.mainCollectionView.isHidden = true
        self.undoButton.isHidden = false
        self.redoButton.isHidden = false
        self.textModel.undoStack.removeAll()
        self.textModel.redoStack.removeAll()
        undoStackFrames.removeAll()
        redoStackFrames.removeAll()
       // enableDisableUIControl()
        self.editOptions()
        if let defaultCropperState = self.initialState {
            self.restoreState(defaultCropperState)
        }
        self.backgroundView.transform = .identity
    }

    func editOptions() {
        self.mainPreviousImage = mainImageView.image
        self.undoButton.isHidden = false
        self.redoButton.isHidden = false
        self.hideCrossTickOnly()
        self.mainCollectionView.reloadData()
        switch self.filterSelection {
        case .gallery:
            UINavigationBar.appearance().tintColor = UIColor.blue
            self.mainCollectionView.isHidden = false
            self.openPhotoLibrary(isEdit: false)
        case .transform:
            self.setUpTransformView()
        case .text:
            self.setUpTextView(isSaveCross: self.saveCrossView.isHidden)
        case .sticker:
            self.undoButton.isHidden = true
            self.redoButton.isHidden = true
            self.setUpStickerView()
        case .frame:
            self.undoButton.isHidden = true
            self.redoButton.isHidden = true
            self.setUpFrameView()
        case .brush:
            
            self.removePanGestureMainEdit()
            self.setUpBrushView()
        case .auto:
            self.mainPreviousImage = mainImageView.image
            self.option.isAuto = !self.option.isAuto
            self.mainImageView.image = self.applyingAllFilters()
            self.saveEdit()
            self.addFilterUndoArray(option: "auto")
        case .filter:
            self.undoButton.isHidden = true
            self.redoButton.isHidden = true
            self.setUpFilter()
        case .adjust:
            self.undoButton.isHidden = true
            self.redoButton.isHidden = true
            self.setUpAdjustsView()
        default:
            self.filterSelection = FilterSelection(rawValue: -1)
            break
        }
        self.mainCollectionView.reloadData()
    }
    
    func addFilterUndoArray(option: String = "") {
        let data: [String: Any] = [
            "view": mainImageView,
            "image": mainImageView.image,
            "previousImage": mainPreviousImage!,
            "option" : option
        ]
        let action = EditAction(type: .add, filterSelection: .none, data: data)
        globalUndoStack.append(action)
    }
    
    func addStickerUndoArray() {
        let data: [String: Any] = [
            "view": stickerTextView,
            "image": stickerTextView,
            "previousImage": stickerTextView
        ]
        let action = EditAction(type: .add, filterSelection: .none, data: data)
        globalUndoStack.append(action)
    }
    
    func setPreviousViewInUndo() {
        if globalUndoStack.count > 0 {
            guard let lastAction = globalUndoStack.last else { return }
            if (lastAction.data as? [String: Any])?["view"] is UIImageView {
                if let data = lastAction.data as? [String: Any] {
                    let previousFrame = data["image"] as? UIImage
                    mainPreviousImage = previousFrame
                }
            }
        }
        
        if mainPreviousImage == nil {
            framePreviousImage = UIImage.init(named: "thumb")
        }
    }
}
