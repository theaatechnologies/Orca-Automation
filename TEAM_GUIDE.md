# Team Orca Agent — Setup & Usage Guide

## Overview

The **Orca-Automation** repo contains shared automation skills that every team member can use inside their Orca agent session. Skills are self-contained folders with a `SKILL.md` manifest and a `scripts/` directory. The `install.sh` script handles setup in one command.

**Repo:** https://github.com/theaatechnologies/Orca-Automation.git

---

## Available Skills

| Skill | What it does | Schedule |
|---|---|---|
| `hello-automation` | Prints a hello-world greeting | On demand |
| `ai-news-automation` | Summarizes top 3 AI & tech news from RSS feeds (TechCrunch AI, The Verge, MIT Tech Review) | Daily at 3:10 PM |

---

## Step-by-Step Setup

### Step 1 — Clone the repo

```bash
git clone https://github.com/theaatechnologies/Orca-Automation.git
cd Orca-Automation
```

If you already cloned it earlier, pull the latest:

```bash
cd Orca-Automation
git pull
```

### Step 2 — Run the installer

**To install skills only (no scheduled jobs):**

```bash
./install.sh
```

**To install skills AND set up the daily 3:10 PM cron job:**

```bash
./install.sh --cron
```

What `install.sh` does:
1. Copies every folder with a `SKILL.md` into `~/.agents/skills/`
2. Creates the `reports/` directory for log output
3. With `--cron`, adds a crontab entry for the AI news summary (skips if already present)

**Custom skills directory:** set `ORCA_SKILLS_DIR` to install to a different location (useful for testing):

```bash
ORCA_SKILLS_DIR=/tmp/test-skills ./install.sh
```

### Step 3 — Restart your Orca session

Orca only discovers new skills at startup. Close and reopen your Orca session after running `install.sh`.

### Step 4 — Verify the skills are loaded

In your Orca session, ask the agent to use a skill:

```
run hello world automation
```

or

```
summarize today's AI news
```

If the skill is installed correctly, Orca will recognize the request and execute the bundled script.

---

## Daily Workflow

### Getting the AI news summary

The summary runs automatically at **3:10 PM daily** if you set up cron (`--cron`). Output is appended to:

```
Orca-Automation/reports/ai_news_summary.log
```

You can also run it manually at any time:

```bash
python3 ai-news-automation/scripts/ai_news_summary.py
```

Or simply ask your Orca agent:

```
ai news
```

### Pulling updates

When a teammate adds or updates a skill:

```bash
git pull
./install.sh --cron
```

Then restart your Orca session. The installer overwrites existing skills with the latest versions and safely updates cron entries.

---

## Creating a New Skill

1. Create a new folder in the repo root:

   ```
   my-new-skill/
   ├── SKILL.md
   └── scripts/
       └── my_script.py
   ```

2. Write `SKILL.md` with this frontmatter:

   ```markdown
   ---
   name: my-new-skill
   description: >-
     Short description of what this skill does. Use this skill whenever the user
     asks for X, says "X", or wants Y.
   ---

   # My New Skill

   ## Run it

   \```bash
   python3 scripts/my_script.py
   \```

   ## Notes for teammates

   - No dependencies beyond Python 3.
   - To install: run `./install.sh` from the repo root.
   ```

3. Add your script to `scripts/`. Use only Python 3 stdlib unless teammates all have the same dependency.

4. Commit and push:

   ```bash
   git add my-new-skill/
   git commit -m "Add my-new-skill automation"
   git push
   ```

5. Tell teammates to run `git pull && ./install.sh --cron` and restart Orca.

---

## Important Notes

- **Cron is per-machine.** The schedule is not shared via git. Every teammate must run `./install.sh --cron` on their own machine.
- **Keep the clone in place.** The cron job runs the script from the cloned repo. If you move or delete the `Orca-Automation/` folder, the cron job will break.
- **Restart Orca after every install/update.** Orca only discovers skills at startup.
- **macOS cron may need Full Disk Access.** If the cron job silently fails on macOS, grant Full Disk Access to `/usr/sbin/cron` in System Settings > Privacy & Security.
- **Your Mac must be awake.** Cron jobs don't run while the machine is asleep. Consider `caffeinate` or a launchd alternative if needed.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Orca doesn't recognize the skill | Restart your Orca session |
| Skill not in `~/.agents/skills/` | Re-run `./install.sh` |
| Cron job not running | Run `crontab -l` to check; re-run `./install.sh --cron` |
| Cron runs but no output | On macOS, grant Full Disk Access to `/usr/sbin/cron` |
| News script fails with network error | Check internet connection; RSS sources may be temporarily down |
| `install.sh: Permission denied` | Run `chmod +x install.sh` |
| The Verge returns 0 items | Already fixed — script now handles Atom feeds |

---

## Architecture

```
Orca-Automation/
├── install.sh                    # One-command setup script
├── TEAM_GUIDE.md                 # This guide
├── reports/                      # Cron job output logs
│   └── ai_news_summary.log
├── hello-automation/             # Skill: hello world
│   ├── SKILL.md                  #   manifest (name, description, instructions)
│   └── scripts/
│       └── hello.py
└── ai-news-automation/           # Skill: AI news summary
    ├── SKILL.md
    └── scripts/
        └── ai_news_summary.py    #   supports RSS + Atom, proper date parsing
```

Each skill folder is self-contained. The `install.sh` script discovers skills automatically by scanning for `SKILL.md` files — no manual registration needed.
