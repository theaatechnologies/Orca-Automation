---
name: evidence-based-verification
description: Use when claiming a task, fix or feature is complete. Demands raw terminal output as proof.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Use when claiming a task, fix or feature is complete."
  tags: ["testing", "verification", "evidence"]
---
# Evidence-Based Verification

## When to Use
- Before saying work is done, fixed or passing.

## Rules
- Never say "it works" or "it's fixed" without output.
- Show the exact command and its terminal output, pass/fail counts included.
- Truncate large logs to the exact passing or failing lines.
- Evidence precedes assertion. If a check could not run, say so; do not imply it passed.
- A passing check only proves what it covers: name what was and was not covered.
- If the check ran in a different environment than the change (host vs workshop), say which.
