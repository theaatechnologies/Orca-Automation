---
name: bug-triage
description: Triage a bug report for any repo: extract facts, locate the code, write a failing test, propose a fix. Use when given a bug report or error.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Triage a bug report for any repo: extract facts, locate the code, write a failing test, propose a fix."
  tags: ["bug", "triage"]
---

# Bug Triage

1. Extract: command/action, expected vs actual, version, error text, logs.
2. Locate: grep the error text and trace the call path to the code.
3. Reproduce with a failing test before changing code. Show it failing.
4. Fix minimally, rerun, show it passing, then run the repo existing checks.
5. Summarise: root cause (one sentence), fix, test added, risk.
