---
name: code-review-behavior
description: Use when reviewing a PR or addressing review comments. Focuses on logic, invariants and actionable feedback.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Use when reviewing a PR or addressing review comments."
  tags: ["review", "pr", "feedback"]
---
# Code Review Behavior

## When to Use
- Reviewing a pull request, or processing received review feedback.

## Providing review
- Direct, actionable, terse: "Use `foo` instead of `bar` to avoid a leak".
- Focus on logic, invariants and security. Leave style to linters.
- Rank findings by severity and cite `file:line`.
- Review a plan through different lenses in parallel (correctness, maintainability, security, tests) using the `@reviewer` subagent.

## Receiving review
- Never apply feedback blindly if it breaks an invariant.
- Verify technically first, then fix, rerun the checks and reply to close the thread.
