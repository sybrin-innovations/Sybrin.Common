// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sybrin.Common",
    defaultLocalization: "en",
    products: [
        .library(
            name: "Sybrin.Common",
            targets: ["Sybrin.Common"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Sybrin.Common"),
        .testTarget(
            name: "Sybrin.CommonTests",
            dependencies: ["Sybrin.Common"]),
    ]
)
