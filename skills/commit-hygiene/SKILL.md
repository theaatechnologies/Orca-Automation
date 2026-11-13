---
name: commit-hygiene
description: Use when writing git commits or planning git history. Defines atomic units, Conventional Commits and the 50/72 rule.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Use when writing git commits or planning git history."
  tags: ["commit", "git", "history"]
---
# Commit Hygiene

## When to Use
- Committing code, or rebasing/squashing history.

## Rules
- Conventional Commits: `<type>(<scope>): <subject>`. Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- Atomic, logical units: one reason to revert per commit.
- 50/72: subject at most 50 characters, body wrapped at 72.
- Imperative mood ("Add feature", not "Added feature").
- Forbidden: filler words, "wip", "fix tests", "address review".
- Explain why when it is not obvious, using technical facts only.
- Follow the target repo's own conventions first (for example snap-openstack requires `Signed-off-by` and a bug trailer such as `Closes-Bug: #<id>`).
- Never fabricate attribution: no `Co-authored-by` or `Generated-by` trailers unless a human asks for them.
- Agents commit only in a `just worktree` sandbox with the `dev` agent; never push without human approval.
