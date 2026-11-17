# Orca Automation Workshop

Ready-made **opencode skills**, **scheduled Orca automations** and **quality and security gates** for
day-to-day team tasks: standups, PR triage, dependency and security scans, bug and CI triage,
code review, issue-to-PR work, release readiness. Point it at any repo; `canonical/snap-openstack`
is the worked example. Architecture and standards follow Canonical's `ck8s-dev` workspace.

## Quick Start (5 minutes)

### Prerequisites

```bash
# Ubuntu 24.04 or 22.04
sudo apt install -y git jq

# Make sure Orca code editor is installed and running
orca status  # Should show "runtimeReachable: true"

# Install Workshop (for reproducible container environment)
sudo snap install --classic workshop
sudo snap install lxd --channel=6/stable
sudo usermod -aG lxd $USER
newgrp lxd  # or logout/login
lxd init --auto
```

### Setup (one command)

```bash
git clone -b orca-automation-workshop https://github.com/theaatechnologies/Orca-Automation
cd Orca-Automation

# Optional: change target repo (default: canonical/snap-openstack)
nano config/example/config.json  # edit "target_repo"

# Launch workshop - installs everything in Ubuntu 24.04 container
just launch-workshop
```

**What this does:**
- Creates Ubuntu 24.04 container
- Installs opencode + just automatically
- Links 24 skills
- Clones your target repo inside
- Takes ~2-3 minutes first time, ~10 seconds after (ZFS snapshots)

### Register Automations

```bash
# Register (disabled by default)
just automations-install

# Or enable immediately
ENABLE=1 just automations-install
```

### Use It

```bash
# List what's available
just skills                      # 24 skills
just automations                 # 9 automations

# Run one manually
orca automations run --id <id>   # Get ID from `just automations`
cat reports/standup-*.md         # Reports appear here

# Test inside workshop
workshop shell automation
  cd /project
  opencode "Use standup skill"
  exit

# All gates
just check
```

---

## Alternative: Host-only Setup (no containers)

If you don't want Workshop containers, you can run on your host machine:

```bash
# Install opencode
INSTALL=1 just setup-opencode

# Setup on host
just setup

# Edit config and clone target
nano config/config.json
just target-clone

# Register automations
just automations-install
```

**Trade-off:** Faster setup, but not reproducible across teammates' machines.

---

## What's Inside

| Area | What |
|---|---|
| **Skills** (24, `skills/`) | reports (`standup`, `pr-triage`, `dependency-check`, `security-review`, `repo-analysis`); standards (`commit-hygiene`, `pull-request-standards`, `code-quality`, `code-review-behavior`, `evidence-based-verification`); workflows (`issue`, `bug-triage`, `ci-triage`, `code-review`, `run-tests`, `release-notes`, `weekly-release`); kit (`kit-maintainer`, `upgrade-manager`); snap-openstack examples (`so-*`) |
| **Automations** (9, `automations/`) | daily standup, PR triage, commit standards audit; weekly dependency check, security scan, kit health, release readiness; two snap-openstack examples |
| **Agents** (`.opencode/agents/`) | `dev` (interactive, push needs approval), `reviewer` and `security-auditor` (read-only subagents) |
| **Gates** (`just check`) | secret scan, JSON/YAML, skill frontmatter, automation schema, shellcheck over recipes; `just test-gates` proves each rejects bad input |
| **Workshop** (`.workshop/`) | Reproducible Ubuntu 24.04 container with opencode, skills, and target repo |

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

## Troubleshooting

**"workshop not installed"**
```bash
sudo snap install --classic workshop
```

**"lxd not initialized"**
```bash
lxd init --auto
```

**"permission denied" on lxd**
```bash
sudo usermod -aG lxd $USER
newgrp lxd
```

**"just command not found"**
Workshop installs it automatically. On host: `curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash`

**"Orca not running"**
```bash
# Open the Orca code editor
orca status  # should show runtimeReachable: true
```

## Add Your Own

Use the `kit-maintainer` skill, or: skill in `skills/<name>/SKILL.md` then `just skills-install`;
automation in `automations/<name>.json` then `just automations-install`; always finish with `just check`.
