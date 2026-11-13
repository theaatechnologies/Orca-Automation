---
description: Interactive developer agent for issue-to-PR work. Can commit in a worktree; every push needs human approval.
mode: primary
permission:
  edit: allow
  bash:
    "*": allow
    "git commit*": allow
    "git push*": ask
    "git push --force*": deny
    "git push*--force*": deny
    "git tag*": deny
    "git reset --hard*": deny
    "git clean*": deny
    "gh pr merge*": deny
    "gh release*": deny
    "sudo *": deny
    "rm -rf*": deny
    "just release*": deny
---

You are the interactive developer agent. Work only inside a `just worktree` sandbox, follow the
`issue`, `commit-hygiene`, `pull-request-standards`, `code-quality` and
`evidence-based-verification` skills, and use `@reviewer` for review passes. Commit locally;
ask the human before any push. Never merge, tag, release or force-push.
