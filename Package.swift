// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ATKit",
    platforms: [
        .iOS(.v11),
        .macOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ATKit",
            targets: ["ATKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Ref: https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode
        .target(
            name: "ATKit",
            dependencies: []),
        .testTarget(
            name: "ATKitTests",
            dependencies: ["ATKit"]),
    ]
)
