# Orca Automation Workshop

Ready-made **opencode skills** and **scheduled Orca automations** for day-to-day team tasks:
standups, PR triage, dependency checks, bug and CI triage, code review, release readiness.
Point it at any repo; `canonical/snap-openstack` is the worked example.

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
just agent                      # chat with opencode here (it sees all skills)
```

**Enable schedules:** `ENABLE=1 just automations-install` (re-run is safe), or toggle in the Orca app.
**Run one now:** `orca automations run <id>` (ids from `just automations`). Reports land in `reports/`
(gitignored) and reviews in `reviews/`. A run takes 2-5 minutes and uses your opencode model provider.

**Heads-up:** unattended runs may only read inside this project; opencode auto-rejects other
paths such as `/tmp`. Put inputs (logs, files) under the project, for example `reports/`.

`just setup` is idempotent and needs no containers or sudo. `just doctor` re-checks everything.

## Optional: isolated checks (needs `workshop` + `lxd`)

`just test` (sample app), `just so-check` (snap-openstack lint, mypy, unit, Go) and the
release-readiness automation run in an Ubuntu 24.04 [Workshop](https://documentation.ubuntu.com/workshop/)
container that starts on demand. Install once: `sudo snap install --classic workshop`,
`sudo snap install lxd --channel=6/stable`, `sudo usermod -aG lxd $USER` (then re-login).
`just doctor-workshop` checks these. If a run fails with `cannot exec command ... unexpected EOF`,
the container dropped: run `workshop restart dev` and retry.

## Releasing

`just release-notes` writes `RELEASE_NOTES.md` using opencode (plain commit list if opencode is
unavailable). `just release patch|minor|major` tags and pushes: **humans only**, the agents are
denied it, and it refuses to run with a dirty working tree.

## What is inside

| Skills (`skills/`) | Use |
|---|---|
| `standup`, `pr-triage`, `dependency-check` | daily/weekly reports on the target repo |
| `bug-triage`, `ci-triage`, `code-review` | investigate a bug, failing CI, or a diff |
| `run-tests`, `release-notes`, `weekly-release` | test and release flow |
| `so-*` (5) | snap-openstack example: checks, PR review, manifests, bugs, features |

| Automations (`automations/*.json`) | When |
|---|---|
| daily standup report, PR triage | weekdays |
| weekly dependency check, weekly release readiness | weekly |
| snap-openstack daily commit review, manifest check | weekdays / weekly |

Automations run with **opencode** through Orca. `opencode.json` denies `git push/commit/tag`,
`gh pr merge/review`, `rm -rf` and `just release`, so unattended runs are read-only on your repos.

## Add your own

- Skill: `skills/<name>/SKILL.md` (frontmatter `name`, `description`), then `just skills-install`.
- Automation: `automations/<name>.json` (name, trigger, time, provider, prompt), then `just automations-install`.
- Other target repo: set `target_repo` in `config/config.json`, run `just target-clone`.

Agents working here: read `AGENTS.md`.
