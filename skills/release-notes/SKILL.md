---
name: release-notes
description: Generate release notes from commits since the last tag. Use when asked for a changelog or release notes.
---

# Release Notes

1. `just release-notes` (or `just release-notes <tag>`) writes `RELEASE_NOTES.md`.
2. Review the output: group by Features / Fixes / Chores, remove noise, keep one line per change.
3. Do not tag or push; that is the `weekly-release` skill.
