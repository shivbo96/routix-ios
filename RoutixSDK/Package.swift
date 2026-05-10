// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "RoutixSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "RoutixSDK",
            targets: ["RoutixSDK"]
        )
    ],
    targets: [
        .target(
            name: "RoutixSDK",
            path: "Sources/RoutixSDK"
        )
    ]
)
