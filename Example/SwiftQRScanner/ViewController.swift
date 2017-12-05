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
    let scanner = QRCodeScannerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    @IBAction func scanQRCode(_ sender: Any) {
        self.present(scanner, animated: true, completion: nil)
    }
    
    //SwiftQRScanner delegate methods
    func qrCodeScanningDidCompleteWithResult(result: String) {
        print(result)
    }
    
    func qrCodeScanningFailedWithError(error: String) {
        print(error)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

