# ProGlove ConnectSDK

The **ProGlove ConnectSDK** is a Swift SDK used to communicate with the ProGlove scanners.

## Licence

** **BY USING THIS SDK YOU AGREE TO THE FOLLOWING [LICENSE TERMS](/LICENSE) AS DEFINED BY PROGLOVE.** **

## Requirements

The ConnectSDK for Swift supports the following:
- Swift 5.5 or higher
- iOS 12 or higher (<= v2.5.0)
- iOS 13 or higher (>= v2.6.0)

The environment for watchOS is supported by this library: [ConnectSDKWatch](https://github.com/workaroundgmbh/pg-connect-sdk-watchos)

## Dependencies

Dependencies that are being used are necessary for the SDK to work properly and also features like Insight Cloud connection are possible because of them.

Current dependencies that are being used in the package are:
- SwiftProtobuf
- ZipFoundation
- OpenSSL
- AWS iOS SDK
- nRF Connect Device Manager

## Integrating Into an Existing Xcode Project or Package

Here are the steps to get the Connect SDK installed into either your existing Xcode Project or Package.

### Installing the Connect SDK into your Xcode Project

1. Open your project in the Xcode IDE.  From the drop-down menu, select File > Add Packages...

2. In the field labeled "Search or Enter Package URL", enter "https://github.com/workaroundgmbh/pg-connect-sdk-ios".  Set the
dependency rule and project as needed, then click "Add Package". The package will download and install to your Xcode
project.

3. In the "Choose Package Products for ConnectSDK" popup window, check the box, and set the Xcode target.  Click "Add Package".

### Installing the Connect SDK into your Swift Package

In your package's `Package.swift`, add Connect SDK as a package dependency:
```swift
// swift-tools-version:5.5
import PackageDescription
let package = Package(
    name: "<Your Product Name>",
    dependencies: [
		  .package(url: "https://github.com/workaroundgmbh/pg-connect-sdk-ios", .upToNextMajor(from: "1.8.0"))
    ],
)
```
### Adding the SDK as a local Package

1. Go to [ProGlove Documentation](https://docs.proglove.com/en/insight-mobile--ios-.html) and follow the instructions to download the SDK
   
2. Once downloaded, unpack the zipped package

3. Add the SDK to the project
   
   a. Go to the **Add Packages** option and choose at the bottom **Add Local...**

   then choose **ConnectSDK** folder containing the `Package.swift` file

   b. OR drag&drop the **ConnectSDK** folder containing the `Package.swift` file into the Project root folder

   this method requires adding the ConnectSDK Framework manually in the "Frameworks, Libraries, and Embedded Content" section

## API Reference documentation

Please use the [ProGlove Documentation](https://docs.proglove.com/en/insight-mobile--ios-.html) that is already provided.

DocC generated API documentation might be provided at a later point in time.

For any questions regarding SDK refer to the [Help Page](https://docs.proglove.com/en/faq-46207.html#need-more-help-)
