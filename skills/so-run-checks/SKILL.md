---
name: so-run-checks
description: Run the snap-openstack CI checks locally (ruff, mypy, pytest, Go) and report with evidence. Use before declaring any snap-openstack change done.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Run the snap-openstack CI checks locally (ruff, mypy, pytest, Go) and report with evidence."
  tags: ["run", "checks", "snap-openstack"]
---

# snap-openstack: Run Checks

Repo: `git/snap-openstack` (run `just so-clone` first).

1. Python: `just so-lint`, `just so-types`, `just so-unit` (narrow with `just so-unit tests/unit/<path>`).
2. Go (only if `sunbeam-microcluster/` changed): `just so-go`.
3. YAML (manifests/workflows changed): `just so-validate-yaml`.
4. Report each command, its exit status, and failing output verbatim. Never claim green without output.
5. Fix lint with `cd git/snap-openstack/sunbeam-python && uvx --with tox-uv tox -e fmt`.

Functional tests need a real host and a built snap: do not run them unprompted.
