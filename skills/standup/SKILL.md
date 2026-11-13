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

Target repo: the one in `config/config.json` `target_repo` (`just target-clone` clones it to `git/<name>`).

1. `git -C git/<name> fetch -q && git -C git/<name> log --since="24 hours ago" --no-merges --format="%h %an %s" origin/HEAD`.
2. Group by area (top-level directory touched) and by author.
3. Output max 10 lines: Done / In progress (open branches with recent commits) / Risks (reverts, fixes, large diffs).
4. Save to `reports/standup-<date>.md`. Read-only: never commit or push.
