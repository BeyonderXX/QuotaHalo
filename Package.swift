// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "QuotaHalo",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "QuotaHalo", targets: ["QuotaHalo"])
    ],
    targets: [
        .executableTarget(
            name: "QuotaHalo",
            path: "Sources/QuotaHalo"
        )
    ]
)
