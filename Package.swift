// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-acoustics-voice",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Acoustics Voice", targets: ["Acoustics Voice"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-molecules/swift-acoustics.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-fourier.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-numeric.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-space.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-frequency.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-pressure.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-flow.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-mass.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-stiffness.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-loss.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Acoustics Voice",
            dependencies: [
                .product(name: "Acoustics", package: "swift-acoustics"),
                .product(name: "Fourier", package: "swift-fourier"),
                .product(name: "Numeric", package: "swift-numeric"),
                .product(name: "Space", package: "swift-space"),
                .product(name: "Frequency", package: "swift-frequency"),
                .product(name: "Pressure", package: "swift-pressure"),
                .product(name: "Flow", package: "swift-flow"),
                .product(name: "Mass", package: "swift-mass"),
                .product(name: "Stiffness", package: "swift-stiffness"),
                .product(name: "Loss", package: "swift-loss"),
            ]
        ),
        .testTarget(
            name: "Acoustics Voice Tests",
            dependencies: [
                .target(name: "Acoustics Voice")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableExperimentalFeature("Lifetimes"),
            .treatAllWarnings(as: .error),
        ]
}
