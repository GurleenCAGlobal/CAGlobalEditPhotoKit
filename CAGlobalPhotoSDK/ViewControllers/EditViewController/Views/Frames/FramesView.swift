//
//  FramesView.swift
//  CAGlobalPhotoSDK
//
//  Created by Gurleen Singh on 19/05/23.
//

import UIKit

// Define a protocol for the cell's data source
protocol FramesViewDelegate: AnyObject {
    func selectedFramesImage(image: String, isEdit:Bool)
    func selectedFramesImageApi(image: UIImage)
}

class FramesView: UIView, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: - Outlets
    
    // Outlet for the base view of the Framess view
    @IBOutlet weak var baseView: UIView!
    
    // Outlets for the Collection View
    @IBOutlet weak var framesCollectionView: UICollectionView!
    
    // Outlets for the Sub Collection View
    @IBOutlet weak var subFramesCollectionView: UICollectionView!
    
    private var framesManager = FramesManager()
    private(set) var framesData = [String]()
    private(set) var subFramesData = [String]()
    private(set) var subFramesDataApi = [SubFramesModel]()
    
    weak var delegate: FramesViewDelegate?
    var isEdit: Bool?
    var imagePicker = UIImagePickerController()
    var framesSelection = Int()
    var selectedRatioWith: CGFloat?
    var isLandscape: Bool?

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        backgroundColor = .clear
        baseView = loadViewFromNib()
        baseView.frame = bounds
        baseView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        baseView.translatesAutoresizingMaskIntoConstraints = true
        addSubview(baseView)
        // Usage
        self.initCollectionView()
    }
    
    func createFramesArray(isLandscape: Bool, selectedRatio: CGFloat) {
        self.isLandscape = isLandscape
        self.selectedRatioWith = selectedRatio
        self.framesData.append("none")
        self.framesData.append(self.framesManager.getFramesData(isLandscape: isLandscape, selectedRatio: selectedRatio))
        self.subFramesData = self.framesManager.getEmoticonData(isLandscape: isLandscape, selectedRatio: selectedRatio)
        self.framesSelection = 1
        self.framesCollectionView.reloadData()
    }
    
    private func loadViewFromNib() -> UIView {
        let bundlePath = Bundle(for: FramesView.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = bundlePath != nil ? Bundle(path: bundlePath!) : nil

        let nib = UINib(nibName: FramesView.className, bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return nibView ?? UIView()
    }
    
    private func initCollectionView() {
        let bundlePath = Bundle(for: FrameCell.self).path(forResource: "CAGlobalPhotoSDKResources", ofType: "bundle")
        let bundle = bundlePath != nil ? Bundle(path: bundlePath!) : nil

        let nib = UINib(nibName: FrameCell.className, bundle: bundle)
        framesCollectionView.register(nib, forCellWithReuseIdentifier: FrameCell.className)
        framesCollectionView.dataSource = self
        framesCollectionView.delegate = self
        
        let subNib = UINib(nibName: FrameCell.className, bundle: bundle)
        subFramesCollectionView.register(subNib, forCellWithReuseIdentifier: FrameCell.className)
        subFramesCollectionView.dataSource = self
        subFramesCollectionView.delegate = self
    }
}

extension FramesView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of cells in the table view
        switch collectionView {
        case self.framesCollectionView:
            if framesFromApi.count > 0 {
                return self.framesData.count + framesFromApi.count
            }
            return self.framesData.count
        case self.subFramesCollectionView:
            if self.framesData.count == framesSelection {
                if subFramesFromApi.count > 0 {
                    return subFramesFromApi.count
                }
            }
            return self.subFramesData.count
        default:
            break;
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FrameCell.className, for: indexPath) as? FrameCell else {
            let cell = FrameCell()
            return cell
        }
        cell.dataSource = self
//        cell.delegate = self
        switch collectionView {
        case self.framesCollectionView:
            if self.framesData.count <= indexPath.row {
                if framesFromApi.count > 0 {
                    let data = framesFromApi[indexPath.row - self.framesData.count]
                    var subFrames : SubFramesModel!
                    for item in subFramesFromApi {
                        if item.eventId == data.id {
                            subFrames = item
                            break
                        }
                    }
                    cell.configureApiData(with: data, subImage: subFrames, isSubSelected: false)
                    if self.framesSelection == indexPath.row {
                        cell.layer.borderWidth = 1
                        cell.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
                    } else {
                        cell.layer.borderWidth = 0
                    }
                }
            } else {
                let data = self.framesData[indexPath.row]
                cell.configure(with: data, subImage: self.framesManager.getEmoticonData(isLandscape: self.isLandscape ?? false, selectedRatio: self.selectedRatioWith ?? 2)[1], isSubSelected: false)
                if self.framesSelection == indexPath.row {
                    cell.layer.borderWidth = 1
                    cell.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 177 / 255.0, blue: 255 / 255.0, alpha: 1).cgColor
                } else {
                    cell.layer.borderWidth = 0
                }
            }
            
        case self.subFramesCollectionView:
            cell.heightConstraint.constant = 0
            if self.framesData.count == framesSelection {
                if subFramesDataApi.count > 0 {
                    let data = subFramesDataApi[indexPath.row]
                    let frames = framesFromApi[0]
                    cell.configureApiData(with: frames, subImage: data, isSubSelected: true)
                }
            } else {
                let data = self.subFramesData[indexPath.row]
                cell.configure(with: "", subImage: data, isSubSelected: true)
            }
        default:
            break;
        }
        
        return cell
    }
}

extension FramesView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? FrameCell
        switch collectionView {
        case self.framesCollectionView:
            self.subFramesData = self.framesManager.getEmoticonData(isLandscape: self.isLandscape ?? false, selectedRatio: self.selectedRatioWith ?? 2)
            self.framesSelection = indexPath.row
            self.subFramesCollectionView.isHidden = false
            if self.framesData.count == framesSelection {
                let data = framesFromApi[self.framesData.count - indexPath.row]
                for item in subFramesFromApi {
                    if item.eventId == data.id {
                        subFramesDataApi.append(item)
                    }
                }
            }
            if framesSelection == 0 {
                //cell?.handleSelection(with: "none", isEdit: self.isEdit ?? false)
            }
            
            self.subFramesCollectionView.reloadData()
            self.framesCollectionView.reloadData()
        case self.subFramesCollectionView:
            if self.framesData.count == framesSelection {
                if subFramesDataApi.count > 0 {
                    _ = subFramesDataApi[indexPath.row]
                }
            } else {
                let data = self.subFramesData[indexPath.row]
                //cell?.handleSelection(with: data, isEdit: self.isEdit ?? false)
            }
        default:
            break;
        }
    }
}

extension FramesView: FrameCellDataSource {
    func getImage() -> [String] {
        // Return the image for the cell at the specified index path
        return self.framesData
    }
}

//extension FramesView: FrameCellDelegate {
//    func didSelectCell(with data: UIImage, isEdit: Bool) {
//        
//    }
//    
//    func didSelectCellCategory(with data: String) {
//        
//    }
//    
//    func didSelectCellApi(with data: UIImage, isEdit: Bool) {
//        self.delegate?.selectedFramesImageApi(image: data)
//    }
//    
//    func didSelectCell(with data: String, isEdit:Bool) {
//        // Handle cell selection
//        self.delegate?.selectedFramesImage(image: data, isEdit: isEdit)
//    }
//}
