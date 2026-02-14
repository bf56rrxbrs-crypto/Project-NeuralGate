# Contributing to Project-NeuralGate

Thank you for your interest in contributing to Project-NeuralGate! This document provides guidelines for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)
- [Feature Requests](#feature-requests)

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md) to ensure a welcoming environment for all contributors.

## Getting Started

### Prerequisites

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- macOS for development

### Setting Up Your Development Environment

1. **Fork the Repository**
   ```bash
   # Fork via GitHub UI, then clone your fork
   git clone https://github.com/YOUR-USERNAME/Project-NeuralGate.git
   cd Project-NeuralGate
   ```

2. **Build the Project**
   ```bash
   swift build
   ```

3. **Run Tests**
   ```bash
   swift test
   ```

## Development Workflow

### Creating a Branch

Create a feature branch from `main`:

```bash
git checkout -b feature/your-feature-name
```

Use descriptive branch names:
- `feature/` for new features
- `fix/` for bug fixes
- `docs/` for documentation updates
- `test/` for test additions
- `refactor/` for code refactoring

### Making Changes

1. Make your changes in focused, logical commits
2. Write clear commit messages following conventional commits:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `test:` for test additions/changes
   - `refactor:` for code refactoring
   - `chore:` for maintenance tasks

Example:
```bash
git commit -m "feat: add multilingual support for AI responses"
```

### Keeping Your Branch Updated

Regularly sync with the main repository:

```bash
git fetch upstream
git rebase upstream/main
```

## Coding Standards

### Swift Style Guide

Follow Apple's Swift API Design Guidelines and these project-specific conventions:

1. **Naming Conventions**
   - Use clear, descriptive names
   - Classes: `PascalCase`
   - Functions/variables: `camelCase`
   - Constants: `camelCase` (not SCREAMING_SNAKE_CASE)

2. **Code Organization**
   - Group related functionality
   - Use extensions for protocol conformance
   - Keep files focused and under 500 lines when possible

3. **Documentation**
   - Add documentation comments for public APIs
   - Use `///` for documentation
   - Include parameter descriptions and return values
   - Add usage examples for complex functions

Example:
```swift
/// Processes a natural language request and executes the corresponding task.
///
/// - Parameter request: The user's natural language input
/// - Returns: The result of processing and executing the request
/// - Throws: `NeuralGateError` if processing fails
public func processRequest(_ request: String) async throws -> TaskResult {
    // Implementation
}
```

4. **Error Handling**
   - Use Swift's error handling (`throws`, `try`, `catch`)
   - Provide meaningful error messages
   - Include fallback mechanisms for critical operations

5. **Concurrency**
   - Use Swift's async/await for asynchronous operations
   - Avoid blocking the main thread
   - Use `Swift.Task` explicitly to avoid naming collisions with model types

6. **Testing**
   - Write unit tests for all new functionality
   - Aim for high code coverage
   - Test edge cases and error conditions

### SwiftLint

The project uses SwiftLint for code quality. Run it before committing:

```bash
swiftlint
```

Configuration is in `.swiftlint.yml`.

## Testing Guidelines

### Writing Tests

1. **Unit Tests**
   - Test individual functions and methods
   - Mock external dependencies
   - Use clear test names: `test_methodName_condition_expectedResult`

Example:
```swift
func test_processRequest_validInput_returnsSuccess() async throws {
    let agent = NeuralGateAgent()
    let result = try await agent.processRequest("Send a message")
    XCTAssertTrue(result.success)
}
```

2. **Integration Tests**
   - Test interactions between modules
   - Verify workflow execution
   - Test iOS integration points

3. **Test Coverage**
   - Aim for at least 80% code coverage
   - Focus on critical paths and edge cases
   - Don't sacrifice test quality for coverage numbers

### Running Tests

```bash
# Run all tests
swift test

# Run with coverage
swift test --enable-code-coverage

# Run specific test
swift test --filter NeuralGateTests
```

## Submitting Changes

### Pull Request Process

1. **Before Submitting**
   - Run all tests and ensure they pass
   - Run SwiftLint and fix any issues
   - Update documentation if needed
   - Add tests for new functionality

2. **Creating a Pull Request**
   - Push your branch to your fork
   - Create a PR against the `main` branch
   - Fill out the PR template completely
   - Link any related issues

3. **PR Title Format**
   - Use clear, descriptive titles
   - Follow conventional commits format
   - Example: `feat: add voice command support for workflows`

4. **PR Description**
   - Explain what changes you made and why
   - Include screenshots for UI changes
   - List any breaking changes
   - Mention related issues or PRs

5. **Review Process**
   - Address reviewer feedback promptly
   - Keep discussions constructive and professional
   - Be open to suggestions and improvements
   - Update your PR based on feedback

6. **CI/CD Checks**
   - All CI checks must pass
   - Build must succeed
   - Tests must pass
   - Code quality checks must pass
   - Security scans must pass

### After Your PR is Merged

- Delete your feature branch
- Update your fork's main branch
- Celebrate! 🎉

## Reporting Issues

### Bug Reports

Use the bug report template and include:

1. **Description**: Clear description of the issue
2. **Steps to Reproduce**: Detailed steps to reproduce the bug
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Environment**:
   - iOS version
   - Xcode version
   - Device model
6. **Screenshots**: If applicable
7. **Logs**: Relevant error messages or logs

### Security Issues

For security vulnerabilities:
- **Do not** open a public issue
- Email security concerns to the maintainers
- Provide detailed information about the vulnerability
- Wait for acknowledgment before public disclosure

## Feature Requests

Use the feature request template and include:

1. **Problem**: What problem does this solve?
2. **Proposed Solution**: Describe your proposed solution
3. **Alternatives**: Any alternative solutions considered
4. **Additional Context**: Use cases, mockups, examples
5. **iPhone-Specific**: How does this benefit iPhone users?

## Project Areas

### Core Modules

- **NeuralGate**: Core framework and models
- **NeuralGateAI**: AI decision engine and analytics
- **NeuralGateAutomation**: Task and workflow automation
- **NeuralGateLearning**: Self-improvement and feedback loops

### Areas Needing Contribution

1. **iOS Integration**: Real implementations for Siri, Shortcuts, Notifications
2. **AI/ML Models**: Actual ML models using CoreML
3. **Natural Language Processing**: Enhanced NLP capabilities
4. **Performance Optimization**: Battery and memory efficiency
5. **Testing**: Increased test coverage
6. **Documentation**: More examples and tutorials

## Getting Help

- **GitHub Discussions**: Ask questions and discuss ideas
- **Issues**: Search existing issues before creating new ones
- **Documentation**: Check [DOCUMENTATION.md](DOCUMENTATION.md)
- **Examples**: See the [Examples](Examples/) directory

## Recognition

Contributors will be recognized in:
- The repository's contributor list
- Release notes for significant contributions
- Special mentions for major features

## License

By contributing to Project-NeuralGate, you agree that your contributions will be licensed under the same license as the project.

## Thank You!

Your contributions make Project-NeuralGate better for everyone. We appreciate your time and effort! 🙏
