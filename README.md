# Orca Automation Workshop

Ready-made **opencode skills** and **scheduled Orca automations** for day-to-day team tasks:
standups, PR triage, dependency checks, bug and CI triage, code review, release readiness.
Point it at any repo; `canonical/snap-openstack` is the worked example.

## Quick start

Needs [Orca](https://github.com/stablyai/orca) running and `just git jq` (`sudo apt install -y just git jq`).

```bash
INSTALL=1 just setup-opencode   # only if opencode is missing; logs you in
just setup                      # links skills, registers automations (disabled)
just target-clone               # clone target_repo from config/config.json
just skills                     # what agents can do
just automations                # what is scheduled
just agent                      # chat with opencode in this project
```

Enable schedules: `ENABLE=1 just automations-install` (or toggle in the Orca app).
Run one now: `orca automations run <id>`; reports land in `reports/`.

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

## Optional: isolated checks

`just so-check` (lint, mypy, unit, Go for snap-openstack) runs in an Ubuntu 24.04
[Workshop](https://documentation.ubuntu.com/workshop/) container that starts on demand
(needs `workshop` + `lxd`). `just test` does the same for the sample app.

## Add your own

- Skill: `skills/<name>/SKILL.md` (frontmatter `name`, `description`), then `just skills-install`.
- Automation: `automations/<name>.json` (name, trigger, time, provider, prompt), then `just automations-install`.
- Other target repo: set `target_repo` in `config/config.json`, run `just target-clone`.

Agents working here: read `AGENTS.md`.
