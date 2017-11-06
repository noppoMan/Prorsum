// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Prorsum",
    products: [
        .executable(name: "prorsum-performance", targets: ["Performance"]),
        .library(name: "Prorsum", targets: ["Prorsum"])
    ],
    dependencies: [
        .package(url: "https://github.com/Zewo/CHTTPParser.git", .exact("0.14.0")),
        .package(url: "https://github.com/noppoman/ProrsumNet.git", .upToNextMajor(from: "0.1.0"))
    ],
    targets: [
        .target(name: "Prorsum", dependencies: ["CHTTPParser", "ProrsumNet"]),
        .target(name: "Performance", dependencies: ["Prorsum"]),
        .testTarget(name: "ProrsumTests", dependencies: ["Prorsum"])
    ]
)
