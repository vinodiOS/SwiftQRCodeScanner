# SwiftQRCodeScanner
![QR Scanner](https://user-images.githubusercontent.com/30258541/170004280-ecac29ec-5102-469f-9234-6a5909162937.gif)

## Features
- Easy to use
- Customize everything
- Scan QR Code from saved photos

## Screenshots
**Without camera and flash** 
<img src="https://user-images.githubusercontent.com/30258541/169960154-a1c4770d-a3df-412c-9064-85abdcbe1ac8.jpeg"> 

**With camera and flash**
<img src="https://user-images.githubusercontent.com/30258541/169960286-143ba622-0ce2-4252-9d3c-be450641546c.jpeg"> 

## Example
To run the example project, clone the repo, go to Example folder and open SwiftQRScanner.xcworkspace.

## Requirements
- iOS 10.0
- Xcode 11.0+
- Swift 5

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

```Swift
import SwiftQRScanner

class ViewController: UIViewController {
}

extension ViewController: QRScannerCodeDelegate {
}
```

Create instance of SwiftQRScanner to scan QR code.
```
let scanner = QRCodeScannerController()
scanner.delegate = self
self.present(scanner, animated: true, completion: nil)
```
To use more features like camera switch, flash and many other options use **QRScannerConfiguration**:
```
var configuration = QRScannerConfiguration()
configuration.cameraImage = UIImage(named: "camera")
configuration.flashOnImage = UIImage(named: "flash-on")
configuration.galleryImage = UIImage(named: "photos")

let scanner = QRCodeScannerController(qrScannerConfiguration: configuration)
scanner.delegate = self
self.present(scanner, animated: true, completion: nil)
```
You can use following **QRScannerConfiguration** properties:

| Property Name | Default Value | Description |
| ------ | ------ |------ |
| title | Scan QR Code | Title of SwiftQRCodeScanner |
| hint | Align QR code within frame to scan | Hint for QR Code scan suggestion |
| uploadFromPhotosTitle | Upload from photos | Button title for pick QR Code from saved photos |
| invalidQRCodeAlertTitle | Invalid QR Code | Title for Alert if invalid QR Code |
| invalidQRCodeAlertActionTitle | OK | Title for Action if invalid QR Code |
| cameraImage | nil | Image for camera switch button |
| flashOnImage | nil | Image for flash button |
| length | 20.0 | Length of QR Code scanning frame |
| color | green | Color of QR Code scanning frame |
| radius | 10.0 | Corner Radius of QR Code scanning frame |
| thickness | 5.0 | Corner Thickness of QR Code scanning frame |
| readQRFromPhotos | true | Hide/show "Upload From photos" button|

And finally implement delegate methods to get result:
```
func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
    print("result:\(result)")
}

func qrScannerDidFail(_ controller: UIViewController, error: QRCodeError) {
    print("error:\(error.localizedDescription)")
}

func qrScannerDidCancel(_ controller: UIViewController) {
    print("SwiftQRScanner did cancel")
}
```

## Author

Vinod, vinod.jagtap@hotmail.com

## License

SwiftQRScanner is available under the MIT license. See the LICENSE file for more info.

