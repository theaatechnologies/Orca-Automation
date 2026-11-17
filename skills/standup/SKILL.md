---
name: standup
description: Summarise what changed in the target repo since yesterday as a short standup report. Use for daily standup, what changed, or activity summary requests.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Summarise what changed in the target repo since yesterday as a short standup report."
  tags: ["standup"]
---

# Standup

**Environment Detection (CRITICAL - Run this first):**

Detect where you're running to find the correct paths:

```bash
if [ -d /project/repos ]; then
    # Inside Workshop container
    REPO_DIR=$(ls -1 /project/repos | head -1)
    TARGET_REPO="/project/repos/$REPO_DIR"
    OUTPUT_DIR="/project/reports"
elif [ -d git ]; then
    # On host machine
    REPO_NAME=$(jq -r '.target_repo' config/config.json | cut -d/ -f2)
    TARGET_REPO="git/$REPO_NAME"
    OUTPUT_DIR="reports"
else
    echo "ERROR: Cannot find target repo" && exit 1
fi

mkdir -p "$OUTPUT_DIR"
```

**Workflow:**

1. Detect environment (use code above) to set TARGET_REPO and OUTPUT_DIR
2. `git -C "$TARGET_REPO" fetch -q && git -C "$TARGET_REPO" log --since="24 hours ago" --no-merges --format="%h %an %s" origin/HEAD`
3. Group by area (top-level directory touched) and by author
4. Output max 10 lines: Done / In progress (open branches with recent commits) / Risks (reverts, fixes, large diffs)
5. Save to `$OUTPUT_DIR/standup-$(date +%Y-%m-%d).md`
6. Read-only: never commit or push
