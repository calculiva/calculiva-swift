// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "calculiva-swift",
    products: [
        .library(name: "Calculiva", targets: ["Calculiva"]),
    ],
    targets: [
        .target(name: "Calculiva"),
        .testTarget(
            name: "CalculivaTests",
            dependencies: ["Calculiva"],
            exclude: ["vectors.json"]
        ),
    ]
)
