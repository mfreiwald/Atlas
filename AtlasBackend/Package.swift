// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AtlasBackend",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .executable(name: "AtlasBackend", targets: ["AtlasBackend"]),
        .library(name: "Shared", targets: ["Shared"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.3.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/mfreiwald/SwiftOpenAI.git", branch: "serverside"),
    ],
    targets: [
        .executableTarget(
            name: "AtlasBackend",
            dependencies: [
                .target(name: "Shared"),
                .product(name: "Hummingbird", package: "Hummingbird"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftOpenAI", package: "SwiftOpenAI"),
            ]),
        .target(
            name: "Shared"
        )
    ]
)
