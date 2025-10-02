// swift-tools-version: 5.5
import PackageDescription

let version = "2.7.2"
let checksum = "7a773ffc98436849d416c81c6a555605161fc36376d77299c5e44b98d58cdc33"

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
            url: "https://dl.cloudsmith.io/QQ43WPa2Y7VlFUM3/proglove/markconnectiossdk-prod/raw/names/ConnectSDK-\(version).xcframework/versions/\(version)/ConnectSDK-\(version).xcframework.zip?accept_eula=8",
            checksum: checksum),
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
