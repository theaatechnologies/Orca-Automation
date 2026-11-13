---
name: so-pr-review
description: Review a snap-openstack PR or branch against the repo conventions (logging guide, ADRs, signed commits, tests). Use when asked to review a snap-openstack change.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Review a snap-openstack PR or branch against the repo conventions (logging guide, ADRs, signed commits, tests)."
  tags: ["pr", "review", "snap-openstack"]
---

# snap-openstack: PR Review

1. `just so-diff` for scope, `just so-signed` (shows Signed-off-by exactly; cryptographic signatures cannot be verified locally without allowed-signers, so confirm them on the PR page: unsigned commits fail upstream CI).
2. Read `docs/LOGGING_STYLE_GUIDE.md`; check new log calls (no f-strings, no redundant tracebacks).
3. Architectural change? It needs an ADR in `docs/adr/` (template: `adr-template.md`). Feature flags must follow `docs/FEATURE_GATES.md`.
4. Layout: new features go under `sunbeam-python/sunbeam/features/<name>/`, steps under `sunbeam/steps/`. Each behaviour change needs a test in `sunbeam-python/tests/unit/`.
5. Run skill `so-run-checks`.
6. Output findings by severity with file:line and a suggested fix. Draft only; do not post comments unless asked. Save the draft to `reviews/<sha>.md`.
