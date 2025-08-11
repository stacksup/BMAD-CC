# Contributing to BMAD-CC

Thank you for your interest in contributing to BMAD-CC! This guide will help you get started with contributing to the framework.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct:

- **Be respectful** - Treat everyone with respect
- **Be collaborative** - Work together to solve problems
- **Be inclusive** - Welcome newcomers and help them get started
- **Be constructive** - Provide helpful feedback
- **Be professional** - Keep discussions focused on the project

## How to Contribute

### Types of Contributions

We welcome various types of contributions:

- **Bug Reports** - Help us identify issues
- **Feature Requests** - Suggest new capabilities
- **Code Contributions** - Fix bugs or add features
- **Documentation** - Improve guides and references
- **Templates** - Share useful templates
- **Expansion Packs** - Create domain-specific extensions
- **Testing** - Help test new features

### Getting Started

1. **Fork the Repository**
```bash
# Fork on GitHub, then clone
git clone https://github.com/YOUR-USERNAME/bmad-cc.git
cd bmad-cc
```

2. **Create a Branch**
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

3. **Set Up Development Environment**
```bash
# Install dependencies
npm install

# Run tests
npm test

# Start development
npm run dev
```

4. **Make Your Changes**
- Follow coding standards
- Add tests for new features
- Update documentation
- Follow the no-fallback policy

5. **Submit Pull Request**
- Push to your fork
- Create PR to `main` branch
- Fill out PR template
- Wait for review

---

## Development Guidelines

### Project Structure

```
bmad-cc/
├── templates/          # All template files
│   ├── .claude/       # Claude Code integration
│   ├── docs/          # Documentation templates
│   └── data/          # Knowledge base
├── scripts/           # Installation scripts
├── docs/              # Project documentation
├── tests/             # Test files
└── examples/          # Example projects
```

### Coding Standards

#### PowerShell Scripts
```powershell
# Use consistent style
$ErrorActionPreference = "Stop"

# Clear function names
function Install-BMADComponent {
    param(
        [string]$Component,
        [string]$Path
    )
    
    # Implementation
}

# Proper error handling
try {
    # Code
} catch {
    Write-Error "Clear error message: $_"
    exit 1
}
```

#### Markdown Templates
```markdown
# Use clear headers
## Section Title

### Subsection
- Use bullet points for lists
- Keep lines under 120 characters
- Use code blocks with language hints

\`\`\`javascript
// Example code
\`\`\`
```

#### Agent Templates
```markdown
---
name: agent-name
color: blue
description: Clear description
tools: Read, Write, Edit
---

# Agent Title

## ROLE
Clear role definition...

## RESPONSIBILITIES
- Specific responsibility 1
- Specific responsibility 2
```

### Commit Messages

Follow conventional commits:

```bash
# Format
type(scope): description

# Examples
feat(agents): add new validation capability to QA agent
fix(docker): resolve port conflict in docker-compose
docs(readme): update installation instructions
chore(deps): update Task Master to v2.0
test(workflows): add tests for smart-cycle routing
```

Types:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Formatting
- `refactor` - Code restructuring
- `test` - Tests
- `chore` - Maintenance

### Testing

#### Running Tests
```bash
# All tests
npm test

# Specific suite
npm test -- --grep "agents"

# With coverage
npm test -- --coverage
```

#### Writing Tests
```javascript
describe('BMAD Component', () => {
  it('should perform expected behavior', () => {
    // Arrange
    const input = setupTestData();
    
    // Act
    const result = performAction(input);
    
    // Assert
    expect(result).toBe(expected);
  });
});
```

### Documentation

#### Documentation Standards
- Write clear, concise explanations
- Include code examples
- Add diagrams where helpful
- Keep README under 300 lines
- Link to detailed guides

#### Updating Documentation
When making changes:
1. Update relevant guides in `docs/`
2. Update CHANGELOG.md
3. Update README if needed
4. Add examples if applicable

---

## Pull Request Process

### Before Submitting

- [ ] Code follows style guidelines
- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] No dummy data or fallback patterns
- [ ] Commit messages follow convention
- [ ] Branch is up to date with main

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [ ] Tests pass
- [ ] Manual testing performed

## Screenshots (if applicable)

## Checklist
- [ ] No-fallback policy followed
- [ ] Documentation updated
- [ ] Tests added/updated
```

### Review Process

1. **Automated Checks** - CI runs tests
2. **Code Review** - Maintainer reviews code
3. **Testing** - Manual testing if needed
4. **Feedback** - Address review comments
5. **Approval** - Get approval from maintainer
6. **Merge** - Maintainer merges PR

---

## Creating Expansion Packs

### Pack Structure

```
expansion-pack-name/
├── manifest.yaml
├── agents/
│   └── specialist.md
├── workflows/
│   └── domain-workflow.md
├── templates/
│   └── domain-template.md
├── tests/
│   └── pack.test.js
└── README.md
```

### Manifest Example

```yaml
name: healthcare-pack
version: 1.0.0
description: Healthcare domain expansion
author: Your Name
license: MIT

bmad-version: ">=2.1.0"

agents:
  - clinical-specialist
  - compliance-officer
  
workflows:
  - clinical-trial
  
templates:
  - patient-record
  - clinical-protocol
```

### Submission Process

1. Create pack following guidelines
2. Test with real projects
3. Document thoroughly
4. Submit PR with pack files
5. Include example usage

---

## Reporting Issues

### Bug Reports

Use GitHub Issues with this template:

```markdown
**Describe the bug**
Clear description of the issue

**To Reproduce**
1. Step one
2. Step two
3. See error

**Expected behavior**
What should happen

**Screenshots**
If applicable

**Environment:**
- OS: [e.g., Windows 11]
- Claude Code version:
- Docker version:
- Node version:

**Additional context**
Any other relevant information
```

### Feature Requests

```markdown
**Is your feature request related to a problem?**
Description of the problem

**Describe the solution**
What you'd like to see

**Alternatives considered**
Other approaches

**Additional context**
Why this would be valuable
```

---

## Community

### Getting Help

- **Discord**: [Join our server](https://discord.gg/bmad-cc)
- **GitHub Discussions**: Ask questions
- **Stack Overflow**: Tag with `bmad-cc`

### Staying Updated

- Watch the repository for updates
- Join Discord for announcements
- Follow our blog for tutorials

### Recognition

Contributors are recognized in:
- CONTRIBUTORS.md file
- Release notes
- Discord community
- Annual contributor report

---

## Development Setup

### Required Tools

- Node.js 16+
- Docker Desktop
- Git
- PowerShell Core
- Text editor (VS Code recommended)

### Environment Setup

```bash
# Clone repository
git clone https://github.com/YOUR-USERNAME/bmad-cc.git

# Install dependencies
cd bmad-cc
npm install

# Set up pre-commit hooks
npm run setup-hooks

# Run tests
npm test

# Start development
npm run dev
```

### Testing Changes

```bash
# Test installation script
./scripts/setup.ps1 -ProjectDir ./test-project -ProjectType saas

# Test specific component
npm test -- --grep "component-name"

# Test in Docker
docker-compose -f docker-compose.test.yml up
```

---

## Release Process

### Version Numbering

We follow Semantic Versioning:
- **Major**: Breaking changes (3.0.0)
- **Minor**: New features (2.1.0)
- **Patch**: Bug fixes (2.0.1)

### Release Checklist

1. Update version in package.json
2. Update CHANGELOG.md
3. Run full test suite
4. Create release branch
5. Create GitHub release
6. Update documentation site
7. Announce on Discord

---

## Legal

### Contributor License Agreement

By contributing, you agree that:
- Your contributions are your original work
- You have the right to submit the work
- You grant us license to use your contributions
- Your contributions are provided "as is"

### License

BMAD-CC is MIT licensed. See LICENSE file for details.

---

## Thank You!

Your contributions make BMAD-CC better for everyone. Whether you're fixing a typo, adding a feature, or creating an expansion pack, every contribution matters.

**Happy Contributing! 🚀**

---

*Questions? Join our [Discord](https://discord.gg/bmad-cc) or open a [Discussion](https://github.com/YOUR-USERNAME/bmad-cc/discussions).*