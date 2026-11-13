---
name: weekly-release
description: Cut a weekly release: test, notes, tag. Use only when the user explicitly asks to release.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Cut a weekly release: test, notes, tag."
  tags: ["weekly", "release"]
---

# Weekly Release

Preconditions: clean working tree on the release branch, `just test` green.

1. `just test` and show the result.
2. `just release-notes`, show the user the notes.
3. Ask for confirmation of the bump type (patch/minor/major).
4. `just release <type>`. Report the new tag.
Never run this step unprompted: it tags and pushes.
