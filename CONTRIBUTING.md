# Contributing to Project-NeuralGate

Thank you for your interest in contributing to Project-NeuralGate! This document provides guidelines and instructions for contributing to the project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Pull Request Process](#pull-request-process)
- [Project Structure](#project-structure)

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on what is best for the community
- Show empathy towards other community members
- Accept constructive criticism gracefully

## Getting Started

### Prerequisites

- macOS with Xcode 15.0 or later
- Swift 5.9 or later
- Git
- Familiarity with iOS development and Swift

### Setting Up Development Environment

1. **Fork and Clone**
   ```bash
   # Fork the repository on GitHub, then:
   git clone https://github.com/YOUR_USERNAME/Project-NeuralGate.git
   cd Project-NeuralGate
   ```

2. **Install Dependencies**
   ```bash
   # Install SwiftLint
   brew install swiftlint
   
   # Install SwiftFormat
   brew install swiftformat
   ```

3. **Build the Project**
   ```bash
   swift build
   ```

4. **Run Tests**
   ```bash
   swift test
   ```

## Development Workflow

### Branch Naming

Use descriptive branch names with prefixes:

- `feature/` - New features (e.g., `feature/add-calendar-integration`)
- `fix/` - Bug fixes (e.g., `fix/crash-on-nil-task`)
- `docs/` - Documentation updates (e.g., `docs/update-api-reference`)
- `refactor/` - Code refactoring (e.g., `refactor/simplify-task-manager`)
- `test/` - Test additions/updates (e.g., `test/add-integration-tests`)
- `chore/` - Maintenance tasks (e.g., `chore/update-dependencies`)

### Development Process

1. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   - Follow the coding standards (see below)
   - Write or update tests
   - Update documentation

3. **Test Your Changes**
   ```bash
   # Run tests
   swift test
   
   # Run SwiftLint
   swiftlint lint
   
   # Format code
   swiftformat .
   ```

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "feat: add your feature"
   ```

5. **Push to Your Fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request**
   - Go to the original repository on GitHub
   - Click "New Pull Request"
   - Select your branch
   - Fill in the PR template

## Coding Standards

### Swift Style Guide

Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) and [Google Swift Style Guide](https://google.github.io/swift/).

### Key Principles

1. **Naming Conventions**
   - Use clear, descriptive names
   - Classes and structs: `UpperCamelCase`
   - Functions and variables: `lowerCamelCase`
   - Constants: `lowerCamelCase` (not SCREAMING_CASE)
   - Protocols: Descriptive nouns or adjectives with -able, -ible suffix

2. **Code Organization**
   - Group related code with `// MARK: -` comments
   - Properties before methods
   - Public APIs before private implementations
   - Protocol conformance in extensions

3. **Error Handling**
   - Use proper error types with associated values
   - Provide descriptive error messages
   - Include recovery suggestions where appropriate
   - Always validate inputs

4. **Documentation**
   - Add doc comments for all public APIs
   - Use `///` for single-line comments
   - Use `/** */` for multi-line comments
   - Include parameters, returns, and throws information

### Example

```swift
/// Manages task scheduling and execution
public class TaskManager {
    
    // MARK: - Properties
    
    private var tasks: [UUID: Task] = [:]
    
    // MARK: - Public Methods
    
    /// Creates a new task from the given intent
    /// - Parameter intent: The parsed user intent
    /// - Returns: The created task
    /// - Throws: `TaskError.invalidInput` if intent is invalid
    public func createTask(from intent: Intent) throws -> Task {
        guard !intent.action.isEmpty else {
            throw TaskError.invalidInput("Task action cannot be empty")
        }
        
        // Implementation...
    }
    
    // MARK: - Private Methods
    
    private func validateTask(_ task: Task) -> Bool {
        // Implementation...
    }
}
```

### SwiftLint Configuration

The project uses SwiftLint for code consistency. Configuration is in `.swiftlint.yml`. Key rules:

- Line length: 120 characters
- Function body length: 50 lines
- Type body length: 300 lines
- File length: 500 lines
- Nesting depth: 3 levels

### SwiftFormat Configuration

Code formatting is enforced by SwiftFormat. Configuration is in `.swiftformat`. Run before committing:

```bash
swiftformat .
```

## Testing Guidelines

### Test Structure

- Place tests in the appropriate test target:
  - `NeuralGateTests` - Core functionality tests
  - `NeuralGateAITests` - AI/ML component tests
  - `NeuralGateAutomationTests` - Automation tests
  - `NeuralGateLearningTests` - Learning system tests

### Writing Tests

1. **Test Naming**
   - Use `test` prefix
   - Be descriptive: `testTaskManagerCreatesTaskFromValidIntent`

2. **Test Structure**
   - Arrange: Set up test data
   - Act: Execute the code being tested
   - Assert: Verify the results

3. **Coverage**
   - Aim for 80%+ code coverage
   - Test happy paths and error cases
   - Test edge cases and boundary conditions

### Example Test

```swift
import XCTest
@testable import NeuralGate

final class TaskManagerTests: XCTestCase {
    var sut: TaskManager!
    
    override func setUp() {
        super.setUp()
        sut = TaskManager()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testCreateTaskFromValidIntent() throws {
        // Arrange
        let intent = Intent(
            action: "send_message",
            originalText: "Send message to John",
            priority: .high
        )
        
        // Act
        let task = try sut.createTask(from: intent)
        
        // Assert
        XCTAssertEqual(task.name, "send_message")
        XCTAssertEqual(task.priority, .high)
    }
    
    func testCreateTaskThrowsOnEmptyAction() {
        // Arrange
        let intent = Intent(
            action: "",
            originalText: "Invalid intent",
            priority: .low
        )
        
        // Act & Assert
        XCTAssertThrowsError(try sut.createTask(from: intent)) { error in
            XCTAssertTrue(error is TaskError)
        }
    }
}
```

## Commit Message Guidelines

### Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semicolons, etc.)
- `refactor`: Code refactoring (no functional changes)
- `test`: Adding or updating tests
- `chore`: Maintenance tasks (dependencies, build config, etc.)
- `perf`: Performance improvements
- `ci`: CI/CD changes

### Examples

```
feat(task-manager): add support for recurring tasks

- Add RecurringTask model
- Implement scheduling logic
- Update TaskManager to handle recurrence
- Add unit tests for recurring tasks

Closes #123
```

```
fix(ios-integration): handle Siri authorization denial gracefully

Previously, the app would crash if Siri authorization was denied.
Now it throws a proper IntegrationError with recovery suggestion.

Fixes #456
```

## Pull Request Process

### Before Submitting

1. ✅ All tests pass (`swift test`)
2. ✅ Code follows style guidelines (`swiftlint lint`)
3. ✅ Code is formatted (`swiftformat .`)
4. ✅ Documentation is updated
5. ✅ Commit messages follow guidelines

### PR Template

Your PR should include:

1. **Title**: Clear, descriptive title with conventional commits prefix
2. **Description**:
   - What changes were made
   - Why these changes were needed
   - How to test the changes
   - Screenshots (for UI changes)
   - Breaking changes (if any)
3. **Checklist**: Complete the PR checklist
4. **References**: Link related issues

### Review Process

1. **Automated Checks**: CI/CD pipeline runs automatically
2. **Code Review**: Maintainers review your code
3. **Feedback**: Address any requested changes
4. **Approval**: At least one maintainer must approve
5. **Merge**: Maintainer merges after approval

### After Merge

- Delete your feature branch
- Update your fork's main branch
- Celebrate! 🎉

## Project Structure

```
Project-NeuralGate/
├── Sources/
│   ├── NeuralGate/              # Core framework
│   │   ├── Core/                # Core components
│   │   ├── Integration/         # iOS integrations
│   │   ├── Models/              # Data models
│   │   ├── UI/                  # UI components
│   │   └── Workflows/           # Workflow engine
│   ├── NeuralGateAI/            # AI/ML components
│   ├── NeuralGateAutomation/    # Automation engine
│   └── NeuralGateLearning/      # Learning systems
├── Tests/
│   ├── NeuralGateTests/
│   ├── NeuralGateAITests/
│   ├── NeuralGateAutomationTests/
│   └── NeuralGateLearningTests/
├── Examples/                     # Example apps
├── Documentation/                # Detailed docs
├── .github/                      # GitHub config
│   ├── workflows/               # CI/CD workflows
│   └── ISSUE_TEMPLATE/          # Issue templates
├── Package.swift                # SPM manifest
└── README.md                    # Project overview
```

## Questions?

- Open an [issue](https://github.com/bf56rrxbrs-crypto/Project-NeuralGate/issues) for bugs or feature requests
- Check [existing issues](https://github.com/bf56rrxbrs-crypto/Project-NeuralGate/issues) first
- Review [documentation](DOCUMENTATION.md) for API details

## License

By contributing to Project-NeuralGate, you agree that your contributions will be licensed under the project's proprietary license.

---

Thank you for contributing to Project-NeuralGate! 🎉
