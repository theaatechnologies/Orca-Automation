---
name: repo-analysis
description: Use when asked to analyse, explain or map an unfamiliar repository: structure, architecture, skills, automation and security posture.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Use when asked to analyse, explain or map an unfamiliar repository: structure, architecture, skills, automatio."
  tags: ["analysis", "architecture", "onboarding"]
---
# Repo Analysis

## When to Use
- "Read this repo and explain it", onboarding to a new codebase, or comparing a repo against this kit.

## Method
1. Map: `git ls-files | head`, directory sizes, entrypoint (Justfile, Makefile, package.json), README and AGENTS.md.
2. Architecture: layers and boundaries, what runs where, how components talk, state and config locations.
3. Workflow surface: commands users run, CI workflows, scheduled jobs, skills and agent instructions.
4. Standards and safety: lint gates, commit and PR rules, secrets handling, permissions, pinned versions, accepted risks.
5. Gaps: list what the repo lacks versus its own stated rules.

## Output
`reports/analysis-<repo>-<date>.md` with: purpose in one line, architecture table, command index, skills and automations, security controls, gaps. Every claim cites a file. Read-only: do not edit the analysed repo.
