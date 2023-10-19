// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LibrarySPM",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "LibrarySPM",
            targets: ["LibrarySPM", "CustomViews", "Helpers", "Folder", "Practice", "DestinationFolder", "VideoPlayer"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LibrarySPM"),
        .target(
            name: "CustomViews",
            dependencies: []),
        .target(
            name: "Helpers",
            dependencies: []),
        .target(
            name: "Folder",
            dependencies: ["CustomViews", "Helpers"]),
        .target(
            name: "Practice",
            dependencies: ["CustomViews", "Helpers"]),
        .target(
            name: "DestinationFolder",
            dependencies: ["CustomViews", "Helpers"]),
        .target(
            name: "VideoPlayer",
            dependencies: ["CustomViews", "Helpers"]),
        .testTarget(
            name: "LibrarySPMTests",
            dependencies: ["LibrarySPM", "CustomViews", "Helpers", "Folder", "Practice", "DestinationFolder", "VideoPlayer"]),
    ]
)

