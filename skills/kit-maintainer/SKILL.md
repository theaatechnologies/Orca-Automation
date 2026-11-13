---
name: kit-maintainer
description: Use when adding or changing a skill, automation, recipe, agent or CI gate in this kit. Keeps the kit consistent and verified.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Use when adding or changing a skill, automation, recipe, agent or CI gate in this kit."
  tags: ["maintenance", "skills", "automations"]
---
# Kit Maintainer

## When to Use
- Adding a skill (`skills/<name>/SKILL.md`), automation (`automations/<name>.json`), recipe, agent or gate.

## Steps
1. Skill: frontmatter needs `name` (equal to the directory), `description` starting with what it does and containing "Use when ...", `license`, `metadata.version`. Then `just skills-install`.
2. Automation: JSON with `name`, `trigger`, `provider: opencode`, `prompt`, plus `time`/`day` as needed. The prompt must carry a guard ("Do not commit or push", "read-only", "report only") and name an output under `reports/` or `reviews/`. Then `just automations-install`.
3. Recipe: argument-taking recipes validate input; shebang recipes must pass shellcheck.
4. Update `AGENTS.md` (layout, skills) and the matching page in `docs/`.
5. Run `just check` and `just test-gates`. Show their output (evidence-based-verification).
6. Commit with `commit-hygiene`. Never push without human approval.
