// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// The package definition.
let package = Package(
    name: "VHDLMachines",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other
        // packages.
        .library(name: "VHDLMachines", targets: ["VHDLMachines"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
        .package(url: "https://github.com/mipalgu/VHDLParsing", from: "2.7.0"),
        .package(url: "https://github.com/cpslabgu/SwiftUtils", from: "0.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package
        // depends on.
        .target(
            name: "VHDLMachines",
            dependencies: [
                .product(name: "SwiftUtils", package: "SwiftUtils"),
                .product(name: "VHDLParsing", package: "VHDLParsing"),
                .product(name: "StringHelpers", package: "VHDLParsing")
            ]
        ),
        .testTarget(name: "TestUtils", dependencies: ["VHDLParsing", "VHDLMachines"]),
        .testTarget(
            name: "VHDLMachinesTests",
            dependencies: [
                "VHDLMachines",
                .product(name: "SwiftUtils", package: "SwiftUtils"),
                "VHDLParsing",
                "TestUtils"
            ]
        )
    ]
)
