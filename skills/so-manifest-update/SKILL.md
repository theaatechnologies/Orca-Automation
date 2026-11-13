---
name: so-manifest-update
description: Update charm revisions or add a release manifest under manifests/ (2024.1, 2025.1, 2026.1). Use for manifest or charm revision changes.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Update charm revisions or add a release manifest under manifests/ (2024.1, 2025.1, 2026.1)."
  tags: ["manifest", "update", "snap-openstack"]
---

# snap-openstack: Manifest Update

1. Manifests live in `manifests/<release>/`. Upstream main has no scheduled revision-update workflow: check open PRs and recent `git log -- manifests` before duplicating work.
2. Manual bump: `tools/add_charm_revisions.py` (read its `--help` first).
3. Verify: `just so-validate-yaml` then `just so-unit` (manifest parsing tests).
4. Show the diff; revisions must change only for the intended charms.
