# Agents and permissions

opencode agents, what each may do, and how that is enforced. [← README](../README.md)

## Agents

| Agent | Mode | Used by | May edit | May commit | May push |
|---|---|---|---|---|---|
| `build` (default) | primary | Orca automations | yes | no (denied) | no (denied) |
| `dev` | primary | `just agent` (interactive) | yes | yes | only with your approval |
| `reviewer` | subagent | `issue`, `code-review-behavior` passes | no | no | no |
| `security-auditor` | subagent | `security-review`, weekly scan | no | no | no |

Subagents cannot be started with `--agent`; opencode falls back to the default agent. They are called by a primary agent through the task tool or `@reviewer`.

## Policy in `opencode.json`

Global bash is allow-by-default with explicit denies: `git push/commit/tag/reset --hard/clean/config/remote`, `gh pr merge/review`, `gh release`, `sudo`, piping a download into a shell, `chmod -R`, `rm -rf`, `workshop remove`, `lxc delete`, `snap remove`, `just release`. Reads of `.env*`, `*.pem`, SSH keys, `.git-credentials` and `auth.json` are denied. Paths outside the project are auto-rejected in unattended runs (ask-rules resolve to reject when nobody can answer), so put inputs under the project.

Verified by tool calls: default agent denied `git commit`; `dev` allowed it and its `git push` was rejected without a human; `reviewer` could not create a file; a read of `.env` was denied.

## Skills

24 skills in `skills/`, grouped: reports (`standup`, `pr-triage`, `dependency-check`, `security-review`, `repo-analysis`), engineering standards (`commit-hygiene`, `pull-request-standards`, `code-quality`, `code-review-behavior`, `evidence-based-verification`, `issue`), investigation (`bug-triage`, `ci-triage`, `code-review`), release (`run-tests`, `release-notes`, `weekly-release`), kit (`kit-maintainer`, `upgrade-manager`), and the five `so-*` snap-openstack examples. `just check-skills` enforces frontmatter, because opencode silently drops a skill without a description.
