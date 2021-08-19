// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Watchface",
    products: [
        .library(
            name: "Watchface",
            targets: ["Watchface"]),
    ],
    dependencies: [
        // for generating public memberwise init by `swift run -c release swift-mod`
        .package(url: "https://github.com/ra1028/swift-mod.git", .revision("0.0.6")), // use revision instead of `from` to allow unstable dependency ref from swift-mod to swift-syntax
    ],
    targets: [
        .target(
            name: "Watchface",
            dependencies: [],
            path: "Watchface")
    ]
)
