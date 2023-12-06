// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SomeKit",
    products: [
        .library(
            name: "SomeKit",
            targets: ["SomeKit"]),
    ],
    targets: [
        .target(
            name: "SomeKit"),
        .testTarget(
            name: "SomeKitTests",
            dependencies: ["SomeKit"]),
    ]
)
