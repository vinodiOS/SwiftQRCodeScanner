//
//  ImagePicker.swift
//  SwiftQRScanner
//
//  Created by Vinod Jagtap on 15/05/22.
//

#if os(iOS)
import Foundation
import UIKit
import PhotosUI

public protocol ImagePickerDelegate: AnyObject {
    func didSelect(image: UIImage?)
}


class PhotoPicker: NSObject {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        
        self.pickerController = UIImagePickerController()
        super.init()
        self.presentationController = presentationController
        self.delegate = delegate
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = false
        
    }
    
    public func present(from sourceView: UIView) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraRollAction = UIAlertAction(title: "Camera roll", style: .default) { [unowned self] _ in
            self.pickerController.sourceType = .savedPhotosAlbum
            presentationController?.present(self.pickerController, animated: true)
        }
        let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default) { [unowned self] _ in
            self.pickerController.sourceType = .photoLibrary
            presentationController?.present(self.pickerController, animated: true)
        }
        [cameraRollAction, photoLibraryAction].forEach { action in
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(image: image)
    }
}

extension PhotoPicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension PhotoPicker: UINavigationControllerDelegate {}

@available(iOS 14, *)
extension PHPhotoPicker: UINavigationControllerDelegate{}

@available(iOS 14, *)
class PHPhotoPicker: NSObject {
    private let pickerController: PHPickerViewController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        var phPickerConfiguration = PHPickerConfiguration(photoLibrary: .shared())
        phPickerConfiguration.selectionLimit = 1
        phPickerConfiguration.filter = .images
        self.pickerController = PHPickerViewController(configuration: phPickerConfiguration)
        super.init()
        self.pickerController.delegate = self
        self.presentationController = presentationController
        self.delegate = delegate
    }
    
    public func present() {
        PHPhotoLibrary.requestAuthorization({
            (newStatus) in
            DispatchQueue.main.async {
                if newStatus ==  PHAuthorizationStatus.authorized {
                    
                    self.presentationController?.present(self.pickerController, animated: true)
                }
            }
        })
    }
    
}

@available(iOS 14, *)
extension PHPhotoPicker: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.delegate?.didSelect(image: image)
                    }
                }
            })
        }
    }
    
}

#endif

