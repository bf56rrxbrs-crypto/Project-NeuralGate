# GitHub Actions Workflows Documentation

This document provides comprehensive information about the GitHub Actions workflows implemented for Project NeuralGate. These workflows automate CI/CD, testing, code quality, deployment, metrics collection, and issue management.

## Table of Contents

1. [Overview](#overview)
2. [Workflow Files](#workflow-files)
3. [CI/CD Pipeline](#cicd-pipeline)
4. [Code Quality Checks](#code-quality-checks)
5. [Security Scanning](#security-scanning)
6. [Deployment Automation](#deployment-automation)
7. [Performance Metrics](#performance-metrics)
8. [Issue Management](#issue-management)
9. [Dependency Management](#dependency-management)
10. [Configuration](#configuration)
11. [Troubleshooting](#troubleshooting)

## Overview

The GitHub Actions workflows for NeuralGate provide automated:

- **Continuous Integration**: Automated building and testing on every push and PR
- **Code Quality**: Linting and formatting checks using SwiftLint and SwiftFormat
- **Security Scanning**: CodeQL analysis, dependency review, and secret detection
- **Deployment**: Automated deployment to staging and production environments
- **Metrics**: Performance monitoring and build time tracking
- **Issue Management**: Automated labeling, categorization, and reporting

## Workflow Files

All workflow files are located in `.github/workflows/`:

| File | Purpose | Triggers |
|------|---------|----------|
| `ci-cd.yml` | Main CI/CD pipeline | Push to main/develop, PRs |
| `code-quality.yml` | Linting and code analysis | Push, PRs |
| `security.yml` | Security scanning and analysis | Push, PRs, schedule |
| `deployment.yml` | Deployment automation | Push to main/develop, tags |
| `metrics.yml` | Performance metrics collection | Push, PRs, schedule |
| `issue-management.yml` | Issue automation | Issue events, schedule |

Additional configuration:
- `.github/dependabot.yml` - Dependabot configuration for dependency updates

## CI/CD Pipeline

**File**: `ci-cd.yml`

### Purpose
Automated build, test, and validation pipeline that runs on every push and pull request.

### Jobs

#### 1. build-and-test
- Runs on macOS 14 with Swift 5.9
- Builds all NeuralGate modules
- Executes all unit and integration tests
- Generates code coverage reports
- Uploads test results and build artifacts

**Key Features**:
- Swift Package Manager cache for faster builds
- Code coverage collection and export
- Codecov integration for coverage tracking
- Test result artifacts with 30-day retention

#### 2. test-report
- Runs after build-and-test completes
- Posts test results as PR comments
- Shows build status, test status, and coverage

#### 3. build-status
- Final status check job
- Reports overall build success/failure

### Usage

The workflow runs automatically on:
- Push to `main` or `develop` branches
- All pull requests to `main` or `develop`
- Manual trigger via workflow_dispatch

### Environment Variables
- `SWIFT_VERSION`: Swift version to use (default: 5.9)

### Artifacts
- **test-results**: Test execution results (30 days)
- **build-artifacts**: Compiled binaries (7 days)

## Code Quality Checks

**File**: `code-quality.yml`

### Purpose
Enforces code quality standards using SwiftLint and SwiftFormat.

### Jobs

#### 1. swiftlint
- Installs and runs SwiftLint
- Reports violations in GitHub Actions logs
- Generates JSON and HTML reports
- Continues on error to allow other checks

#### 2. swiftformat
- Installs and runs SwiftFormat
- Checks code formatting compliance
- Reports formatting issues

#### 3. quality-report
- Aggregates quality check results
- Posts detailed report as PR comment
- Lists top violations with file/line information

#### 4. quality-gate
- Final quality status check
- Currently allows warnings but tracks them
- Can be configured to enforce strict quality gates

### SwiftLint Configuration

To customize SwiftLint rules, create a `.swiftlint.yml` file in the repository root:

```yaml
disabled_rules:
  - trailing_whitespace
opt_in_rules:
  - empty_count
  - missing_docs
included:
  - Sources
excluded:
  - .build
  - Tests
```

### SwiftFormat Configuration

To customize SwiftFormat rules, create a `.swiftformat` file:

```
--swiftversion 5.9
--indent 4
--maxwidth 120
```

### Usage

Runs automatically on:
- Pull requests
- Push to main/develop
- Manual trigger

## Security Scanning

**File**: `security.yml`

### Purpose
Performs comprehensive security analysis including CodeQL analysis, dependency review, and secret scanning.

### Jobs

#### 1. CodeQL Security Analysis
- Runs static code analysis using GitHub CodeQL
- Analyzes Swift code for security vulnerabilities
- Uses security-extended and security-and-quality query suites
- Uploads results to GitHub Security tab

**Key Features**:
- Builds the project for accurate analysis
- Categorizes findings by language
- Integrates with GitHub Advanced Security

#### 2. Dependency Review
- Reviews dependency changes in pull requests
- Detects known vulnerabilities in dependencies
- Checks for restricted licenses (GPL-2.0, GPL-3.0)
- Fails on moderate or higher severity issues

**⚠️ Important**: This job requires the **Dependency Graph** feature to be enabled in repository settings.

**Enable Dependency Graph**:
1. Go to repository Settings
2. Navigate to "Code security and analysis"
3. Enable "Dependency graph"
4. URL: https://github.com/bf56rrxbrs-crypto/Project-NeuralGate/settings/security_analysis

**Note**: The dependency-review job is configured with `continue-on-error: true` to prevent workflow failures if Dependency Graph is not enabled. However, for full security coverage, it's recommended to enable this feature.

#### 3. Secret Scanning Alert Check
- Checks for exposed secrets in code
- Placeholder for custom secret pattern detection
- GitHub secret scanning runs automatically if enabled

#### 4. Security Report
- Aggregates results from all security jobs
- Generates comprehensive security summary
- Reports pass/fail status for each check
- Posted to GitHub Actions summary

### Usage

Runs automatically on:
- Push to `main` or `develop` branches
- All pull requests
- Weekly on Mondays at 3 AM UTC (scheduled)
- Manual trigger via workflow_dispatch

### Security Features Checklist

To get full security coverage, ensure these features are enabled:

- ✅ **CodeQL Analysis** - Enabled in workflow (no additional setup required)
- ⚠️ **Dependency Graph** - Must be enabled in repository settings
- ⚠️ **Dependabot Alerts** - Requires Dependency Graph to be enabled first
- ⚠️ **Secret Scanning** - Available for public repos, or enable for private repos

**Enable in GitHub Settings**:
Settings > Code security and analysis > Enable all security features

## Deployment Automation

**File**: `deployment.yml`

### Purpose
Automates deployment to staging and production environments with release management.

### Jobs

#### 1. build-release
- Builds in release configuration
- Runs all tests
- Packages release artifacts
- Uploads artifacts with 90-day retention

#### 2. deploy-staging
- Deploys to staging environment
- Triggered on push to `develop` branch
- Uses GitHub environment protection
- Environment URL: https://staging.neuralgate.app

#### 3. deploy-production
- Deploys to production environment
- Triggered on version tags (v*.*.*)
- Uses GitHub environment protection
- Environment URL: https://neuralgate.app

#### 4. create-release
- Creates GitHub release for version tags
- Generates automated changelog
- Attaches release artifacts
- Uses semantic versioning

#### 5. update-changelog
- Updates CHANGELOG.md file
- Categorizes changes (Added, Changed, Fixed)
- Commits back to main branch
- Maintains version history

#### 6. notify-deployment
- Sends deployment status notifications
- Generates deployment summary
- Can be extended for Slack/email notifications

### Release Process

1. **Tag a Release**:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **Workflow Actions**:
   - Builds release artifacts
   - Deploys to production
   - Creates GitHub release
   - Updates CHANGELOG.md
   - Sends notifications

3. **Manual Deployment**:
   Use workflow_dispatch to manually deploy to staging or production.

### Environment Configuration

Configure in GitHub Settings > Environments:

1. **staging**
   - No protection rules (for faster iteration)
   - Environment secrets for staging credentials

2. **production**
   - Required reviewers
   - Wait timer (optional)
   - Environment secrets for production credentials

## Performance Metrics

**File**: `metrics.yml`

### Purpose
Collects and tracks performance metrics over time.

### Jobs

#### 1. build-metrics
- Measures clean and incremental build times
- Analyzes package sizes
- Tracks build output and logs

#### 2. test-metrics
- Measures test execution time
- Counts test cases
- Tracks pass/fail statistics

#### 3. performance-profiling
- Analyzes binary sizes
- Estimates memory footprint
- Profiles release builds

#### 4. metrics-report
- Aggregates all metrics
- Generates comprehensive report
- Posts to PR comments
- Stores historical data

#### 5. trend-analysis
- Tracks metrics over time
- Stores historical reports
- Enables trend visualization (future enhancement)

### Metrics Collected

- **Build Time**: Clean and incremental builds
- **Test Time**: Total test execution duration
- **Package Size**: Build output size
- **Binary Size**: Individual library sizes
- **Test Count**: Total number of tests
- **Test Success Rate**: Pass/fail ratio

### Scheduled Runs

Metrics are collected:
- On every push and PR
- Daily at 2 AM UTC (scheduled)
- On manual trigger

### Historical Data

Metrics history is stored in `.metrics-history/` (last 30 reports).

## Issue Management

**File**: `issue-management.yml`

### Purpose
Automates issue triaging, labeling, and feedback management.

### Jobs

#### 1. auto-label-issues
- Automatically labels new issues
- Detects bug/enhancement/documentation
- Identifies AI, automation, learning topics
- Estimates priority and difficulty
- Adds welcome message for first-time contributors

**Auto-detected Labels**:
- `bug`, `enhancement`, `documentation`
- `testing`, `performance`, `security`
- `ai`, `automation`, `learning`
- `priority: high/medium/low`
- `difficulty: easy/hard`

#### 2. categorize-feedback
- Categorizes issues by type
- Adds category comments
- Enables better tracking and filtering

#### 3. weekly-report
- Generates weekly issue statistics
- Categorizes issues by type
- Shows open/closed counts
- Saves reports as artifacts

**Report Contents**:
- Total issues opened/closed
- Issues by category
- Currently open issues
- Trends and patterns

#### 4. stale-issues
- Marks inactive issues as stale after 60 days
- Closes stale issues after 14 days
- Exempts labeled issues (keep-open, security, critical)
- Sends notification comments

#### 5. ai-feedback-analysis
- Placeholder for future AI integration
- Sentiment analysis (planned)
- Duplicate detection (planned)
- Auto-assignment (planned)

### Usage

Runs automatically on:
- Issue creation/editing
- Issue comments
- Weekly schedule (Mondays at 9 AM UTC)
- Manual trigger

## Dependency Management

**File**: `.github/dependabot.yml`

### Purpose
Automates dependency updates and security vulnerability detection.

### Configuration

#### Swift Package Manager
- Weekly updates on Monday at 9 AM UTC
- Groups minor/patch updates together
- Security updates created individually
- Maximum 10 open PRs

#### GitHub Actions
- Weekly updates on Monday at 9 AM UTC
- Groups all action updates together
- Maximum 5 open PRs

### Labels
Dependabot PRs are labeled with:
- `dependencies`
- `swift` or `github-actions`
- `automated`

### Security Updates

Dependabot automatically creates PRs for:
- Vulnerable dependencies
- Security advisories
- CVE disclosures

**Enable in GitHub**:
Settings > Code security and analysis > Dependabot security updates

## Configuration

### Repository Settings

Important repository settings that must be enabled for full workflow functionality:

#### Security Features

Go to **Settings > Code security and analysis**:

1. **✅ Dependency Graph** (Required for dependency-review workflow)
   - Enables dependency tracking and vulnerability detection
   - Required by the `actions/dependency-review-action` in security.yml
   - **Important**: The workflow will run but skip dependency review if not enabled
   
2. **✅ Dependabot Alerts** (Recommended)
   - Automatically alerts on vulnerable dependencies
   - Requires Dependency Graph to be enabled first
   
3. **✅ Dependabot Security Updates** (Recommended)
   - Automatically creates PRs to fix vulnerabilities
   - See `.github/dependabot.yml` for configuration
   
4. **✅ Secret Scanning** (Recommended for private repos)
   - Detects accidentally committed secrets
   - Automatically enabled for public repos

**Quick Setup Link**: https://github.com/bf56rrxbrs-crypto/Project-NeuralGate/settings/security_analysis

### Secrets Required

None required for basic functionality. Optional secrets:

- `CODECOV_TOKEN`: For private repo coverage uploads
- Deployment credentials (staging/production)
- Notification webhooks (Slack, Discord)

### Environment Variables

Set in workflow files or repository settings:

- `SWIFT_VERSION`: Swift version (default: 5.9)
- Deployment URLs and configurations

### Branch Protection

Recommended settings for `main` branch:

- ✅ Require status checks to pass
  - `build-and-test`
  - `quality-gate`
- ✅ Require branches to be up to date
- ✅ Require pull request reviews (1)
- ✅ Dismiss stale reviews
- ✅ Require linear history

## Troubleshooting

### Security Scanning Issues

**Issue**: Dependency Review fails with "Dependency review is not supported"
- **Cause**: Dependency Graph feature is not enabled in repository settings
- **Solution**: 
  1. Go to Settings > Code security and analysis
  2. Enable "Dependency graph"
  3. Re-run the workflow
- **Note**: The workflow is configured with `continue-on-error: true` so it won't block other checks
- **Reference**: https://github.com/bf56rrxbrs-crypto/Project-NeuralGate/settings/security_analysis

**Issue**: CodeQL analysis fails
- Check Swift build succeeds first
- Verify CodeQL action version is current
- Review build logs for compilation errors
- Ensure macOS runner has sufficient resources

**Issue**: Secret scanning not working
- Enable in repository settings for private repos
- Check if secrets match GitHub's patterns
- Review security alerts in the Security tab

### Build Failures

**Issue**: Swift build fails
- Check Swift version compatibility
- Clear SPM cache: `swift package clean`
- Verify Package.swift dependencies

**Issue**: Tests fail
- Review test logs in workflow artifacts
- Run tests locally: `swift test`
- Check for environment-specific issues

### Code Quality Issues

**Issue**: SwiftLint violations
- Review violations in workflow logs
- Run locally: `swiftlint lint`
- Fix violations or update `.swiftlint.yml`

**Issue**: SwiftFormat failures
- Run locally: `swiftformat --lint .`
- Auto-fix: `swiftformat .`
- Update `.swiftformat` for custom rules

### Deployment Issues

**Issue**: Staging deployment fails
- Check environment configuration
- Verify deployment secrets
- Review deployment logs

**Issue**: Release creation fails
- Ensure tag follows semantic versioning
- Check GitHub token permissions
- Verify changelog generation

### Metrics Collection

**Issue**: Metrics not collected
- Verify workflow triggers
- Check artifact upload/download
- Review scheduled job execution

**Issue**: Report generation fails
- Verify artifacts exist
- Check script permissions
- Review JSON parsing errors

### Issue Management

**Issue**: Auto-labeling not working
- Check issue content matches patterns
- Verify label names exist in repository
- Review workflow permissions

**Issue**: Stale bot too aggressive
- Adjust `days-before-stale` setting
- Add `keep-open` label to important issues
- Update exemption rules

## Best Practices

### For Developers

1. **Before Pushing**:
   - Run `swift build` locally
   - Run `swift test` locally
   - Run `swiftlint lint`
   - Run `swiftformat --lint .`

2. **For Pull Requests**:
   - Keep PRs focused and small
   - Write descriptive commit messages
   - Respond to automated feedback
   - Wait for all checks to pass

3. **For Releases**:
   - Use semantic versioning
   - Update CHANGELOG.md manually if needed
   - Tag from main branch
   - Verify production deployment

### For Maintainers

1. **Workflow Maintenance**:
   - Review weekly issue reports
   - Monitor metrics trends
   - Update dependencies regularly
   - Adjust stale bot settings as needed

2. **Security**:
   - Enable Dependabot security updates
   - Review security PRs promptly
   - Monitor vulnerability alerts
   - Keep actions up to date

3. **Performance**:
   - Monitor build times
   - Optimize slow tests
   - Cache dependencies effectively
   - Review metrics reports regularly

## Future Enhancements

Planned improvements:

1. **CI/CD**:
   - Parallel test execution
   - Test result dashboard
   - Performance regression detection
   - Matrix builds for multiple iOS versions

2. **Code Quality**:
   - Custom lint rules
   - Code complexity analysis
   - Duplicate code detection
   - Security scanning (Snyk, SonarQube)

3. **Deployment**:
   - Blue-green deployments
   - Canary releases
   - Automated rollback
   - App Store Connect integration

4. **Metrics**:
   - Grafana dashboards
   - Prometheus integration
   - APM integration
   - Custom performance tests

5. **Issue Management**:
   - AI-powered categorization
   - Sentiment analysis
   - Duplicate detection
   - Smart assignment

## Support

For questions or issues with workflows:

1. Check this documentation
2. Review workflow logs in GitHub Actions
3. Open an issue with the `ci` or `automation` label
4. Contact the maintainers

## Version History

- **v1.0.0** (2026-02-05): Initial implementation
  - CI/CD pipeline
  - Code quality checks
  - Deployment automation
  - Performance metrics
  - Issue management
  - Dependabot configuration

---

**Last Updated**: 2026-02-05  
**Maintained By**: Project NeuralGate Team
