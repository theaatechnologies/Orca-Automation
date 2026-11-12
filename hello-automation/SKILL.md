---
name: hello-automation
description: >-
  Runs the team's hello world automation. Use this skill whenever the user asks
  to run the hello world automation, says "hello world", or wants to try the
  team automation example. Bundles the script so it runs identically on every
  teammate's machine.
---

# Hello Automation

Runs the team's shared hello world automation.

## Run it

Execute the bundled script with Python (no arguments needed):

```bash
python3 scripts/hello.py
```

The script prints `Hello world`, then greets the team member and notes that
this automation was created by devticks. Return that output to the user.

## Notes for teammates

- No dependencies beyond Python 3 (`python3`).
- To install: copy this whole `hello-automation/` folder into your skills
  directory (e.g. `~/.agents/skills/` or `~/.config/opencode/skills/`) and
  restart your session.
- To update an automation: edit `scripts/hello.py`, share the folder again
  (git repo, shared drive, or zip), and teammates re-copy it.
