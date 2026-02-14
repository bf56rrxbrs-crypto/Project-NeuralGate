# How to Submit Feedback

Thank you for taking the time to provide feedback on Project-NeuralGate! Your input helps us make the project better for everyone.

## Types of Feedback

### 🐛 Bug Reports

If you've encountered a bug or unexpected behavior:

1. **Check Existing Issues**: Search [existing issues](https://github.com/bf56rrxbrs-crypto/Project-NeuralGate/issues) to see if it's already reported
2. **Use the Bug Report Template**: Click "New Issue" and select "Bug Report"
3. **Provide Details**:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs. actual behavior
   - iOS version and device model
   - Screenshots or screen recordings if applicable
   - Relevant error messages or logs

**Example**: "NeuralGateAgent crashes when processing empty string input on iOS 16.4"

### 💡 Feature Requests

Have an idea for a new feature or enhancement?

1. **Check Existing Requests**: Look through [open issues](https://github.com/bf56rrxbrs-crypto/Project-NeuralGate/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement) and [discussions](https://github.com/bf56rrxbrs-crypto/Project-NeuralGate/discussions)
2. **Use the Feature Request Template**: Select "Feature Request" when creating a new issue
3. **Describe Your Idea**:
   - What problem does it solve?
   - How would it work?
   - Why is it valuable for iPhone users?
   - Any alternative solutions you've considered
   - Mockups or examples if applicable

**Example**: "Add voice feedback option for task completion notifications"

### 📚 Documentation Feedback

Found unclear documentation or have suggestions for improvement?

1. **Specific Pages**: If feedback is about a specific document, open an issue referencing that file
2. **General Feedback**: Use GitHub Discussions for broader documentation topics
3. **Quick Fixes**: For typos or small corrections, feel free to submit a PR directly

**Areas we especially appreciate feedback on**:
- Setup instructions
- API documentation
- Usage examples
- Architecture explanations

### 🎨 User Experience Feedback

Share your experience using Project-NeuralGate:

1. **What's Working Well**: Tell us what you love!
2. **What's Confusing**: Help us identify pain points
3. **Workflow Improvements**: Suggest how we can make common tasks easier
4. **iPhone-Specific**: Share insights about iOS integration and user experience

**Use GitHub Discussions** for UX feedback and general impressions.

### 🔒 Security Vulnerabilities

**Important**: Do NOT report security issues publicly!

For security vulnerabilities:
1. Email the maintainers privately (contact info in README)
2. Provide detailed information about the vulnerability
3. Wait for acknowledgment before any public disclosure
4. We aim to respond within 48 hours

## Where to Submit Feedback

### GitHub Issues
**Best for**: Bug reports, feature requests, specific problems

- Navigate to [Issues](https://github.com/bf56rrxbrs-crypto/Project-NeuralGate/issues)
- Click "New Issue"
- Choose the appropriate template
- Fill out all required fields

### GitHub Discussions
**Best for**: Questions, ideas, general feedback, community discussions

- Navigate to [Discussions](https://github.com/bf56rrxbrs-crypto/Project-NeuralGate/discussions)
- Click "New Discussion"
- Choose a category:
  - **General**: General questions and discussions
  - **Ideas**: Feature ideas and brainstorming
  - **Q&A**: Technical questions
  - **Show and Tell**: Share what you've built with NeuralGate

### Pull Requests
**Best for**: Code contributions, documentation fixes

- See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines
- Fork the repository
- Make your changes
- Submit a PR with a clear description

## Feedback Guidelines

### Be Specific

❌ Bad: "The AI doesn't work"
✅ Good: "The AI decision engine returns incorrect priority when processing tasks with long descriptions (>500 characters)"

### Provide Context

Include:
- Your use case
- What you were trying to accomplish
- Your environment (iOS version, device, Xcode version)
- Steps you've already tried

### Be Constructive

- Focus on the issue, not the person
- Suggest solutions if possible
- Be respectful and professional
- Assume good intent

### One Topic Per Issue

- Keep issues focused on a single problem or feature
- If you have multiple items, create separate issues
- This makes tracking and resolution easier

## What Happens After You Submit?

### 1. Acknowledgment
- We aim to acknowledge all feedback within 3 business days
- You'll receive a response or label on your issue

### 2. Evaluation
- Maintainers will review and prioritize
- We may ask clarifying questions
- Your issue may be labeled (bug, enhancement, documentation, etc.)

### 3. Discussion
- Community members may provide input
- We may discuss implementation approaches
- Your participation in discussions is welcome!

### 4. Resolution
- Bug fixes are prioritized by severity
- Feature requests are evaluated against project roadmap
- We'll update the issue as work progresses
- You'll be notified when issues are resolved

## Priority Levels

### Critical 🔴
- Security vulnerabilities
- Data loss issues
- App crashes
- **Response time**: Within 24 hours

### High 🟠
- Major functionality broken
- Significant user experience issues
- Performance problems
- **Response time**: Within 3 days

### Medium 🟡
- Minor functionality issues
- Enhancement requests
- Documentation improvements
- **Response time**: Within 1 week

### Low 🟢
- Nice-to-have features
- Cosmetic issues
- Minor optimizations
- **Response time**: As time permits

## Feedback We're Especially Looking For

### Current Focus Areas

1. **iOS Integration Quality**
   - Siri integration experiences
   - Shortcuts functionality
   - Notification behavior
   - Battery and performance impact

2. **AI Decision Making**
   - Accuracy of task prioritization
   - Quality of workflow suggestions
   - Natural language understanding

3. **User Experience**
   - Setup and onboarding process
   - Daily usage workflows
   - Documentation clarity

4. **Real-World Use Cases**
   - How you're using NeuralGate
   - What workflows you've created
   - Problems you've solved

## Tips for Great Feedback

### Do ✅
- Search before posting
- Use templates
- Include reproduction steps
- Attach screenshots/logs
- Follow up on questions
- Be patient and respectful

### Don't ❌
- Post duplicate issues
- Demand immediate fixes
- Include unrelated topics in one issue
- Share private/sensitive information
- Bump issues excessively
- Be rude or dismissive

## Examples of Great Feedback

### Bug Report Example
```
**Title**: App crashes when scheduling recurring tasks for future dates

**Description**: When I try to schedule a recurring task more than 30 days in the future, 
the app crashes immediately after tapping "Save".

**Steps to Reproduce**:
1. Open NeuralGate app
2. Create a new task
3. Set it to repeat daily
4. Set start date to 45 days from today
5. Tap "Save"

**Expected**: Task should be saved and scheduled
**Actual**: App crashes with "Index out of range" error

**Environment**:
- iOS 16.4.1
- iPhone 14 Pro
- NeuralGate v1.2.0

**Logs**: [attached crash log]
**Screenshot**: [attached]
```

### Feature Request Example
```
**Title**: Add support for conditional workflow steps

**Problem**: Currently, workflows execute all steps sequentially. I need the ability 
to execute certain steps only if conditions are met (e.g., only send notification 
if task takes longer than expected).

**Proposed Solution**: Add conditional step types that evaluate expressions and 
branch workflow execution accordingly.

**Use Case**: I want to create a "Smart Morning Routine" workflow that:
1. Checks weather
2. If raining, notify to bring umbrella
3. If temperature < 50°F, suggest warm clothes
4. Always remind about calendar events

**Alternatives Considered**: 
- Creating multiple workflows (too complex)
- Using Shortcuts conditions (loses NeuralGate context)

**Benefit for iPhone Users**: Makes workflows more intelligent and reduces notification 
spam by only alerting when relevant.
```

## Thank You! 🎉

Every piece of feedback helps make Project-NeuralGate better. Whether you're reporting a bug, suggesting a feature, or sharing your experience, we appreciate you taking the time to help us improve.

---

**Questions about this process?** Open a discussion or check [CONTRIBUTING.md](CONTRIBUTING.md).
