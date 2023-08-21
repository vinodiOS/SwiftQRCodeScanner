//
//  SwiftQRScanner.swift
//  SwiftQRScanner
//
//  Created by Vinod Jagtap on 12/5/17.
//

#if os(iOS)
import UIKit
import CoreGraphics
import AVFoundation


/**
 QRCodeScannerController is ViewController which calls up method which presents view with AVCaptureSession and previewLayer
 to scan QR and other codes.
 */

public class QRCodeScannerController: UIViewController,
                                      AVCaptureMetadataOutputObjectsDelegate,
                                      UIImagePickerControllerDelegate,
                                      UINavigationBarDelegate {
    
    public weak var delegate: QRScannerCodeDelegate?
    public var qrScannerConfiguration: QRScannerConfiguration
    private var flashButton: UIButton?
    
    //Default Properties
    private let spaceFactor: CGFloat = 16.0
    private let devicePosition: AVCaptureDevice.Position = .back
    private var _delayCount: Int = 0
    private let delayCount: Int = 15
    private let roundButtonHeight: CGFloat = 50.0
    private let roundButtonWidth: CGFloat = 50.0
    var photoPicker: NSObject?
    
    //Initialise CaptureDevice
    private lazy var defaultDevice: AVCaptureDevice? = {
        if let device = AVCaptureDevice.default(for: .video) {
            return device
        }
        return nil
    }()
    
    //Initialise front CaptureDevice
    private lazy var frontDevice: AVCaptureDevice? = {
        if #available(iOS 10, *) {
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                return device
            }
        } else {
            for device in AVCaptureDevice.devices(for: .video) {
                if device.position == .front { return device }
            }
        }
        return nil
    }()
    
    //Initialise AVCaptureInput with defaultDevice
    private lazy var defaultCaptureInput: AVCaptureInput? = {
        if let captureDevice = defaultDevice {
            do {
                return try AVCaptureDeviceInput(device: captureDevice)
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }()
    
    //Initialise AVCaptureInput with frontDevice
    private lazy var frontCaptureInput: AVCaptureInput?  = {
        if let captureDevice = frontDevice {
            do {
                return try AVCaptureDeviceInput(device: captureDevice)
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }()
    
    private let dataOutput = AVCaptureMetadataOutput()
    private let captureSession = AVCaptureSession()
    
    //Initialise videoPreviewLayer with capture session
    private lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        layer.cornerRadius = 10.0
        return layer
    }()
    
    public init(qrScannerConfiguration: QRScannerConfiguration = .default) {
        
        self.qrScannerConfiguration = qrScannerConfiguration
        super.init(nibName: nil, bundle: nil)
        if #available(iOS 14, *) {
            photoPicker = PHPhotoPicker(presentationController: self, delegate: self) as PHPhotoPicker
        } else {
            photoPicker = PhotoPicker(presentationController: self, delegate: self) as PhotoPicker
        }
    }
    
    required convenience init?(coder: NSCoder) {
        self.init()
    }
    
    deinit {
        print("SwiftQRScanner deallocating...")
    }
    
    //MARK: Life cycle methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        navigationBar.shadowImage = UIImage()
        view.addSubview(navigationBar)
        
        let title = UINavigationItem(title: qrScannerConfiguration.title)
        let cancelBarButton = UIBarButtonItem(title: qrScannerConfiguration.cancelButtonTitle,
                                     style: .plain,
                                     target: self,
                                     action: #selector(dismissVC))
        if let tintColor = qrScannerConfiguration.cancelButtonTintColor {
            cancelBarButton.tintColor = tintColor
        }
        title.leftBarButtonItem = cancelBarButton
        navigationBar.setItems([title], animated: false)
        self.presentationController?.delegate = self
        
        //Currently only "Portraint" mode is supported
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        _delayCount = 0
        prepareQRScannerView()
        startScanningQRCode()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addButtons()
    }
    
    /** This calls up methods which makes code ready for scan codes.
     - parameter view: UIView in which you want to add scanner.
     */
    private func prepareQRScannerView() {
        setupCaptureSession(devicePosition) //Default device capture position is rear
        addViedoPreviewLayer()
        addRoundCornerFrame()
    }
    
    //Creates corner rectagle frame with green coloe(default color)
    private func addRoundCornerFrame() {
        let width: CGFloat = self.view.frame.size.width / 1.5
        let height: CGFloat = self.view.frame.size.height / 2
        let roundViewFrame = CGRect(origin: CGPoint(x: self.view.frame.midX - width/2,
                                                    y: self.view.frame.midY - height/2),
                                    size: CGSize(width: width, height: width))
        self.view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        let qrFramedView = QRScannerFrame(frame: roundViewFrame)
        qrFramedView.thickness = qrScannerConfiguration.thickness
        qrFramedView.length = qrScannerConfiguration.length
        qrFramedView.radius = qrScannerConfiguration.radius
        qrFramedView.color = qrScannerConfiguration.color
        qrFramedView.autoresizingMask = UIView.AutoresizingMask(rawValue: UInt(0.0))
        self.view.addSubview(qrFramedView)
        if qrScannerConfiguration.readQRFromPhotos {
            addPhotoPickerButton(frame: CGRect(origin: CGPoint(x: self.view.frame.midX - width/2,
                                                               y: roundViewFrame.origin.y + width + 30),
                                               size: CGSize(width: self.view.frame.size.width/2.2, height: 36)))
        }
        
    }
    
    private func addPhotoPickerButton(frame: CGRect) {
        let photoPickerButton = UIButton(frame: frame)
        let buttonAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.black]
        let attributedTitle = NSMutableAttributedString(string: qrScannerConfiguration.uploadFromPhotosTitle, attributes: buttonAttributes)
        photoPickerButton.setAttributedTitle(attributedTitle, for: .normal)
        photoPickerButton.center.x = self.view.center.x
        photoPickerButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        photoPickerButton.layer.cornerRadius = 18
        if let galleryImage = qrScannerConfiguration.galleryImage {
            photoPickerButton.setImage(galleryImage, for: .normal)
            photoPickerButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
            photoPickerButton.titleEdgeInsets.left = 10
        }
        photoPickerButton.addTarget(self, action: #selector(showImagePicker), for: .touchUpInside)
        self.view.addSubview(photoPickerButton)
    }
    
    
    @objc private func showImagePicker() {
        if #available(iOS 14, *) {
            if let picker = photoPicker as? PHPhotoPicker {
                picker.present()
            }
        } else {
            if let picker = photoPicker as? PhotoPicker {
                picker.present(from: self.view)
            }
        }
        
    }
    
    // Adds buttons to view which can we used as extra fearures
    private func addButtons() {
        
        //Torch button
        if let flashOffImg = qrScannerConfiguration.flashOnImage {
            flashButton = RoundButton(frame: CGRect(x: 32, y: self.view.frame.height-100, width: roundButtonWidth, height: roundButtonHeight))
            flashButton!.addTarget(self, action: #selector(toggleTorch), for: .touchUpInside)
            flashButton!.setImage(flashOffImg, for: .normal)
            view.addSubview(flashButton!)
        }
        
        //Camera button
        if let cameraImg = qrScannerConfiguration.cameraImage {
            let cameraSwitchButton = RoundButton(frame: CGRect(x: self.view.bounds.width - (roundButtonWidth + 32), y: self.view.frame.height-100, width: roundButtonWidth, height: roundButtonHeight))
            cameraSwitchButton.setImage(cameraImg, for: .normal)
            cameraSwitchButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
            view.addSubview(cameraSwitchButton)
        }
    }
    
    //Toggle torch
    @objc private func toggleTorch() {
        //If device postion is front then no need to torch
        if let currentInput = getCurrentInput() {
            if currentInput.device.position == .front { return }
        }
        
        guard  let defaultDevice = defaultDevice else {return}
        if defaultDevice.isTorchAvailable {
            do {
                try defaultDevice.lockForConfiguration()
                defaultDevice.torchMode = defaultDevice.torchMode == .on ? .off : .on
                flashButton?.backgroundColor = defaultDevice.torchMode == .on ? UIColor.white.withAlphaComponent(0.3) : UIColor.black.withAlphaComponent(0.5)
                defaultDevice.unlockForConfiguration()
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    //Switch camera
    @objc private func switchCamera() {
        if let frontDeviceInput = frontCaptureInput {
            captureSession.beginConfiguration()
            if let currentInput = getCurrentInput() {
                captureSession.removeInput(currentInput)
                let newDeviceInput = (currentInput.device.position == .front) ? defaultCaptureInput : frontDeviceInput
                captureSession.addInput(newDeviceInput!)
            }
            captureSession.commitConfiguration()
        }
    }
    
    private func getCurrentInput() -> AVCaptureDeviceInput? {
        if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
            return currentInput
        }
        return nil
    }
    
    @objc private func dismissVC() {
        self.dismiss(animated: true, completion: nil)
        delegate?.qrScannerDidCancel(self)
    }
    
    //MARK: - Setup and start capturing session
    
   private func startScanningQRCode() {
        if captureSession.isRunning { return }
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    private func setupCaptureSession(_ devicePostion: AVCaptureDevice.Position) {
        if captureSession.isRunning { return }
        switch devicePosition {
        case .front:
            if let frontDeviceInput = frontCaptureInput {
                if !captureSession.canAddInput(frontDeviceInput) {
                    delegate?.qrScannerDidFail(self, error: .inputFailed)
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                captureSession.addInput(frontDeviceInput)
            }
        case .back, .unspecified :
            if let defaultDeviceInput = defaultCaptureInput {
                if !captureSession.canAddInput(defaultDeviceInput) {
                    delegate?.qrScannerDidFail(self, error: .inputFailed)
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                captureSession.addInput(defaultDeviceInput)
            }
        default: print("Do nothing")
        }
        
        if !captureSession.canAddOutput(dataOutput) {
            delegate?.qrScannerDidFail(self, error: .outoutFailed)
            self.dismiss(animated: true, completion: nil)
            return
        }
        captureSession.addOutput(dataOutput)
        dataOutput.metadataObjectTypes = dataOutput.availableMetadataObjectTypes
        dataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    }
    
    //Inserts layer to view
    private func addViedoPreviewLayer() {
        videoPreviewLayer.frame = CGRect(x: view.bounds.origin.x,
                                         y: view.bounds.origin.y,
                                         width: view.bounds.size.width,
                                         height: view.bounds.size.height)
        view.layer.insertSublayer(videoPreviewLayer, at: 0)
        addMaskToVideoPreviewLayer()
    }
    
    // This method get called when Scanning gets complete
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for data in metadataObjects {
            let transformed = videoPreviewLayer.transformedMetadataObject(for: data) as? AVMetadataMachineReadableCodeObject
            if let unwraped = transformed {
                if view.bounds.contains(unwraped.bounds) {
                    _delayCount = _delayCount + 1
                    if _delayCount > delayCount {
                        if let unwrapedStringValue = unwraped.stringValue {
                            delegate?.qrScanner(self, scanDidComplete: unwrapedStringValue)
                        } else {
                            delegate?.qrScannerDidFail(self, error: .emptyResult)
                        }
                        captureSession.stopRunning()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension QRCodeScannerController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss( _ presentationController: UIPresentationController) {
        self.delegate?.qrScannerDidCancel(self)
    }
}

extension QRCodeScannerController: ImagePickerDelegate {
    public func didSelect(image: UIImage?) {
        if let selectedImage = image, let qrCodeData = selectedImage.parseQR() {
            if(qrCodeData.isEmpty) {
                showInvalidQRCodeAlert()
                return
            }
            self.delegate?.qrScanner(self, scanDidComplete: qrCodeData)
            self.dismiss(animated: true)
        } else {
            showInvalidQRCodeAlert()
        }
    }
    
    private func showInvalidQRCodeAlert() {
        let alert = UIAlertController(title: qrScannerConfiguration.invalidQRCodeAlertTitle, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: qrScannerConfiguration.invalidQRCodeAlertActionTitle, style: .cancel))
        self.present(alert, animated: true)
    }
}


///Currently Scanner suppoerts only portrait mode.
///This makes sure orientation is portrait
extension QRCodeScannerController {
    //Make orientations to portrait
    
    override public var shouldAutorotate: Bool {
        return false
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
}

extension QRCodeScannerController {
    
    private func addMaskToVideoPreviewLayer() {
        let qrFrameWidth: CGFloat = self.view.frame.size.width / 1.5
        let scanFrameWidth: CGFloat  = self.view.frame.size.width / 1.8
        let scanFrameHeight: CGFloat = self.view.frame.size.width / 1.8
        let screenHeight: CGFloat = self.view.frame.size.height / 2
        let roundViewFrame = CGRect(origin: CGPoint(x: self.view.frame.midX - scanFrameWidth/2,
                                                    y: self.view.frame.midY - screenHeight/2 + (qrFrameWidth-scanFrameWidth)/2),
                                    size: CGSize(width: scanFrameWidth, height: scanFrameHeight))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.fillColor = UIColor(white: 0.0, alpha: 0.5).cgColor
        let path = UIBezierPath(roundedRect: roundViewFrame, byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: 10, height: 10))
        path.append(UIBezierPath(rect: view.bounds))
        maskLayer.path = path.cgPath
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        view.layer.insertSublayer(maskLayer, above: videoPreviewLayer)
        addHintTextLayer(maskLayer: maskLayer)
    }
    
    private func addHintTextLayer(maskLayer: CAShapeLayer) {
        guard let hint = qrScannerConfiguration.hint else { return }
        let hintTextLayer = CATextLayer()
        hintTextLayer.fontSize = 18.0
        hintTextLayer.string = hint
        hintTextLayer.alignmentMode = CATextLayerAlignmentMode.center
        hintTextLayer.contentsScale = UIScreen.main.scale
        hintTextLayer.frame = CGRect(x: spaceFactor,
                                     y: self.view.frame.midY - self.view.frame.size.height/4 - 62,
                                     width: view.frame.size.width - (2.0 * spaceFactor),
                                     height: 22)
        hintTextLayer.foregroundColor = UIColor.white.withAlphaComponent(0.7).cgColor
        view.layer.insertSublayer(hintTextLayer, above: maskLayer)
    }
}


#endif
