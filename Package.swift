// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "ConnectSDK",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "ConnectSDK",
            targets: ["ConnectSDK", "Dependencies"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.16.0"),
        .package(url: "https://github.com/aws-amplify/aws-sdk-ios-spm", from: "2.0.0"),
        .package(url: "https://github.com/krzyzanowskim/OpenSSL.git", from: "1.0.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.16")
    ],
    targets: [
        .binaryTarget(
            name: "ConnectSDK",
            url: "https://dl.cloudsmith.io/2Hwd6s6l2EPoHzYB/proglove/markconnectiossdk-prod/raw/versions/2.0.0/ConnectSDK-2.0.0.xcframework.zip",
            checksum: "ff6296dfa6713963c166dd0e4ca71f01bff49d03c7eac5db9dea21321136693a"),
        .target(
            name: "Dependencies",
            dependencies: [
                "ZIPFoundation",
                "OpenSSL",
                .target(name: "ConnectSDK"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
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
