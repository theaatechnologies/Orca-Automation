---
name: pull-request-standards
description: Use when creating or updating a pull request. Defines PR context, high-level changes and CI expectations.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Use when creating or updating a pull request."
  tags: ["pr", "review", "git"]
---
# Pull Request Standards

## When to Use
- Opening a PR or updating its description.

## Rules
- Context: a plain paragraph first, explaining why (problem or issue link). No bullets, no title line.
- Change: a `### Change` header followed by high-level bullets, with reasoning when not obvious.
- No narration ("This PR addresses...").
- One logical change per PR. No drive-by refactoring.
- Re-read the title and description after every update; fix them if scope or approach changed.
- All lint and CI checks must be green before the work counts as done (`just check` locally first).
- Include the issue reference (`Fixes #<n>`) when one exists.
- Do not merge unless the human says so.
