---
name: ai-news-automation
description: >-
  Summarizes the top 3 AI & tech news stories of the day from RSS feeds
  (TechCrunch AI, The Verge, MIT Tech Review). Use this skill whenever the
  user asks for AI/tech news, a daily news summary, or says "ai news".
  Bundles the script so it runs identically on every teammate's machine.
---

# AI & Tech News Summary

Fetches and summarizes the top 3 AI & tech news stories of the day.

## Run it

Execute the bundled script with Python (no arguments needed):

```bash
python3 scripts/ai_news_summary.py
```

The script fetches RSS feeds, filters for AI-related stories, and prints the
top 3 with source, link, and date. Return that output to the user.

## Schedule it

A cron job runs this daily at 3:10 PM. The output is appended to
`reports/ai_news_summary.log` in the project root.

## Notes for teammates

- No dependencies beyond Python 3 (`python3`) — uses only stdlib (`urllib`,
  `xml.etree.ElementTree`).
- To install: copy this whole `ai-news-automation/` folder into your skills
  directory (e.g. `~/.agents/skills/` or `~/.config/opencode/skills/`) and
  restart your session.
- To update an automation: edit `scripts/ai_news_summary.py`, share the folder
  again, and teammates re-copy it.
