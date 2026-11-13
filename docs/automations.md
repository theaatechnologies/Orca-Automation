# Automations

Scheduled Orca automations that run opencode. [← README](../README.md)

| Automation | When | Skill | Output |
|---|---|---|---|
| daily standup report | weekdays 09:00 | `standup` | `reports/standup-<date>.md` |
| snap-openstack: daily review of new commits | weekdays 09:00 | `so-pr-review` | `reviews/<sha>.md` |
| PR triage | weekdays 13:00 | `pr-triage` | `reports/pr-triage-<date>.md` |
| daily commit standards audit | weekdays 11:00 | `commit-hygiene`, `code-quality` | `reports/commit-audit-<date>.md` |
| weekly dependency check | Mon 10:00 | `dependency-check` | `reports/deps-<date>.md` |
| snap-openstack: weekly manifest refresh check | Mon 10:00 | `so-manifest-update` | `reviews/manifest-<date>.md` |
| weekly security scan | Wed 10:00 | `security-review` | `reports/security-<date>.md` |
| weekly kit health check | Fri 09:00 | `kit-maintainer` | `reports/kit-health-<date>.md` |
| weekly release readiness report | Fri 10:00 | `run-tests`, `release-notes` | `reports/release-readiness-<date>.md` |

All are read-only toward your repos. They are created disabled; enable with `ENABLE=1 just automations-install` or in the Orca app. Run one now with `orca automations run <id>` (`just automations` lists ids). A run takes 2-5 minutes and uses your opencode model provider.

## Add one

Create `automations/<name>.json`:

```json
{"name": "my automation", "trigger": "weekdays", "time": "09:00", "provider": "opencode",
 "prompt": "Use the <skill> skill on the target repo. Write reports/<x>-<date>.md. Report only: do not commit or push."}
```

`just check-automations` rejects a missing field, a provider other than `opencode`, a bad trigger, a prompt with no guard phrase, or a prompt that names no output under `reports/` or `reviews/`. Then `just automations-install`.
