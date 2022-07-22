//
//  QRScannerFrameConfig.swift
//  SwiftQRScanner
//
//  Created by Vinod Jagtap on 07/05/22.
//

#if os(iOS)
import Foundation
import UIKit

public struct QRScannerConfiguration {
    public var title: String
    public var hint: String?
    public var invalidQRCodeAlertTitle: String
    public var invalidQRCodeAlertActionTitle: String
    public var uploadFromPhotosTitle: String
    public var cameraImage: UIImage?
    public var flashOnImage: UIImage?
    public var galleryImage: UIImage?
    public var length: CGFloat
    public var color: UIColor
    public var radius: CGFloat
    public var thickness: CGFloat
    public var readQRFromPhotos: Bool
    public var cancelButtonTitle: String
    public var cancelButtonTintColor: UIColor?
    
    public init(title: String = "Scan QR Code",
                hint: String = "Align QR code within frame to scan",
                uploadFromPhotosTitle: String = "Upload from photos",
                invalidQRCodeAlertTitle: String = "Invalid QR Code",
                invalidQRCodeAlertActionTitle: String = "OK",
                cameraImage: UIImage? = nil,
                flashOnImage: UIImage? = nil,
                length: CGFloat = 20.0,
                color: UIColor = .green,
                radius: CGFloat = 10.0,
                thickness: CGFloat = 5.0,
                readQRFromPhotos: Bool = true,
                cancelButtonTitle: String = "Cancel",
                cancelButtonTintColor: UIColor? = nil) {
        self.title = title
        self.hint = hint
        self.uploadFromPhotosTitle = uploadFromPhotosTitle
        self.invalidQRCodeAlertTitle = invalidQRCodeAlertTitle
        self.invalidQRCodeAlertActionTitle = invalidQRCodeAlertActionTitle
        self.cameraImage = cameraImage
        self.flashOnImage = flashOnImage
        self.length = length
        self.color = color
        self.radius = radius
        self.thickness = thickness
        self.readQRFromPhotos = readQRFromPhotos
        self.cancelButtonTitle = cancelButtonTitle
        self.cancelButtonTintColor = cancelButtonTintColor
    }
}

extension QRScannerConfiguration {
    public static var `default`: QRScannerConfiguration {
        QRScannerConfiguration(title: "Scan QR Code",
                               hint: "Align QR code within frame to scan",
                               uploadFromPhotosTitle: "Upload from photos",
                               invalidQRCodeAlertTitle: "Invalid QR Code",
                               invalidQRCodeAlertActionTitle: "OK",
                               cameraImage: nil,
                               flashOnImage: nil,
                               length: 20.0,
                               color: .green,
                               radius: 10.0,
                               thickness: 5.0,
                               readQRFromPhotos: true,
                               cancelButtonTitle: "Cancel",
                               cancelButtonTintColor: nil)
    }
}
#endif
