---
name: so-bug-triage
description: Triage a snap-openstack bug report: locate the code, reproduce with a unit test, propose a fix. Use when given a Launchpad bug or failure log.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Triage a snap-openstack bug report: locate the code, reproduce with a unit test, propose a fix."
  tags: ["bug", "triage", "snap-openstack"]
---

# snap-openstack: Bug Triage

Bugs are tracked on Launchpad (`bugs.launchpad.net/snap-openstack`), not GitHub issues.

1. Extract: command run (`sunbeam ...`), error, snap/manifest version, log excerpt.
2. Locate: `grep -rn` the error text under `sunbeam-python/sunbeam/` (commands in `commands/`, plans in `steps/`, features in `features/`); Go daemon issues are in `sunbeam-microcluster/`.
3. Reproduce with a failing unit test in `sunbeam-python/tests/unit/` before changing code.
4. Fix minimally, run skill `so-run-checks`.
5. Commit message must reference the bug (`Closes-Bug: #<id>`) and commits must be signed.
