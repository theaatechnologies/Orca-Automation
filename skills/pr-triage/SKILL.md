---
name: pr-triage
description: Triage open pull requests of the target repo: size, risk, missing tests, who should review. Use when asked to triage or prioritise PRs.
---

# PR Triage

1. List open PRs: `gh pr list --json number,title,author,additions,deletions,updatedAt` if `gh` exists, else `curl -s https://api.github.com/repos/<owner>/<repo>/pulls` (public repos, unauthenticated).
2. For each PR record: size (S<100, M<500, L), touches tests (yes/no), age, last activity.
3. Rank: stale-but-ready first, then small/low-risk, then large. Flag PRs with no test changes.
4. Output a table plus one-line recommendation per PR. Save to `reports/pr-triage-<date>.md`.
5. Do not comment on, approve or merge PRs. For a deep review of one PR use the `code-review` skill.
