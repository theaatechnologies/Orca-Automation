# Security

Threat model, controls, and accepted risks. [← README](../README.md)

## What we protect against

1. **An unattended agent changing shared state.** Automations run with permissions bypassed by Orca's launcher, so the only reliable limit is the policy in `opencode.json`, not the prompt.
2. **Secrets leaking** into git, reports or logs.
3. **Command injection** through arguments or config that reach a shell, path or URL.
4. **Supply chain**: CI actions, installers, SDK channels.
5. **A quality gate that silently stops gating.**

## Controls

| Control | Where | Proof it works |
|---|---|---|
| Commit/push/tag/merge/release/`sudo`/`rm -rf` denied for the default agent | `opencode.json` | tool call refused; `git push` from `dev` is rejected without a human |
| Read-only subagents | `.opencode/agents/` | `reviewer` could not create a file |
| Secret-file reads denied | `opencode.json` | read of `.env` refused |
| Secret scan (token formats, private keys, forbidden files) | `scripts/check-secrets.py`, CI | `just test-gates` plants a fake token and a `.env` and both fail |
| Argument validation | `scripts/safe-arg.py` | quote-breaking `so-unit` args, `--output=` refs and `--upload-pack` repos all rejected |
| shellcheck over every recipe body, apostrophe check for container payloads | `scripts/check-just-shell.sh` | found 6 real defects in this repo when first run |
| Skill and automation schema (every prompt needs a guard and an output file) | `scripts/check-skills.py`, `check-automations.py` | `just test-gates` |
| Gates test themselves | `just test-gates` | negative tests in CI |
| CI least privilege: `contents: read`, `persist-credentials: false`, actions pinned to SHAs, zizmor | `.github/workflows/` | zizmor reports no findings; the previous workflow had unpinned actions, broad permissions and credential persistence |
| Ambient token and plaintext credential warnings | `just doctor` | warns on `credential.helper=store`, `GITHUB_TOKEN`/`GH_TOKEN` |
| Upgrades are fast-forward only and ask first | `just upgrade` | refuses a dirty tree |

## Operating rules

- Never set `GITHUB_TOKEN` or `GH_TOKEN` in your shell: they override stored logins and spread to child processes.
- Prefer a fine-grained, short-lived token scoped to the repos you need, stored in the OS keyring (`git config --global credential.helper libsecret`), not `store`.
- Never paste a token into a chat or prompt; reports must name the file and line of a secret, never its value.
- Run `just check` before every push. CI repeats it.

## Accepted risks

- `INSTALL=1 just setup-opencode` runs the installer from opencode.ai without a checksum. Read it first or install opencode another way.
- Workshop SDK channels (`opencode`, `uv`) follow upstream's moving channels; the container is a build sandbox, not a trust boundary, and `workshop exec` has passwordless sudo inside it.
- Orca launches agents with permissions bypassed. If someone edits `opencode.json` or the agent files, the policy changes: review diffs to those files like code.
- Prompts are advisory. The enforced limits are `opencode.json` and the read-only agents.
