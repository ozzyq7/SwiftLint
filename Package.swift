// swift-tools-version:5.0
import PackageDescription

#if canImport(CommonCrypto)
private let addCryptoSwift = false
#else
private let addCryptoSwift = true
#endif

let package = Package(
    name: "SwiftLint",
    products: [
        .library(name: "SwiftLintFramework", targets: ["SwiftLintFramework"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/SourceKitten.git", .upToNextMinor(from: "0.29.0")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
    ] + (addCryptoSwift ? [.package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMinor(from: "1.0.0"))] : []),
    targets: [
        .target(
            name: "SwiftLintFramework",
            dependencies: [
                "SourceKittenFramework",
                "Yams",
            ] + (addCryptoSwift ? ["CryptoSwift"] : [])
        ),
    ]
)
