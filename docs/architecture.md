# Architecture

How the kit is layered and where each part lives. [← README](../README.md)

## Layers

| Layer | Where | Responsibility |
|---|---|---|
| 1 - Host | your machine | `just` recipes, Orca, opencode, your model credentials. Runs the scheduled automations. |
| 2 - Workshop container (`dev`, optional) | LXD container | Ubuntu 24.04 with Go, Node and uv. Runs builds and tests (`just so-*`, `just test`) so results match upstream CI. Started on demand. |
| Target repo | `git/<name>` (gitignored) | The repository the skills and automations work on, set by `target_repo` in `config/config.json`. |

```
 Orca (scheduler) --orca automations run--> opencode (agent: build, default)
                                                |  reads skills/ via .agents/skills, .opencode/skills
                                                |  obeys opencode.json permissions
                                                v
        just recipes ---(workshop exec)---> container: tox / make / pytest
                                                |
                       reports/ and reviews/ <--+   (outputs; gitignored / drafts)
```

Interactive work uses `just agent` (the `dev` agent) inside a `just worktree` sandbox.

## Repository layout

| Path | Contents |
|---|---|
| `Justfile`, `just/` | Entrypoint and recipe modules: `check`, `worktree`, `upgrade`, `snap-openstack`. `just --list` shows all. |
| `skills/` | Agent skills (source of truth). Linked into `.agents/skills` and `.opencode/skills` by `just skills-install`. |
| `automations/` | Scheduled automations as JSON, registered with `orca automations create` (disabled by default). |
| `.opencode/agents/`, `opencode.json` | Agent definitions and the permission policy (see [Agents](agents.md)). |
| `scripts/` | Quality and security gates (`check-*.py`, `check-just-shell.sh`, `test-gates.sh`, `safe-arg.py`) and the sample-app scripts. |
| `config/` | `example/` templates are tracked; `config.json` is local and gitignored. |
| `examples/sample-app/` | Small Go + Node app used to exercise `just test` and the release flow. |
| `.github/` | CI: `lint.yml` (gates), `security.yml` (zizmor, secret scan), `dependabot.yml`. |
| `reports/`, `reviews/` | Automation outputs. `reports/` is gitignored; `reviews/` holds saved draft reviews. |
| `.state/` | Upgrade-check state (mode 0700, gitignored). |
| `AGENTS.md` | Contract for agents working here. |
