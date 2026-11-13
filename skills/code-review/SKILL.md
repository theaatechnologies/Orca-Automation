---
name: code-review
description: Review a diff or PR for correctness, tests, and risk. Use when asked to review code.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Review a diff or PR for correctness, tests, and risk."
  tags: ["code", "review"]
---

# Code Review

1. Read the diff (`git diff main...HEAD`).
2. Check: logic errors, missing tests, error handling, security (secrets, injection), breaking changes.
3. Output findings ordered by severity, each with file:line and a concrete suggested fix.
4. Skip style nits that the linter already covers.
