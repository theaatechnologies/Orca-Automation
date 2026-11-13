# Troubleshooting

Traps hit while building and verifying this kit. [← README](../README.md)

## An automation sits at "dispatched" and never finishes

Orca's launcher started a Claude pane and it is waiting at the "Bypass Permissions mode" confirmation. Automations use `provider: opencode`; recreate old ones with `orca automations remove <id>` then `just automations-install`, and close the stuck pane.

## `unsafe args` / `unsafe ref` / `target_repo must look like owner/repo`

`scripts/safe-arg.py` rejected an argument containing a quote, `;`, `|`, a leading `-` or other shell or option syntax. Pass plain pytest arguments, git refs and `owner/repo` values.

## An unattended run cannot read a file outside the project

opencode auto-rejects paths such as `/tmp` when nobody can approve. Put logs and inputs under the project (for example `reports/`).

## `cannot exec command in "dev": ... unexpected EOF`

The workshop connection dropped, often when several runs start at once. `workshop restart dev`, then retry.

## `just test` says FAILED but my change is fine

`just test` runs the sample app's tests and now exits non-zero on any failing test. Read `test-results/`.

## `workshop launch` says "multiple workshops found"

The project defines `dev` and `test`; recipes pass the name (`dev`). Do not call `workshop launch` without it.

## `netifaces` fails to build on the host

Newer GCC cannot build it. The `so-*` recipes run inside the Ubuntu 24.04 container, which matches upstream CI; use them instead of host `tox`.

## `just check-shell` needs shellcheck

It installs shellcheck in the container if missing, or run `sudo apt install -y shellcheck` and re-run.

## opencode ignores my skill

`just check-skills` shows why: the name must equal the directory, a description containing "Use when ..." is required, and `just skills-install` must have linked it.

## `--agent reviewer` falls back to the default agent

`reviewer` and `security-auditor` are subagents. Ask a primary agent to call them (`@reviewer`).
