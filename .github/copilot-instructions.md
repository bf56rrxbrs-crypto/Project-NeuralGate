# Copilot Instructions for Project-NeuralGate

## Project Overview

NeuralGate is a comprehensive AI-powered task and workflow automation framework designed exclusively for iPhone users. It combines state-of-the-art AI methodologies, advanced feedback loops, and self-improvement capabilities to deliver unparalleled mobile task automation.

### Key Objectives
- Provide intelligent task automation through AI decision-making
- Enable complex workflow orchestration with failover support
- Implement continuous learning through feedback loops
- Optimize for iOS device constraints (battery, memory, CPU)
- Deliver explainable AI decisions for transparency

### Target Platform
- **Platform**: iOS 16.0+ (iPhone only)
- **Language**: Swift 5.9+
- **Build System**: Swift Package Manager
- **Xcode**: 14.0+

## Repository Structure

This is a Swift Package with multiple modules:

```
Project-NeuralGate/
├── Sources/
│   ├── NeuralGate/              # Core module: types, config, error handling
│   ├── NeuralGateAI/            # AI module: decision engine, predictive analytics
│   ├── NeuralGateAutomation/    # Automation: workflows, task management
│   └── NeuralGateLearning/      # Learning: feedback loops, self-improvement
├── Tests/
│   ├── NeuralGateTests/
│   ├── NeuralGateAITests/
│   ├── NeuralGateAutomationTests/
│   └── NeuralGateLearningTests/
├── Examples/                     # Example implementations
├── .github/
│   ├── workflows/               # CI/CD automation
│   └── ISSUE_TEMPLATE/          # Issue templates
├── Package.swift                # Swift Package Manager manifest
├── ARCHITECTURE.md              # Detailed architecture documentation
├── DOCUMENTATION.md             # Comprehensive API documentation
└── README.md                    # Project overview
```

### Module Dependencies
- **NeuralGate**: No dependencies (core foundation)
- **NeuralGateAI**: Depends on NeuralGate
- **NeuralGateLearning**: Depends on NeuralGate, NeuralGateAI
- **NeuralGateAutomation**: Depends on all other modules

## Build and Test Instructions

### Building the Project
```bash
# Build all targets
swift build

# Build with verbose output
swift build --verbose

# Build in release mode
swift build -c release
```

### Running Tests
```bash
# Run all tests
swift test

# Run tests with code coverage
swift test --enable-code-coverage

# Run tests for a specific module
swift test --filter NeuralGateAITests
```

### Code Quality Checks

#### SwiftLint
```bash
# Install SwiftLint (if not already installed)
brew install swiftlint

# Run SwiftLint
swiftlint lint

# Fix auto-fixable issues
swiftlint --fix
```

#### SwiftFormat
```bash
# Install SwiftFormat (if not already installed)
brew install swiftformat

# Check formatting
swiftformat --lint .

# Apply formatting
swiftformat .
```

### CI/CD Workflows

The project uses GitHub Actions for automation:
- **ci-cd.yml**: Build, test, and coverage on push/PR
- **code-quality.yml**: SwiftLint and SwiftFormat checks
- **security.yml**: CodeQL analysis and security scanning
- **metrics.yml**: Performance tracking
- **issue-management.yml**: Automated issue labeling

All workflows run automatically on pull requests to `main` and `develop` branches.

## Development Guidelines

### Code Style

#### Swift Best Practices
- Use Swift's type inference where appropriate but be explicit when it improves clarity
- Prefer `let` over `var` for immutability
- Use guard statements for early returns
- Leverage Swift's powerful error handling with `throws` and `Result`
- Use async/await for asynchronous operations (no completion handlers)
- Follow protocol-oriented programming patterns

#### Naming Conventions
- Types: `PascalCase` (e.g., `NeuralGateAgent`, `TaskManager`)
- Variables/Functions: `camelCase` (e.g., `executeTask`, `taskResult`)
- Constants: `camelCase` (e.g., `maxMemoryUsage`)
- Protocols: `PascalCase`, often ending in `-able` or `-ing` (e.g., `ResourceAware`)
- Enums: `PascalCase` for type, `camelCase` for cases

#### Documentation Comments
- Use `///` for single-line documentation
- Use `/** ... */` for multi-line documentation
- Document all public APIs with parameters, returns, and throws
- Include usage examples for complex APIs

Example:
```swift
/// Executes a task using the AI decision engine with failover support.
///
/// - Parameter task: The task to execute
/// - Returns: An explainable result containing the task execution outcome
/// - Throws: `NeuralGateError` if execution fails after all retries
public func executeTask(_ task: Task) async throws -> ExplainableResult<TaskExecutionResult>
```

### Architecture Patterns

#### Design Patterns in Use
- **Facade Pattern**: `NeuralGateAgent` provides unified interface
- **Strategy Pattern**: Swappable AI models via `AIModel` protocol
- **Ensemble Pattern**: Multiple models voting on decisions
- **Observer Pattern**: Feedback collection and analytics
- **Chain of Responsibility**: Task execution pipeline

#### Concurrency Model
- Use Swift's modern concurrency (async/await, actors)
- All long-running operations must be async
- Use value types (structs) for thread safety where possible
- Actor isolation for shared mutable state
- No locks or semaphores - prefer Swift's structured concurrency

#### Resource Management
- Implement `ResourceAware` protocol for memory/CPU reporting
- Respect `maxMemoryUsage` from configuration
- Use lazy initialization for expensive resources
- Implement proper cleanup in deinit

### Making Changes

#### Before Starting
1. Read relevant documentation (ARCHITECTURE.md, DOCUMENTATION.md)
2. Understand the module you're working in
3. Check existing tests to understand expected behavior
4. Review recent commits for context

#### During Development
1. Write tests first (TDD) or alongside code
2. Keep changes focused and atomic
3. Run tests frequently: `swift test`
4. Run linters before committing: `swiftlint lint && swiftformat --lint .`
5. Ensure code coverage for new code

#### Commit Guidelines
- Use conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`
- Keep commits focused on a single concern
- Write clear, descriptive commit messages
- Reference issue numbers when applicable

### Testing Strategy

#### Unit Tests
- Test individual components in isolation
- Mock dependencies using protocols
- Aim for 80%+ code coverage
- Test both success and failure paths

#### Integration Tests
- Test module interactions
- Test end-to-end workflows
- Validate AI decision-making logic

#### Performance Tests
- Benchmark critical paths
- Monitor memory usage
- Validate battery impact
- Test with realistic data volumes

### Common Pitfalls to Avoid

1. **Don't block the main thread**: Use async/await
2. **Don't ignore resource limits**: Check memory usage
3. **Don't skip error handling**: All operations should handle failures
4. **Don't break the API**: Maintain backward compatibility
5. **Don't skip tests**: All new code needs tests
6. **Don't ignore warnings**: Fix SwiftLint warnings before committing

### Debugging Tips

#### Using Print Debugging
```swift
#if DEBUG
print("[DEBUG] Task execution started: \(task.name)")
#endif
```

#### Using NeuralGateLogger
```swift
NeuralGateLogger.log("Decision made", level: .info, context: ["task": task.name])
```

#### Running Tests with Specific Cases
```bash
# Run a specific test
swift test --filter testAIDecisionMaking

# Run with verbose output
swift test --verbose
```

## Key Concepts

### AI Decision Engine
- Ensemble of multiple AI models
- Weighted voting based on model confidence
- Explainable results with reasoning
- Resource-aware execution

### Workflow Automation
- Composition strategies: sequential, parallel, conditional
- Automatic failover and retry logic
- Context-aware execution
- Comprehensive error handling

### Learning System
- Feedback collection and analysis
- Pattern recognition in task history
- Autonomous performance optimization
- Continuous model improvement

### Resource Optimization
- Battery-aware algorithms (optimization levels 0-3)
- Memory limits enforced at runtime
- CPU-efficient implementations (O(n log n) or better)
- Lazy loading and caching

## Notes for Copilot

### Platform Specifics
- This is an iOS-only framework - no macOS, watchOS, or other platforms
- Target iOS 16.0+ for modern Swift concurrency support
- Consider iOS-specific constraints (battery, memory, app lifecycle)
- Leverage iOS frameworks when appropriate (Foundation, Combine)

### When Suggesting Code
- Prefer Swift-native solutions over third-party libraries
- Use async/await over completion handlers
- Follow existing patterns in the codebase
- Maintain consistency with architecture
- Include appropriate error handling
- Add documentation comments for public APIs

### When Adding Dependencies
- Avoid external dependencies unless absolutely necessary
- If adding a dependency, justify why it's needed
- Update Package.swift dependencies array
- Ensure dependency is compatible with iOS 16.0+
- Consider impact on package size and build time

### When Modifying Architecture
- Discuss major architectural changes first
- Maintain existing module boundaries
- Don't introduce circular dependencies
- Keep the dependency graph clean (Core → AI → Learning/Automation)
- Consider backward compatibility

### Accessibility and UX
- While this is a framework (not an app), consider developer experience
- Provide clear error messages
- Make APIs intuitive and hard to misuse
- Follow the principle of least surprise
- Document complex behaviors

## Quick Reference

### Common Commands
```bash
# Full build and test cycle
swift build && swift test

# Clean build
rm -rf .build && swift build

# Code quality check
swiftlint lint && swiftformat --lint .

# Generate documentation (requires jazzy)
jazzy --min-acl public --module NeuralGate
```

### File Locations
- Core types: `Sources/NeuralGate/`
- AI logic: `Sources/NeuralGateAI/`
- Workflows: `Sources/NeuralGateAutomation/`
- Learning: `Sources/NeuralGateLearning/`
- Tests: `Tests/[ModuleName]Tests/`
- Config: `.swiftlint.yml`, `.swiftformat`

### Important Links
- [Architecture Documentation](../ARCHITECTURE.md)
- [API Documentation](../DOCUMENTATION.md)
- [Examples](../Examples/)
- [CI/CD Workflows](.github/workflows/)
