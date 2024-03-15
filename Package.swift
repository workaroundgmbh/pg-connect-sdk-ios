// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "ConnectSDK",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "ConnectSDK",
            targets: ["ConnectSDK", "ConnectSDKDependencies"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.16.0"),
        .package(url: "https://github.com/workaroundgmbh/aws-sdk-ios-spm", branch: "release"),
        .package(url: "https://github.com/workaroundgmbh/OpenSSL.git", from: "1.0.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.16"),
        .package(url: "https://github.com/NordicSemiconductor/IOS-nRF-Connect-Device-Manager", from: "1.6.0")
    ],
    targets: [
        .binaryTarget(
            name: "ConnectSDK",
            url: "https://dl.cloudsmith.io/QQ43WPa2Y7VlFUM3/proglove/markconnectiossdk-prod/raw/names/ConnectSDK-2.3.0.xcframework/versions/2.3.0/ConnectSDK-2.3.0.xcframework.zip?accept_eula=5",
            checksum: "816c4cf61d16338ccc8228bed24e45ad26db8d6e76cf10661bc66981e1931d83"),
        .target(
            name: "ConnectSDKDependencies",
            dependencies: [
                "OpenSSL",
                "ZIPFoundation",
                .target(name: "ConnectSDK"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "iOSMcuManagerLibrary", package: "IOS-nRF-Connect-Device-Manager"),
                .product(name: "AWSCore", package: "aws-sdk-ios-spm"),
                .product(name: "AWSAuthCore", package: "aws-sdk-ios-spm"),
                .product(name: "AWSCognitoIdentityProvider", package: "aws-sdk-ios-spm"),
                .product(name: "AWSCognitoIdentityProviderASF", package: "aws-sdk-ios-spm"),
                .product(name: "AWSIoT", package: "aws-sdk-ios-spm"),
                .product(name: "AWSMobileClientXCF", package: "aws-sdk-ios-spm")],
                path: "Sources/ConnectSDK"
        )
    ]
)
