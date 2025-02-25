//
//  BusinessViewController.swift
//  CAGlobalPhotoSDK
//
//  Created by iOS Developer on 22/8/23.
//

import UIKit

class BusinessViewController: BaseViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    var editViewModel = CAEditViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add pinch gesture recognizer to labels
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinchGesture.delegate = self
        nameLabel.addGestureRecognizer(pinchGesture)
        
        let pinchGesture2 = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinchGesture2.delegate = self
        titleLabel.addGestureRecognizer(pinchGesture2)
        
        let companyPinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        companyPinchGesture.delegate = self
        companyLabel.addGestureRecognizer(companyPinchGesture)
        
        let addressPinchGesture2 = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        addressPinchGesture2.delegate = self
        addressLabel.addGestureRecognizer(addressPinchGesture2)
        
        // Add pan gesture recognizer to labels
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        pinchGesture.delegate = self
        nameLabel.addGestureRecognizer(panGesture)
        
        let panGesture2 = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture2.delegate = self
        titleLabel.addGestureRecognizer(panGesture2)
        
        let companyPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        companyPanGesture.delegate = self
        companyLabel.addGestureRecognizer(companyPanGesture)
        
        let addressPanGesture2 = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addressPanGesture2.delegate = self
        addressLabel.addGestureRecognizer(addressPanGesture2)
        
        nameLabel.isUserInteractionEnabled = true
        titleLabel.isUserInteractionEnabled = true
        companyLabel.isUserInteractionEnabled = true
        addressLabel.isUserInteractionEnabled = true
        profileImageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
        tapGesture.numberOfTapsRequired = 1
        profileImageView.addGestureRecognizer(tapGesture)
        
        let nameTapGesture = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        nameTapGesture.numberOfTapsRequired = 2
        nameLabel.addGestureRecognizer(nameTapGesture)
        
        let titleTapGesture = UITapGestureRecognizer(target: self, action: #selector(titleTapped))
        titleTapGesture.numberOfTapsRequired = 2
        
        titleLabel.addGestureRecognizer(titleTapGesture)
        
        let companyTapGesture = UITapGestureRecognizer(target: self, action: #selector(companyTapped))
        companyTapGesture.numberOfTapsRequired = 2
        companyLabel.addGestureRecognizer(companyTapGesture)
        
        let addressTapGesture = UITapGestureRecognizer(target: self, action: #selector(addressTapped))
        addressTapGesture.numberOfTapsRequired = 2
        addressLabel.addGestureRecognizer(addressTapGesture)
        
    }
    
    @objc func profileTapped() {
        self.profileImageTapped()
    }
    
    @objc func nameTapped() {
        let alertController = UIAlertController(title: "Enter Name", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.text = self.nameLabel.text
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            // This block will be called when the "Save" button is tapped.
            if let textField = alertController.textFields?.first {
                if let text = textField.text {
                    self.nameLabel.text = text
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func titleTapped() {
        let alertController = UIAlertController(title: "Enter Title", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.text = self.titleLabel.text
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            // This block will be called when the "Save" button is tapped.
            if let textField = alertController.textFields?.first {
                if let text = textField.text {
                    self.titleLabel.text = text
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func companyTapped() {
        let alertController = UIAlertController(title: "Enter Company", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.text = self.companyLabel.text
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            // This block will be called when the "Save" button is tapped.
            if let textField = alertController.textFields?.first {
                if let text = textField.text {
                    self.companyLabel.text = text
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func addressTapped() {
        let alertController = UIAlertController(title: "Enter Address", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.text = self.addressLabel.text
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            // This block will be called when the "Save" button is tapped.
            if let textField = alertController.textFields?.first {
                if let text = textField.text {
                    self.addressLabel.text = text
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func profileImageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                // Handle case where camera is not available
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(galleryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    // UIImagePickerControllerDelegate method to handle image selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageView.image = selectedImage
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    @objc func handlePinchGesture(_ pinch: UIPinchGestureRecognizer) {
        if pinch.view != nil {
            let view = pinch.view
            if let viewLabel = view as? UILabel {
                if (viewLabel.font!.pointSize ) * pinch.scale > 90 {
                    return
                }
                let font = UIFont(name: (viewLabel.font!.fontName), size: (viewLabel.font!.pointSize) * pinch.scale)
                viewLabel.font = font
                viewLabel.numberOfLines = 0
                viewLabel.bounds.size = CGSize(width: viewLabel.frame.size.width,
                                               height: (viewLabel.intrinsicContentSize.height ) + 80)
                viewLabel.setNeedsDisplay()
                viewLabel.frame.origin.x = viewLabel.frame.origin.x
                viewLabel.setNeedsDisplay()
                pinch.scale = 1
            }
        }
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        
        let translation = sender.translation(in: self.view)
        label.center = CGPoint(x: label.center.x + translation.x, y: label.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    // MARK: - Gesture Recognizer delegate methods
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - IBActions
    @IBAction func actionBackButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func actionDoneButton(_ sender: Any) {
        let savedImage = self.captureImageInView(inView: self.viewCard)
        SaveImageWithCustomAlbum().saveImageInAlbum(name: SaveImageStaticStrings.albumEditName, withImage: savedImage!)
        //self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
}
