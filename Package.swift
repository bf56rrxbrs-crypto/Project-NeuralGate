// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "NeuralGate",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "NeuralGate",
            targets: ["NeuralGate"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NeuralGate",
            dependencies: []),
        .testTarget(
            name: "NeuralGateTests",
            dependencies: ["NeuralGate"]),
    ]
)
