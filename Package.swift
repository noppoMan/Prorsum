import PackageDescription

let package = Package(
    name: "Prorsum",
    targets: [
        Target(name: "Performance", dependencies: ["Prorsum"]),
        Target(name: "Prorsum")
    ],
    dependencies: [
        .Package(url: "https://github.com/Zewo/CHTTPParser.git", majorVersion: 0, minor: 14)
    ]
)
