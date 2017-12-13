# SwiftQRCodeScanner

[![CI Status](http://img.shields.io/travis/vinodiOS/SwiftQRScanner.svg?style=flat)](https://travis-ci.org/vinodiOS/SwiftQRScanner)
[![Version](https://img.shields.io/cocoapods/v/SwiftQRScanner.svg?style=flat)](http://cocoapods.org/pods/SwiftQRScanner)
[![License](https://img.shields.io/cocoapods/l/SwiftQRScanner.svg?style=flat)](http://cocoapods.org/pods/SwiftQRScanner)
[![Platform](https://img.shields.io/cocoapods/p/SwiftQRScanner.svg?style=flat)](http://cocoapods.org/pods/SwiftQRScanner)

## Screenshots
Without camera and flash buttons:

![alt text](https://s2.postimg.org/ndrpxvax5/IMG_0300.png "Without camera and flash buttons")

With camera and flash buttons:

![alt text](https://s2.postimg.org/utqzjre2x/IMG_0299.png "With camera and flash buttons")

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- iOS 9
- Xcode 9+
- Swift 4

## Installation
### Using CocoaPods
SwiftQRScanner is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftQRScanner', :git => ‘https://github.com/vinodiOS/SwiftQRScanner’
```
### Manual Installation
Download the latest version ,then unzip & drag-drop the Classes  folder inside your iOS project. You can do that directly within Xcode,
just be sure you have the **copy items if needed** and the **create groups** options checked.

## How to use
Import SwiftQRScanner module and confirm to the QRScannerCodeDelegate protocol.

```
#import SwiftQRScanner

class ViewController: UIViewController {
}

extension ViewController: QRScannerCodeDelegate {
}
```

Create instance of SwiftQRScanner to scan QR code. To use SwiftQRScanner with simple cancel button option you can code like following:
```
let scanner = QRCodeScannerController()
scanner.delegate = self
self.present(scanner, animated: true, completion: nil)
```
To use more features like camera switch , flash and cance options you can provide images like following:
```
let scanner = QRCodeScannerController(cameraImage: UIImage(named: "camera"), cancelImage: UIImage(named: "cancel"), flashOnImage: UIImage(named: "flash-on"), flashOffImage: UIImage(named: "flash-off"))
scanner.delegate = self
self.present(scanner, animated: true, completion: nil)
```
And finally implement delegate methods to get result:
```
func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
    print("result:\(result)")
}

func qrScannerDidFail(_ controller: UIViewController, error: String) {
    print("error:\(error)")
}

func qrScannerDidCancel(_ controller: UIViewController) {
    print("SwiftQRScanner did cancel")
}
```

## Author

Vinod, vinod.jagtap@hotmail.com

## License

SwiftQRScanner is available under the MIT license. See the LICENSE file for more info.
