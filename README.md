# My-App - Automated Testing & Release Workflow

> Powered by **Orca** AI orchestration + **Workshop** sandboxed environments

## 🎯 Overview

This project uses AI-powered automation to eliminate manual testing pain and streamline weekly releases:

- ✅ **Automated Testing**: Unit + Integration tests in isolated Workshop environments
- ✅ **AI-Generated Release Notes**: Claude analyzes commits and generates comprehensive release notes
- ✅ **Weekly Auto-Releases**: Scheduled releases every Friday with full test coverage
- ✅ **AI Code Review**: Automatic code review on every PR
- ✅ **Bug Analysis**: AI-powered bug analysis and test case generation

## 🚀 Quick Start

```bash
sudo apt install -y just git jq   # once
just setup                        # doctor + local config + launch workshop
just test                         # run all tests in the workshop
just agent                        # AI agent inside the workshop
just --list                       # everything else; `just skills` lists agent skills
```

Agents: read `AGENTS.md`. Skills live in `skills/`.

### Manual prerequisites (what `just doctor` checks)

```bash
# Install Workshop
sudo snap install --channel=6/stable lxd
sudo snap install --classic workshop

# Install Orca (if not already installed)
# Orca is already installed at ~/.config/orca/
```

### Running Tests

```bash
# Run all tests in Workshop environment
workshop shell dev -- ./scripts/run-tests.sh all

# Run only unit tests
workshop shell dev -- ./scripts/run-tests.sh unit

# Run only integration tests
workshop shell dev -- ./scripts/run-tests.sh integration
```

### Manual Release

```bash
# Generate release notes
./scripts/generate-release-notes.sh

# Or with specific tag
./scripts/generate-release-notes.sh v0.1.0
```

## 📁 Project Structure

```
My-app/
├── .github/
│   └── workflows/
│       └── orca-automation.yml    # CI/CD pipeline
├── .workshop/
│   └── dev.yaml                   # Workshop environment config
├── scripts/
│   ├── run-tests.sh              # Test automation script
│   └── generate-release-notes.sh # Release notes generator
├── tests/
│   ├── unit/                     # Unit tests
│   └── integration/              # Integration tests
├── main.go                       # Go application
├── main_test.go                  # Go tests
├── index.js                      # Node.js application
├── package.json                  # Node.js configuration
├── go.mod                        # Go modules
└── orca.yaml                     # Orca workflow configuration
```

## 🤖 AI-Powered Workflows

### 1. Continuous Testing

**Trigger**: Every commit and PR

**Process**:
1. Code is pushed to GitHub
2. GitHub Actions launches Workshop test environment
3. OpenCode AI agent runs unit and integration tests
4. Claude AI generates human-readable test report
5. Results posted as PR comment

### 2. Weekly Automated Release

**Trigger**: Every Friday at 10 AM UTC (or manual)

**Process**:
1. AI analyzes all commits since last release
2. Claude determines version bump (major/minor/patch)
3. AI generates comprehensive release notes
4. Version files are updated
5. Git tag is created
6. GitHub release is published
7. Team is notified

### 3. AI Code Review

**Trigger**: Every PR

**Process**:
1. PR is created
2. Claude AI agent performs code review
3. Analyzes code quality, potential bugs, best practices
4. Posts review comments on PR

### 4. Bug Analysis & Test Generation

**Trigger**: Issue labeled as "bug"

**Process**:
1. Claude analyzes the bug report
2. Codex generates regression test cases
3. PR is automatically created with new tests

## 📊 Testing Strategy

### Unit Tests

- **Go**: `go test ./... -v -cover`
- **JavaScript**: `npm test` (Jest with 80% coverage threshold)
- **Isolation**: Each test suite runs in Workshop container
- **Coverage**: 80% minimum threshold

### Integration Tests

- **Go**: Tagged with `//go:build integration`
- **JavaScript**: Located in `tests/integration/`
- **Environment**: Clean Workshop environment per test run
- **Data**: Uses test fixtures and mocks

### Test Reports

Test results are saved to `test-results/` directory:
- `go-coverage.out` - Go coverage report
- `go-coverage.html` - HTML coverage visualization
- `node-unit-tests.json` - Jest test results
- `summary.txt` - Overall test summary

## 📝 Release Notes Format

AI-generated release notes include:

- 🚀 **New Features**
- 🐛 **Bug Fixes**
- ⚡ **Performance Improvements**
- 📚 **Documentation**
- 🔧 **Maintenance**
- 💥 **Breaking Changes**
- 📦 **Dependencies**

Each item includes:
- Descriptive title
- Commit SHA
- PR number (if applicable)
- Contributor credit

## 🔄 Workshop Environments

### Development Environment (`dev`)

```yaml
name: dev
base: ubuntu@24.04
sdks:
  - name: opencode    # AI coding agent
  - name: go          # Go 1.27
    channel: "1.27"
  - name: node        # Node.js 24
    channel: "24"
```

**Usage**:
```bash
# Enter Workshop shell
workshop shell dev

# Launch background
workshop launch dev

# Stop Workshop
workshop stop dev
```

### Testing Environment (`test`)

Clean environment for running tests without dev tools.

### Staging Environment (`staging`)

Pre-release testing environment.

## ⚙️ Configuration

### Orca Configuration (`orca.yaml`)

Defines:
- Automation workflows
- AI agent roles
- Testing strategy
- Release configuration
- Notifications

### GitHub Actions (`.github/workflows/orca-automation.yml`)

Configured workflows:
- **test**: Runs on every push/PR
- **code-review**: AI review on PRs
- **weekly-release**: Scheduled weekly releases
- **analyze-bugs**: Auto-analysis of bug reports

## 🎮 Commands

### Testing

```bash
# Run all tests locally
./scripts/run-tests.sh all

# Run in Workshop
workshop shell dev -- ./scripts/run-tests.sh all

# Watch mode (JavaScript)
npm run test:watch
```

### Release Management

```bash
# Generate release notes
./scripts/generate-release-notes.sh

# Check Orca status
orca status

# View Orca workflows
cat orca.yaml
```

### Orca Operations

```bash
# List agent accounts
orca account list

# View available skills
orca skills list

# Run AI task
orca agent run claude --task "your-task"
```

## 📈 Metrics & Monitoring

### Test Coverage

- View Go coverage: Open `test-results/go-coverage.html`
- View JS coverage: Run `npm test -- --coverage`

### CI/CD Pipeline

- GitHub Actions: Check `.github/workflows/`
- Test results: Available as artifacts on each run
- Release history: GitHub Releases page

## 🔐 Security

- All tests run in isolated Workshop containers
- No privileged access required
- Sandboxed AI agent execution
- Secrets managed via GitHub Secrets

## 🛠️ Troubleshooting

### Tests failing in Workshop

```bash
# Check Workshop status
workshop list

# View Workshop logs
workshop shell dev -- journalctl -xe

# Restart Workshop
workshop stop dev
workshop launch dev
```

### AI agent issues

```bash
# Check Orca status
orca status

# View agent logs
ls ~/.config/orca/logs/

# Verify API connectivity
curl https://openrouter.ai/api/v1/models
```

### Release automation issues

```bash
# Test release notes generation locally
./scripts/generate-release-notes.sh

# Check GitHub Actions logs
gh run list
gh run view <run-id>
```

## 🎯 Pain Points Solved

### Before
- ❌ Manual testing every week (time-consuming)
- ❌ Inconsistent test environments
- ❌ Forgotten edge cases
- ❌ Manual release note compilation
- ❌ Human error in releases

### After
- ✅ Automated testing in isolated environments
- ✅ Consistent, reproducible test runs
- ✅ AI-generated comprehensive test cases
- ✅ Auto-generated release notes from commits
- ✅ Reliable, scheduled weekly releases

## 📚 Additional Resources

- [Workshop Documentation](https://documentation.ubuntu.com/canonical-workshop/stable/)
- [Orca Skills Guide](~/.config/orca/linux-orca-cli-shim/orca skills list)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

## 🤝 Contributing

1. Create feature branch
2. Make changes with tests
3. Push and create PR
4. AI will review your code
5. Tests run automatically
6. Merge when approved

## 📄 License

MIT

---

**Powered by Orca AI Orchestration + Workshop Sandboxed Environments**

*Automate your workflow, eliminate manual testing pain!*
