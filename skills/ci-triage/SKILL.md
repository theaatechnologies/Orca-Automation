---
name: ci-triage
description: Diagnose a failing CI run or failing tests: find the first real error, classify it (flaky, env, real bug) and propose a fix. Use when given a CI log or failure.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Diagnose a failing CI run or failing tests: find the first real error, classify it (flaky, env, real bug) and ."
  tags: ["ci", "triage"]
---

# CI Failure Triage

1. Get the log (pasted, file, or `curl` the run log URL). Find the FIRST error, not the last: later errors are usually fallout.
2. Classify: flaky (passes on rerun, timing/network), environment (missing tool/version/permission), real (reproducible assertion/compile error).
3. Reproduce locally with the narrowest command (a single test or tox env). Show the command and output.
4. Propose the smallest fix, with file:line. For flaky tests say how to confirm (rerun N times).
5. Never claim fixed without the passing command output.
