---
name: pr-triage
description: Triage open pull requests of the target repo: size, risk, missing tests, who should review. Use when asked to triage or prioritise PRs.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Triage open pull requests of the target repo: size, risk, missing tests, who should review."
  tags: ["pr", "triage"]
---

# PR Triage

**Environment Detection (CRITICAL - Run this first):**

```bash
if [ -d /project/repos ]; then
    # Inside Workshop container
    REPO_DIR=$(ls -1 /project/repos | head -1)
    cd "/project/repos/$REPO_DIR"
    REPO_SLUG=$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')
    OUTPUT_DIR="/project/reports"
elif [ -d git ]; then
    # On host machine
    REPO_SLUG=$(jq -r '.target_repo' config/config.json)
    OUTPUT_DIR="reports"
else
    echo "ERROR: Cannot find target repo" && exit 1
fi

mkdir -p "$OUTPUT_DIR"
```

**Workflow:**

1. Detect environment (use code above) to set REPO_SLUG and OUTPUT_DIR
2. List open PRs: `gh pr list --repo "$REPO_SLUG" --json number,title,author,additions,deletions,updatedAt` (if gh exists), else `curl -s "https://api.github.com/repos/$REPO_SLUG/pulls"`
3. For each PR record: size (S<100, M<500, L), touches tests (yes/no), age, last activity
4. Rank: stale-but-ready first, then small/low-risk, then large. Flag PRs with no test changes
5. Output a table plus one-line recommendation per PR
6. Save to `$OUTPUT_DIR/pr-triage-$(date +%Y-%m-%d).md`
7. Do not comment on, approve or merge PRs. For a deep review of one PR use the `code-review` skill.
