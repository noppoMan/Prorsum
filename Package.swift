import PackageDescription

let package = Package(
    name: "Prorsum",
    dependencies: [
        .Package(url: "https://github.com/Zewo/CHTTPParser.git", majorVersion: 0, minor: 14)
    ]
)
