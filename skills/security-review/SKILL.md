---
name: security-review
description: Use when asked for a security review, audit or hardening check of a repo, diff or configuration. Covers secrets, injection, supply chain and permissions.
license: Apache-2.0
metadata:
  author: orca-automation-workshop
  version: "1.0.0"
  summary: "Use when asked for a security review, audit or hardening check of a repo, diff or configuration."
  tags: ["security", "audit", "hardening"]
---
# Security Review

## When to Use
- Security audit of a repo, a diff or this kit's own configuration.
- Weekly security scan automation.

## Method
1. Scope: `git ls-files`, plus `git diff` when reviewing a change. Use the `@security-auditor` subagent for the read-only pass.
2. Run `just check-secrets` first. Never print a secret value: name file, line and kind.
3. Walk the checklist and record only findings you can point to.

## Checklist
- **Secrets**: tokens, keys, `.env`, credentialed URLs, tokens in shell history or CI logs; files that should be gitignored.
- **Injection**: user or config values interpolated into shell commands, `bash -c` payloads, SQL, paths or URLs without validation; `curl | sh`; `eval`.
- **Supply chain**: unpinned dependencies or actions (pin to a commit SHA), installers fetched over the network without verification, unpinned SDK channels. Record accepted risks explicitly.
- **CI**: workflow `permissions` (least privilege), `persist-credentials: false`, no `pull_request_target` with untrusted checkout, no `${{ }}` of untrusted input inside `run:`. Run `uvx zizmor .github/workflows/` when available.
- **Permissions**: file modes on key material, over-broad tokens (prefer fine-grained, short-lived), agent permissions in `opencode.json`.
- **Data**: logs or reports containing credentials, kubeconfigs, customer data.

## Output
Table of findings (severity, `file:line`, impact, minimal fix) saved to `reports/security-<date>.md`, then a short list of accepted risks. Report only: do not change code, commit or push.
