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

extension CAEditViewController: AMColorPickerDelegate {
    
    func colorPicker(_ colorPicker: any AMColorPicker, didSelect color: UIColor, opacity: CGFloat, isBackground: Bool) {
        switch self.filterSelection {
        case .text:
            let textModel = TextModel()
            let rgba = color.rgba
            let alpha = rgba.alpha / 100.0
            if isBackground == true {
                textModel.backgroungColor = UIColor(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: alpha)
                textModel.selectedBackGrounfColorIndex = 101
                textModel.previousBackgroundColor = self.selectedTextModel.previousBackgroundColor
                textModel.previousSelectedBackgroundColorIndex = self.selectedTextModel.previousSelectedBackgroundColorIndex

            } else {
                textModel.color = UIColor(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: alpha)
                textModel.selectedColorIndex = 101
                textModel.previousColor = self.selectedTextModel.previousColor
                textModel.previousSelectedColorIndex = self.selectedTextModel.previousSelectedColorIndex
            }
            
            textModel.selectedFontIndex = self.selectedTextModel.selectedFontIndex
            textModel.previousSelectedFontIndex = self.selectedTextModel.previousSelectedFontIndex
            textModel.textString = self.selectedTextModel.textString
            textModel.previousTextString = self.selectedTextModel.previousTextString
            textModel.fontCustom = self.selectedTextModel.fontCustom
            textModel.previousFont = self.selectedTextModel.previousFont
            self.selectedTextModel = textModel
            
            let colorModel = ColorModel()
            colorModel.selectedColorIndex = 101
            colorModel.isColor = true
            colorModel.color = color
            if isBackground == true {
                self.stickersText(text: .setBackgroundColor, textModel: self.selectedTextModel, color: colorModel, index: 101, isText: true)
                self.textView.colorBackWheelImage.image = UIImage(named: "Color Wheel - Selected")
                self.textView.colorBackWheelSelectedImage.backgroundColor = color

            } else {
                self.stickersText(text: .setColor, textModel: self.selectedTextModel, color: colorModel, index: 101, isText: true)
                self.textView.colorWheelImage.image = UIImage(named: "Color Wheel - Selected")
                self.textView.colorWheelSelectedImage.backgroundColor = color

            }
            self.textView.setUpTextAndColor(views: self.stickerTextView.subviews)
            if let defaultCropperState = self.initialState {
                self.restoreState(defaultCropperState)
            }
            self.backgroundView.transform = .identity
        case .brush:
            self.brushView.updateFontColor(color: color)
            self.drawingViewWillBeginDraw()
            self.option.selectedBrushColorIndex = 101
            self.viewPaintDrawing.colorIndex = 101
            self.viewPaintDrawing.strokeColor = color
            self.viewPaintDrawing.strokeOpacity = self.viewPaintDrawing.strokeOpacity
            self.brushView.colorButton.backgroundColor = self.viewPaintDrawing.strokeColor
            self.brushView.sharpnessColorLbl.backgroundColor = self.viewPaintDrawing.strokeColor
            self.brushView.brushTransparencyLabel.backgroundColor = self.viewPaintDrawing.strokeColor
            self.brushView.brushSizeLabel.backgroundColor = self.viewPaintDrawing.strokeColor
            self.brushView.colorWheelImage.image = UIImage(named: "Color Wheel - Selected")
            self.brushView.colorWheelSelectedImage.backgroundColor = color
            self.viewPaintDrawing.isUserInteractionEnabled = true
            self.stickerTextView.isUserInteractionEnabled = false
            self.magnifyingGlass.magnifiedView = nil
            self.removeGesturesMainImageViewForMagnify()
        case .sticker:
//            let rgba = color.rgba
//            let alpha = rgba.alpha / 100.0
//            let color = UIColor(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: alpha)

            self.selectedStickerColor = color
            
            let colorModel = ColorModel()
            colorModel.selectedColorIndex = 101
            colorModel.isColor = true
            colorModel.color = color
            
            self.stickersText(text: .setColor, color: colorModel, index: 101, isText: false)
            self.stickerOption.colorWheelImage.image = UIImage(named: "Color Wheel - Selected")
            self.stickerOption.colorWheelSelectedImage.backgroundColor = color
            self.stickerOption.setUpColor(color: color, model: colorModel)

        default:
            break
        }
    }
}

// MARK: - UICollectionViewDataSource and UICollectionViewDelegate -

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
        cell?.handleSelection(filterSelection: self.filterSelection ?? .none, currentFilterSelection: currentFilterSelection, editOptions: self.option)
    }

    // MARK: Cell Delegates
    func didSelectCell(filterSelection: FilterSelection, currentFilterSelection: FilterSelection, editOptions: EditOptions) {
        self.resetImageView()
        self.unsavedOptions()
        self.filterSelection = currentFilterSelection
        self.stickerTextView.isUserInteractionEnabled = true
        self.mainCollectionView.isHidden = true
        self.editOptions()
        if let defaultCropperState = self.initialState {
            self.restoreState(defaultCropperState)
        }
        self.backgroundView.transform = .identity
    }

    // MARK: - Main View Bottom Sub option
    func editOptions() {
        self.mainPreviousImage = mainImageView.image
        self.hideCrossTickOnly()
        self.isShownRedoUndo()
        self.mainCollectionView.reloadData()
        switch self.filterSelection {
        case .gallery:
            self.isShownRedoUndo()
            UINavigationBar.appearance().tintColor = UIColor.blue
            self.mainCollectionView.isHidden = false
            self.openPhotoLibrary(isEdit: false)
            if let defaultCropperState = self.initialState {
                self.restoreState(defaultCropperState)
            }
            self.backgroundView.transform = .identity
        case .transform:
            self.isShowingRedoUndo()
            self.setUpTransformView()
        case .text:
            self.isShownRedoUndo()
            self.setUpTextView(isSaveCross: self.saveCrossView.isHidden)
        case .sticker:
            self.isShownRedoUndo()
            self.setUpStickerView()
        case .frame:
            self.isShowingRedoUndo()
            self.setUpFrameView()
        case .brush:
            self.isShownRedoUndo()
            isEnableRedoUndo()
            self.removePanGestureMainEdit()
            self.setUpBrushView()
        case .auto:
            self.isShowingRedoUndo()
            self.option.isAuto = !self.option.isAuto
            self.mainImageView.image = self.applyingAllFilters()
            self.saveEdit()
        case .filter:
            self.isShownRedoUndo()
            self.setUpFilter()
        case .adjust:
            self.isShowingRedoUndo()
            self.setUpAdjustsView()
        default:
            self.isShowingRedoUndo()
            self.filterSelection = FilterSelection(rawValue: -1)
            break
        }
        self.mainCollectionView.reloadData()
    }
}
