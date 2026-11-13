# Keep the kit current. The agent checks (read-only); a human approves the upgrade.

# Read-only: is a newer version of this kit available? Writes .state/upgrade-available.json
check-upgrade:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{justfile_directory()}}"
    mkdir -p .state && chmod 0700 .state
    git fetch origin --quiet || echo "warning: could not reach origin" >&2
    local_hash="$(git rev-parse HEAD)"
    remote_hash="$(git rev-parse '@{u}' 2>/dev/null || git rev-parse origin/HEAD 2>/dev/null || echo "$local_hash")"
    behind=false
    if [ "$local_hash" != "$remote_hash" ] && git merge-base --is-ancestor "$local_hash" "$remote_hash" 2>/dev/null; then
        behind=true
    fi
    date +%s > .state/last-upgrade-check
    printf '{"update_available": %s, "local": "%s", "remote": "%s"}\n' "$behind" "$local_hash" "$remote_hash" > .state/upgrade-available.json
    if [ "$behind" = true ]; then echo "ℹ update available: run 'just upgrade'"; else echo "✓ kit is up to date"; fi

# Apply the update: fast-forward only, re-link skills, re-register automations, run the gates (asks first)
upgrade:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{justfile_directory()}}"
    if [ -n "$(git status --porcelain)" ]; then echo "Working tree is not clean; commit or stash first." >&2; exit 1; fi
    git fetch origin --quiet
    target="$(git rev-parse '@{u}' 2>/dev/null || git rev-parse origin/HEAD)"
    if [ "$(git rev-parse HEAD)" = "$target" ]; then echo "✓ already up to date"; exit 0; fi
    git log --oneline "HEAD..$target" | head -20
    if [ "${UPGRADE_YES:-0}" != 1 ]; then
        printf 'Fast-forward to %s? [y/N] ' "${target:0:9}"
        read -r reply
        case "$reply" in [yY] | [yY][eE][sS]) ;; *) echo "aborted"; exit 1 ;; esac
    fi
    git merge --ff-only "$target"
    just skills-install
    just automations-install
    just check
    date +%s > .state/last-upgrade-check
    printf '{"update_available": false}\n' > .state/upgrade-available.json
    echo "✓ upgraded"
