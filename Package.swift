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
            targets: ["LibrarySPM"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            url: "https://cengizhan-tomak@bitbucket.org/liveviewsports/lvrealmkit.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/honkmaster/TTProgressHUD",
            from: "0.0.5"
        ),
        .package(
            url: "https://github.com/cengizhantomak/CustomAlertPackage",
            branch: "main"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "LibrarySPM",
            path: "Sources"),
        .testTarget(
            name: "LibrarySPMTests",
            dependencies: ["LibrarySPM"]),
    ]
)

