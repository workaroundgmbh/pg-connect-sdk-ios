// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "ConnectSDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "ConnectSDK",
            targets: ["ConnectSDK", "ConnectSDKDependencies"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.26.0"),
        .package(url: "https://github.com/workaroundgmbh/aws-sdk-ios-spm", from: "2.36.2"),
        .package(url: "https://github.com/workaroundgmbh/OpenSSL.git", from: "1.1.4"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.19"),
        .package(url: "https://github.com/NordicSemiconductor/IOS-nRF-Connect-Device-Manager", .upToNextMinor(from: "1.6.0"))
    ],
    targets: [
        .binaryTarget(
            name: "ConnectSDK",
            url: "https://dl.cloudsmith.io/QQ43WPa2Y7VlFUM3/proglove/markconnectiossdk-prod/raw/names/ConnectSDK-2.6.0.xcframework/versions/2.6.0/ConnectSDK-2.6.0.xcframework.zip?accept_eula=8",
            checksum: "2b06983f2f4e7ab6b824c8c1e36a90f5e4f3ec57c40e691fa2e1ddd1664c9452"),
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
                path: "Sources/ConnectSDKDependencies"
        )
    ]
)
