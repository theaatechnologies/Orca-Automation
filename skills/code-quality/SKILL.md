---
name: code-quality
description: Use when writing or editing any code. Defines comment, naming and hygiene standards.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Use when writing or editing any code."
  tags: ["quality", "comments", "naming"]
---
# Code Quality

## When to Use
- Writing or editing code in any file, or reviewing a change before a PR.

## Rules
- Comments are sparse, short and add real context. One line where one line suffices.
- No narration: no history, no bug stories, no restating the next line.
- No opaque internal references ("rule 3", "phase 0"); a comment must stand alone.
- Keep functional directives verbatim (for example `# shellcheck disable=SC2016`).
- Explain why only when the code cannot say it.
- Names state intent, so the comment is needed less.
- Delete dead code; never comment it out. No debug prints or TODO placeholders in a finished change.
- Match the file's existing style; do not reformat lines you did not change.
- Prefer the boring implementation; add an abstraction only when a second real caller exists.
- Validate every external input (arguments, config, file names) before it reaches a shell, path or URL.
