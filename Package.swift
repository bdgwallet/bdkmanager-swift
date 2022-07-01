// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BDKManager",
    platforms: [
           .macOS(.v12),
           .iOS(.v15),
        ],
    products: [
        .library(
            name: "BDKManager",
            targets: ["BDKManager"]),
    ],
    dependencies: [
        .package(url: "https://github.com/bitcoindevkit/bdk-swift", .exactItem("0.4.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "BDKManager",
            dependencies: [.product(name: "BitcoinDevKit", package: "bdk-swift")],
            path: "Sources"),
    ]
)
