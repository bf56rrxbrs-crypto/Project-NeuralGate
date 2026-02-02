# Copilot Instructions for Project-NeuralGate

## Project Overview

Project-NeuralGate is an AI agent for task and workflow automation exclusively for iPhone users.

## Repository Structure

This is a Swift Package Manager project with the following structure:
- `Sources/` - Main source code organized by modules (NeuralGate, NeuralGateAI, NeuralGateAutomation, NeuralGateLearning)
- `Tests/` - Test files for each module
- `Package.swift` - Swift Package Manager configuration
- `README.md` - Project description and documentation

## Development Guidelines

### Code Style
- Follow Swift best practices and Apple's Human Interface Guidelines for iOS development
- Use meaningful variable and function names
- Include documentation comments for public APIs
- Use `// MARK:` comments to organize code sections (e.g., `// MARK: - Public Methods`, `// MARK: - Private Properties`)
- Prefer `let` over `var` whenever possible for immutability
- Avoid force unwrapping (`!`) - use optional binding (`if let`, `guard let`) or nil coalescing (`??`) instead

### Architecture Patterns
- Use MVVM (Model-View-ViewModel) architecture for UI components
- Utilize Swift Concurrency (async/await) for asynchronous operations
- Apply dependency injection for testability and modularity
- Keep view controllers lightweight by moving business logic to ViewModels or dedicated service classes

### Error Handling
- Use Swift's `Result` type or throwing functions for operations that can fail
- Provide meaningful error messages that help with debugging
- Implement appropriate logging for errors and important events
- Handle errors gracefully at appropriate levels of the app

### Testing Guidelines
- Write unit tests for business logic using the XCTest framework
- Aim for high test coverage of critical paths
- Mock external dependencies to isolate unit tests
- Keep tests focused, fast, and independent

### Build and Test Instructions

Build and test the project using Swift Package Manager:
- Build: `swift build`
- Test: `swift test`
- Clean: `swift package clean`

When making changes:
- Always run the build command before submitting changes
- Run all tests to ensure no regressions
- Follow any linting rules that are configured

### Making Changes

1. Ensure changes align with the project's focus on iPhone task and workflow automation
2. Test any changes locally before committing
3. Keep commits focused and atomic
4. Use semantic commit message conventions:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `docs:` for documentation changes
   - `refactor:` for code refactoring
   - `test:` for adding or updating tests
   - `chore:` for maintenance tasks

## Notes for Copilot

- This repository targets iOS/iPhone platform exclusively with a minimum target of iOS 16+
- When suggesting code, prefer Swift and iOS-native solutions
- Consider accessibility and usability in all UI-related changes
- Prefer SF Symbols for icons and system imagery
- Prioritize the following frameworks for automation features:
  - **App Intents** - For Siri and Shortcuts integration
  - **SiriKit** - For voice command integration
  - **Shortcuts** - For workflow automation
- Consider privacy implications - prefer on-device processing when possible
- Always prefer native Apple frameworks over third-party alternatives when suitable

## Key Frameworks

This project leverages several iOS frameworks for automation capabilities:

- **App Intents** - Siri and Shortcuts integration for voice and automation workflows
- **BackgroundTasks** - Scheduling and executing background work for automated tasks
- **UserNotifications** - Alerting users about automation results and events
- **CoreData/SwiftData** - Local data persistence for workflows and user data
- **Combine** - Reactive programming patterns for event handling and data flow

## Security Considerations

- Never hardcode secrets, API keys, or sensitive data in source code
- Use Keychain Services for storing sensitive information like credentials
- Validate all user inputs to prevent injection attacks
- Ensure compliance with App Transport Security (ATS) requirements
- Follow principle of least privilege for permissions
