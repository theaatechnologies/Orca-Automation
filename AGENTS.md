# Orca Automation Workshop - Agent Instructions

> Agents MUST update this file when they change structure, Justfile recipes, or skills.

## Overview
Project workspace with automated testing and weekly releases, run in an isolated
Workshop container (`dev`). `just` is the single entrypoint; `orca.yaml` defines workflows.

## Layout
```
Justfile          entrypoint: setup, doctor, test, release, shell, agent, skills
orca.yaml         Orca workflow definitions (testing, review, weekly release)
.workshop/        Workshop environments (dev.yaml, test.yaml)
scripts/          run-tests.sh, generate-release-notes.sh, weekly-release.sh
just/             recipe modules (snap-openstack.just)
workflows/        agent workflows per target repo
git/              cloned target repos (gitignored)
skills/           agent skills, one dir each with SKILL.md
config/example/   config templates; config/config.json is local and gitignored
tests/            unit/ and integration/
```

## Runbook
```bash
just doctor     # verify host
just setup      # idempotent: doctor + local config + launch workshop
just test       # all tests inside the workshop (just test unit|integration)
just release-notes
just so-clone    # fetch canonical/snap-openstack into git/
just so-check    # lint + mypy + unit + Go checks on it
just release patch|minor|major
```

## Rules
1. Run tests via `just test` (workshop), not host toolchains, so results are reproducible.
2. Never claim tests pass without showing the command output (see skill `run-tests`).
3. `just release` tags and pushes: only run when the user explicitly asks.
4. Never commit secrets; `config/config.json` and `.env*` are gitignored.
5. Run `just doctor` before reporting an environment problem.
6. After editing a recipe, run `just --list` to confirm it still parses.

## Skills
See `skills/`: `run-tests`, `release-notes`, `weekly-release`, `code-review`,
and for snap-openstack: `so-run-checks`, `so-pr-review`, `so-manifest-update`,
`so-bug-triage`, `so-add-feature`. Workflows: `workflows/snap-openstack.yaml`.
Recipes: `just/snap-openstack.just`. Target repo lives in gitignored `git/`.
