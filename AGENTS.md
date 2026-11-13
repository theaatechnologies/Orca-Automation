# Orca Automation Workshop - Agent Instructions

> Agents MUST update this file when they change structure, Justfile recipes, skills or automations.

## Overview
Kit of opencode skills and scheduled Orca automations for day-to-day team tasks against a
configurable target repo (`config/config.json` `target_repo`). `just` is the single entrypoint;
`automations/*.json` define scheduled runs; an optional isolated Workshop container runs builds and tests.

## Layout
```
Justfile, just/   entrypoint and recipe modules: check, worktree, upgrade, snap-openstack
skills/           agent skills, one dir each with SKILL.md (source of truth)
.agents/skills, .opencode/skills   symlinks to skills/ so agents find them
.opencode/agents/ dev (interactive), reviewer and security-auditor (read-only subagents)
opencode.json     permission policy: deny push/commit/tag/merge/release/sudo, deny secret reads
automations/      scheduled Orca automations (JSON), registered by `just automations-install`
scripts/          gates: check-secrets/skills/automations (py), check-just-shell.sh, safe-arg.py, test-gates.sh
config/example/   templates; config/config.json is local and gitignored
examples/sample-app/  Go + Node sample used by `just test` and the release scripts
docs/             architecture, setup, agents, automations, security, troubleshooting
git/, reports/, .state/  cloned repos, outputs, upgrade state (all gitignored)
reviews/          saved draft reviews
```

## Runbook
```bash
just doctor            # verify host (and warn about credential traps)
just setup             # no containers: config, opencode, skills, automations
just check             # ALL gates: secrets, config, skills, automations, shellcheck. Run before every push
just test-gates        # prove the gates reject bad input
just agent             # interactive dev agent; just worktree <repo> <name> for an isolated branch
just target-clone      # clone target_repo into git/
just so-check          # snap-openstack lint + mypy + unit + Go (auto-starts the workshop)
just check-upgrade     # read-only; `just upgrade` only with the user's consent
```

## Invariants
1. **Evidence before assertion.** Never claim a check passed without its output (skill `evidence-based-verification`). Say which environment ran it.
2. **Agents never push, merge, tag, release or force-push.** `opencode.json` denies it for the default agent; `dev` asks the human for every push. `just release` is human-only.
3. **Work in a worktree.** Implementation happens via `just worktree`, never on the main checkout of a target repo.
4. **Read-only automations.** Every automation prompt carries a guard and names a `reports/` or `reviews/` output; `just check-automations` enforces it.
5. **No secrets.** Never commit or print a token, key or `.env`. Reports name file and line, never the value. `GITHUB_TOKEN`/`GH_TOKEN` must not be set.
6. **Validate inputs.** Anything reaching a shell, path or URL goes through `scripts/safe-arg.py` or an equivalent allow-list.
7. **Gates must be able to fail.** Changing a gate means adding a negative case to `scripts/test-gates.sh`.
8. **Recipes pass shellcheck.** After editing a recipe: `just --list` parses and `just check-shell` is clean. In `{{in_ws}} '...'` payloads, never use an apostrophe.
9. **Pin and least-privilege CI.** Actions pinned to commit SHAs, `permissions: contents: read`, `persist-credentials: false`; `uvx zizmor .github/workflows/` must be clean.
10. **Keep this file true.** Update it with any structure, recipe, skill or automation change.

## What an agent may and may not do

| Action | Status |
|---|---|
| `just check*`, `test-gates`, `doctor`, `skills`, `automations`, `so-lint/types/unit/go`, `so-diff` | Safe, read-only or local build. |
| `just target-clone`, `so-clone` | Clones or fast-forwards `git/<repo>`. Safe. |
| `just worktree`, `worktree-clean` | Creates or removes worktrees under `git/`; clean refuses dirty or unmerged ones. |
| `just setup`, `skills-install`, `automations-install` | Writes symlinks and registers disabled automations. Fine; ask before `ENABLE=1`. |
| `just upgrade` | Fast-forwards this repo. Only after explicit consent. |
| `just release*`, `git push/tag/merge`, `gh pr merge/review`, `gh release` | Humans only. Denied for agents. |
| `just cleanup`, `workshop remove`, `lxc delete`, `snap remove` | Denied. Ask the user. |

## Skills
`standup`, `pr-triage`, `dependency-check`, `security-review`, `repo-analysis`, `bug-triage`,
`ci-triage`, `code-review`, `code-review-behavior`, `commit-hygiene`, `pull-request-standards`,
`code-quality`, `evidence-based-verification`, `issue`, `run-tests`, `release-notes`,
`weekly-release`, `kit-maintainer`, `upgrade-manager`, and for snap-openstack:
`so-run-checks`, `so-pr-review`, `so-manifest-update`, `so-bug-triage`, `so-add-feature`.
Automations: `automations/` (see `docs/automations.md`).
