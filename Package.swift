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
        .package(url: "https://github.com/apple/swift-protobuf", from: "1.16.0"),
        .package(url: "https://github.com/workaroundgmbh/aws-sdk-ios-spm", .upToNextMajor(from: "2.34.1")),
        .package(url: "https://github.com/workaroundgmbh/OpenSSL", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/weichsel/ZIPFoundation", from: "0.9.16"),
        .package(url: "https://github.com/NordicSemiconductor/IOS-nRF-Connect-Device-Manager", from: "1.6.0")
    ],
    targets: [
        .binaryTarget(
            name: "ConnectSDK",
            url: "https://dl.cloudsmith.io/CujHIwqxWVjq8tLK/proglove/markconnectiossdk-dev/raw/names/ConnectSDK-2.3.1.xcframework/versions/2.3.1/ConnectSDK-2.3.1.xcframework.zip",
            checksum: "4cd982855cc83f7f5cecda23b7b8e47d73e53ee871f240192c541a9a41e34232"),
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
