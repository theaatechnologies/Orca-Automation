---
name: so-add-feature
description: Add or change a Sunbeam feature (sunbeam/features/*) following feature gates, tests and ADR rules. Use when implementing a new feature.
---

# snap-openstack: Add a Feature

1. Read `docs/FEATURE_GATES.md` and a similar feature under `sunbeam-python/sunbeam/features/` (e.g. `vault`, `dns`) as the template.
2. Check `docs/agents/specs` and `docs/agents/plans` for existing design/plan docs; for non-trivial work write spec then plan there first.
3. Implement, add unit tests, follow `docs/LOGGING_STYLE_GUIDE.md`.
4. Significant architecture decision: add an ADR in `docs/adr/`.
5. Run skill `so-run-checks`; keep commits small and signed.
