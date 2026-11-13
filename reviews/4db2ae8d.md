# Review draft: 4db2ae8d feat(pro): deploy the ubuntu-pro charm instead of ubuntu-advantage

Status: DRAFT, not posted. Skill: so-pr-review.

**Verdict:** approve, with one question and two nits.

## Evidence
- `just so-lint`: All checks passed.
- `just so-unit tests/unit/sunbeam/features/test_pro.py`: 14 passed.
- No remaining references to `ubuntu-advantage` or `ubuntu-advantage-channel` outside the new tests.
- No new log calls (logging guide n/a). No ADR needed (charm swap, not architecture).
- `Signed-off-by` present. Cryptographic signature not verifiable locally; confirm on the PR page.

## Findings
1. **Question (medium) - upgrade path.** The commit says there is no in-place migration (disable then re-enable pro). Nothing detects an existing `ubuntu-advantage` deployment, and `main.tf` changes the charm `name` under the same resource address, so a re-enable may plan a replacement or fail depending on the Juju provider (not tested). Suggest a release note, a warning in the enable step, or confirming provider behaviour.
2. **Nit (low) - feature.py:42.** `UBUNTU_PRO_CHANNEL` is read only by the test (checked against the Terraform default). Add a comment saying it exists to keep Python and Terraform in sync.
3. **Nit (low) - test_pro.py `TestTerraformPlan`.** Regex parsing of HCL is brittle if formatting changes; acceptable for now.

## Positive
- Application name and Terraform resource address preserved, so `disable pro` still works on old deployments.
- New tests cover the blocked-status error paths.
