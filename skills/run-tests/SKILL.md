---
name: run-tests
description: Run unit/integration tests in the Workshop and report evidence-based results. Use when asked to test, verify, or validate changes.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Run unit/integration tests in the Workshop and report evidence-based results."
  tags: ["run", "tests"]
---

# Run Tests

1. `just doctor` if the environment looks broken.
2. `just test unit`, then `just test integration` (or `just test` for all).
3. Report: command run, pass/fail counts, failing test names, coverage from `test-results/`.
4. On failure: quote the failing output, identify root cause, propose a fix. Never say "tests pass" without the output.
