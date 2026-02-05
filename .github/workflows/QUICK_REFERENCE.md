# GitHub Actions Workflows - Quick Reference

## Workflow Overview

| Workflow | File | Triggers | Purpose |
|----------|------|----------|---------|
| **CI/CD Pipeline** | `ci-cd.yml` | Push, PR | Build, test, coverage |
| **Code Quality** | `code-quality.yml` | Push, PR | Linting, formatting |
| **Security Scanning** | `security.yml` | Push, PR, Schedule | CodeQL, dependencies |
| **Deployment** | `deployment.yml` | Push, Tags | Deploy to environments |
| **Performance Metrics** | `metrics.yml` | Push, PR, Schedule | Build/test metrics |
| **Issue Management** | `issue-management.yml` | Issues, Schedule | Auto-label, reports |
| **Reusable Build** | `reusable-build.yml` | Called by others | Common build tasks |

## Quick Commands

### Trigger Manual Workflow
```bash
# Via GitHub UI: Actions tab → Select workflow → Run workflow
# Or using GitHub CLI:
gh workflow run ci-cd.yml
gh workflow run metrics.yml
gh workflow run deployment.yml --field environment=staging
```

### Check Workflow Status
```bash
gh run list --workflow=ci-cd.yml
gh run view <run-id>
gh run watch <run-id>
```

### Create a Release
```bash
# Tag and push to trigger deployment
git tag v1.0.0
git push origin v1.0.0

# This will:
# - Build release artifacts
# - Deploy to production
# - Create GitHub release
# - Update CHANGELOG.md
```

## Workflow Triggers

### CI/CD Pipeline
- ✅ Push to `main`, `develop`
- ✅ Pull requests to `main`, `develop`
- ✅ Manual dispatch

### Code Quality
- ✅ Push to `main`, `develop`
- ✅ Pull requests to `main`, `develop`
- ✅ Manual dispatch

### Security Scanning
- ✅ Push to `main`, `develop`
- ✅ Pull requests to `main`, `develop`
- ✅ Weekly schedule (Monday 3 AM UTC)
- ✅ Manual dispatch

### Deployment
- ✅ Push to `main` (staging)
- ✅ Push to `develop` (staging)
- ✅ Version tags `v*.*.*` (production)
- ✅ Manual dispatch with environment selection

### Performance Metrics
- ✅ Push to `main`, `develop`
- ✅ Pull requests to `main`, `develop`
- ✅ Daily schedule (2 AM UTC)
- ✅ Manual dispatch

### Issue Management
- ✅ Issue opened/labeled/edited
- ✅ Issue comments
- ✅ Weekly schedule (Monday 9 AM UTC)
- ✅ Manual dispatch

## Common Tasks

### Run Tests Locally
```bash
swift test
swift test --enable-code-coverage
```

### Check Code Quality Locally
```bash
# Install tools
brew install swiftlint swiftformat

# Run linting
swiftlint lint

# Check formatting
swiftformat --lint .

# Auto-fix formatting
swiftformat .
```

### Build Locally
```bash
# Debug build
swift build

# Release build
swift build -c release

# Clean build
swift package clean
swift build
```

### View Workflow Artifacts
```bash
# List artifacts
gh run view <run-id> --log

# Download artifacts
gh run download <run-id>
```

## Environment Configuration

### Required Secrets
None required for basic functionality.

### Optional Secrets
- `CODECOV_TOKEN` - For private repo coverage
- Deployment credentials (environment-specific)
- Notification webhooks (Slack, Discord)

### Repository Settings
1. **Actions** → Enable workflows
2. **Branches** → Protect `main` branch
3. **Environments** → Configure `staging` and `production`
4. **Code security** → Enable Dependabot

## Status Badges

Add to your README.md:

```markdown
[![CI/CD](https://github.com/bf56rrxbrs-crypto/Project-NeuralGate/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/bf56rrxbrs-crypto/Project-NeuralGate/actions/workflows/ci-cd.yml)
[![Code Quality](https://github.com/bf56rrxbrs-crypto/Project-NeuralGate/actions/workflows/code-quality.yml/badge.svg)](https://github.com/bf56rrxbrs-crypto/Project-NeuralGate/actions/workflows/code-quality.yml)
[![Security](https://github.com/bf56rrxbrs-crypto/Project-NeuralGate/actions/workflows/security.yml/badge.svg)](https://github.com/bf56rrxbrs-crypto/Project-NeuralGate/actions/workflows/security.yml)
```

## Monitoring

### Check Workflow Health
```bash
# List recent runs
gh run list --limit 10

# View failed runs
gh run list --status failure

# Re-run failed workflow
gh run rerun <run-id>
```

### View Metrics
- Check workflow run summaries in GitHub Actions
- Download metrics reports from artifacts
- Review PR comments for automated reports

## Troubleshooting

### Build Fails
1. Check workflow logs
2. Reproduce locally: `swift build`
3. Clear cache: `swift package clean`
4. Check Swift version compatibility

### Tests Fail
1. Review test output in workflow
2. Run locally: `swift test`
3. Check for environment differences
4. Review test artifacts

### Linting Errors
1. Run locally: `swiftlint lint`
2. Auto-fix when possible
3. Update `.swiftlint.yml` if needed
4. Use `swiftlint autocorrect`

### Deployment Issues
1. Check environment configuration
2. Verify secrets are set
3. Review deployment logs
4. Check branch/tag names

## Best Practices

### For Developers
- ✅ Run tests locally before pushing
- ✅ Fix linting issues before creating PR
- ✅ Keep commits focused and atomic
- ✅ Write descriptive commit messages
- ✅ Wait for CI checks before merging

### For Maintainers
- ✅ Review weekly issue reports
- ✅ Monitor build performance metrics
- ✅ Keep dependencies updated
- ✅ Review security alerts promptly
- ✅ Maintain workflow documentation

## Getting Help

1. Check [Workflow Documentation](.github/workflows/README.md)
2. Review workflow logs in GitHub Actions
3. Search existing issues
4. Create new issue with `ci` or `automation` label

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Swift Package Manager](https://swift.org/package-manager/)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)
- [SwiftFormat Rules](https://github.com/nicklockwood/SwiftFormat/blob/master/Rules.md)

---

**Last Updated**: 2026-02-05  
**Version**: 1.0.0
