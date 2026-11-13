---
name: upgrade-manager
description: Use when checking or applying updates to this kit, its skills and its automations. Never upgrades without consent.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Use when checking or applying updates to this kit, its skills and its automations."
  tags: ["upgrade", "maintenance"]
---
# Upgrade Manager

## When to Use
- Start of a session when `.state/last-upgrade-check` is missing or older than 24 hours.
- When the human asks to check or apply updates.

## Rules
- Check: `just check-upgrade` (read-only; writes `.state/upgrade-available.json`).
- If `update_available` is true, say once: "A newer version of this kit is available. Shall I upgrade it?" and continue the task.
- Apply: `just upgrade` only after an explicit yes. It fast-forwards, re-links skills, re-registers automations and runs `just check`.
- Report failed steps from the command output; never hide them.
