// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VHDLMachines",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "VHDLMachines", targets: ["VHDLMachines"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
        .package(url: "git@github.com:mipalgu/VHDLParsing", from: "1.0.1"),
        .package(url: "git@github.com:mipalgu/GUUnits", from: "2.1.0"),
        .package(url: "git@github.com:mipalgu/swift_helpers", from: "2.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "VHDLMachines",
            dependencies: [.product(name: "swift_helpers", package: "swift_helpers"), .product(name: "IO", package: "swift_helpers"), .product(name: "GUUnits", package: "GUUnits"), .product(name: "VHDLParsing", package: "VHDLParsing"), .product(name: "StringHelpers", package: "VHDLParsing")]
        ),
        .testTarget(
            name: "VHDLMachinesTests",
            dependencies: ["VHDLMachines", .product(name: "swift_helpers", package: "swift_helpers"), .product(name: "IO", package: "swift_helpers"), .product(name: "Functional", package: "swift_helpers"), .product(name: "GUUnits", package: "GUUnits"), "VHDLParsing"]
        ),
    ]
)
