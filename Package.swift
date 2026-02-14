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
        .library(
            name: "NeuralGateAI",
            targets: ["NeuralGateAI"]),
        .library(
            name: "NeuralGateAutomation",
            targets: ["NeuralGateAutomation"]),
        .library(
            name: "NeuralGateLearning",
            targets: ["NeuralGateLearning"]),
    ],
    dependencies: [],
    targets: [
        // Core Module
        .target(
            name: "NeuralGate",
            dependencies: []),
        
        // AI Module - Core AI features and decision engine
        .target(
            name: "NeuralGateAI",
            dependencies: ["NeuralGate"]),
        
        // Automation Module - Workflow and task automation
        .target(
            name: "NeuralGateAutomation",
            dependencies: ["NeuralGate", "NeuralGateAI", "NeuralGateLearning"]),
        
        // Learning Module - Loop engineering and self-improvement
        .target(
            name: "NeuralGateLearning",
            dependencies: ["NeuralGate", "NeuralGateAI"]),
        
        // Test Targets
        .testTarget(
            name: "NeuralGateTests",
            dependencies: ["NeuralGate"]),
        .testTarget(
            name: "NeuralGateAITests",
            dependencies: ["NeuralGateAI"]),
        .testTarget(
            name: "NeuralGateAutomationTests",
            dependencies: ["NeuralGateAutomation"]),
        .testTarget(
            name: "NeuralGateLearningTests",
            dependencies: ["NeuralGateLearning"]),
    ]
)
