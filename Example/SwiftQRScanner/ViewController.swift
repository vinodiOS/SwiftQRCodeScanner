//
//  ViewController.swift
//  SwiftQRScanner
//
//  Created by vinodiOS on 12/05/2017.
//  Copyright (c) 2017 vinodiOS. All rights reserved.
//

import UIKit
import SwiftQRScanner

class ViewController: UIViewController, QRScannerCodeDelegate {
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func scanQRCode(_ sender: Any) {
        
        //QRCode scanner without Camera switch and Torch
        //let scanner = QRCodeScannerController()
        
        //QRCode with Camera switch and Torch
        let scanner = QRCodeScannerController(cameraImage: UIImage(named: "camera"), cancelImage: UIImage(named: "cancel"), flashOnImage: UIImage(named: "flash-on"), flashOffImage: UIImage(named: "flash-off"))
        scanner.delegate = self
        self.present(scanner, animated: true, completion: nil)
    }
    
    //SwiftQRScanner delegate methods
    func qrCodeScanningDidCompleteWithResult(result: String) {
        print("result: \(result)")
    }
    
    func qrCodeScanningFailedWithError(error: String) {
        print("error:\(error)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

