---
name: issue
description: Use when handed a GitHub issue or bug and asked to resolve it end to end into a reviewed pull request inside an isolated worktree.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Use when handed a GitHub issue or bug and asked to resolve it end to end into a reviewed pull request inside a."
  tags: ["issue", "pr", "worktree", "review"]
---
# Issue

Drives an issue to a PR with no unresolved review comments, stopping only for genuine blocking questions. Work happens in a `just worktree` sandbox with the interactive `dev` agent (`just agent`). Commit, PR, review and verification conventions live in `commit-hygiene`, `pull-request-standards`, `code-review-behavior` and `evidence-based-verification`.

## Workflow
1. **Read and investigate.** Fetch the issue and linked items (`gh issue view` if `gh` exists, else the public API). Identify the target repo under `git/`. Map relevant files with grep; never open files speculatively.
2. **Propose a fix.** Minimal correct change: what, where, why. No scope beyond the issue.
3. **Classify scope.** Substantial (new behaviour, cross-file, config/API surface, anything uncertain) gets two full review passes. Nit (typo, wording, obvious one-line fix, doc-only) skips the plan review and gets one reviewer on the diff. State the classification; never skip a pass silently.
4. **Plan review (substantial).** Run at least two `@reviewer` subagents in parallel with different lenses (correctness, maintainability, security, tests). Incorporate every substantive point.
5. **Write the plan** to `reports/issue-<n>-plan.md`: files, function-level changes, acceptance criteria, minimal diff.
6. **Implement in a worktree.** `just worktree <repo> issue-<n>`. Never on the main checkout. Follow `code-quality`. Verify with the repo's own lint and test targets and show the output.
7. **Implementation review.** `@reviewer` subagents against the real `git diff` plus the plan; iterate until none raises a new concern, re-running verification after each fix.
8. **Commit and PR.** Commit per `commit-hygiene`. Ask the human before `git push`. Open the PR per `pull-request-standards` with `Fixes #<n>`.
9. **Iterate** on review comments until none remain and CI is green. Do not merge unless told to.

## Non-negotiable
- No contextual comments in code (no TODO, no "per issue #n").
- Minimal changes: untouched lines stay untouched.
- Reviewers run in parallel.
- Never push, merge, tag or release without explicit human approval.
