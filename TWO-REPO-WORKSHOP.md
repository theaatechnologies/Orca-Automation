# Two-Repo Workshop Implementation

## Goal

Workshop container with:
- **snap-openstack** (GitHub) mounted
- **sunbeam-charms** (OpenDev) mounted  
- opencode configured inside
- All skills and automations run INSIDE container

## Architecture

```
Host Machine
  ↓
  just launch-workshop
  ↓
┌─────────────────────────────────────────┐
│ WORKSHOP CONTAINER (Ubuntu 24.04)       │
│                                         │
│  /project/ (mounted from host)          │
│    ├── .opencode/skills/ (24 skills)   │
│    ├── repos/                           │
│    │   ├── snap-openstack/              │
│    │   └── sunbeam-charms/              │
│    ├── reports/                         │
│    └── reviews/                         │
│                                         │
│  opencode 1.19.5 (installed)            │
│  just, git, jq (installed)              │
│                                         │
│  Automations execute HERE               │
│  Skills run HERE                        │
└─────────────────────────────────────────┘
```

## Changes Made

### 1. `.workshop/setup-hook.sh`
- Clones **both** repos inside container:
  - `https://github.com/canonical/snap-openstack`
  - `https://opendev.org/openstack/sunbeam-charms`
- Both at `/project/repos/`

### 2. `Justfile` (automations-install)
- Checks workshop is running before registering
- Wraps prompts to execute inside container
- Skills know about both repos

### 3. Skills (Updated Next)
Need to update to work with both repos:
```bash
# In skills:
SNAP_OPENSTACK="/project/repos/snap-openstack"
SUNBEAM_CHARMS="/project/repos/sunbeam-charms"
```

## Team Member Setup

```bash
# Prerequisites (one-time)
sudo apt install -y git jq
sudo snap install --classic workshop
sudo snap install lxd
sudo usermod -aG lxd $USER && newgrp lxd
lxd init --auto

# Setup (one command)
git clone -b orca-automation-workshop https://github.com/theaatechnologies/Orca-Automation
cd Orca-Automation
just launch-workshop

# This now:
# 1. Creates Ubuntu 24.04 container
# 2. Installs opencode inside
# 3. Clones snap-openstack inside
# 4. Clones sunbeam-charms inside
# 5. Links 24 skills

# Register automations (run inside container)
just automations-install
```

## What Happens When Automation Runs

```
Orca (host) triggers automation
  ↓
Prompt tells agent: "cd /project && opencode ..."
  ↓
Agent starts in workshop container
  ↓
Skills execute inside container
  ↓
Access both repos:
  - /project/repos/snap-openstack
  - /project/repos/sunbeam-charms
  ↓
Write reports to /project/reports/
  (visible on host at ~/Orca-Automation/reports/)
```

## Benefits

✅ **Isolated:** Everything inside container, can't affect host  
✅ **Reproducible:** Every team member gets identical environment  
✅ **Two repos:** Can analyze both openstack and sunbeam-charms  
✅ **Clean:** Host only needs workshop+lxd, nothing else  

## Testing

```bash
# Enter workshop
workshop shell automation

# Inside:
ls /project/repos/
# snap-openstack/  sunbeam-charms/

cd /project/repos/snap-openstack
git log -3

cd /project/repos/sunbeam-charms  
git log -3

# Test skill
opencode "Use standup skill on both repos"
exit
```

## Status

🔄 **In Progress** - Implemented:
- ✅ Two repos clone in setup-hook.sh
- ✅ Automations-install checks workshop running
- ✅ Prompts wrapped for container execution

🔜 **TODO:**
- Update skills to handle both repos
- Test automation runs inside container
- Update README with two-repo setup

## Goal One-Liner

**Workshop container with snap-openstack + sunbeam-charms repos, opencode configured inside, all automations run in the isolated container - team runs `just launch-workshop` and everything executes inside.**
