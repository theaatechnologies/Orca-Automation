---
name: dependency-check
description: Check the target repo for outdated or risky dependencies and summarise upgrades. Use for dependency, vulnerability or upgrade checks.
---

# Dependency Check

1. Detect ecosystems from files: `pyproject.toml`/`uv.lock` (Python), `go.mod` (Go), `package.json` (Node).
2. Report outdated: Python `uv pip list --outdated` or read pinned versions; Go `go list -u -m all`; Node `npm outdated`. Run inside the workshop if host tools are missing.
3. Classify each: patch/minor/major, and security-relevant when a changelog or advisory says so.
4. Output: table (package, current, latest, type) and the top 3 upgrades worth doing now. Save to `reports/deps-<date>.md`.
5. Report only: do not edit lock files or open PRs unless asked.
