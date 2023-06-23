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
            url: "https://dl.cloudsmith.io/CujHIwqxWVjq8tLK/proglove/markconnectiossdk-dev/raw/versions/2.0.0/ConnectSDK-2.0.0-rc-beta.xcframework.zip",
            checksum: "f25dfa26bc2b3646521d90a79bbc279bd1e083f2a6a04bf015a7ecb8a3b40a42"),
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
