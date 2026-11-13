# Orca Automation Workshop

Ready-made **opencode skills**, **scheduled Orca automations** and **quality and security gates** for
day-to-day team tasks: standups, PR triage, dependency and security scans, bug and CI triage,
code review, issue-to-PR work, release readiness. Point it at any repo; `canonical/snap-openstack`
is the worked example. Architecture and standards follow Canonical's `ck8s-dev` workspace.

## Quick start

**You need:** [Orca](https://github.com/stablyai/orca) running, and `just git jq`
(`sudo apt install -y just git jq`). opencode is installed and logged in by step 1.

```bash
# 1. opencode (skip if `opencode providers list` already shows a provider)
INSTALL=1 just setup-opencode   # installs from opencode.ai if missing, then `opencode providers login`

# 2. one-command setup: links skills, registers the automations (disabled)
just setup

# 3. pick the repo the automations work on (default canonical/snap-openstack)
$EDITOR config/config.json      # set "target_repo": "owner/repo"
just target-clone

# 4. use it
just skills                     # list skills
just automations                # list scheduled automations
just agent                      # interactive dev agent (commits locally, asks before any push)
just check                      # all quality and security gates
```

**Enable schedules:** `ENABLE=1 just automations-install` (re-run is safe), or toggle in the Orca app.
**Run one now:** `orca automations run <id>` (ids from `just automations`). Reports land in `reports/`
(gitignored) and reviews in `reviews/`. A run takes 2-5 minutes and uses your opencode model provider.

**Heads-up:** unattended runs may only read inside this project; opencode auto-rejects other paths
such as `/tmp`. Put inputs under the project, for example `reports/`.

## What is inside

| Area | What |
|---|---|
| **Skills** (24, `skills/`) | reports (`standup`, `pr-triage`, `dependency-check`, `security-review`, `repo-analysis`); standards (`commit-hygiene`, `pull-request-standards`, `code-quality`, `code-review-behavior`, `evidence-based-verification`); workflows (`issue`, `bug-triage`, `ci-triage`, `code-review`, `run-tests`, `release-notes`, `weekly-release`); kit (`kit-maintainer`, `upgrade-manager`); snap-openstack examples (`so-*`) |
| **Automations** (9, `automations/`) | daily standup, PR triage, commit standards audit; weekly dependency check, security scan, kit health, release readiness; two snap-openstack examples |
| **Agents** (`.opencode/agents/`) | `dev` (interactive, push needs approval), `reviewer` and `security-auditor` (read-only subagents) |
| **Gates** (`just check`) | secret scan, JSON/YAML, skill frontmatter, automation schema, shellcheck over recipes; `just test-gates` proves each rejects bad input |
| **CI** (`.github/`) | `lint.yml` runs the gates; `security.yml` runs zizmor and the secret scan; actions pinned to SHAs, read-only token |
| **Worktrees** | `just worktree <repo> <name>`, `worktree-list`, `worktree-clean`: isolated branch per task |
| **Upgrades** | `just check-upgrade` (read-only) and `just upgrade` (asks first) |

Automations run with **opencode** through Orca. `opencode.json` denies `git push/commit/tag`, merges,
`sudo`, `rm -rf`, `just release` and secret-file reads, so unattended runs cannot change your repos.

## Documentation

| Page | Contents |
|---|---|
| [Architecture](docs/architecture.md) | layers, data flow, repository layout |
| [Setup](docs/setup.md) | requirements, the setup flow, upgrades, teardown |
| [Automations](docs/automations.md) | every automation, schedules, outputs, how to add one |
| [Agents](docs/agents.md) | agents, permission policy, skills |
| [Security](docs/security.md) | threat model, controls with proof, accepted risks |
| [Troubleshooting](docs/troubleshooting.md) | known traps and fixes |

`AGENTS.md` is the contract for agents working in this repo.

## Optional: isolated checks (needs `workshop` + `lxd`)

`just so-check` (snap-openstack lint, mypy, unit, Go), `just test` (sample app) and the release
readiness automation run in an Ubuntu 24.04 [Workshop](https://documentation.ubuntu.com/workshop/)
container that starts on demand. `just doctor-workshop` checks the prerequisites.

## Releasing

`just release-notes` writes `RELEASE_NOTES.md` using opencode. `just release patch|minor|major` runs
the gates, tags and pushes: **humans only**; agents are denied it and it refuses a dirty tree.

## Add your own

Use the `kit-maintainer` skill, or: skill in `skills/<name>/SKILL.md` then `just skills-install`;
automation in `automations/<name>.json` then `just automations-install`; always finish with `just check`.
