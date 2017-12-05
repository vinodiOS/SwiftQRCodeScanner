//
//  SwiftQRScanner.swift
//  SwiftQRScanner
//
//  Created by Vinod Jagtap on 12/5/17.
//

import UIKit
import CoreGraphics
import AVFoundation

//QRScannerCodeDelegate Protocol
public protocol QRScannerCodeDelegate: class {
    func qrCodeScanningDidCompleteWithResult(result: String)
    func qrCodeScanningFailedWithError(error: String)
}

public class QRCodeScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var squareView: SquareView?
    weak var delegate: QRScannerCodeDelegate?
    var cameraButton: UIButton = UIButton()
    //Default Properties
    let bottomSpace: CGFloat = 60.0
    var devicePosition: AVCaptureDevice.Position = .back
    open var qrScannerFrame: CGRect = CGRect.zero
    
    //Initialization part
    lazy var captureSession = AVCaptureSession()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Currently only "Portraint" mode is supported
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        prepareQRScannerView(self.view)
        startScanningQRCode()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Lazy initialization of properties
    lazy var defaultDevice: AVCaptureDevice? = {
        if let device = AVCaptureDevice.default(for: .video) {
            return device
        }
        
        return nil
    }()
    
    lazy var frontDevice: AVCaptureDevice? = {
        if #available(iOS 10, *) {
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                return device
            }
        } else {
            for device in AVCaptureDevice.devices(for: .video) {
                if device.position == .front {
                    return device
                }
            }
        }
        return nil
    }()
    
    lazy var defaultCaptureInput: AVCaptureInput? = {
        if let captureDevice = defaultDevice {
            do {
                return try AVCaptureDeviceInput(device: captureDevice)
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }()
    
    lazy var frontCaptureInput: AVCaptureInput?  = {
        if let captureDevice = frontDevice {
            do {
                return try AVCaptureDeviceInput(device: captureDevice)
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }()
    
    lazy var dataOutput = AVCaptureMetadataOutput()
    
    lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        layer.cornerRadius = 10.0
        return layer
    }()
    
    open func prepareQRScannerView(_ view: UIView) {
        qrScannerFrame = view.frame
        setupCaptureSession(devicePosition)//Default device capture position is back
        addViedoPreviewLayer(view)
        createCornerFrame()
        addButtons(view)
    }
    
    private func createCornerFrame() {
        let width: CGFloat = 200.0
        let height: CGFloat = 200.0
        let rect = CGRect.init(origin: CGPoint.init(x: self.view.frame.width/2 - width/2, y: self.view.frame.height/2 - (width+bottomSpace)/2), size: CGSize.init(width: width, height: height))
        self.squareView = SquareView(frame: rect)
        if let squareView = squareView {
            self.view.addSubview(squareView)
        }
    }
    
    private func addButtons(_ view: UIView) {
        let height: CGFloat = 44.0
        let width: CGFloat = 44.0
        
        //Cancel button
        let cancelButton: UIButton = UIButton(frame: CGRect(x: view.frame.width/2 - width/2, y: view.frame.height - height, width: width, height: height))
        cancelButton.setTitle("X", for: .normal)
        //cancelButton.setImage(UIImage(named: "cancel"), for: .normal)
        cancelButton.addTarget(self, action: #selector(dismissVC), for:.touchUpInside)
        
        //Torch button
        let torchButton: UIButton = UIButton(frame: CGRect(x: 16, y: self.view.bounds.size.height - (bottomSpace + height), width: width, height: height))
        torchButton.setImage(UIImage(named: "flass-off"), for: .normal)
        torchButton.tintColor = UIColor.white
        torchButton.addTarget(self, action: #selector(toggleTorch), for: .touchUpInside)
        
        //Camera button
        cameraButton = UIButton(frame: CGRect(x: self.view.bounds.width - (width + 16), y: self.view.bounds.size.height - (bottomSpace + height), width: width, height: height))
        cameraButton.setImage(UIImage(named: "switch-camera-button"), for: .normal)
        cameraButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        
        
        view.addSubview(cancelButton)
        view.addSubview(torchButton)
        view.addSubview(cameraButton)
        
    }
    
    //Toggle torch
    @objc func toggleTorch() {
        
        //If device postion is front then no need to torch
        if let currentInput = getCurrentInput() {
            if currentInput.device.position == .front {
                return
            }
        }
        
        guard  let defaultDevice = defaultDevice else {return}
        if defaultDevice.isTorchAvailable {
            do {
                try defaultDevice.lockForConfiguration()
                defaultDevice.torchMode = defaultDevice.torchMode == .on ? .off : .on
                cameraButton.setImage(defaultDevice.torchMode == .on ? UIImage(named: "flash") : UIImage(named: "flass-off"), for: .normal)
                defaultDevice.unlockForConfiguration()
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    //Switch camera
    @objc func switchCamera() {
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
    
    //dismiss ViewController
    @objc func dismissVC() {
        removeVideoPriviewlayer()
        self.dismiss(animated: true, completion: nil)
    }
    
    open func startScanningQRCode() {
        if captureSession.isRunning {
            return
        }
        captureSession.startRunning()
    }
    
    private func setupCaptureSession(_ devicePostion: AVCaptureDevice.Position) {
        
        if captureSession.isRunning {
            return
        }
        
        switch devicePosition {
        case .front:
            if let frontDeviceInput = frontCaptureInput {
                if !captureSession.canAddInput(frontDeviceInput) {
                    delegate?.qrCodeScanningFailedWithError(error: "Failed to add Input")
                    return
                }
                captureSession.addInput(frontDeviceInput)
            }
            break;
        case .back, .unspecified :
            if let defaultDeviceInput = defaultCaptureInput {
                if !captureSession.canAddInput(defaultDeviceInput) {
                    delegate?.qrCodeScanningFailedWithError(error: "Failed to add Input")
                    return
                }
                captureSession.addInput(defaultDeviceInput)
            }
            break
            
        }
        
        if !captureSession.canAddOutput(dataOutput) {
            delegate?.qrCodeScanningFailedWithError(error: "Failed to add Output")
            return
        }
        
        captureSession.addOutput(dataOutput)
        dataOutput.metadataObjectTypes = dataOutput.availableMetadataObjectTypes
        dataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    }
    
    private func addViedoPreviewLayer(_ view: UIView) {
        videoPreviewLayer.frame = CGRect(x:view.bounds.origin.x, y: view.bounds.origin.y, width: view.bounds.size.width, height: view.bounds.size.height - bottomSpace)
        view.layer.insertSublayer(videoPreviewLayer, at: 0)
    }
    
    private func removeVideoPriviewlayer() {
        videoPreviewLayer.removeFromSuperlayer()
    }
    
    /// This method get called when Scanning gets complete
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for data in metadataObjects {
            let transformed = videoPreviewLayer.transformedMetadataObject(for: data) as? AVMetadataMachineReadableCodeObject
            if let unwraped = transformed {
                if unwraped.stringValue != nil {
                    delegate?.qrCodeScanningDidCompleteWithResult(result: unwraped.stringValue!)
                } else {
                    delegate?.qrCodeScanningFailedWithError(error: "Empty string found")
                }
                captureSession.stopRunning()
                removeVideoPriviewlayer()
            }
        }
    }
}

//Currently Scanner suppoerts only portrait mode.

extension QRCodeScannerController {
    ///Make orientations to portrait
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

/** This class is for draw corners of Square to show frame for scan QR code.
 *  @IBInspectable parameters are the line color, sizeMultiplier, line width.
 */
@IBDesignable
class SquareView: UIView {
    @IBInspectable
    var sizeMultiplier : CGFloat = 0.2 {
        didSet{
            self.draw(self.bounds)
        }
    }
    
    @IBInspectable
    var lineWidth : CGFloat = 2 {
        didSet{
            self.draw(self.bounds)
        }
    }
    
    @IBInspectable
    var lineColor : UIColor = UIColor.green {
        didSet{
            self.draw(self.bounds)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }
    
    func drawCorners() {
        let currentContext = UIGraphicsGetCurrentContext()
        
        currentContext?.setLineWidth(lineWidth)
        currentContext?.setStrokeColor(lineColor.cgColor)
        
        //top left corner
        currentContext?.beginPath()
        currentContext?.move(to: CGPoint(x: 0, y: 0))
        currentContext?.addLine(to: CGPoint(x: self.bounds.size.width*sizeMultiplier, y: 0))
        currentContext?.strokePath()
        
        //top rigth corner
        currentContext?.beginPath()
        currentContext?.move(to: CGPoint(x: self.bounds.size.width - self.bounds.size.width*sizeMultiplier, y: 0))
        currentContext?.addLine(to: CGPoint(x: self.bounds.size.width, y: 0))
        currentContext?.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height*sizeMultiplier))
        currentContext?.strokePath()
        
        //bottom rigth corner
        currentContext?.beginPath()
        currentContext?.move(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height - self.bounds.size.height*sizeMultiplier))
        currentContext?.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
        currentContext?.addLine(to: CGPoint(x: self.bounds.size.width - self.bounds.size.width*sizeMultiplier, y: self.bounds.size.height))
        currentContext?.strokePath()
        
        //bottom left corner
        currentContext?.beginPath()
        currentContext?.move(to: CGPoint(x: self.bounds.size.width*sizeMultiplier, y: self.bounds.size.height))
        currentContext?.addLine(to: CGPoint(x: 0, y: self.bounds.size.height))
        currentContext?.addLine(to: CGPoint(x: 0, y: self.bounds.size.height - self.bounds.size.height*sizeMultiplier))
        currentContext?.strokePath()
        
        //second part of top left corner
        currentContext?.beginPath()
        currentContext?.move(to: CGPoint(x: 0, y: self.bounds.size.height*sizeMultiplier))
        currentContext?.addLine(to: CGPoint(x: 0, y: 0))
        currentContext?.strokePath()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.drawCorners()
    }
    
}
