# Quick Start Guide - Automated Testing & Release

This guide will help you get started with the automated testing and release workflow.

## 🚀 1. Verify Setup

```bash
# Navigate to project
cd /home/think/orca/projects/My-app

# Check Workshop is working
workshop list

# Check Orca is running
orca status
```

## 🧪 2. Run Tests Locally

### Option A: Run in Workshop (Recommended)

```bash
# Run all tests in isolated environment
workshop shell dev -- ./scripts/run-tests.sh all

# Run only unit tests
workshop shell dev -- ./scripts/run-tests.sh unit

# Run only integration tests
workshop shell dev -- ./scripts/run-tests.sh integration
```

### Option B: Run on Host

```bash
# Go tests
go test ./... -v -cover

# Node tests
npm install
npm test
```

## 📝 3. Test the Release Notes Generator

```bash
# Make some commits first
git add .
git commit -m "feat: add automated testing framework"
git commit -m "feat: add release automation"
git commit -m "docs: add comprehensive README"

# Generate release notes
./scripts/generate-release-notes.sh
```

This will create `RELEASE_NOTES.md` with AI-generated content.

## 🎉 4. Perform a Test Release

```bash
# Run the weekly release script (patch version)
./scripts/weekly-release.sh patch

# Or specify release type
./scripts/weekly-release.sh minor
./scripts/weekly-release.sh major
```

The script will:
1. ✅ Run all tests
2. ✅ Generate release notes
3. ✅ Bump version
4. ✅ Update version files
5. ✅ Create git tag
6. ✅ Push to remote (with confirmation)
7. ✅ Create GitHub release (optional)

## 🔄 5. Set Up GitHub Actions (CI/CD)

### Prerequisites

1. Push your code to GitHub:
   ```bash
   git remote add origin https://github.com/your-username/my-app.git
   git push -u origin main
   ```

2. The GitHub Actions workflow (`.github/workflows/orca-automation.yml`) will automatically:
   - Run tests on every push
   - Review code on every PR
   - Create weekly releases every Friday

### Configure Secrets (Optional)

For notifications and advanced features:

```bash
# Go to GitHub repository settings
# Settings → Secrets and variables → Actions
# Add these secrets if needed:
# - SLACK_WEBHOOK_URL (for Slack notifications)
```

## 🤖 6. Use Orca for AI-Powered Tasks

### Generate Test Cases

```bash
# Ask Orca to generate test cases for a feature
orca agent run codex --task "Generate test cases for user authentication"
```

### Code Review

```bash
# Get AI code review
orca agent run claude --task "Review the code in main.go for best practices"
```

### Bug Analysis

```bash
# Analyze a bug
orca agent run claude --task "Analyze bug: application crashes on startup"
```

## 📊 7. View Test Results

After running tests:

```bash
# View test summary
cat test-results/summary.txt

# View Go coverage (HTML)
xdg-open test-results/go-coverage.html

# View Node coverage
npm test -- --coverage && xdg-open coverage/lcov-report/index.html
```

## 🎯 8. Weekly Workflow (Automated)

### What Happens Every Friday at 10 AM:

1. **GitHub Actions triggers** `weekly-release` workflow
2. **AI analyzes** all commits since last release
3. **Tests run** in isolated Workshop environment
4. **Release notes generated** by Claude AI
5. **Version bumped** automatically based on changes
6. **GitHub release created** with full changelog
7. **Team notified** (if configured)

### Manual Trigger:

```bash
# Trigger via GitHub UI:
# Actions → Orca-Powered CI/CD → Run workflow

# Or via CLI:
gh workflow run orca-automation.yml
```

## 🔧 9. Customize the Workflow

### Edit Orca Configuration

```bash
# Edit orca.yaml to customize:
nano orca.yaml

# - Change release schedule
# - Add more automation workflows
# - Configure AI agents
# - Set up notifications
```

### Edit GitHub Actions

```bash
# Edit CI/CD pipeline:
nano .github/workflows/orca-automation.yml

# - Modify test matrix
# - Add deployment steps
# - Configure environments
# - Add approval gates
```

## 🎓 10. Advanced Usage

### Create Custom Workshop Environments

```bash
# Create production-like environment
workshop init prod --sdks go,node
nano .workshop/prod.yaml

# Launch it
workshop launch prod
```

### Set Up Jira/Linear Integration

```bash
# Link issues to workspace
orca reference add --worktree my-app https://your-jira.atlassian.net/browse/TASK-123

# Orca will automatically:
# - Update ticket status
# - Add PR links
# - Create follow-up tasks
```

### Multi-Agent Workflows

```bash
# Example: Code generation + review
orca agent run opencode --task "implement-feature" --output code.go
orca agent run claude --task "review code.go" --output review.md
```

## 📈 11. Monitor & Maintain

### Check Workshop Health

```bash
# List all workshops
workshop list

# Get workshop info
workshop info dev

# Stop/restart if needed
workshop stop dev
workshop launch dev
```

### Check Orca Status

```bash
# Orca runtime status
orca status

# View agent sessions
ls ~/.config/orca/agent-session-attachments/

# View logs
tail -f ~/.config/orca/logs/*.log
```

### View CI/CD Status

```bash
# List recent runs
gh run list

# View specific run
gh run view <run-id>

# View logs
gh run view <run-id> --log
```

## 🎉 Success Metrics

After setup, you should see:

- ✅ Tests run automatically on every commit
- ✅ AI code reviews on every PR
- ✅ Working release notes generator
- ✅ Weekly releases published automatically
- ✅ Zero manual testing required
- ✅ Consistent, reproducible environments

## 🆘 Troubleshooting

### Tests Fail

```bash
# Check test output
./scripts/run-tests.sh all

# Check Workshop logs
workshop shell dev -- journalctl -xe

# Restart Workshop
workshop stop dev && workshop launch dev
```

### Orca Not Responding

```bash
# Check status
orca status

# Restart Orca
orca open
```

### GitHub Actions Fail

```bash
# View logs
gh run list --limit 5
gh run view <run-id> --log

# Check workflow syntax
cat .github/workflows/orca-automation.yml
```

## 🎊 You're All Set!

Your automated testing and release workflow is now configured. The manual pain of weekly testing is eliminated!

**Next Steps:**
1. Start developing features
2. Let AI run tests automatically
3. Review AI-generated release notes
4. Enjoy your Fridays without manual testing! 🎉

---

**Need Help?**
- Check the main [README.md](README.md)
- View Orca skills: `orca skills list`
- View Workshop docs: https://documentation.ubuntu.com/canonical-workshop/stable/
